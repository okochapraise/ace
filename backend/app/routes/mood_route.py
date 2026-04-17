from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.services.mood_service import get_mood_recommendation

router = APIRouter()


class MoodRequest(BaseModel):
    mood: str


@router.post("/mood")
def mood_endpoint(req: MoodRequest):

    if not req.mood.strip():
        raise HTTPException(status_code=400, detail="Mood is required")

    result = get_mood_recommendation(req.mood)

    return result