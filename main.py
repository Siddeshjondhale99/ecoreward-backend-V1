import os
import sys

# Add the backend folder to the search path
backend_path = os.path.join(os.path.dirname(__file__), "backend")
sys.path.append(backend_path)

# Now we can import 'app' directly as it is now in the search path
from app.main import app

if __name__ == "__main__":
    import uvicorn
    # Bind to the PORT provided by the cloud platform
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
