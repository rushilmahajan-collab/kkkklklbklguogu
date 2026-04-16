from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.models.agent import Agent
from app.services.agent_service import (
    AgentCreate, AgentUpdate, get_agents, get_agent, create_agent, update_agent, delete_agent, ROLE_PRESETS
)

router = APIRouter(prefix="/agents", tags=["agents"])


class AgentResponse(BaseModel):
    id: str
    name: str
    title: str
    role_type: str
    avatar_emoji: str
    avatar_color: str
    description: Optional[str]
    personality: Optional[str]
    communication_style: str
    parent_agent_id: Optional[str]
    org_level: int
    org_x: int
    org_y: int
    is_active: bool
    capabilities: list
    connected_integrations: list

    class Config:
        from_attributes = True


class OrgChartUpdate(BaseModel):
    agents: List[dict]  # [{id, org_x, org_y, parent_agent_id}]


@router.get("/", response_model=List[AgentResponse])
def list_agents(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return get_agents(db, current_user.id)


@router.post("/", response_model=AgentResponse, status_code=201)
def create_new_agent(
    data: AgentCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return create_agent(db, current_user.id, data)


@router.get("/presets")
def get_presets():
    return {
        role: {
            "role_type": role,
            "title": preset["title"],
            "avatar_emoji": preset["avatar_emoji"],
            "avatar_color": preset["avatar_color"],
            "description": preset["description"],
            "capabilities": preset.get("capabilities", []),
        }
        for role, preset in ROLE_PRESETS.items()
    }


@router.get("/{agent_id}", response_model=AgentResponse)
def get_single_agent(
    agent_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    agent = get_agent(db, agent_id, current_user.id)
    if not agent:
        raise HTTPException(status_code=404, detail="Agent not found")
    return agent


@router.patch("/{agent_id}", response_model=AgentResponse)
def update_existing_agent(
    agent_id: str,
    data: AgentUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    agent = get_agent(db, agent_id, current_user.id)
    if not agent:
        raise HTTPException(status_code=404, detail="Agent not found")
    return update_agent(db, agent, data)


@router.delete("/{agent_id}", status_code=204)
def delete_existing_agent(
    agent_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    agent = get_agent(db, agent_id, current_user.id)
    if not agent:
        raise HTTPException(status_code=404, detail="Agent not found")
    delete_agent(db, agent)


@router.post("/org-chart/update")
def update_org_chart(
    data: OrgChartUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Bulk update positions in the org chart"""
    for agent_data in data.agents:
        agent = get_agent(db, agent_data["id"], current_user.id)
        if agent:
            if "org_x" in agent_data:
                agent.org_x = agent_data["org_x"]
            if "org_y" in agent_data:
                agent.org_y = agent_data["org_y"]
            if "parent_agent_id" in agent_data:
                agent.parent_agent_id = agent_data["parent_agent_id"]
    db.commit()
    return {"status": "updated"}
