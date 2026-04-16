export interface User {
  id: string;
  email: string;
  full_name: string | null;
  company_name: string | null;
  avatar_url: string | null;
  is_active: boolean;
}

export interface Agent {
  id: string;
  name: string;
  title: string;
  role_type: string;
  avatar_emoji: string;
  avatar_color: string;
  description: string | null;
  personality: string | null;
  communication_style: string;
  parent_agent_id: string | null;
  org_level: number;
  org_x: number;
  org_y: number;
  is_active: boolean;
  capabilities: string[];
  connected_integrations: string[];
}

export interface Message {
  id: string;
  role: "user" | "assistant";
  content: string;
  created_at: string;
}

export interface Conversation {
  id: string;
  agent_id: string;
  title: string | null;
  messages: Message[];
  created_at: string;
}

export interface Integration {
  id: string;
  provider: string;
  display_name: string | null;
  status: "connected" | "disconnected" | "error" | "pending";
  extra_data: Record<string, unknown>;
  connected_at: string | null;
}

export interface IntegrationInfo {
  name: string;
  description: string;
  icon: string;
  category: string;
  agent_roles: string[];
  scopes: string[];
}
