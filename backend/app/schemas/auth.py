from pydantic import BaseModel
from typing import Optional
from datetime import datetime

# Auth
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None
    role: Optional[str] = None

class Login(BaseModel):
    username: str # Assuming email
    password: str


