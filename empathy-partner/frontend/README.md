# Mental Sparring Partner - Frontend (Flutter)

## 開発環境セットアップ

Flutter コマンドを利用してプロジェクトを初期化してください。

```bash
cd /Users/syogosuganoya/Documents/趣味/開発/2605_hackthon/empathy-partner
flutter create frontend --platforms web
cd frontend
flutter pub add web_socket_channel
flutter pub add lottie
flutter run -d web-server
```

## 実装内容（Phase 2以降）
1. `lib/main.dart` を編集し、ダークモードのUIを構築。
2. バックエンド（FastAPI WebSocket: `ws://localhost:8000/ws/chat`）への接続。
3. 感情スコアに応じた Lottie アニメーションの実装。
