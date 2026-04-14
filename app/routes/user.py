from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session
from ..database import get_db
from ..schemas.user import User as UserSchema
from ..schemas.waste import WasteCreate, WasteRecord as WasteRecordSchema
from ..models.user import User
from ..models.waste import WasteRecord
from ..services import auth_service, waste_service, vision_service
from ..config import settings
from fastapi import UploadFile, File
import base64

router = APIRouter(tags=["User Features"])
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    user = auth_service.get_user_by_email(db, email=email)
    if user is None:
        raise credentials_exception
    return user

@router.get("/user/profile", response_model=UserSchema)
def get_user_profile(current_user: User = Depends(get_current_user)):
    return current_user

@router.get("/user/history", response_model=list[WasteRecordSchema])
def get_user_history(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return db.query(WasteRecord).filter(WasteRecord.user_id == current_user.id).all()

@router.post("/classify-waste")
async def classify_waste(file: UploadFile = File(...), device_id: Optional[str] = None, db: Session = Depends(get_db)):
    contents = await file.read()
    result = vision_service.classify_waste(contents)
    
    if device_id:
        from ..models.iot import BinState
        bin_state = db.query(BinState).filter(BinState.device_id == device_id).first()
        if bin_state:
            bin_state.last_waste_type = result.get("label")
            bin_state.last_ai_confidence = result.get("confidence")
            db.commit()
            
    return result

# Waste Routes
waste_router = APIRouter(tags=["Waste Submission"])

@waste_router.post("/submit-waste", response_model=WasteRecordSchema)
def submit_waste(waste: WasteCreate, db: Session = Depends(get_db)):
    user = auth_service.get_user_by_rfid(db, rfid_id=waste.rfid_id)
    if not user:
        raise HTTPException(status_code=404, detail="User with this RFID not found")
    
    return waste_service.create_waste_submission(
        db=db, 
        user=user, 
        weight=waste.weight, 
        waste_type=waste.waste_type,
        moisture=waste.moisture or 0.0,
        confidence=waste.ai_confidence or 1.0
    )
