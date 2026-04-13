from sqlalchemy.orm import Session
from ..models.user import User
from ..schemas.user import UserCreate
from ..utils.security import get_password_hash, verify_password

def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()

def get_user_by_rfid(db: Session, rfid_id: str):
    return db.query(User).filter(User.rfid_id == rfid_id).first()

def create_user(db: Session, user: UserCreate, role: str = "user"):
    hashed_password = get_password_hash(user.password)
    db_user = User(
        name=user.name,
        email=user.email,
        hashed_password=hashed_password,
        rfid_id=user.rfid_id,
        role=role
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def authenticate_user(db: Session, email: str, password: str):
    user = get_user_by_email(db, email)
    if not user:
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user
