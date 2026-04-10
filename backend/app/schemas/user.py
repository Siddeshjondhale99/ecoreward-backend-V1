from pydantic import BaseModel, EmailStr
from typing import Optional

class UserBase(BaseModel):
    name: str
    email: EmailStr
    rfid_id: str

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: int
    points: int
    role: str

    class Config:
        from_attributes = True

class UserUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[EmailStr] = None
    rfid_id: Optional[str] = None
    points: Optional[int] = None
