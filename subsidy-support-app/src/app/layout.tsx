import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Grant-A-Gent (グラント・エージェント)",
  description: "あなたのための補助金探索・申請サポートAI",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ja">
      <body className={`${inter.className} bg-gray-50 text-gray-900`}>
        <div className="max-w-md mx-auto min-h-screen bg-white shadow-xl overflow-hidden flex flex-col relative">
          {/* Header */}
          <header className="bg-indigo-600 text-white p-4 shadow-md z-10 flex justify-between items-center">
            <div>
              <h1 className="text-xl font-bold flex items-center gap-2">
                <span className="text-2xl">🎩</span> Grant-A-Gent
              </h1>
              <p className="text-xs text-indigo-200 mt-1 tracking-wider">自律型補助金エージェント</p>
            </div>
          </header>

          {/* Main Content Area */}
          <main className="flex-1 overflow-y-auto bg-slate-50 relative pb-4">
            {children}
          </main>
        </div>
      </body>
    </html>
  );
}
