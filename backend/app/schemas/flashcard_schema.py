from pydantic import BaseModel
from datetime import datetime

class FlashcardSessionCreate(BaseModel):
    correct_answers: int
    wrong_answers: int

class FlashcardSessionResponse(BaseModel):
    id: int
    correct_answers: int
    wrong_answers: int
    accuracy: float
    created_at: datetime

    class Config:
        from_attributes = True