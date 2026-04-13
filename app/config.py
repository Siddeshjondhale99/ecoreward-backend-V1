from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    APP_NAME: str = "EcoReward API"
    SECRET_KEY: str = "YOUR_SUPER_SECRET_KEY_HERE"  # Use openssl rand -hex 32
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days
    DATABASE_URL: str = "postgresql://postgres:postgres@localhost:5432/ecoreward"
    
    # Points Logic
    POINTS_RECYCLABLE: int = 30
    POINTS_PLASTIC: int = 30
    POINTS_DRY: int = 10
    POINTS_WET: int = 5
    POINTS_HAZARDOUS: int = 2
    
    AI_SERVICE_URL: str = "https://web-production-4df6e.up.railway.app"

    class Config:
        env_file = ".env"

settings = Settings()
