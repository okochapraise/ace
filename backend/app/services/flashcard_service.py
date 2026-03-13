import os
import json
import re
import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

MODEL_NAME = "models/gemini-2.5-flash"
model = genai.GenerativeModel(MODEL_NAME)


def _extract_json(text: str):
    try:
        return json.loads(text)
    except:
        match = re.search(r"\[.*\]", text, re.DOTALL)
        if match:
            try:
                return json.loads(match.group())
            except Exception as e:
                print("Secondary JSON parse failed:", e)
        return []


def _calculate_num_cards(available_minutes: int) -> int:
    """
    Dynamically determine number of flashcards
    based on study time.
    """
    if available_minutes <= 10:
        return 5
    elif available_minutes <= 20:
        return 8
    elif available_minutes <= 30:
        return 12
    elif available_minutes <= 45:
        return 18
    else:
        return 25


def generate_flashcards(
    text: str,
    available_minutes: int,
    difficulty: str
):
    if not text.strip():
        return []

    num_cards = _calculate_num_cards(available_minutes)

    prompt = f"""
Generate {num_cards} quiz flashcards from the text below.

Difficulty level: {difficulty}

Each flashcard MUST contain:
- question (string)
- shown_answer (string) → may be correct OR incorrect
- is_correct (boolean)
- difficulty (easy | medium | hard)

Rules:
- At least 40% must be incorrect
- Match difficulty level strictly
- Incorrect answers must be believable
- DO NOT explain anything
- Return ONLY valid JSON array

TEXT:
{text}
"""

    try:
        response = model.generate_content(prompt)
        return _extract_json(response.text.strip())
    except Exception as e:
        print("❌ Flashcard generation failed:", e)
        return []
    
def compute_session_summary(flashcards: list[dict], answers: list[bool]):
    """
    Compute session stats: correct, incorrect, total.
    """
    total = len(flashcards)
    correct = sum(1 for a in answers if a)
    incorrect = total - correct

    return {
        "total_questions": total,
        "correct_answers": correct,
        "incorrect_answers": incorrect,
        "score_percent": round((correct / total) * 100, 2) if total > 0 else 0
    }
