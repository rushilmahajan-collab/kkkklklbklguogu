from sqlalchemy.orm import Session
from typing import Optional, List
from pydantic import BaseModel
from app.models.agent import Agent


ROLE_PRESETS = {
    "ceo": {
        "title": "Chief Executive Officer",
        "avatar_emoji": "👑",
        "avatar_color": "#f59e0b",
        "description": "Your strategic visionary. Oversees all aspects of your life-company, sets long-term direction, and ensures all departments work in harmony.",
        "capabilities": ["strategic_planning", "goal_setting", "performance_review", "vision"],
        "personality": "You are a visionary CEO who thinks in systems and long-term outcomes. You are decisive, inspiring, and always focused on the big picture. You help the user see their life as a company to be optimized and grown.",
    },
    "cfo": {
        "title": "Chief Financial Officer",
        "avatar_emoji": "💰",
        "avatar_color": "#10b981",
        "description": "Your financial guardian. Manages budgets, tracks spending, analyzes investments, and keeps your financial health in check.",
        "capabilities": ["budget_analysis", "expense_tracking", "investment_advice", "financial_planning", "tax_strategy"],
        "personality": "You are a meticulous CFO who lives by the numbers. You analyze financial data with precision, identify patterns in spending, and provide actionable insights to improve financial health. You speak in terms of ROI, cash flow, and financial projections.",
    },
    "cto": {
        "title": "Chief Technology Officer",
        "avatar_emoji": "⚡",
        "avatar_color": "#6366f1",
        "description": "Your tech strategist. Manages your digital tools, automates workflows, and keeps your technology stack optimized.",
        "capabilities": ["tech_stack_management", "automation", "security", "tool_recommendation", "workflow_optimization"],
        "personality": "You are a pragmatic CTO who believes technology should serve people, not the other way around. You evaluate tools for their true utility, recommend automations to save time, and keep the user's digital life secure and efficient.",
    },
    "ea": {
        "title": "Executive Assistant",
        "avatar_emoji": "📅",
        "avatar_color": "#ec4899",
        "description": "Your productivity partner. Manages your calendar, plans your day, tracks tasks, and ensures you focus on what matters most.",
        "capabilities": ["calendar_management", "task_prioritization", "scheduling", "meeting_prep", "daily_briefing"],
        "personality": "You are a highly organized Executive Assistant who anticipates needs before they arise. You manage time with military precision, filter what deserves the CEO's attention, and ensure every day is structured for maximum productivity and wellbeing.",
    },
    "coo": {
        "title": "Chief Operating Officer",
        "avatar_emoji": "⚙️",
        "avatar_color": "#f97316",
        "description": "Your operations optimizer. Streamlines daily processes, builds systems and habits, and ensures everything runs smoothly.",
        "capabilities": ["process_optimization", "habit_tracking", "systems_design", "efficiency", "operations"],
        "personality": "You are a systems-minded COO focused on building repeatable processes and eliminating inefficiencies. You help design the daily operating procedures of life, from morning routines to project management frameworks.",
    },
    "cmo": {
        "title": "Chief Marketing Officer",
        "avatar_emoji": "📣",
        "avatar_color": "#e11d48",
        "description": "Your personal brand strategist. Manages your public presence, networking strategy, and helps you communicate your value.",
        "capabilities": ["personal_branding", "networking", "content_strategy", "social_media", "communication"],
        "personality": "You are a creative CMO who understands that every person is a brand. You help craft compelling personal narratives, identify networking opportunities, and build a presence that opens doors.",
    },
    "chro": {
        "title": "Chief People Officer",
        "avatar_emoji": "🧠",
        "avatar_color": "#8b5cf6",
        "description": "Your wellbeing and growth advisor. Focuses on health, relationships, learning, and personal development.",
        "capabilities": ["wellness_tracking", "relationship_management", "learning_planning", "mental_health", "career_development"],
        "personality": "You are a compassionate CHRO who understands that people are the most important asset. You focus on wellbeing, personal growth, relationship health, and work-life integration. You help build a life that is both productive and fulfilling.",
    },
    "custom": {
        "title": "Custom Advisor",
        "avatar_emoji": "🌟",
        "avatar_color": "#64748b",
        "description": "A custom advisor tailored to your specific needs.",
        "capabilities": [],
        "personality": "You are a helpful advisor.",
    },
}


class AgentCreate(BaseModel):
    name: str
    role_type: str
    title: Optional[str] = None
    avatar_emoji: Optional[str] = None
    avatar_color: Optional[str] = None
    description: Optional[str] = None
    personality: Optional[str] = None
    communication_style: Optional[str] = "professional"
    parent_agent_id: Optional[str] = None
    org_level: Optional[int] = 0
    org_x: Optional[int] = 0
    org_y: Optional[int] = 0


class AgentUpdate(BaseModel):
    name: Optional[str] = None
    title: Optional[str] = None
    description: Optional[str] = None
    personality: Optional[str] = None
    communication_style: Optional[str] = None
    parent_agent_id: Optional[str] = None
    org_level: Optional[int] = None
    org_x: Optional[int] = None
    org_y: Optional[int] = None
    avatar_emoji: Optional[str] = None
    avatar_color: Optional[str] = None
    is_active: Optional[bool] = None


def get_agents(db: Session, user_id: str) -> List[Agent]:
    return db.query(Agent).filter(Agent.user_id == user_id).all()


def get_agent(db: Session, agent_id: str, user_id: str) -> Optional[Agent]:
    return db.query(Agent).filter(Agent.id == agent_id, Agent.user_id == user_id).first()


def create_agent(db: Session, user_id: str, data: AgentCreate) -> Agent:
    preset = ROLE_PRESETS.get(data.role_type, ROLE_PRESETS["custom"])
    agent = Agent(
        user_id=user_id,
        name=data.name,
        role_type=data.role_type,
        title=data.title or preset["title"],
        avatar_emoji=data.avatar_emoji or preset["avatar_emoji"],
        avatar_color=data.avatar_color or preset["avatar_color"],
        description=data.description or preset["description"],
        personality=data.personality or preset["personality"],
        communication_style=data.communication_style,
        capabilities=preset.get("capabilities", []),
        parent_agent_id=data.parent_agent_id,
        org_level=data.org_level,
        org_x=data.org_x,
        org_y=data.org_y,
    )
    db.add(agent)
    db.commit()
    db.refresh(agent)
    return agent


def update_agent(db: Session, agent: Agent, data: AgentUpdate) -> Agent:
    for field, value in data.model_dump(exclude_none=True).items():
        setattr(agent, field, value)
    db.commit()
    db.refresh(agent)
    return agent


def delete_agent(db: Session, agent: Agent) -> None:
    db.delete(agent)
    db.commit()


def seed_default_agents(db: Session, user_id: str) -> List[Agent]:
    """Create default C-suite for a new user"""
    defaults = [
        {"name": "Alex", "role_type": "ceo", "org_level": 0, "org_x": 400, "org_y": 50},
        {"name": "Morgan", "role_type": "cfo", "org_level": 1, "org_x": 100, "org_y": 200},
        {"name": "Jordan", "role_type": "cto", "org_level": 1, "org_x": 400, "org_y": 200},
        {"name": "Riley", "role_type": "ea", "org_level": 1, "org_x": 700, "org_y": 200},
    ]
    agents = []
    for d in defaults:
        agent = create_agent(db, user_id, AgentCreate(**d))
        agents.append(agent)
    # Set CEO as parent for others
    ceo = agents[0]
    for agent in agents[1:]:
        agent.parent_agent_id = ceo.id
    db.commit()
    return agents
