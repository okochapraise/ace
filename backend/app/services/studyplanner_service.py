from typing import List, Dict


def generate_study_plan(
    text_length: int,
    available_minutes: int,
    mood: str
) -> Dict:

    sessions: List[Dict] = []

    # Decide session size based on mood
    if mood.lower() == "tired":
        block = 10
        difficulty = "easy"
        message = "Short sessions recommended because you are tired."

    elif mood.lower() == "stressed":
        block = 8
        difficulty = "easy"
        message = "Gentle study plan to reduce stress."

    elif mood.lower() == "happy":
        block = 15
        difficulty = "medium"
        message = "Great energy! Longer sessions planned."

    else:
        block = 12
        difficulty = "medium"
        message = "Balanced study sessions created."

    remaining_time = available_minutes

    activities = [
        "Read summary",
        "Practice flashcards",
        "Review difficult concepts",
        "Quick revision"
    ]

    i = 0

    while remaining_time > 0:
        duration = min(block, remaining_time)

        sessions.append({
            "duration": duration,
            "activity": activities[i % len(activities)],
            "difficulty": difficulty
        })

        remaining_time -= duration
        i += 1

    return {
        "sessions": sessions,
        "message": message
    }