from fastapi import FastAPI, UploadFile, File
from tensorflow.keras.models import load_model
from PIL import Image
import numpy as np
import io
import os

app = FastAPI()

# Load model relative to this file
_model_path = os.path.join(os.path.dirname(__file__), "model.h5")
model = None

@app.on_event("startup")
def load_ai_model():
    global model
    if os.path.exists(_model_path):
        model = load_model(_model_path, compile=False)
        print("AI Model loaded successfully")
    else:
        print(f"ERROR: Model not found at {_model_path}")

@app.get("/")
def home():
    return {"message": "AI Model Service Running", "model_loaded": model is not None}

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    if model is None:
        return {"error": "Model not loaded"}
    
    # Read image
    contents = await file.read()
    image = Image.open(io.BytesIO(contents)).convert("RGB").resize((224, 224))
    
    # Preprocess (Note: EfficientNet usually handles normalization internally if using preprocess_input, 
    # but the user requested /255.0 manually in their prompt, so I will follow their specific template)
    img_array = np.array(image) / 255.0
    img_array = np.expand_dims(img_array, axis=0)
    
    # Predict
    prediction = model.predict(img_array)
    
    # Convert prediction to labels (assuming the same 4 classes as the main backend)
    class_names = ["dry", "wet", "recyclable", "hazardous"]
    pred_idx = int(np.argmax(prediction[0]))
    confidence = float(np.max(prediction[0]))
    
    return {
        "label": class_names[pred_idx],
        "confidence": round(confidence, 2),
        "raw_prediction": prediction.tolist()
    }
