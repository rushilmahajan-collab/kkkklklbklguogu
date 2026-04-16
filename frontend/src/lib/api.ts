import axios from "axios";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000/api/v1";

export const api = axios.create({
  baseURL: API_URL,
  headers: { "Content-Type": "application/json" },
});

api.interceptors.request.use((config) => {
  if (typeof window !== "undefined") {
    const token = localStorage.getItem("token");
    if (token) config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

api.interceptors.response.use(
  (res) => res,
  (error) => {
    if (error.response?.status === 401 && typeof window !== "undefined") {
      localStorage.removeItem("token");
      window.location.href = "/login";
    }
    return Promise.reject(error);
  }
);

// Auth
export const authApi = {
  register: (data: { email: string; password: string; full_name?: string; company_name?: string }) =>
    api.post("/auth/register", data),
  login: (data: { email: string; password: string }) =>
    api.post("/auth/login", data),
  me: () => api.get("/auth/me"),
  updateProfile: (data: Partial<{ full_name: string; company_name: string; avatar_url: string }>) =>
    api.patch("/auth/me", data),
};

// Agents
export const agentsApi = {
  list: () => api.get("/agents/"),
  get: (id: string) => api.get(`/agents/${id}`),
  create: (data: AgentCreateInput) => api.post("/agents/", data),
  update: (id: string, data: Partial<AgentCreateInput>) => api.patch(`/agents/${id}`, data),
  delete: (id: string) => api.delete(`/agents/${id}`),
  presets: () => api.get("/agents/presets"),
  updateOrgChart: (agents: OrgChartUpdate[]) =>
    api.post("/agents/org-chart/update", { agents }),
};

// Conversations
export const conversationsApi = {
  getOrCreate: (agentId: string) => api.get(`/conversations/agent/${agentId}`),
  chat: (agentId: string, message: string) =>
    api.post(`/conversations/agent/${agentId}/chat`, { message }),
  newConversation: (agentId: string) => api.post(`/conversations/agent/${agentId}/new`),
  history: () => api.get("/conversations/history"),
};

// Integrations
export const integrationsApi = {
  available: () => api.get("/integrations/available"),
  list: () => api.get("/integrations/"),
  connect: (provider: string) => api.post(`/integrations/${provider}/connect`),
  disconnect: (provider: string) => api.post(`/integrations/${provider}/disconnect`),
};

// Types
export interface AgentCreateInput {
  name: string;
  role_type: string;
  title?: string;
  avatar_emoji?: string;
  avatar_color?: string;
  description?: string;
  personality?: string;
  communication_style?: string;
  parent_agent_id?: string;
  org_level?: number;
  org_x?: number;
  org_y?: number;
}

export interface OrgChartUpdate {
  id: string;
  org_x?: number;
  org_y?: number;
  parent_agent_id?: string;
}
