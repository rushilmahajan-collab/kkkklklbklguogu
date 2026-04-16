"use client";

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import toast from "react-hot-toast";
import { integrationsApi } from "@/lib/api";
import type { Integration, IntegrationInfo } from "@/types";
import { cn } from "@/lib/utils";

const CATEGORY_LABELS: Record<string, string> = {
  finance: "💰 Finance",
  productivity: "📋 Productivity",
  tech: "⚡ Technology",
  communication: "💬 Communication",
};

export default function IntegrationsPage() {
  const qc = useQueryClient();

  const { data: available = {} } = useQuery<Record<string, IntegrationInfo>>({
    queryKey: ["integrations-available"],
    queryFn: async () => {
      const res = await integrationsApi.available();
      return res.data;
    },
  });

  const { data: connected = [] } = useQuery<Integration[]>({
    queryKey: ["integrations"],
    queryFn: async () => {
      const res = await integrationsApi.list();
      return res.data;
    },
  });

  const { mutate: connect, isPending: connecting } = useMutation({
    mutationFn: (provider: string) => integrationsApi.connect(provider),
    onSuccess: (res, provider) => {
      const data = res.data;
      if (data.action === "oauth" && data.auth_url) {
        window.location.href = data.auth_url;
      } else {
        qc.invalidateQueries({ queryKey: ["integrations"] });
        toast.success(`${provider} connected!`);
      }
    },
    onError: () => toast.error("Connection failed"),
  });

  const { mutate: disconnect } = useMutation({
    mutationFn: (provider: string) => integrationsApi.disconnect(provider),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["integrations"] });
      toast.success("Disconnected");
    },
  });

  const connectedMap = new Map(connected.map((i) => [i.provider, i]));

  // Group by category
  const byCategory: Record<string, [string, IntegrationInfo][]> = {};
  Object.entries(available).forEach(([key, info]) => {
    if (!byCategory[info.category]) byCategory[info.category] = [];
    byCategory[info.category].push([key, info]);
  });

  return (
    <div className="p-8 max-w-4xl mx-auto animate-fade-in">
      <div className="mb-8">
        <h1 className="text-3xl font-bold">Integrations</h1>
        <p className="text-[#8888aa] mt-1">
          Connect your tools to give your executives real-time data
        </p>
      </div>

      {/* Connected count */}
      <div className="bg-[#12121a] border border-[#2a2a3d] rounded-xl p-5 mb-8 flex items-center gap-4">
        <div className="text-3xl">🔌</div>
        <div>
          <div className="font-bold text-xl">{connected.filter((i) => i.status === "connected").length} Connected</div>
          <div className="text-[#8888aa] text-sm">of {Object.keys(available).length} available integrations</div>
        </div>
      </div>

      {/* By category */}
      {Object.entries(byCategory).map(([category, items]) => (
        <div key={category} className="mb-8">
          <h2 className="text-sm font-semibold text-[#8888aa] uppercase tracking-wider mb-3">
            {CATEGORY_LABELS[category] || category}
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {items.map(([provider, info]) => {
              const existing = connectedMap.get(provider);
              const isConnected = existing?.status === "connected";
              return (
                <IntegrationCard
                  key={provider}
                  provider={provider}
                  info={info}
                  isConnected={isConnected}
                  onConnect={() => connect(provider)}
                  onDisconnect={() => disconnect(provider)}
                  connecting={connecting}
                />
              );
            })}
          </div>
        </div>
      ))}

      {/* Note */}
      <div className="bg-[#1a1a27] border border-[#2a2a3d] rounded-xl p-4 text-sm text-[#8888aa]">
        <p className="font-medium text-[#f0f0ff] mb-1">Demo Mode</p>
        <p>
          Integrations like Plaid and Google Calendar require API keys. Add your keys to{" "}
          <code className="bg-[#12121a] px-1 rounded text-xs">.env</code> to enable real data.
          In demo mode, connections are simulated.
        </p>
      </div>
    </div>
  );
}

function IntegrationCard({
  provider,
  info,
  isConnected,
  onConnect,
  onDisconnect,
  connecting,
}: {
  provider: string;
  info: IntegrationInfo;
  isConnected: boolean;
  onConnect: () => void;
  onDisconnect: () => void;
  connecting: boolean;
}) {
  return (
    <div
      className={cn(
        "bg-[#12121a] border rounded-xl p-5 transition-colors",
        isConnected ? "border-[#10b981]/40" : "border-[#2a2a3d]"
      )}
    >
      <div className="flex items-start justify-between mb-3">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-lg bg-[#1a1a27] flex items-center justify-center text-xl">
            {info.icon}
          </div>
          <div>
            <div className="font-semibold">{info.name}</div>
            <div className="flex items-center gap-1.5 mt-0.5">
              <div
                className={cn(
                  "w-1.5 h-1.5 rounded-full",
                  isConnected ? "bg-[#10b981]" : "bg-[#4a4a6a]"
                )}
              />
              <span className="text-xs text-[#8888aa]">
                {isConnected ? "Connected" : "Not connected"}
              </span>
            </div>
          </div>
        </div>
        {isConnected ? (
          <button
            onClick={onDisconnect}
            className="text-xs text-[#8888aa] hover:text-red-400 transition-colors border border-[#2a2a3d] px-3 py-1.5 rounded-lg"
          >
            Disconnect
          </button>
        ) : (
          <button
            onClick={onConnect}
            disabled={connecting}
            className="text-xs bg-[#6366f1] hover:bg-[#818cf8] disabled:opacity-50 text-white px-3 py-1.5 rounded-lg transition-colors"
          >
            Connect
          </button>
        )}
      </div>
      <p className="text-[#8888aa] text-sm">{info.description}</p>
      <div className="mt-3 flex flex-wrap gap-1">
        {info.agent_roles.map((role) => (
          <span
            key={role}
            className="text-xs bg-[#1a1a27] text-[#8888aa] px-2 py-0.5 rounded-full"
          >
            {role.toUpperCase()}
          </span>
        ))}
      </div>
    </div>
  );
}
