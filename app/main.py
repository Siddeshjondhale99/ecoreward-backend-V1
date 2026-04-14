from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from .database import engine, Base, SessionLocal, get_db
from .routes import auth, user, reward, iot
from .models import iot as iot_model # Ensure model is loaded for metadata
from .config import settings

# Create database tables
try:
    Base.metadata.create_all(bind=engine)
    print("Database connected and tables created successfully")
except Exception as e:
    print(f"Database connection failed: {e}")
    print("Application is starting without active DB connection...")

app = FastAPI(
    title=settings.APP_NAME,
    description="Smart Waste Segregation System Backend",
    version="1.0.0"
)

# Maintenance Route: Drops and recreates the bin_states table to fix schema mismatches
from sqlalchemy import text
@app.post("/debug/reset-iot-table")
def reset_iot_table(db: SessionLocal = Depends(get_db)):
    try:
        db.execute(text("DROP TABLE IF EXISTS bin_states CASCADE;"))
        db.commit()
        Base.metadata.create_all(bind=engine)
        return {"message": "bin_states table recreated successfully with latest schema"}
    except Exception as e:
        return {"error": str(e)}

# CORS Middleware for Flutter app integration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(auth.router)
app.include_router(user.router)
app.include_router(user.waste_router)
app.include_router(reward.router)
app.include_router(reward.admin_router)
app.include_router(iot.router)

@app.get("/")
def root():
    return {"message": "Welcome to EcoReward API. Visit /docs for documentation."}
