import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {
  // Clear existing subsidies
  await prisma.subsidy.deleteMany()
  await prisma.user.deleteMany()

  // Create dummy user
  const user = await prisma.user.create({
    data: {
      name: 'テストユーザー',
      businessType: '飲食店',
      techStack: 'POSレジ, モバイルオーダー',
    },
  })

  // Create dummy subsidies
  await prisma.subsidy.createMany({
    data: [
      {
        title: 'IT導入補助金（通常枠）',
        description: '中小企業・小規模事業者等が自社の課題やニーズに合ったITツールを導入する経費の一部を補助します。',
        maxAmount: 1500000,
        category: 'IT導入補助金',
        requirements: '・日本国内で事業を行う中小企業・小規模事業者\n・gBizIDプライムアカウントの取得\n・労働生産性の向上目標の設定',
        deadline: new Date('2026-08-31T23:59:59Z'),
      },
      {
        title: '小規模事業者持続化補助金（一般型）',
        description: '小規模事業者が直面する制度変更（働き方改革、被用者保険の適用拡大、賃上げ、インボイス導入等）に対応するため、経営計画を作成し、それに基づいて行う販路開拓等の取り組みを支援します。',
        maxAmount: 500000,
        category: '小規模事業者持続化補助金',
        requirements: '・常時使用する従業員が20人以下（商業・サービス業は5人以下）の法人・個人事業主\n・商工会議所の支援を受けながら経営計画を策定すること',
        deadline: new Date('2026-09-15T23:59:59Z'),
      },
      {
        title: '事業再構築補助金',
        description: '新型コロナウイルス感染症の影響が長期化する中、当面の需要や売り上げの回復が期待しづらい中、ポストコロナ・ウィズコロナ時代の経済社会の変化に対応するために新市場進出（新分野展開、業態転換）、事業・業種転換、事業再編、国内回帰又はこれらの取組を通じた規模の拡大等、思い切った事業再構築に意欲を有する中小企業等の挑戦を支援します。',
        maxAmount: 60000000,
        category: '事業再構築補助金',
        requirements: '・売上が減っていること\n・事業再構築に取り組むこと\n・認定経営革新等支援機関と事業計画を策定すること',
        deadline: new Date('2026-07-30T23:59:59Z'),
      },
    ],
  })

  console.log('Dummy data seeded successfully.')
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
