import os
import urllib.parse
from dotenv import load_dotenv
import google.generativeai as genai


load_dotenv()

genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

MODEL_NAME = "models/gemini-2.5-flash"
model = genai.GenerativeModel(MODEL_NAME)


MOOD_BASE = {
    "happy": {
        "activity": "Full study session with practice questions",
        "reason": "Positive mood improves learning efficiency and memory retention."
    },
    "tired": {
        "activity": "Light review with flashcards or summaries",
        "reason": "Low energy makes heavy learning harder, so lighter tasks help maintain progress."
    },
    "stressed": {
        "activity": "Short focused session with breaks",
        "reason": "Stress reduces concentration, so shorter sessions prevent burnout."
    },
    "neutral": {
        "activity": "Balanced study session with mixed activities",
        "reason": "A neutral state is suitable for steady learning."
    }
}


def generate_ai_support(mood: str) -> dict:
    """
    Generate encouragement and music suggestion using AI.
    """

    prompt = f"""
You are an AI study companion helping a student.

User mood: {mood}

Generate:
1. A short motivational encouragement message for studying.
2. A music recommendation query suitable for studying with this mood.

Rules:
- Encouragement must be supportive and positive.
- Music query should be 3–6 words (example: "lofi focus music").
- Do NOT include explanations.
- Return JSON only.

Example:
{{
  "encouragement": "You are capable of more than you think. Small steps matter.",
  "music_query": "lofi beats for focus"
}}
"""

    try:
        response = model.generate_content(prompt)
        text = response.text.strip()

        import json
        import re

        try:
            data = json.loads(text)
        except:
            match = re.search(r"\{.*\}", text, re.DOTALL)
            data = json.loads(match.group()) if match else {}

        return data

    except Exception as e:
        print("AI generation failed:", e)
        return {
            "encouragement": "Keep going. Every small step you take brings you closer to success.",
            "music_query": "focus study music"
        }


def get_mood_recommendation(mood: str) -> dict:
    mood = mood.lower()

    base = MOOD_BASE.get(
        mood,
        {
            "activity": "General study session",
            "reason": "Consistent practice improves learning."
        }
    )

    ai_data = generate_ai_support(mood)

    music_query = ai_data.get("music_query", "focus music")


    encoded_query = urllib.parse.quote(music_query)
    spotify_url = f"https://open.spotify.com/search/{encoded_query}"

    return {
        "mood": mood,
        "activity": base["activity"],
        "reason": base["reason"],
        "encouragement": ai_data.get(
            "encouragement",
            "You’re doing great. Stay consistent and trust the process."
        ),
        "music": {
            "query": music_query,
            "spotify_url": spotify_url
        }
    }