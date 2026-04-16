from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime
from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.models.integration import Integration
from app.core.config import settings

router = APIRouter(prefix="/integrations", tags=["integrations"])

SUPPORTED_INTEGRATIONS = {
    "plaid": {
        "name": "Plaid",
        "description": "Connect your bank accounts for financial insights",
        "icon": "🏦",
        "category": "finance",
        "agent_roles": ["cfo"],
        "scopes": ["transactions", "balances", "accounts"],
    },
    "google_calendar": {
        "name": "Google Calendar",
        "description": "Sync your calendar for scheduling and planning",
        "icon": "📅",
        "category": "productivity",
        "agent_roles": ["ea"],
        "scopes": ["calendar.readonly", "calendar.events"],
    },
    "github": {
        "name": "GitHub",
        "description": "Connect your repos for tech oversight",
        "icon": "💻",
        "category": "tech",
        "agent_roles": ["cto"],
        "scopes": ["repo", "user"],
    },
    "notion": {
        "name": "Notion",
        "description": "Connect your workspace for knowledge management",
        "icon": "📝",
        "category": "productivity",
        "agent_roles": ["cto", "ea"],
        "scopes": ["read_content", "update_content"],
    },
    "slack": {
        "name": "Slack",
        "description": "Connect Slack for team communications",
        "icon": "💬",
        "category": "communication",
        "agent_roles": ["ea", "cmo"],
        "scopes": ["channels:read", "chat:write"],
    },
    "stripe": {
        "name": "Stripe",
        "description": "Connect payment processing for revenue tracking",
        "icon": "💳",
        "category": "finance",
        "agent_roles": ["cfo"],
        "scopes": ["read_only"],
    },
    "linear": {
        "name": "Linear",
        "description": "Connect project tracking",
        "icon": "📋",
        "category": "tech",
        "agent_roles": ["cto", "coo"],
        "scopes": ["read", "write"],
    },
    "gmail": {
        "name": "Gmail",
        "description": "Connect email for communication management",
        "icon": "📧",
        "category": "communication",
        "agent_roles": ["ea"],
        "scopes": ["gmail.readonly"],
    },
}


class IntegrationResponse(BaseModel):
    id: str
    provider: str
    display_name: Optional[str]
    status: str
    extra_data: dict
    connected_at: Optional[str]

    class Config:
        from_attributes = True


@router.get("/available")
def get_available_integrations():
    return SUPPORTED_INTEGRATIONS


@router.get("/", response_model=List[IntegrationResponse])
def list_integrations(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    integrations = db.query(Integration).filter(Integration.user_id == current_user.id).all()
    return [
        IntegrationResponse(
            id=i.id,
            provider=i.provider,
            display_name=i.display_name,
            status=i.status,
            extra_data=i.extra_data or {},
            connected_at=i.connected_at.isoformat() if i.connected_at else None,
        )
        for i in integrations
    ]


@router.post("/{provider}/connect")
async def connect_integration(
    provider: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if provider not in SUPPORTED_INTEGRATIONS:
        raise HTTPException(status_code=400, detail=f"Unsupported integration: {provider}")

    # Check if already exists
    existing = db.query(Integration).filter(
        Integration.user_id == current_user.id,
        Integration.provider == provider,
    ).first()

    if provider == "plaid":
        # Return Plaid link token creation endpoint
        return {
            "action": "oauth",
            "message": "Plaid integration requires bank connection via Plaid Link",
            "setup_url": f"/api/v1/integrations/plaid/link-token",
            "provider": provider,
        }
    elif provider == "google_calendar":
        auth_url = (
            f"https://accounts.google.com/o/oauth2/v2/auth?"
            f"client_id={settings.GOOGLE_CLIENT_ID or 'YOUR_CLIENT_ID'}"
            f"&redirect_uri={settings.GOOGLE_REDIRECT_URI}"
            f"&response_type=code"
            f"&scope=https://www.googleapis.com/auth/calendar.readonly"
            f"&access_type=offline"
        )
        return {"action": "oauth", "auth_url": auth_url, "provider": provider}
    else:
        # For demo: simulate connection
        if existing:
            existing.status = "connected"
            existing.connected_at = datetime.utcnow()
            existing.extra_data = {"demo": True, "note": "Demo connection - configure API keys"}
        else:
            integration = Integration(
                user_id=current_user.id,
                provider=provider,
                display_name=SUPPORTED_INTEGRATIONS[provider]["name"],
                status="connected",
                connected_at=datetime.utcnow(),
                extra_data={"demo": True, "note": "Demo connection - configure API keys"},
            )
            db.add(integration)
        db.commit()
        return {"status": "connected", "provider": provider, "demo": True}


@router.post("/{provider}/disconnect")
def disconnect_integration(
    provider: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    integration = db.query(Integration).filter(
        Integration.user_id == current_user.id,
        Integration.provider == provider,
    ).first()
    if integration:
        integration.status = "disconnected"
        integration.credentials = {}
        db.commit()
    return {"status": "disconnected", "provider": provider}


@router.get("/plaid/link-token")
async def create_plaid_link_token(
    current_user: User = Depends(get_current_user),
):
    """Create a Plaid link token for the frontend to initialize Plaid Link"""
    if not settings.PLAID_CLIENT_ID:
        return {
            "demo_mode": True,
            "message": "Plaid not configured. Add PLAID_CLIENT_ID and PLAID_SECRET to .env",
        }
    # Real Plaid implementation would go here
    return {"link_token": "demo_token"}


@router.post("/google/callback")
async def google_oauth_callback(
    code: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Handle Google OAuth callback"""
    # In production, exchange code for tokens
    integration = db.query(Integration).filter(
        Integration.user_id == current_user.id,
        Integration.provider == "google_calendar",
    ).first()
    if not integration:
        integration = Integration(
            user_id=current_user.id,
            provider="google_calendar",
            display_name="Google Calendar",
            status="connected",
            connected_at=datetime.utcnow(),
            credentials={"code": code},
        )
        db.add(integration)
    else:
        integration.status = "connected"
        integration.credentials = {"code": code}
    db.commit()
    return {"status": "connected"}
