import os
import sys

# Add the backend folder to the search path
sys.path.append(os.path.join(os.path.dirname(__file__), "backend"))

# Import the app from the backend folder
from backend.app.main import app

if __name__ == "__main__":
    import uvicorn
    # Bind to the PORT provided by the cloud platform
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
