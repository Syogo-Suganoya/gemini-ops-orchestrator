AIエージェントの「自律的」な振る舞い（審査基準の核）
自律的なマッチング: ユーザーが事業計画や日々の売上、興味のある技術（Flutter, Firebase等）を雑談ベースでエージェントに話しておくだけで、Geminiが「その事業なら、この『IT導入補助金』のこの枠が通りますよ！」と自発的に提案します。

書類の自動生成とブラッシュアップ: 過去の採択事例を学習したエージェントが、ユーザーの事業データから申請書のドラフトを自動作成。さらに「この表現はもう少し『地域活性化』に寄せたほうが採択率が上がります」と、エージェント側から改善のアドバイスを行います。

執念のスケジュール管理: 締切が近づくと、「まだこの書類が足りません」「今日の17時までにこれをアップロードしないと間に合いません」と、プッシュ通知で徹底的に追いかけます。

2. 技術構成（Google Cloud 活用案）
実行: Cloud Run

補助金情報のスクレイピングや、書類生成などの不定期かつ高負荷な処理を効率的に実行。

AI (Vertex AI / Gemini API):

Gemini 1.5 Pro: 膨大な補助金公募要領（PDF100ページ超えなど）を読み込み、要点を抽出。

Vertex AI Vector Search: 過去の膨大な「採択された申請書」と、ユーザーの事業計画を照らし合わせ、類似性の高い成功パターンを検索。

通知・フロントエンド:

Firebase Cloud Messaging (FCM): 締切や新着補助金のプッシュ通知。

Flutter: 「気軽に相談」を実現するモバイルアプリ。

検索・データ蓄積:

Elasticsearch (スポンサー枠活用): 全国数千件の補助金データから、地域・業種・金額で高速にフィルタリング。

3. 解決する課題とストーリー
背景: 補助金は「知っている人だけが得をする」状態。中小企業や個人開発者は、探す時間も書く時間もない。

価値: 専門の代行業者（高い手数料）に頼む前の「超気軽に相談できるパートナー」としての立ち位置。

新規性: 検索を待つのではなく、AIがユーザーのビジネスを理解して「これ、あなた用です」と持ってくるプッシュ型の体験。

💡 審査員へのアピールポイント
「AIエージェントである必然性」: 補助金の公募要領は複雑怪奇です。これを人間が読み解く代わりに、Geminiが「自律的に解釈して要約する」点は、まさにAIにしかできない役割です。

「実装力」: Vertex AIでのPDF解析、Firebaseでの通知、Elasticsearchでの検索と、提供されたツールをフルコンボで活用できます。

「拡張性」: 将来的には、申請だけでなく「採択後の実績報告」まで自律的に管理する「伴走型エージェント」への進化を提示できます。

https://gemini-ops-orchestrator.web.app/subsidy-support-app/demo.html


This is a [Next.js](https://nextjs.org) project bootstrapped with [`create-next-app`](https://nextjs.org/docs/app/api-reference/cli/create-next-app).

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `app/page.tsx`. The page auto-updates as you edit the file.

This project uses [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts) to automatically optimize and load [Geist](https://vercel.com/font), a new font family for Vercel.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.
