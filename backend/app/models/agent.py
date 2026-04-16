from sqlalchemy import Column, String, Boolean, DateTime, Text, ForeignKey, JSON, Integer
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid
from app.core.database import Base


class Agent(Base):
    __tablename__ = "agents"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"), nullable=False)

    # Identity
    name = Column(String, nullable=False)
    title = Column(String, nullable=False)  # CFO, CTO, CEO, EA, etc.
    role_type = Column(String, nullable=False)  # cfo, cto, ceo, ea, coo, cmo, chro, custom
    avatar_emoji = Column(String, default="🤖")
    avatar_color = Column(String, default="#6366f1")
    description = Column(Text, nullable=True)

    # Personality & System Prompt
    personality = Column(Text, nullable=True)
    system_prompt = Column(Text, nullable=True)
    communication_style = Column(String, default="professional")  # professional, casual, analytical

    # Org Chart Position
    parent_agent_id = Column(String, ForeignKey("agents.id"), nullable=True)
    org_level = Column(Integer, default=0)  # 0=C-suite, 1=VP, 2=Director, etc.
    org_x = Column(Integer, default=0)  # Position in org chart
    org_y = Column(Integer, default=0)

    # Status
    is_active = Column(Boolean, default=True)
    is_onboarded = Column(Boolean, default=False)

    # Capabilities & tools
    capabilities = Column(JSON, default=list)  # ["financial_analysis", "budgeting", etc.]
    connected_integrations = Column(JSON, default=list)  # ["plaid", "google_calendar", etc.]

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    user = relationship("User", back_populates="agents")
    conversations = relationship("Conversation", back_populates="agent", cascade="all, delete-orphan")
    direct_reports = relationship("Agent", backref="manager", foreign_keys=[parent_agent_id])
