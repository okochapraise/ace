from fastapi import APIRouter
from pydantic import BaseModel
from app.services.studyplanner_service import generate_study_plan


router = APIRouter(prefix="/study-plan", tags=["Study Planner"])



class StudyPlanRequest(BaseModel):
    text_length: int
    available_minutes: int
    mood: str


@router.post("/")
def create_study_plan(request: StudyPlanRequest):

    plan = generate_study_plan(
        text_length=request.text_length,
        available_minutes=request.available_minutes,
        mood=request.mood
    )

    return plan