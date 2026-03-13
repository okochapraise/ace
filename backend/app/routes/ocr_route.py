from fastapi import APIRouter, UploadFile, File, HTTPException
from fastapi.responses import StreamingResponse, JSONResponse
from app.services.ocr_service import extract_text, stream_text_from_pdf, should_stream_pdf
import re
from autocorrect import Speller

router = APIRouter()
spell = Speller(lang="en")


def clean_text(text: str) -> str:
    """Remove non-ASCII chars and extra spaces."""
    return re.sub(r"[^\x20-\x7E]", "", re.sub(r"\s+", " ", text)).strip()


def autocorrect_text(text: str) -> str:
    """Autocorrect each word in the text."""
    return " ".join(spell(word) for word in text.split())


@router.post("/ocr")
async def ocr_endpoint(file: UploadFile = File(...)):
    if not file:
        raise HTTPException(status_code=400, detail="No file uploaded")

    content = await file.read()
    filename = file.filename or ""
    mime_type = file.content_type or ""

    # Stream large PDFs directly
    if filename.lower().endswith(".pdf") or mime_type.lower() == "application/pdf" or content.startswith(b"%PDF"):
        if should_stream_pdf(content):
            return StreamingResponse(stream_text_from_pdf(content), media_type="text/plain")

    text = extract_text(content, filename, mime_type)

    if not text.strip() or "Error" in text:
        return JSONResponse(
            content={"text": "", "message": text if "Error" in text else "No readable text found"}
        )

    # Clean + autocorrect if small
    cleaned = clean_text(text)
    if len(cleaned) < 100_000:
        cleaned = autocorrect_text(cleaned)

    return JSONResponse(content={"text": cleaned})
