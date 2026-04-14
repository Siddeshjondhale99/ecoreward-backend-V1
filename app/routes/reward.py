from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import get_db
from ..schemas.waste import Reward as RewardSchema, RedeemedVoucher as VoucherSchema
from ..models.user import User
from ..models.waste import WasteRecord, Reward, RedeemedVoucher
from ..services import waste_service
from .user import get_current_user
from sqlalchemy import func

router = APIRouter(tags=["Rewards"])

@router.get("/rewards", response_model=list[RewardSchema])
def get_rewards(db: Session = Depends(get_db)):
    return waste_service.get_rewards(db)

@router.post("/redeem/{reward_id}", response_model=VoucherSchema)
def redeem_reward(reward_id: int, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    voucher, error = waste_service.redeem_reward(db, current_user, reward_id)
    if error:
        raise HTTPException(status_code=400, detail=error)
    return voucher

@router.post("/redeem-custom", response_model=VoucherSchema)
def redeem_custom(points: int, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    voucher, error = waste_service.redeem_custom_points(db, current_user, points)
    if error:
        raise HTTPException(status_code=400, detail=error)
    return voucher

# Admin Routes
admin_router = APIRouter(tags=["Admin Control"])

def check_admin_role(current_user: User = Depends(get_current_user)):
    if current_user.role != "admin":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not an admin")
    return current_user

@admin_router.get("/admin/dashboard")
def get_admin_dashboard(admin: User = Depends(check_admin_role), db: Session = Depends(get_db)):
    total_users = db.query(User).count()
    total_waste = db.query(func.sum(WasteRecord.weight)).scalar() or 0
    total_points = db.query(func.sum(User.points)).scalar() or 0
    
    return {
        "total_users": total_users,
        "total_waste_kg": total_waste,
        "total_points_in_circulation": total_points
    }

@admin_router.get("/admin/analytics")
def get_analytics(admin: User = Depends(check_admin_role), db: Session = Depends(get_db)):
    # Group by waste type
    waste_by_type = db.query(
        WasteRecord.waste_type, 
        func.sum(WasteRecord.weight).label("total_weight")
    ).group_by(WasteRecord.waste_type).all()
    
    # Leaderboard
    leaderboard = db.query(User.name, User.points).order_by(User.points.desc()).limit(10).all()
    
    return {
        "waste_distribution": {item[0]: item[1] for item in waste_by_type},
        "leaderboard": [{"name": item[0], "points": item[1]} for item in leaderboard]
    }
