from pydantic import BaseModel, EmailStr
from typing import Optional

class UserBase(BaseModel):
    name: str
    email: EmailStr
    rfid_id: str
    address: Optional[str] = None
    ward_no: Optional[str] = None
    house_no: Optional[str] = None
    profile_photo: Optional[str] = None
    city: Optional[str] = None
    pincode: Optional[str] = None

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
    address: Optional[str] = None
    ward_no: Optional[str] = None
    house_no: Optional[str] = None
    profile_photo: Optional[str] = None
    city: Optional[str] = None
    pincode: Optional[str] = None
