from sqlalchemy import Column, Integer, String
from ..database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    rfid_id = Column(String, unique=True, index=True, nullable=False)
    points = Column(Integer, default=0)
    role = Column(String, default="user") # "admin" or "user"
