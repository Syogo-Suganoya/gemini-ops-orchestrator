from fastapi import FastAPI, WebSocket, WebSocketDisconnect
import json
import asyncio
from pydantic import BaseModel
from typing import Dict, List
import os
from dotenv import load_dotenv
import vertexai
from vertexai.generative_models import GenerativeModel
from google.cloud import language_v2

# .envファイルの読み込み
load_dotenv()

app = FastAPI(title="Mental Sparring Partner API")

# --- AI & GCP Settings ---
# TODO: Vertex AIの設定 (Project ID, Region等は環境変数から取得)
PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT")
REGION = os.getenv("GOOGLE_CLOUD_REGION", "us-central1")

if PROJECT_ID:
    vertexai.init(project=PROJECT_ID, location=REGION)
    gemini_model = GenerativeModel("gemini-1.5-flash-001")
    # Natural Language API client
    nl_client = language_v2.LanguageServiceClient()
else:
    gemini_model = None
    nl_client = None

# --- Connection Manager for WebSockets ---
class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)

    async def send_personal_message(self, message: dict, websocket: WebSocket):
        await websocket.send_json(message)

manager = ConnectionManager()

# --- Mock Analysis & AI Inference Functions ---
async def analyze_sentiment(text: str) -> float:
    """
    ユーザーのテキストから感情スコアを算出する。
    -1.0 (ネガティブ) 〜 1.0 (ポジティブ)
    """
    if nl_client is None:
        # GCP未設定時のモック用スコア
        # 「疲れた」「辞めたい」が含まれていたらネガティブ
        if "疲れた" in text or "辞めたい" in text or "つらい" in text:
            return -0.8
        return 0.5

    try:
        document = language_v2.Document(
            content=text,
            type_=language_v2.Document.Type.PLAIN_TEXT,
            language_code="ja"
        )
        response = nl_client.analyze_sentiment(
            request={"document": document}
        )
        return response.document_sentiment.score
    except Exception as e:
        print(f"NL API Error: {e}")
        return 0.0

async def generate_response(text: str) -> str:
    """
    Gemini 1.5 Flash を使って応答を生成する。
    スパーリングパートナーとして、問いを投げかける。
    """
    prompt = f"""
あなたは「Mental Sparring Partner（共感・メンタル・スパーラー）」です。
単にユーザーを慰めるだけでなく、あえて「問い」を投げかけ、ユーザーの思考の解像度を上げる対話エージェントとして振る舞ってください。
以下のユーザーの発言に対して、共感を示しつつ、新たな視点や気づきを与える問いかけを1〜2文で返してください。

ユーザーの発言: {text}
"""
    if gemini_model is None:
        # モック応答
        await asyncio.sleep(1) # 遅延シミュレート
        return f"「{text}」と感じているのですね。でも、別の視点から見るとどうでしょうか？"
    
    try:
        response = gemini_model.generate_content(prompt)
        return response.text
    except Exception as e:
        print(f"Gemini API Error: {e}")
        return "申し訳ありません、今うまく考えがまとまりません。"

# --- WebSocket Endpoint ---
@app.websocket("/ws/chat")
async def websocket_endpoint(websocket: WebSocket):
    await manager.connect(websocket)
    try:
        # 初回メッセージ
        await manager.send_personal_message({
            "type": "agent_message",
            "text": "こんにちは。今日はどのようなことを考えていますか？",
            "sentiment": 0.0
        }, websocket)

        while True:
            # クライアントからのメッセージを受信
            data = await websocket.receive_text()
            
            # --- 並列処理 (推論と感情分析) ---
            # 実際のアプリケーションでは、ここに過去の文脈(RAG)の取得も入る
            task_ai = asyncio.create_task(generate_response(data))
            task_sentiment = asyncio.create_task(analyze_sentiment(data))
            
            ai_response, sentiment_score = await asyncio.gather(task_ai, task_sentiment)
            
            # 結果をクライアントへ返す
            await manager.send_personal_message({
                "type": "agent_message",
                "text": ai_response,
                "sentiment": sentiment_score
            }, websocket)
            
            # 危険域の判定（強制介入）
            if sentiment_score <= -0.8:
                # 感情スコアが極めて低い場合、自律的な介入を実行
                await asyncio.sleep(2) # 少し間を置く
                await manager.send_personal_message({
                    "type": "intervention",
                    "text": "感情のトーンがかなり落ち込んでいるようです。今日はここまでにしましょう。おやすみなさい。",
                    "action": "force_close"
                }, websocket)

    except WebSocketDisconnect:
        manager.disconnect(websocket)
    except Exception as e:
        print(f"WebSocket Error: {e}")
        manager.disconnect(websocket)

# --- Health Check ---
@app.get("/health")
def health_check():
    return {"status": "ok"}
