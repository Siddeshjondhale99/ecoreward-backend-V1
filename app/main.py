from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .database import engine, Base
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

# Debug Middleware: Capture and return full traceback for 500 errors
from fastapi import Request
from fastapi.responses import JSONResponse
import traceback

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal Server Error",
            "detail": str(exc),
            "traceback": traceback.format_exc()
        }
    )

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
