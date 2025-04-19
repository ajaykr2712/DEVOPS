"""Authentication module for AIRAG Security Model API."""
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from typing import Optional
import os

# In production, use a secure user store and hashed passwords
USERS = {
    "admin": "adminpassword",
    "user": "userpassword"
}

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/token")

def fake_decode_token(token: str) -> Optional[str]:
    # In production, decode JWT or similar
    if token in USERS:
        return token
    return None

def get_current_user(token: str = Depends(oauth2_scheme)):
    user = fake_decode_token(token)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user