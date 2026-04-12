import requests
import time
from typing import Dict, Optional
from ..config import settings

def check_health() -> Dict[str, any]:
    """
    Checks the health of the AI model service.
    Recommended by the technical spec to be called before serving traffic.
    """
    url = f"{settings.AI_SERVICE_URL}/health"
    try:
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            return response.json()
        return {"status": "unhealthy", "code": response.status_code}
    except Exception as e:
        return {"status": "error", "message": str(e)}

def classify_waste(file_contents: bytes, max_retries: int = 3) -> Dict[str, any]:
    """
    Classifies waste image by calling the Railway AI microservice.
    Handles multipart/form-data upload, error codes, and transient retries.
    """
    url = f"{settings.AI_SERVICE_URL}/predict"
    
    # Files dictionary for multipart/form-data
    files = {"file": ("image.jpg", file_contents, "image/jpeg")}
    
    attempt = 0
    while attempt < max_retries:
        try:
            response = requests.post(url, files=files, timeout=25)
            
            # 1. Success
            if response.status_code == 200:
                result = response.json()
                # Expected keys: predicted_index, predicted_label, confidence, prediction
                return {
                    "label": result.get("predicted_label", "unknown"),
                    "confidence": result.get("confidence", 0.0),
                    "index": result.get("predicted_index", -1),
                    "raw": result
                }
            
            # 2. Client Issues (400, 422) - Do not retry
            elif response.status_code in [400, 422]:
                error_msg = response.json().get("error", "Bad Request")
                return {
                    "label": "error",
                    "confidence": 0.0,
                    "message": f"Client error: {error_msg}"
                }
            
            # 3. Service Unavailable (503) - Circuit breaker path
            elif response.status_code == 503:
                return {
                    "label": "error",
                    "confidence": 0.0,
                    "message": "Model service not loaded (503)"
                }
            
            # 4. Transient 5xx errors - Retry with backoff
            elif response.status_code >= 500:
                attempt += 1
                if attempt < max_retries:
                    time.sleep(2 ** attempt) # Exponential backoff
                    continue
                return {
                    "label": "error",
                    "confidence": 0.0,
                    "message": f"Server error after retries: {response.status_code}"
                }
            
            else:
                return {
                    "label": "error",
                    "confidence": 0.0,
                    "message": f"Unexpected error: {response.status_code}"
                }

        except requests.exceptions.Timeout:
            attempt += 1
            if attempt < max_retries:
                time.sleep(1)
                continue
            return {"label": "error", "confidence": 0.0, "message": "Request timed out"}
        except Exception as e:
            return {"label": "error", "confidence": 0.0, "message": str(e)}
    
    return {"label": "error", "confidence": 0.0, "message": "Max retries exceeded"}

def call_ai_service(file):
    """
    Main entry point for waste classification.
    """
    return classify_waste(file.read())
