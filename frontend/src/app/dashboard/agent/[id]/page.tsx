"use client";

import { useState, useEffect, useRef } from "react";
import { useParams, useRouter } from "next/navigation";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import toast from "react-hot-toast";
import { agentsApi, conversationsApi } from "@/lib/api";
import type { Agent, Message } from "@/types";
import { cn, formatTime } from "@/lib/utils";

export default function AgentChatPage() {
  const { id } = useParams<{ id: string }>();
  const router = useRouter();
  const qc = useQueryClient();
  const [input, setInput] = useState("");
  const [messages, setMessages] = useState<Message[]>([]);
  const [conversationId, setConversationId] = useState<string | null>(null);
  const [streaming, setStreaming] = useState(false);
  const [streamingContent, setStreamingContent] = useState("");
  const bottomRef = useRef<HTMLDivElement>(null);

  const { data: agent, isLoading: agentLoading } = useQuery<Agent>({
    queryKey: ["agent", id],
    queryFn: async () => {
      const res = await agentsApi.get(id);
      return res.data;
    },
    enabled: !!id,
  });

  const { data: conversation, isLoading: convLoading } = useQuery({
    queryKey: ["conversation", id],
    queryFn: async () => {
      const res = await conversationsApi.getOrCreate(id);
      return res.data;
    },
    enabled: !!id,
  });

  useEffect(() => {
    if (conversation) {
      setMessages(conversation.messages || []);
      setConversationId(conversation.id);
    }
  }, [conversation]);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages, streamingContent]);

  const sendMessage = async () => {
    if (!input.trim() || streaming || !conversationId) return;
    const userMsg = input.trim();
    setInput("");

    // Optimistic update
    const tempUserMsg: Message = {
      id: "temp-" + Date.now(),
      role: "user",
      content: userMsg,
      created_at: new Date().toISOString(),
    };
    setMessages((prev) => [...prev, tempUserMsg]);
    setStreaming(true);
    setStreamingContent("");

    try {
      // Use SSE streaming
      const token = localStorage.getItem("token");
      const res = await fetch(
        `${process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000/api/v1"}/conversations/agent/${id}/chat`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
          body: JSON.stringify({ message: userMsg, stream: true }),
        }
      );

      if (!res.ok) throw new Error("Failed to send message");

      const reader = res.body?.getReader();
      const decoder = new TextDecoder();
      let fullContent = "";

      if (reader) {
        while (true) {
          const { done, value } = await reader.read();
          if (done) break;
          const chunk = decoder.decode(value);
          const lines = chunk.split("\n");
          for (const line of lines) {
            if (line.startsWith("data: ")) {
              const data = line.slice(6);
              if (data === "[DONE]") break;
              try {
                const parsed = JSON.parse(data);
                fullContent += parsed.content;
                setStreamingContent(fullContent);
              } catch {
                // Skip malformed chunks
              }
            }
          }
        }
      }

      setMessages((prev) => [
        ...prev,
        {
          id: "resp-" + Date.now(),
          role: "assistant",
          content: fullContent,
          created_at: new Date().toISOString(),
        },
      ]);
      setStreamingContent("");
      qc.invalidateQueries({ queryKey: ["conversation", id] });
    } catch {
      toast.error("Failed to get response");
      setMessages((prev) => prev.filter((m) => m.id !== tempUserMsg.id));
    } finally {
      setStreaming(false);
    }
  };

  if (agentLoading || convLoading) {
    return (
      <div className="h-full flex items-center justify-center">
        <div className="text-[#8888aa]">Loading...</div>
      </div>
    );
  }

  if (!agent) {
    return (
      <div className="h-full flex items-center justify-center">
        <div className="text-center">
          <p className="text-[#8888aa] mb-4">Agent not found</p>
          <button onClick={() => router.push("/dashboard")} className="text-[#6366f1]">
            Back to Dashboard
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="h-full flex flex-col">
      {/* Header */}
      <div className="flex-shrink-0 px-6 py-4 border-b border-[#2a2a3d] flex items-center gap-4 bg-[#12121a]">
        <button
          onClick={() => router.push("/dashboard")}
          className="text-[#8888aa] hover:text-[#f0f0ff] text-sm"
        >
          ← Back
        </button>
        <div
          className="w-10 h-10 rounded-xl flex items-center justify-center text-xl"
          style={{ backgroundColor: agent.avatar_color + "22", border: `1px solid ${agent.avatar_color}44` }}
        >
          {agent.avatar_emoji}
        </div>
        <div>
          <div className="font-semibold">{agent.name}</div>
          <div className="text-xs text-[#8888aa]">{agent.title}</div>
        </div>
        <div className="ml-auto flex items-center gap-2">
          <div className="w-2 h-2 rounded-full bg-[#10b981] animate-pulse" />
          <span className="text-xs text-[#8888aa]">Active</span>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-auto px-6 py-6 space-y-6">
        {messages.length === 0 && !streaming && (
          <div className="flex flex-col items-center justify-center h-full text-center">
            <div
              className="w-16 h-16 rounded-2xl flex items-center justify-center text-3xl mb-4"
              style={{ backgroundColor: agent.avatar_color + "22", border: `1px solid ${agent.avatar_color}44` }}
            >
              {agent.avatar_emoji}
            </div>
            <h3 className="font-semibold text-lg mb-2">
              {agent.name} is ready
            </h3>
            <p className="text-[#8888aa] text-sm max-w-md">{agent.description}</p>
            <div className="mt-6 flex flex-wrap gap-2 justify-center">
              {getStarterPrompts(agent.role_type).map((prompt) => (
                <button
                  key={prompt}
                  onClick={() => { setInput(prompt); }}
                  className="bg-[#1a1a27] border border-[#2a2a3d] rounded-full px-4 py-2 text-sm text-[#8888aa] hover:text-[#f0f0ff] hover:border-[#6366f1]/50 transition-colors"
                >
                  {prompt}
                </button>
              ))}
            </div>
          </div>
        )}

        {messages.map((msg) => (
          <MessageBubble key={msg.id} message={msg} agent={agent} />
        ))}

        {streaming && streamingContent && (
          <StreamingBubble content={streamingContent} agent={agent} />
        )}
        {streaming && !streamingContent && (
          <ThinkingBubble agent={agent} />
        )}

        <div ref={bottomRef} />
      </div>

      {/* Input */}
      <div className="flex-shrink-0 px-6 py-4 border-t border-[#2a2a3d] bg-[#12121a]">
        <div className="flex gap-3 items-end">
          <textarea
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter" && !e.shiftKey) {
                e.preventDefault();
                sendMessage();
              }
            }}
            placeholder={`Message ${agent.name}...`}
            rows={1}
            className="flex-1 bg-[#1a1a27] border border-[#2a2a3d] rounded-xl px-4 py-3 text-[#f0f0ff] placeholder-[#4a4a6a] focus:outline-none focus:border-[#6366f1] transition-colors resize-none"
            style={{ maxHeight: "120px" }}
          />
          <button
            onClick={sendMessage}
            disabled={!input.trim() || streaming}
            className="bg-[#6366f1] hover:bg-[#818cf8] disabled:opacity-50 text-white px-4 py-3 rounded-xl transition-colors flex-shrink-0"
          >
            {streaming ? "..." : "↑"}
          </button>
        </div>
        <p className="text-xs text-[#4a4a6a] mt-2">
          Press Enter to send, Shift+Enter for new line
        </p>
      </div>
    </div>
  );
}

function MessageBubble({ message, agent }: { message: Message; agent: Agent }) {
  const isUser = message.role === "user";
  return (
    <div className={cn("flex gap-3", isUser && "flex-row-reverse")}>
      {!isUser && (
        <div
          className="w-8 h-8 rounded-lg flex items-center justify-center text-sm flex-shrink-0 mt-0.5"
          style={{ backgroundColor: agent.avatar_color + "22" }}
        >
          {agent.avatar_emoji}
        </div>
      )}
      <div className={cn("max-w-[70%]", isUser && "items-end flex flex-col")}>
        <div
          className={cn(
            "px-4 py-3 rounded-2xl text-sm leading-relaxed whitespace-pre-wrap",
            isUser
              ? "bg-[#6366f1] text-white rounded-br-sm"
              : "bg-[#1a1a27] text-[#f0f0ff] rounded-bl-sm"
          )}
        >
          {message.content}
        </div>
        <span className="text-xs text-[#4a4a6a] mt-1 px-1">
          {message.created_at ? formatTime(message.created_at) : ""}
        </span>
      </div>
    </div>
  );
}

function StreamingBubble({ content, agent }: { content: string; agent: Agent }) {
  return (
    <div className="flex gap-3">
      <div
        className="w-8 h-8 rounded-lg flex items-center justify-center text-sm flex-shrink-0 mt-0.5"
        style={{ backgroundColor: agent.avatar_color + "22" }}
      >
        {agent.avatar_emoji}
      </div>
      <div className="max-w-[70%]">
        <div className="bg-[#1a1a27] px-4 py-3 rounded-2xl rounded-bl-sm text-sm leading-relaxed whitespace-pre-wrap">
          {content}
          <span className="inline-block w-1 h-4 bg-[#6366f1] ml-0.5 animate-pulse" />
        </div>
      </div>
    </div>
  );
}

function ThinkingBubble({ agent }: { agent: Agent }) {
  return (
    <div className="flex gap-3">
      <div
        className="w-8 h-8 rounded-lg flex items-center justify-center text-sm flex-shrink-0"
        style={{ backgroundColor: agent.avatar_color + "22" }}
      >
        {agent.avatar_emoji}
      </div>
      <div className="bg-[#1a1a27] px-4 py-3 rounded-2xl rounded-bl-sm">
        <div className="flex gap-1 items-center h-4">
          {[0, 1, 2].map((i) => (
            <div
              key={i}
              className="w-1.5 h-1.5 rounded-full bg-[#8888aa]"
              style={{ animation: `bounce 1.2s ${i * 0.2}s infinite` }}
            />
          ))}
        </div>
      </div>
    </div>
  );
}

function getStarterPrompts(roleType: string): string[] {
  const prompts: Record<string, string[]> = {
    cfo: ["What's my spending breakdown this month?", "Help me build a budget", "Am I on track financially?"],
    ea: ["Plan my day", "What should I focus on today?", "Schedule a deep work block"],
    cto: ["Audit my tech stack", "What tools should I cut?", "How can I automate more?"],
    ceo: ["Give me a strategic review", "What are my top priorities?", "How is the company performing?"],
    coo: ["Review my systems and habits", "Help me optimize my morning routine", "What processes can I improve?"],
    cmo: ["Review my personal brand", "How should I be networking?", "Help me communicate my value"],
    chro: ["Check in on my wellbeing", "What should I be learning?", "Review my relationships"],
  };
  return prompts[roleType] || ["What can you help me with?", "Give me your assessment", "What's your recommendation?"];
}
