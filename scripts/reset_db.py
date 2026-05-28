import sys
import os

# Add ecoreward project root to python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from dotenv import load_dotenv
load_dotenv()

from sqlalchemy import create_engine, text
from app.database import Base, SessionLocal
from app.config import settings

# Import models to register them with metadata
from app.models.user import User
from app.models.waste import WasteRecord, Reward, RedeemedVoucher
from app.models.iot import BinState
from app.utils.security import get_password_hash

def reset_and_seed():
    db_url = settings.DATABASE_URL
    print(f"Connecting to database to reset: {db_url}")
    engine = create_engine(db_url)
    
    # 1. Drop all tables
    print("Dropping all existing tables...")
    try:
        # Using CASCADE to handle foreign key constraints cleanly
        with engine.connect() as conn:
            conn.execute(text("DROP TABLE IF EXISTS waste_records, redeemed_vouchers, rewards, bin_states, users CASCADE;"))
            conn.commit()
        print("Tables dropped successfully.")
    except Exception as e:
        print(f"Error dropping tables: {e}")
        # Fallback to metadata drop
        Base.metadata.drop_all(bind=engine)
        print("Fallback metadata drop complete.")

    # 2. Re-create all tables
    print("Re-creating all tables...")
    Base.metadata.create_all(bind=engine)
    print("Tables re-created successfully.")

    # 3. Seed default data
    print("Seeding initial data...")
    db = SessionLocal()
    try:
        # Create default Admin
        admin_user = User(
            name="System Admin",
            email="admin@ecoreward.com",
            hashed_password=get_password_hash("AdminPassword123"),
            rfid_id="RFID_ADMIN_01",
            points=1000,
            role="admin"
        )
        db.add(admin_user)

        # Create default User
        test_user = User(
            name="John Doe",
            email="user@ecoreward.com",
            hashed_password=get_password_hash("UserPassword123"),
            rfid_id="RFID_USER_01",
            points=500,
            role="user"
        )
        db.add(test_user)

        # Create default rewards
        rewards = [
            Reward(name="Property Tax Rebate Voucher - Rs. 100", points_required=1000),
            Reward(name="Property Tax Rebate Voucher - Rs. 500", points_required=5000),
            Reward(name="Electricity Bill Discount - Rs. 50", points_required=500),
            Reward(name="Electricity Bill Discount - Rs. 200", points_required=2000),
            Reward(name="Water Tax/Bill Discount - Rs. 50", points_required=500),
            Reward(name="Water Tax/Bill Discount - Rs. 150", points_required=1500),
        ]
        for r in rewards:
            db.add(r)

        # Create default BinState
        bin_state = BinState(
            device_id="BIN_001",
            status="idle"
        )
        db.add(bin_state)

        db.commit()
        print("Seeding completed successfully!")
        
        # Verify
        print(f"Total Users: {db.query(User).count()}")
        print(f"Total Rewards: {db.query(Reward).count()}")
        print(f"BinState Status: {db.query(BinState).first().status}")
        
    except Exception as e:
        db.rollback()
        print(f"Error seeding data: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    reset_and_seed()
