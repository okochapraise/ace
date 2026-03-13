from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
from fastapi import Depends
from sqlalchemy.orm import Session
from database.database import get_db
from app.dependencies.auth_dependency import get_current_user
from app.models.user_model import User
from app.models.flashcard_session import FlashcardSession
from app.services.flashcard_service import generate_flashcards, compute_session_summary

router = APIRouter()

# ----------------------------
# Request Models
# ----------------------------
class FlashcardRequest(BaseModel):
    text: str
    available_minutes: int
    difficulty: str


class FlashcardAnswerRequest(BaseModel):
    flashcards: List[dict]  # list of generated flashcards
    answers: List[bool]     # user's correct/incorrect input


# ----------------------------
# Endpoints
# ----------------------------
@router.post("/flashcards")
def create_flashcards(
    req: FlashcardRequest,
    current_user: User = Depends(get_current_user),
):
    """
    Generate flashcards from input text.
    Returns a list of cards with question, answer, difficulty.
    """
    if not req.text.strip():
        raise HTTPException(status_code=400, detail="Text is required")

    cards = generate_flashcards(
    text=req.text,
    available_minutes=req.available_minutes,
    difficulty=req.difficulty
)
    return {"flashcards": cards}

@router.post("/flashcards/session-summary")
def session_summary(
    req: FlashcardAnswerRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if len(req.flashcards) != len(req.answers):
        raise HTTPException(
            status_code=400,
            detail="Number of answers must match number of flashcards."
        )

    summary = compute_session_summary(req.flashcards, req.answers)

    session = FlashcardSession(
    user_id=current_user.id,
    correct_answers=summary["correct_answers"],
    wrong_answers=summary["incorrect_answers"],
    accuracy=summary["score_percent"],
)

    db.add(session)
    db.commit()

    return {"session_summary": summary}

@router.get("/flashcards/stats")
def get_user_stats(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    sessions = db.query(FlashcardSession).filter(
        FlashcardSession.user_id == current_user.id
    ).all()

    return sessions