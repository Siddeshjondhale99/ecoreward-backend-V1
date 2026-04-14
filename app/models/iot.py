from sqlalchemy import Column, String, Integer, DateTime, Float
from datetime import datetime
from ..database import Base

class BinState(Base):
    __tablename__ = "bin_states"

    id = Column(Integer, primary_key=True, index=True)
    device_id = Column(String, unique=True, index=True, default="BIN_001")
    status = Column(String, default="idle") # "idle", "allowed", "denied"
    last_updated = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    last_user_id = Column(Integer, nullable=True)
    last_waste_type = Column(String, nullable=True)
    last_ai_confidence = Column(Float, nullable=True)
