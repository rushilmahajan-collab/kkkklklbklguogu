from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.services.auth_service import UserCreate, UserLogin, UserResponse, create_user, login_user, get_user_by_email
from app.services.agent_service import seed_default_agents
from app.api.deps import get_current_user
from app.models.user import User
from pydantic import BaseModel
from typing import Optional

router = APIRouter(prefix="/auth", tags=["auth"])


class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    user: UserResponse


class UpdateProfile(BaseModel):
    full_name: Optional[str] = None
    company_name: Optional[str] = None
    avatar_url: Optional[str] = None


@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
def register(user_data: UserCreate, db: Session = Depends(get_db)):
    existing = get_user_by_email(db, user_data.email)
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")
    user = create_user(db, user_data)
    # Seed default agents for new users
    seed_default_agents(db, user.id)
    result = login_user(db, UserLogin(email=user_data.email, password=user_data.password))
    return TokenResponse(
        access_token=result["access_token"],
        token_type="bearer",
        user=UserResponse.model_validate(user),
    )


@router.post("/login", response_model=TokenResponse)
def login(login_data: UserLogin, db: Session = Depends(get_db)):
    result = login_user(db, login_data)
    if not result:
        raise HTTPException(status_code=401, detail="Invalid email or password")
    return TokenResponse(
        access_token=result["access_token"],
        token_type="bearer",
        user=UserResponse.model_validate(result["user"]),
    )


@router.get("/me", response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)):
    return UserResponse.model_validate(current_user)


@router.patch("/me", response_model=UserResponse)
def update_profile(
    data: UpdateProfile,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    for field, value in data.model_dump(exclude_none=True).items():
        setattr(current_user, field, value)
    db.commit()
    db.refresh(current_user)
    return UserResponse.model_validate(current_user)
