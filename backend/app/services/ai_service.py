from openai import AsyncOpenAI
from typing import Optional, AsyncIterator
from sqlalchemy.orm import Session
from app.models.agent import Agent
from app.models.conversation import Conversation, Message
from app.core.config import settings

client = AsyncOpenAI(
    api_key=settings.DEEPSEEK_API_KEY or "placeholder",
    base_url=settings.DEEPSEEK_BASE_URL,
)


def build_system_prompt(agent: Agent, user_name: str, company_name: str) -> str:
    base = f"""You are {agent.name}, the {agent.title} of {company_name} — a personal life management company for {user_name}.

Your role: {agent.description}

Your personality: {agent.personality}

Communication style: {agent.communication_style}

You treat the user's life like a business. Be proactive, insightful, and actionable.
Reference relevant data when available. Keep responses concise but valuable.
When you need more information to give better advice, ask targeted questions.

Current capabilities you have access to: {', '.join(agent.capabilities) if agent.capabilities else 'General advisory'}
"""
    return base


async def chat_with_agent(
    db: Session,
    agent: Agent,
    conversation_id: str,
    user_message: str,
    user_name: str,
    company_name: str,
    integration_context: Optional[dict] = None,
) -> str:
    """Send a message to an agent and get a response"""
    conversation = db.query(Conversation).filter(Conversation.id == conversation_id).first()
    if not conversation:
        return "Conversation not found"

    # Build message history
    history = []
    for msg in conversation.messages[-20:]:  # Last 20 messages for context
        history.append({"role": msg.role, "content": msg.content})

    # Add context from integrations if available
    context_addition = ""
    if integration_context:
        context_addition = f"\n\nCurrent context data:\n{integration_context}"

    # Add user message to db
    user_msg = Message(
        conversation_id=conversation_id,
        role="user",
        content=user_message,
    )
    db.add(user_msg)
    db.commit()

    system_prompt = build_system_prompt(agent, user_name, company_name)
    messages = [{"role": "system", "content": system_prompt}] + history + [{"role": "user", "content": user_message + context_addition}]

    try:
        response = await client.chat.completions.create(
            model=settings.DEEPSEEK_MODEL,
            max_tokens=1024,
            messages=messages,
        )
        assistant_content = response.choices[0].message.content or ""
    except Exception as e:
        assistant_content = f"I apologize, I'm having trouble connecting right now. Error: {str(e)}"

    # Save assistant response
    assistant_msg = Message(
        conversation_id=conversation_id,
        role="assistant",
        content=assistant_content,
    )
    db.add(assistant_msg)
    db.commit()

    return assistant_content


async def stream_chat_with_agent(
    db: Session,
    agent: Agent,
    conversation_id: str,
    user_message: str,
    user_name: str,
    company_name: str,
) -> AsyncIterator[str]:
    """Stream a response from an agent"""
    conversation = db.query(Conversation).filter(Conversation.id == conversation_id).first()
    if not conversation:
        yield "Conversation not found"
        return

    history = []
    for msg in conversation.messages[-20:]:
        history.append({"role": msg.role, "content": msg.content})

    user_msg = Message(
        conversation_id=conversation_id,
        role="user",
        content=user_message,
    )
    db.add(user_msg)
    db.commit()

    system_prompt = build_system_prompt(agent, user_name, company_name)
    messages = [{"role": "system", "content": system_prompt}] + history + [{"role": "user", "content": user_message}]

    full_response = ""
    try:
        stream = await client.chat.completions.create(
            model=settings.DEEPSEEK_MODEL,
            max_tokens=1024,
            messages=messages,
            stream=True,
        )
        async for chunk in stream:
            text = chunk.choices[0].delta.content or ""
            if text:
                full_response += text
                yield text
    except Exception as e:
        error_msg = f"Connection error: {str(e)}"
        full_response = error_msg
        yield error_msg

    # Save full response
    assistant_msg = Message(
        conversation_id=conversation_id,
        role="assistant",
        content=full_response,
    )
    db.add(assistant_msg)
    db.commit()


def create_or_get_conversation(db: Session, user_id: str, agent_id: str) -> Conversation:
    """Get latest conversation or create a new one"""
    conv = (
        db.query(Conversation)
        .filter(Conversation.user_id == user_id, Conversation.agent_id == agent_id)
        .order_by(Conversation.created_at.desc())
        .first()
    )
    if not conv:
        conv = Conversation(
            user_id=user_id,
            agent_id=agent_id,
            title="New Conversation",
        )
        db.add(conv)
        db.commit()
        db.refresh(conv)
    return conv
