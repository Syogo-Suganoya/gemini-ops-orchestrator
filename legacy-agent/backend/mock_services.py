from enum import Enum
from pydantic import BaseModel
from typing import List, Optional

class AgentPhase(str, Enum):
    ACTIVE = "ACTIVE"              # 通常状態（元気に活動中）
    WARNING = "WARNING"            # 警告状態（カレンダーの予定が過ぎてもアクセスがないため生存確認中）
    LEGACY = "LEGACY"              # 死亡判定（遺族への情報整理・送信フェーズ）

class StatusResponse(BaseModel):
    phase: AgentPhase
    last_active_days_ago: int
    message: str

class AppState:
    def __init__(self):
        self.phase = AgentPhase.ACTIVE
        self.last_active_days_ago = 0
        
    def advance_time(self):
        self.last_active_days_ago += 3
        if self.last_active_days_ago >= 3 and self.phase == AgentPhase.ACTIVE:
            self.phase = AgentPhase.WARNING
        elif self.last_active_days_ago >= 7 and self.phase == AgentPhase.WARNING:
            self.phase = AgentPhase.LEGACY

    def reset(self):
        self.phase = AgentPhase.ACTIVE
        self.last_active_days_ago = 0

state = AppState()

# モックデータ: Vertex AI Searchが抽出したという設定の「重要情報」
def get_extracted_legacy_info():
    if state.phase != AgentPhase.LEGACY:
        return None
    return {
        "financial_assets": [
            {"name": "〇〇銀行 本店", "type": "銀行口座", "note": "メインバンク。生活費の引き落とし口座。"},
            {"name": "△△証券", "type": "証券口座", "note": "インデックス投資用。ログインIDはパスワードマネージャーに保存。"}
        ],
        "digital_subscriptions": [
            {"name": "Netflix", "action_required": "解約推奨"},
            {"name": "AWS (Amazon Web Services)", "action_required": "サービス稼働中のため早急に確認・停止推奨"}
        ],
        "important_contacts": [
            {"name": "山田 太郎", "relation": "共同創業者", "email": "yamada@example.com", "note": "プロジェクトの引き継ぎについて連絡してください"}
        ],
        "private_notes": "PC内の『secret』フォルダは絶対に見ないで破棄してください。"
    }

# モックデータ: Gemini 1.5 Proがユーザーの過去の文章から学習して生成したメッセージ
def get_generated_message():
    if state.phase != AgentPhase.LEGACY:
        return None
    return {
        "text": "家族のみんなへ。このメッセージが届いているということは、私はもうこの世にいないのだと思います。突然のことで驚かせたかもしれません。今まで本当にありがとう。銀行口座やサブスクなどの必要な手続き情報は、このシステムがすべて整理してくれています。どうか悲しまず、笑顔で前を向いて歩んでください。",
        "audio_url": "/api/legacy/audio" # Text-to-Speech APIのモック
    }
