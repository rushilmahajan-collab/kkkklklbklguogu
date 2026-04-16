"use client";

import { useState, useCallback, useEffect } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import {
  ReactFlow,
  Node,
  Edge,
  Controls,
  Background,
  BackgroundVariant,
  useNodesState,
  useEdgesState,
  addEdge,
  Connection,
  MiniMap,
} from "@xyflow/react";
import "@xyflow/react/dist/style.css";
import toast from "react-hot-toast";
import { agentsApi } from "@/lib/api";
import type { Agent } from "@/types";
import type { AgentCreateInput } from "@/lib/api";
import { ROLE_PRESETS } from "@/lib/agent-presets";

// Custom node component
function AgentNode({ data }: { data: { agent: Agent; onChat: () => void } }) {
  const { agent } = data;
  return (
    <div
      className="bg-[#12121a] border border-[#2a2a3d] rounded-xl p-4 min-w-[160px] hover:border-[#6366f1]/50 transition-colors shadow-lg"
      style={{ borderColor: agent.avatar_color + "44" }}
    >
      <div className="flex items-center gap-2 mb-2">
        <div
          className="w-10 h-10 rounded-lg flex items-center justify-center text-xl"
          style={{ backgroundColor: agent.avatar_color + "22" }}
        >
          {agent.avatar_emoji}
        </div>
        <div>
          <div className="text-sm font-semibold text-[#f0f0ff]">{agent.name}</div>
          <div className="text-xs text-[#8888aa]">{agent.title}</div>
        </div>
      </div>
      <button
        onClick={data.onChat}
        className="w-full text-xs bg-[#6366f1]/20 hover:bg-[#6366f1]/30 text-[#818cf8] py-1.5 rounded-lg transition-colors"
      >
        Chat →
      </button>
    </div>
  );
}

const nodeTypes = { agentNode: AgentNode };

export default function OrgChartPage() {
  const qc = useQueryClient();
  const [nodes, setNodes, onNodesChange] = useNodesState<Node>([]);
  const [edges, setEdges, onEdgesChange] = useEdgesState<Edge>([]);
  const [showAddModal, setShowAddModal] = useState(false);

  const { data: agents = [] } = useQuery<Agent[]>({
    queryKey: ["agents"],
    queryFn: async () => {
      const res = await agentsApi.list();
      return res.data;
    },
  });

  const { mutate: updateOrgChart } = useMutation({
    mutationFn: (updates: { id: string; org_x: number; org_y: number }[]) =>
      agentsApi.updateOrgChart(updates),
  });

  const { mutate: createAgent } = useMutation({
    mutationFn: (data: AgentCreateInput) => agentsApi.create(data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["agents"] });
      toast.success("Agent added to org chart!");
      setShowAddModal(false);
    },
  });

  const { mutate: deleteAgent } = useMutation({
    mutationFn: (id: string) => agentsApi.delete(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["agents"] });
      toast.success("Agent removed");
    },
  });

  // Build nodes and edges from agents
  useEffect(() => {
    const newNodes: Node[] = agents.map((agent) => ({
      id: agent.id,
      type: "agentNode",
      position: { x: agent.org_x || 0, y: agent.org_y || 0 },
      data: {
        agent,
        onChat: () => window.location.href = `/dashboard/agent/${agent.id}`,
      },
    }));

    const newEdges: Edge[] = agents
      .filter((a) => a.parent_agent_id)
      .map((a) => ({
        id: `${a.parent_agent_id}-${a.id}`,
        source: a.parent_agent_id!,
        target: a.id,
        style: { stroke: "#2a2a3d", strokeWidth: 2 },
        animated: false,
      }));

    setNodes(newNodes);
    setEdges(newEdges);
  }, [agents, setNodes, setEdges]);

  const onNodeDragStop = useCallback(
    (_: React.MouseEvent, node: Node) => {
      updateOrgChart([{ id: node.id, org_x: Math.round(node.position.x), org_y: Math.round(node.position.y) }]);
    },
    [updateOrgChart]
  );

  const onConnect = useCallback(
    (connection: Connection) => {
      setEdges((eds) => addEdge({ ...connection, style: { stroke: "#2a2a3d", strokeWidth: 2 } }, eds));
      if (connection.source && connection.target) {
        agentsApi.update(connection.target, { parent_agent_id: connection.source });
      }
    },
    [setEdges]
  );

  return (
    <div className="h-full flex flex-col">
      {/* Header */}
      <div className="flex-shrink-0 px-6 py-4 border-b border-[#2a2a3d] flex items-center justify-between bg-[#12121a]">
        <div>
          <h1 className="text-xl font-bold">Org Chart</h1>
          <p className="text-[#8888aa] text-sm">{agents.length} executives • Drag to rearrange</p>
        </div>
        <button
          onClick={() => setShowAddModal(true)}
          className="bg-[#6366f1] hover:bg-[#818cf8] text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors"
        >
          + Add Executive
        </button>
      </div>

      {/* React Flow */}
      <div className="flex-1" style={{ background: "#0a0a0f" }}>
        <ReactFlow
          nodes={nodes}
          edges={edges}
          onNodesChange={onNodesChange}
          onEdgesChange={onEdgesChange}
          onConnect={onConnect}
          onNodeDragStop={onNodeDragStop}
          nodeTypes={nodeTypes}
          fitView
          fitViewOptions={{ padding: 0.2 }}
          style={{ background: "#0a0a0f" }}
        >
          <Background color="#2a2a3d" variant={BackgroundVariant.Dots} gap={20} size={1} />
          <Controls style={{ background: "#12121a", border: "1px solid #2a2a3d" }} />
          <MiniMap
            style={{ background: "#12121a", border: "1px solid #2a2a3d" }}
            nodeColor={(node) => {
              const agent = agents.find((a) => a.id === node.id);
              return agent?.avatar_color || "#6366f1";
            }}
          />
        </ReactFlow>
      </div>

      {/* Add Agent Modal */}
      {showAddModal && (
        <AddAgentModal
          agents={agents}
          onAdd={(data) => createAgent(data)}
          onClose={() => setShowAddModal(false)}
        />
      )}
    </div>
  );
}

function AddAgentModal({
  agents,
  onAdd,
  onClose,
}: {
  agents: Agent[];
  onAdd: (data: AgentCreateInput) => void;
  onClose: () => void;
}) {
  const [form, setForm] = useState({
    name: "",
    role_type: "ceo",
    parent_agent_id: "",
    org_x: 200,
    org_y: 200,
  });

  const preset = ROLE_PRESETS[form.role_type] || ROLE_PRESETS.custom;

  return (
    <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-50 p-4">
      <div className="bg-[#12121a] border border-[#2a2a3d] rounded-2xl p-6 w-full max-w-md">
        <h2 className="text-lg font-bold mb-4">Add Executive</h2>
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium mb-1.5">Role</label>
            <select
              value={form.role_type}
              onChange={(e) => setForm({ ...form, role_type: e.target.value })}
              className="w-full bg-[#1a1a27] border border-[#2a2a3d] rounded-lg px-4 py-3 text-[#f0f0ff] focus:outline-none focus:border-[#6366f1]"
            >
              {Object.entries(ROLE_PRESETS).map(([key, p]) => (
                <option key={key} value={key}>
                  {p.avatar_emoji} {p.title}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium mb-1.5">Name</label>
            <input
              type="text"
              value={form.name}
              onChange={(e) => setForm({ ...form, name: e.target.value })}
              placeholder={preset?.avatar_emoji + " e.g. Morgan, Alex..."}
              className="w-full bg-[#1a1a27] border border-[#2a2a3d] rounded-lg px-4 py-3 text-[#f0f0ff] placeholder-[#4a4a6a] focus:outline-none focus:border-[#6366f1]"
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1.5">Reports To</label>
            <select
              value={form.parent_agent_id}
              onChange={(e) => setForm({ ...form, parent_agent_id: e.target.value })}
              className="w-full bg-[#1a1a27] border border-[#2a2a3d] rounded-lg px-4 py-3 text-[#f0f0ff] focus:outline-none focus:border-[#6366f1]"
            >
              <option value="">No manager (top level)</option>
              {agents.map((a) => (
                <option key={a.id} value={a.id}>
                  {a.avatar_emoji} {a.name} — {a.title}
                </option>
              ))}
            </select>
          </div>
          {preset && (
            <div className="bg-[#1a1a27] rounded-lg p-3 text-sm text-[#8888aa]">
              {preset.description}
            </div>
          )}
        </div>
        <div className="flex gap-3 mt-6">
          <button
            onClick={onClose}
            className="flex-1 bg-[#1a1a27] border border-[#2a2a3d] text-[#8888aa] py-2.5 rounded-lg hover:text-[#f0f0ff] transition-colors"
          >
            Cancel
          </button>
          <button
            onClick={() => {
              if (!form.name.trim()) { toast.error("Enter a name"); return; }
              onAdd({
                name: form.name,
                role_type: form.role_type,
                parent_agent_id: form.parent_agent_id || undefined,
                org_x: form.org_x,
                org_y: form.org_y,
              });
            }}
            className="flex-1 bg-[#6366f1] hover:bg-[#818cf8] text-white py-2.5 rounded-lg font-medium transition-colors"
          >
            Add to Board
          </button>
        </div>
      </div>
    </div>
  );
}
