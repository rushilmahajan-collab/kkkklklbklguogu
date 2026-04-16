export const ROLE_PRESETS: Record<string, {
  title: string;
  avatar_emoji: string;
  avatar_color: string;
  description: string;
  capabilities: string[];
}> = {
  ceo: {
    title: "Chief Executive Officer",
    avatar_emoji: "👑",
    avatar_color: "#f59e0b",
    description: "Your strategic visionary. Oversees all aspects of your life-company, sets long-term direction, and ensures all departments work in harmony.",
    capabilities: ["strategic_planning", "goal_setting", "performance_review", "vision"],
  },
  cfo: {
    title: "Chief Financial Officer",
    avatar_emoji: "💰",
    avatar_color: "#10b981",
    description: "Your financial guardian. Manages budgets, tracks spending, analyzes investments, and keeps your financial health in check.",
    capabilities: ["budget_analysis", "expense_tracking", "investment_advice", "financial_planning"],
  },
  cto: {
    title: "Chief Technology Officer",
    avatar_emoji: "⚡",
    avatar_color: "#6366f1",
    description: "Your tech strategist. Manages your digital tools, automates workflows, and keeps your technology stack optimized.",
    capabilities: ["tech_stack_management", "automation", "security", "tool_recommendation"],
  },
  ea: {
    title: "Executive Assistant",
    avatar_emoji: "📅",
    avatar_color: "#ec4899",
    description: "Your productivity partner. Manages your calendar, plans your day, tracks tasks, and ensures you focus on what matters most.",
    capabilities: ["calendar_management", "task_prioritization", "scheduling", "daily_briefing"],
  },
  coo: {
    title: "Chief Operating Officer",
    avatar_emoji: "⚙️",
    avatar_color: "#f97316",
    description: "Your operations optimizer. Streamlines daily processes, builds systems and habits, and ensures everything runs smoothly.",
    capabilities: ["process_optimization", "habit_tracking", "systems_design", "efficiency"],
  },
  cmo: {
    title: "Chief Marketing Officer",
    avatar_emoji: "📣",
    avatar_color: "#e11d48",
    description: "Your personal brand strategist. Manages your public presence, networking strategy, and helps you communicate your value.",
    capabilities: ["personal_branding", "networking", "content_strategy", "social_media"],
  },
  chro: {
    title: "Chief People Officer",
    avatar_emoji: "🧠",
    avatar_color: "#8b5cf6",
    description: "Your wellbeing and growth advisor. Focuses on health, relationships, learning, and personal development.",
    capabilities: ["wellness_tracking", "relationship_management", "learning_planning", "mental_health"],
  },
  custom: {
    title: "Custom Advisor",
    avatar_emoji: "🌟",
    avatar_color: "#64748b",
    description: "A custom advisor tailored to your specific needs.",
    capabilities: [],
  },
};
