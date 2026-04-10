from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .database import engine, Base
from .routes import auth, user, reward
from .config import settings

# Create database tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title=settings.APP_NAME,
    description="Smart Waste Segregation System Backend",
    version="1.0.0"
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

@app.get("/")
def root():
    return {"message": "Welcome to EcoReward API. Visit /docs for documentation."}
