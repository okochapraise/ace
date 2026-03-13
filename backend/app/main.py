from fastapi import FastAPI
from app.routes import ocr_route, summarize_route, flashcard_route
from app.routes import mood_route
from app.routes import studyplanner_route
from database.database import engine, Base
from app.models.user_model import User
from app.routes import auth_route

Base.metadata.create_all(bind=engine)

from app.routes import (
    ocr_route,
    summarize_route,
    flashcard_route,
    mood_route
)

app = FastAPI(
    title="AI Study Companion API",
    version="1.0.0"
)

app.include_router(ocr_route.router)
app.include_router(summarize_route.router)
app.include_router(flashcard_route.router)
app.include_router(mood_route.router)
app.include_router(studyplanner_route.router)
app.include_router(auth_route.router)


@app.get("/")
def root():
    return {"message": "AI Study Companion Backend is running 🚀"}