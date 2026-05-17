1. Google×Salesforce「自律型インサイドセールス・エージェント（Auto-Pilot）」
商談獲得から顧客フォローまで、Googleサービスを横断して自律的に動き回る営業エージェントです。

課題: 営業マンはSalesforceの入力、メール返信、Meetの調整、アナリティクス確認などに追われ、顧客と向き合う時間が削られている。

AIエージェントの振る舞い:

Google アナリティクス / 広告: 「特定の重要顧客（企業）がWebサイトの料金ページを何度も見ている」という予兆を検知。

Salesforce: 自動でその企業のリード情報を引き出し、過去の商談履歴をVertex AI Vector Searchで分析。

Gmail / カレンダー: Geminiが最適な提案メールを自動起票。さらに、自分のGoogle カレンダーの空き時間を自動で算出して、顧客にGoogle Meetの候補リンク付きでメールを送信（または下書き作成）。

技術スタック:

実行: Cloud Run（トリガーベースのワークフロー実行）

AI: Gemini API、Vertex AI (Salesforceデータとのセキュアな連携)

Google連携: Gmail API, Calendar API, Google Analytics Data API


![alt text](image-1.png)

https://gemini-ops-orchestrator.web.app/Auto-Pilot/demo.html