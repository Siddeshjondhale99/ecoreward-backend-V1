import io
import os
import numpy as np
import tensorflow as tf
from PIL import Image
from tensorflow.keras.applications import efficientnet
from typing import Dict

# Global model variable for lazy loading
_model = None
_class_names = ["Dry", "Wet", "Recyclable", "Hazardous"]
_image_size = 224
_model_path = os.path.abspath(os.path.join(
    os.path.dirname(__file__), "..", "ml_models", "best_model.keras"
))

def _load_model():
    """Lazy load the AI model to save memory during startup."""
    global _model
    if _model is None:
        if not os.path.exists(_model_path):
            print(f"WARNING: Model not found at {_model_path}")
            return
        try:
            _model = tf.keras.models.load_model(_model_path)
            print(f"AI Model loaded successfully from {_model_path}")
        except Exception as e:
            print(f"ERROR: Failed to load model: {e}")

def classify_waste(image_bytes: bytes) -> Dict[str, any]:
    """Classifies waste image using the pre-trained EfficientNetB0 model."""
    _load_model()
    
    if _model is None:
        return {
            "label": "error",
            "confidence": 0.0,
            "message": "Model not loaded"
        }
    
    try:
        # 1. Preprocess image
        image = Image.open(io.BytesIO(image_bytes))
        image = image.convert("RGB")
        image = image.resize((_image_size, _image_size))
        
        # 2. Convert to efficient format
        arr = np.asarray(image).astype("float32")
        arr = efficientnet.preprocess_input(arr)
        input_tensor = np.expand_dims(arr, axis=0)
        
        # 3. Model Prediction
        probs = _model.predict(input_tensor, verbose=0)[0]
        confidence = float(np.max(probs))
        pred_idx = int(np.argmax(probs))
        label = _class_names[pred_idx]
        
        return {
            "label": label.lower(),
            "confidence": round(confidence, 2)
        }
    except Exception as e:
        return {
            "label": "error",
            "confidence": 0.0,
            "message": f"Inference error: {str(e)}"
        }
