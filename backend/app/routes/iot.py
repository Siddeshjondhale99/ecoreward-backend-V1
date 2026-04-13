from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import get_db
from ..models.iot import BinState
from ..models.user import User
from ..schemas.iot import QRVerification, DeviceStatus, VerificationResponse
from datetime import datetime

router = APIRouter(prefix="/iot", tags=["IoT & Hardware"])

@router.post("/verify-user", response_model=VerificationResponse)
def verify_user(data: QRVerification, db: Session = Depends(get_db)):
    """
    Called by the Mobile App when a QR code is scanned.
    qr_data can be user email or a specific user ID.
    """
    # Check if user exists (by email or rfid_id)
    user = db.query(User).filter(
        (User.email == data.qr_data) | (User.rfid_id == data.qr_data)
    ).first()

    if not user:
        # For prototype purposes, we could also allow custom mock IDs
        if data.qr_data == "USER_123":
            pass # Special mock case allowed
        else:
            # Set bin to denied
            bin_state = db.query(BinState).filter(BinState.device_id == "BIN_001").first()
            if bin_state:
                bin_state.status = "denied"
                db.commit()
            raise HTTPException(status_code=404, detail="User not verified")

    # Set bin status to 'allowed'
    bin_state = db.query(BinState).filter(BinState.device_id == "BIN_001").first()
    if not bin_state:
        # Auto-create if not exists
        bin_state = BinState(device_id="BIN_001", status="allowed", last_user_id=user.id if user else None)
        db.add(bin_state)
    else:
        bin_state.status = "allowed"
        bin_state.last_user_id = user.id if user else None
        bin_state.last_updated = datetime.utcnow()
    
    db.commit()
    return {"status": "verified", "message": f"Welcome {user.name if user else 'Guest'}! Bin is opening."}

@router.get("/device-status", response_model=DeviceStatus)
def get_device_status(device_id: str = "BIN_001", db: Session = Depends(get_db)):
    """
    Called by ESP32 poller every 2-3 seconds.
    Resets status to 'idle' after successful read.
    """
    bin_state = db.query(BinState).filter(BinState.device_id == device_id).first()
    
    if not bin_state:
        # Default if not initialized
        return {"status": "idle", "device_id": device_id}

    current_status = bin_state.status
    
    # Auto-reset if it was in a triggered state
    if current_status in ["allowed", "denied"]:
        bin_state.status = "idle"
        db.commit()
    
    return {"status": current_status, "device_id": device_id}

@router.post("/reset-device")
def reset_device(device_id: str = "BIN_001", db: Session = Depends(get_db)):
    """
    Manual override to reset bin to idle.
    """
    bin_state = db.query(BinState).filter(BinState.device_id == device_id).first()
    if bin_state:
        bin_state.status = "idle"
        db.commit()
    return {"message": "Device reset successful"}
