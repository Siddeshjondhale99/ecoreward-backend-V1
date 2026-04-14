from sqlalchemy.orm import Session
from ..models.waste import WasteRecord, Reward, RedeemedVoucher
from ..models.user import User
from ..config import settings
import random
import string

def calculate_points(weight: float, waste_type: str, moisture: float = 0.0, confidence: float = 1.0) -> int:
    base_multiplier = 0
    if waste_type == "recyclable":
        base_multiplier = settings.POINTS_RECYCLABLE
    elif waste_type == "plastic":
        base_multiplier = settings.POINTS_PLASTIC
    elif waste_type == "dry":
        base_multiplier = settings.POINTS_DRY
    elif waste_type == "wet":
        base_multiplier = settings.POINTS_WET
    elif waste_type == "hazardous":
        base_multiplier = settings.POINTS_HAZARDOUS
    
    # AI-Based Reward Logic: If weight or moisture is zero, use confidence-based points
    if weight == 0 or moisture == 0:
        return int(confidence * 50)
    
    points = int(weight * base_multiplier)
    
    # Bonuses
    # 1. Moisture Bonus
    if waste_type == "wet" and moisture > 0.6:
        points += 10 # Bonus for accurately identifying high-moisture wet waste
    elif waste_type == "dry" and moisture < 0.2:
        points += 5 # Bonus for clean dry waste
        
    # 2. AI Confidence Bonus
    if confidence > 0.85:
        points += 5
        
    return points

def create_waste_submission(db: Session, user: User, weight: float, waste_type: str, moisture: float = 0.0, confidence: float = 1.0):
    points = calculate_points(weight, waste_type, moisture, confidence)
    
    # Update user points
    user.points += points
    db.add(user)
    
    # Create record
    db_record = WasteRecord(
        user_id=user.id,
        weight=weight,
        waste_type=waste_type,
        moisture=moisture,
        ai_confidence=confidence,
        points_earned=points
    )
    db.add(db_record)
    db.commit()
    db.refresh(db_record)
    return db_record

def get_rewards(db: Session):
    return db.query(Reward).all()

def create_reward(db: Session, name: str, points: int):
    db_reward = Reward(name=name, points_required=points)
    db.add(db_reward)
    db.commit()
    db.refresh(db_reward)
    return db_reward

def generate_voucher_code(length=8):
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=length))

def redeem_reward(db: Session, user: User, reward_id: int):
    reward = db.query(Reward).filter(Reward.id == reward_id).first()
    if not reward:
        return None, "Reward not found"
    
    if user.points < reward.points_required:
        return None, "Insufficient points"
        
    # Deduct points
    user.points -= reward.points_required
    db.add(user)
    
    # Generate voucher
    voucher_code = generate_voucher_code()
    db_voucher = RedeemedVoucher(
        user_id=user.id,
        reward_id=reward.id,
        voucher_code=voucher_code
    )
    db.add(db_voucher)
    db.commit()
    db.refresh(db_voucher)
    return db_voucher, None

def redeem_custom_points(db: Session, user: User, points: int):
    if points < 100:
        return None, "Minimum 100 points required to generate a voucher"
    
    if user.points < points:
        return None, "Insufficient points"
        
    # Deduct points
    user.points -= points
    db.add(user)
    
    # Generate voucher
    voucher_code = generate_voucher_code()
    # For custom redemptions, we don't link to a specific reward ID (or use a placeholder)
    db_voucher = RedeemedVoucher(
        user_id=user.id,
        reward_id=None, # Indicates custom voucher
        voucher_code=voucher_code
    )
    db.add(db_voucher)
    db.commit()
    db.refresh(db_voucher)
    return db_voucher, None
