from sqlalchemy import Column, String, Boolean, DateTime, Text, ForeignKey, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid
from app.core.database import Base


class Integration(Base):
    __tablename__ = "integrations"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"), nullable=False)

    provider = Column(String, nullable=False)  # plaid, google_calendar, github, notion, etc.
    display_name = Column(String, nullable=True)
    status = Column(String, default="disconnected")  # connected, disconnected, error, pending

    # Encrypted tokens stored as JSON
    credentials = Column(JSON, default=dict)
    extra_data = Column(JSON, default=dict)  # account info, scopes, etc.

    connected_at = Column(DateTime(timezone=True), nullable=True)
    expires_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    user = relationship("User", back_populates="integrations")
