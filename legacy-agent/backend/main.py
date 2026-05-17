from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from mock_services import state, AgentPhase, StatusResponse, get_extracted_legacy_info, get_generated_message
import os

app = FastAPI(title="Legacy Agent API (Mock)")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/api/status", response_model=StatusResponse)
def get_status():
    message = "システムは正常に稼働しています。"
    if state.phase == AgentPhase.WARNING:
        message = "ユーザーからのアクセスが途絶えています。生存確認のアラートを発出中です。"
    elif state.phase == AgentPhase.LEGACY:
        message = "ユーザーの応答がないため、Legacyモードが発動しました。情報の整理とメッセージの生成が完了しました。"
        
    return StatusResponse(
        phase=state.phase,
        last_active_days_ago=state.last_active_days_ago,
        message=message
    )

@app.post("/api/simulate/advance")
def advance_time():
    """時間を進め、自律実行のフェーズを移行させるシミュレーションAPI"""
    state.advance_time()
    return {"status": "success", "new_phase": state.phase}

@app.post("/api/simulate/reset")
def reset_simulation():
    """状態をリセットする"""
    state.reset()
    return {"status": "success", "new_phase": state.phase}

@app.get("/api/legacy/data")
def get_legacy_data():
    """遺族向けの整理済み情報とメッセージを取得する"""
    info = get_extracted_legacy_info()
    msg = get_generated_message()
    if not info or not msg:
        return {"error": "Legacyモードが発動していません"}
    
    return {
        "extracted_info": info,
        "message": msg
    }

@app.get("/api/legacy/audio")
def get_audio():
    """モックの音声ファイルを返す（実際はText-to-Speechで生成）"""
    # 本当はここで音声ファイルを返すが、モックなのでダミーのレスポンスか空を返す
    # ここでは便宜上、200 OKを返すだけにする（必要ならダミーmp3を置く）
    return {"message": "Audio file simulation (Play sound in frontend via synthesis or placeholder)"}
