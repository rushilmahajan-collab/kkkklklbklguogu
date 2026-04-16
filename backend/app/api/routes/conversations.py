from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.models.conversation import Conversation, Message
from app.services.agent_service import get_agent
from app.services.ai_service import chat_with_agent, stream_chat_with_agent, create_or_get_conversation
import json

router = APIRouter(prefix="/conversations", tags=["conversations"])


class MessageResponse(BaseModel):
    id: str
    role: str
    content: str
    created_at: str

    class Config:
        from_attributes = True


class ConversationResponse(BaseModel):
    id: str
    agent_id: str
    title: Optional[str]
    messages: List[MessageResponse]
    created_at: str

    class Config:
        from_attributes = True


class ChatRequest(BaseModel):
    message: str
    stream: bool = False


@router.get("/agent/{agent_id}", response_model=ConversationResponse)
def get_or_create_conversation(
    agent_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    agent = get_agent(db, agent_id, current_user.id)
    if not agent:
        raise HTTPException(status_code=404, detail="Agent not found")
    conv = create_or_get_conversation(db, current_user.id, agent_id)
    messages = [
        MessageResponse(
            id=m.id,
            role=m.role,
            content=m.content,
            created_at=m.created_at.isoformat() if m.created_at else "",
        )
        for m in conv.messages
    ]
    return ConversationResponse(
        id=conv.id,
        agent_id=agent_id,
        title=conv.title,
        messages=messages,
        created_at=conv.created_at.isoformat() if conv.created_at else "",
    )


@router.post("/agent/{agent_id}/chat")
async def chat(
    agent_id: str,
    request: ChatRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    agent = get_agent(db, agent_id, current_user.id)
    if not agent:
        raise HTTPException(status_code=404, detail="Agent not found")

    conv = create_or_get_conversation(db, current_user.id, agent_id)
    user_name = current_user.full_name or current_user.email.split("@")[0]
    company_name = current_user.company_name or "My Life Company"

    if request.stream:
        async def event_stream():
            async for chunk in stream_chat_with_agent(
                db, agent, conv.id, request.message, user_name, company_name
            ):
                yield f"data: {json.dumps({'content': chunk})}\n\n"
            yield "data: [DONE]\n\n"

        return StreamingResponse(event_stream(), media_type="text/event-stream")
    else:
        response = await chat_with_agent(
            db, agent, conv.id, request.message, user_name, company_name
        )
        return {"response": response}


@router.post("/agent/{agent_id}/new")
def new_conversation(
    agent_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    agent = get_agent(db, agent_id, current_user.id)
    if not agent:
        raise HTTPException(status_code=404, detail="Agent not found")
    conv = Conversation(user_id=current_user.id, agent_id=agent_id, title="New Conversation")
    db.add(conv)
    db.commit()
    db.refresh(conv)
    return {"id": conv.id}


@router.get("/history")
def get_all_conversations(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    convs = (
        db.query(Conversation)
        .filter(Conversation.user_id == current_user.id)
        .order_by(Conversation.updated_at.desc())
        .limit(50)
        .all()
    )
    return [
        {
            "id": c.id,
            "agent_id": c.agent_id,
            "title": c.title,
            "message_count": len(c.messages),
            "created_at": c.created_at.isoformat() if c.created_at else "",
        }
        for c in convs
    ]
