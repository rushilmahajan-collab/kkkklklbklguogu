"use client";

import { useQuery } from "@tanstack/react-query";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { agentsApi, integrationsApi } from "@/lib/api";
import { useAuthStore } from "@/store/auth";
import type { Agent, Integration } from "@/types";

export default function DashboardPage() {
  const { user } = useAuthStore();
  const router = useRouter();

  const { data: agents = [] } = useQuery<Agent[]>({
    queryKey: ["agents"],
    queryFn: async () => {
      const res = await agentsApi.list();
      return res.data;
    },
  });

  const { data: integrations = [] } = useQuery<Integration[]>({
    queryKey: ["integrations"],
    queryFn: async () => {
      const res = await integrationsApi.list();
      return res.data;
    },
  });

  const connectedCount = integrations.filter((i) => i.status === "connected").length;
  const activeAgents = agents.filter((a) => a.is_active);

  return (
    <div className="p-8 max-w-6xl mx-auto animate-fade-in">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold">
          Good {getGreeting()}, {user?.full_name?.split(" ")[0] || "CEO"} 👋
        </h1>
        <p className="text-[#8888aa] mt-1">
          {user?.company_name} — Board meeting room
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-4 mb-8">
        <StatCard label="Board Members" value={activeAgents.length} emoji="👥" color="#6366f1" />
        <StatCard label="Connected Tools" value={connectedCount} emoji="🔌" color="#10b981" />
        <StatCard label="Departments" value={Math.ceil(agents.length / 2)} emoji="🏢" color="#f59e0b" />
      </div>

      {/* Agents Grid */}
      <div className="mb-8">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-semibold">Your Executive Team</h2>
          <Link
            href="/dashboard/org-chart"
            className="text-sm text-[#6366f1] hover:text-[#818cf8] transition-colors"
          >
            View Org Chart →
          </Link>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {agents.map((agent) => (
            <AgentCard
              key={agent.id}
              agent={agent}
              onClick={() => router.push(`/dashboard/agent/${agent.id}`)}
            />
          ))}
          <AddAgentCard />
        </div>
      </div>

      {/* Quick Actions */}
      <div>
        <h2 className="text-xl font-semibold mb-4">Quick Actions</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <QuickAction
            emoji="💬"
            title="Chat with CFO"
            desc="Review finances & budget"
            href={`/dashboard/agent/${agents.find((a) => a.role_type === "cfo")?.id || ""}`}
            color="#10b981"
          />
          <QuickAction
            emoji="📅"
            title="Plan my day"
            desc="Ask your EA to schedule"
            href={`/dashboard/agent/${agents.find((a) => a.role_type === "ea")?.id || ""}`}
            color="#ec4899"
          />
          <QuickAction
            emoji="🔌"
            title="Connect tools"
            desc="Add Plaid, Calendar & more"
            href="/dashboard/integrations"
            color="#6366f1"
          />
        </div>
      </div>
    </div>
  );
}

function getGreeting() {
  const h = new Date().getHours();
  if (h < 12) return "morning";
  if (h < 17) return "afternoon";
  return "evening";
}

function StatCard({ label, value, emoji, color }: { label: string; value: number; emoji: string; color: string }) {
  return (
    <div className="bg-[#12121a] border border-[#2a2a3d] rounded-xl p-5">
      <div className="flex items-center justify-between mb-2">
        <span className="text-[#8888aa] text-sm">{label}</span>
        <span className="text-xl">{emoji}</span>
      </div>
      <div className="text-3xl font-bold" style={{ color }}>{value}</div>
    </div>
  );
}

function AgentCard({ agent, onClick }: { agent: Agent; onClick: () => void }) {
  return (
    <button
      onClick={onClick}
      className="bg-[#12121a] border border-[#2a2a3d] rounded-xl p-5 text-left hover:border-[#6366f1]/50 hover:-translate-y-0.5 transition-all group"
    >
      <div
        className="w-12 h-12 rounded-xl flex items-center justify-center text-2xl mb-3"
        style={{ backgroundColor: agent.avatar_color + "22", border: `1px solid ${agent.avatar_color}44` }}
      >
        {agent.avatar_emoji}
      </div>
      <div className="font-semibold">{agent.name}</div>
      <div className="text-[#8888aa] text-xs mt-0.5">{agent.title}</div>
      <div className="mt-3 flex items-center gap-1">
        <div
          className="w-1.5 h-1.5 rounded-full"
          style={{ backgroundColor: agent.is_active ? "#10b981" : "#6b7280" }}
        />
        <span className="text-xs text-[#8888aa]">
          {agent.is_active ? "Active" : "Inactive"}
        </span>
      </div>
    </button>
  );
}

function AddAgentCard() {
  const router = useRouter();
  return (
    <button
      onClick={() => router.push("/dashboard/org-chart")}
      className="bg-[#12121a] border border-dashed border-[#2a2a3d] rounded-xl p-5 text-left hover:border-[#6366f1]/50 transition-all flex flex-col items-center justify-center min-h-[140px]"
    >
      <div className="w-12 h-12 rounded-xl bg-[#1a1a27] flex items-center justify-center text-2xl mb-3">
        +
      </div>
      <div className="text-[#8888aa] text-sm">Add executive</div>
    </button>
  );
}

function QuickAction({
  emoji, title, desc, href, color
}: {
  emoji: string; title: string; desc: string; href: string; color: string;
}) {
  return (
    <Link
      href={href}
      className="bg-[#12121a] border border-[#2a2a3d] rounded-xl p-5 hover:border-[#6366f1]/50 hover:-translate-y-0.5 transition-all block"
    >
      <span className="text-2xl mb-3 block">{emoji}</span>
      <div className="font-semibold">{title}</div>
      <div className="text-[#8888aa] text-sm mt-1">{desc}</div>
    </Link>
  );
}
