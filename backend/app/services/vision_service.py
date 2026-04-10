import os
import requests
from typing import Dict

# The URL of the AI microservice
# On Render, set this environment variable: AI_SERVICE_URL
AI_SERVICE_URL = os.getenv("AI_SERVICE_URL", "http://localhost:8001")

def classify_waste(image_bytes: bytes) -> Dict[str, any]:
    """Classifies waste image by calling the dedicated AI microservice."""
    try:
        # Prepare the file for the POST request
        files = {"file": ("image.jpg", image_bytes, "image/jpeg")}
        
        # Call the AI service
        response = requests.post(
            f"{AI_SERVICE_URL}/predict",
            files=files,
            timeout=15  # Reasonable timeout for inference
        )
        
        if response.status_code == 200:
            result = response.json()
            return {
                "label": result.get("label", "error"),
                "confidence": result.get("confidence", 0.0)
            }
        else:
            return {
                "label": "error",
                "confidence": 0.0,
                "message": f"AI service error: {response.status_code}"
            }
            
    except Exception as e:
        print(f"Connection to AI service failed: {e}")
        return {
            "label": "error",
            "confidence": 0.0,
            "message": "AI service unavailable"
        }
