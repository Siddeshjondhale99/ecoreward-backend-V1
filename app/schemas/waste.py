from pydantic import BaseModel
from typing import Optional
from datetime import datetime

# Waste Records
class WasteCreate(BaseModel):
    rfid_id: str
    weight: float
    waste_type: str
    moisture: Optional[float] = None
    ai_confidence: Optional[float] = None

class WasteRecord(BaseModel):
    id: int
    user_id: int
    weight: float
    waste_type: str
    points_earned: int
    timestamp: datetime

    class Config:
        from_attributes = True

# Reward & Redemption
class RewardBase(BaseModel):
    name: str
    points_required: int

class RewardCreate(RewardBase):
    pass

class Reward(RewardBase):
    id: int

    class Config:
        from_attributes = True

class RedeemedVoucher(BaseModel):
    id: int
    user_id: int
    reward_id: int
    voucher_code: str
    timestamp: datetime

    class Config:
        from_attributes = True
class CustomRedeemRequest(BaseModel):
    points: int

    class Config:
        from_attributes = True
