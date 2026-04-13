from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.sql import func
from ..database import Base

class WasteRecord(Base):
    __tablename__ = "waste_records"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    weight = Column(Float, nullable=False)
    waste_type = Column(String, nullable=False) # plastic, dry, wet
    moisture = Column(Float, nullable=True) # moisture sensor reading
    ai_confidence = Column(Float, nullable=True) # AI identification confidence
    points_earned = Column(Integer, nullable=False)
    timestamp = Column(DateTime(timezone=True), server_default=func.now())

class Reward(Base):
    __tablename__ = "rewards"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    points_required = Column(Integer, nullable=False)

class RedeemedVoucher(Base):
    __tablename__ = "redeemed_vouchers"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    reward_id = Column(Integer, ForeignKey("rewards.id"))
    voucher_code = Column(String, nullable=False, unique=True)
    timestamp = Column(DateTime(timezone=True), server_default=func.now())
