from fastapi import FastAPI
from app.routes import ocr_route

app = FastAPI(
    title="AI Study Companion API",
    version="1.0.0"
)

app.include_router(ocr_route.router)

@app.get("/")
def root():
    return {"message": "AI Study Companion Backend is running 🚀"}
