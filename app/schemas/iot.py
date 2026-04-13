from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class QRVerification(BaseModel):
    qr_data: str # Can be email or user ID

class DeviceStatus(BaseModel):
    status: str
    device_id: str

class VerificationResponse(BaseModel):
    status: str
    message: Optional[str] = None

class WasteMeasurement(BaseModel):
    device_id: str = "BIN_001"
    weight: float
    moisture: float
    waste_type: Optional[str] = "unknown" # AI might have already set this
