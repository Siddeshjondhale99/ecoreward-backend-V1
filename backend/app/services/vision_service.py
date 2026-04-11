# [CACHE_BUSTER] Timestamp: 2026-04-11T12:47:00
# This comment forces a fresh build on Render to eliminate stale localhost:8001 logic.

import requests
import base64
from typing import Dict

def classify_waste(file_contents: bytes) -> Dict[str, any]:
    """Classifies waste image by calling the Hugging Face Space API."""
    # EXPLICIT PUBLIC URL - This hardcoded string overrides any environment variables.
    url = "https://siddesh99-eco-ai-model.hf.space/run/predict"
    
    # DEPLOYMENT VERIFICATION LOG
    # If you see this in your Render logs, the new code is active!
    print(f"[DEPLOYMENT_VERIFY] Calling HF API URL: {url}")
    
    try:
        # Convert image bytes to Base64 string for Gradio API
        encoded_image = base64.b64encode(file_contents).decode("utf-8")
        
        # Prepare the payload for the Gradio endpoint
        payload = {
            "data": [f"data:image/jpeg;base64,{encoded_image}"]
        }
        
        # Call the HF service
        response = requests.post(url, json=payload, timeout=20)
        
        # Debug logging
        print("HF Response Status:", response.status_code)
        
        if response.status_code == 200:
            result = response.json()
            print("HF Response Data:", result)
            
            # Extract prediction string from Gradio response data array
            prediction_data = result.get("data", ["unknown"])[0]
            
            return {
                "label": prediction_data,
                "confidence": 1.0,
                "raw": result
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
            "message": str(e)
        }

def call_ai_service(file):
    """
    Requested bridge function to maintain compatibility 
    with the user's provided snippet.
    """
    return classify_waste(file.read())
