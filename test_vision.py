import os
import sys

# Add the app directory to sys.path
sys.path.append(os.path.join(os.path.dirname(__file__), "app"))

try:
    from app.services.vision_service import vision_service
    import io
    from PIL import Image
    import numpy as np
    
    print("Testing VisionService initialization...")
    # This will trigger model loading
    vision_service._load_model()
    
    if vision_service.model is None:
        print("Error: Model could not be loaded. Check if best_model.keras exists in backend/app/ml_models/")
        sys.exit(1)
        
    print("Model loaded successfully.")
    
    # Create a dummy image for testing
    print("Creating dummy image for inference test...")
    dummy_img = Image.new('RGB', (224, 224), color = (73, 109, 137))
    img_byte_arr = io.BytesIO()
    dummy_img.save(img_byte_arr, format='JPEG')
    img_bytes = img_byte_arr.getvalue()
    
    print("Running inference...")
    result = vision_service.classify_waste(img_bytes)
    print(f"Result: {result}")
    
    if "label" in result and result["label"] != "error":
        print("SUCCESS: Vision service is working correctly!")
    else:
        print(f"FAILURE: Vision service returned an error: {result.get('message', 'Unknown error')}")

except ImportError as e:
    print(f"Import Error: {e}")
    print("Make sure you have installed the requirements: pip install -r requirements.txt")
except Exception as e:
    print(f"An unexpected error occurred: {e}")
