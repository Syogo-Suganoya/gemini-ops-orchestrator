"use client";

import { useState, useRef, useEffect } from "react";

type Message = {
  id: string;
  role: "user" | "assistant";
  content: string;
  isProposal?: boolean;
};

export default function Home() {
  const [messages, setMessages] = useState<Message[]>([
    {
      id: "1",
      role: "assistant",
      content: "こんにちは！「Grant-A-Gent」です。あなたの事業について少し教えてください。最適な補助金を勝手に見つけてきますよ！最近のビジネスの調子はどうですか？",
    },
  ]);
  const [input, setInput] = useState("");
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSubmit = (e: React.FormEvent) => {
    e.formEvent?.preventDefault();
    if (!input.trim()) return;

    const newMsg: Message = { id: Date.now().toString(), role: "user", content: input };
    setMessages((prev) => [...prev, newMsg]);
    setInput("");

    // Mock AI Response
    setTimeout(() => {
      setMessages((prev) => [
        ...prev,
        {
          id: (Date.now() + 1).toString(),
          role: "assistant",
          content: "なるほど、飲食店でモバイルオーダーの導入を検討されているのですね！それなら、あなたの事業にぴったりの補助金が見つかりましたよ！",
        },
      ]);
      
      // Mock Proposal
      setTimeout(() => {
        setMessages((prev) => [
          ...prev,
          {
            id: (Date.now() + 2).toString(),
            role: "assistant",
            content: "【IT導入補助金（通常枠）】\n上限150万円まで、ITツールの導入費用が補助されます。あなたのケースなら、この枠でモバイルオーダーの導入費用が申請可能です！私が申請書のドラフトを書きましょうか？",
            isProposal: true,
          },
        ]);
      }, 1500);
    }, 1000);
  };

  return (
    <div className="flex flex-col h-full absolute inset-0">
      {/* Chat Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.map((msg) => (
          <div
            key={msg.id}
            className={`flex ${
              msg.role === "user" ? "justify-end" : "justify-start"
            }`}
          >
            <div
              className={`max-w-[85%] rounded-2xl p-4 shadow-sm ${
                msg.role === "user"
                  ? "bg-indigo-600 text-white rounded-br-none"
                  : msg.isProposal
                  ? "bg-gradient-to-r from-amber-50 to-orange-50 border border-orange-200 text-gray-800 rounded-bl-none"
                  : "bg-white border border-gray-100 text-gray-800 rounded-bl-none"
              }`}
            >
              {msg.isProposal && (
                <div className="flex items-center gap-2 mb-2 text-orange-600 font-bold text-sm">
                  <span>💡</span> 自律的提案
                </div>
              )}
              <p className="whitespace-pre-wrap leading-relaxed text-sm">{msg.content}</p>
              
              {msg.isProposal && (
                <div className="mt-4 flex gap-2">
                  <button className="flex-1 bg-orange-500 hover:bg-orange-600 text-white text-xs font-bold py-2 px-3 rounded shadow transition">
                    ドラフトを作成する
                  </button>
                  <button className="flex-1 bg-white border border-orange-200 text-orange-600 hover:bg-orange-50 text-xs font-bold py-2 px-3 rounded transition">
                    詳細を見る
                  </button>
                </div>
              )}
            </div>
          </div>
        ))}
        <div ref={messagesEndRef} />
      </div>

      {/* Input Area */}
      <div className="bg-white border-t border-gray-200 p-3 shadow-[0_-4px_6px_-1px_rgba(0,0,0,0.05)] z-20">
        <form
          onSubmit={(e) => {
            e.preventDefault();
            handleSubmit(e);
          }}
          className="flex items-end gap-2 bg-gray-100 rounded-2xl p-1 pr-2 border border-gray-200 focus-within:ring-2 focus-within:ring-indigo-500 transition-all"
        >
          <textarea
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter" && !e.shiftKey) {
                e.preventDefault();
                handleSubmit(e);
              }
            }}
            placeholder="事業の状況を教えてください..."
            className="flex-1 bg-transparent border-none focus:ring-0 resize-none max-h-32 min-h-[44px] py-3 px-3 text-sm"
            rows={1}
          />
          <button
            type="submit"
            disabled={!input.trim()}
            className="mb-1 p-2 rounded-xl bg-indigo-600 text-white disabled:opacity-50 disabled:bg-gray-400 transition-colors flex-shrink-0 flex items-center justify-center w-10 h-10 shadow-sm"
          >
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className="w-5 h-5">
              <path d="M3.478 2.404a.75.75 0 00-.926.941l2.432 7.905H13.5a.75.75 0 010 1.5H4.984l-2.432 7.905a.75.75 0 00.926.94 60.519 60.519 0 0018.445-8.986.75.75 0 000-1.218A60.517 60.517 0 003.478 2.404z" />
            </svg>
          </button>
        </form>
      </div>
    </div>
  );
}
