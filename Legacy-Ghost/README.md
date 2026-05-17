3. 「退職・引き継ぎゴースト」エージェント
【ストーリー】 属人化の解消。担当者が辞めても、彼の「仕事の魂（メールの癖、Meetでの約束、顧客の傾向）」をAIがイタコのように憑依させ、完璧な引き継ぎ書を作成して次の担当者をアサインする。

⚙️ 実装プラン & アーキテクチャ
ステップ 1：トリガー（Salesforce → GKE / Cloud Run）

SalesforceのUserオブジェクトで、該当社員のステータスが「退職予定（または休職）」に変更されたことをWebhookで検知。

ステップ 2：デジタル足跡の全スキャン（Google API群 → Gemini 1.5 Pro）

これがGeminiの「長尺コンテキスト（200万トークン）」の真骨頂。

Gmail API: 過去3ヶ月の顧客との全やり取り。

Google Meet (Drive内の録画・議事録): 直近の商談での発言、約束事。

Google Analytics: 彼が管理していたマーケティング成果。

これらをすべてGKE上に構築したパイプラインでGemini 1.5 Proに流し込む。

ステップ 3：自律型引き継ぎ書の生成（Google Docs API）

Geminiが「顧客ごとの現在の状況」「未解決の課題」「相手のキーマンの性格と好む連絡頻度」を分析し、Googleドキュメントに構造化された引き継ぎ書を自動生成。

ステップ 4：後任へのパスとカレンダーセット（Calendar API）

Salesforce上で自動アサインされた後任のGoogleカレンダーをチェック。空いている時間に「〇〇社 引き継ぎミーティング（資料リンク付き）」という予定を自律的にねじ込む。


![alt text](image.png)

https://gemini-ops-orchestrator.web.app/Legacy-Ghost/demo.html