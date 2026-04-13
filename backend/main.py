import os
import sys

# Ensure the current directory is in the path so 'import app' works
current_dir = os.path.dirname(__file__)
if current_dir not in sys.path:
    sys.path.append(current_dir)

from app.main import app

if __name__ == "__main__":
    import uvicorn
    # Bind to the PORT provided by the cloud platform
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
