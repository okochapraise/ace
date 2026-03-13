from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.services.summarizer_service import summarize_long_text

router = APIRouter()

class SummarizeRequest(BaseModel):
    text: str


@router.post("/summarize")
async def summarize(req: SummarizeRequest):
    text = req.text.strip()
    if not text:
        raise HTTPException(status_code=400, detail="Text is required")

    summary = summarize_long_text(text)
    return {"summary": summary}
