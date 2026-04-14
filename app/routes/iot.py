from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import get_db
from ..models.iot import BinState
from ..models.user import User
from ..schemas.iot import QRVerification, DeviceStatus, VerificationResponse, WasteMeasurement
from datetime import datetime

router = APIRouter(prefix="/iot", tags=["IoT & Hardware"])

@router.post("/verify-user", response_model=VerificationResponse)
def verify_user(data: QRVerification, db: Session = Depends(get_db)):
    """
    Called by the Mobile App when a QR code is scanned.
    qr_data can be user email or a specific user ID.
    """
    # Priority 1: Link to the specific user email provided by the app
    user = None
    if data.user_email:
        from ..services import auth_service
        user = auth_service.get_user_by_email(db, email=data.user_email)

    if not user:
        # Priority 2: Check if QR data itself matches an email or rfid_id
        user = db.query(User).filter(
            (User.email == data.qr_data) | (User.rfid_id == data.qr_data)
        ).first()

    if not user:
        # Fallback for prototype testing: use ANY existing user only if the QR data is 'USER_123'
        if data.qr_data == "USER_123":
            # But ONLY if we don't already have one from the app's logged-in status
            user = db.query(User).first()
            if not user:
                raise HTTPException(status_code=404, detail="No users exist in DB to assign session")
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

@router.post("/report-measurements")
def report_measurements(data: WasteMeasurement, db: Session = Depends(get_db)):
    """
    Called by ESP32 after the waste has been dropped and measured.
    Links the weight/moisture to the last user who scanned the bin.
    """
    bin_state = db.query(BinState).filter(BinState.device_id == data.device_id).first()
    
    if not bin_state or not bin_state.last_user_id:
        raise HTTPException(status_code=400, detail="No active user session for this device")

    user = db.query(User).filter(User.id == bin_state.last_user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Create the waste record and award points
    # We use the waste_type from the AI prediction if available, otherwise unknown
    # Note: In a full flow, the App might have already set the 'last_waste_type' in BinState
    from ..services import waste_service
    
    # Use the persisted AI results if available from the app scan
    final_waste_type = bin_state.last_waste_type or data.waste_type or "unknown"
    final_confidence = bin_state.last_ai_confidence or 0.9

    record = waste_service.create_waste_submission(
        db=db,
        user=user,
        weight=data.weight,
        waste_type=final_waste_type,
        moisture=data.moisture,
        confidence=final_confidence
    )

    # Reset session and clear AI history for next user
    bin_state.last_user_id = None
    bin_state.last_waste_type = None
    bin_state.last_ai_confidence = None
    db.commit()

    return {
        "status": "success",
        "points_earned": record.points_earned,
        "new_total": user.points
    }

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
