import os
from dotenv import load_dotenv
import google.generativeai as genai


load_dotenv()
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

MODEL_NAME = "models/gemini-2.5-flash"
model = genai.GenerativeModel(MODEL_NAME)

PROMPT_TEMPLATE = """
You are a private tutor for a 12-year-old. Explain the following text simply.
- Keep all numbered items in order.
- Do NOT add greetings, intros, or filler text.
- Focus on clarity and completeness.
- Use examples or analogies only if necessary.
- Return in full, readable, multi-line format.

Text:
{}
"""

def generate_summary(text: str, max_tokens: int = 4096) -> str:
    """
    Generate a simplified summary using Gemini 2.5 Flash.
    max_tokens can be increased depending on your plan.
    """
    try:
        response = model.generate_content(
            PROMPT_TEMPLATE.format(text),
            generation_config={
                "temperature": 0.3,
                "max_output_tokens": max_tokens
            }
        )

     
        if hasattr(response, "text") and response.text:
            return response.text.strip()

        summary_parts = []
        if getattr(response, "candidates", None):
            for c in response.candidates:
                if getattr(c, "content", None) and getattr(c.content, "parts", None):
                    for p in c.content.parts:
                        if getattr(p, "text", None):
                            summary_parts.append(p.text)

        summary = " ".join(summary_parts).strip()
        return summary or "No summary generated."

    except Exception as e:
        print(f"[ERROR] Summarization failed: {e}")
        return "Sorry, I couldn’t generate a summary this time."


def summarize_long_text(text: str, chunk_size: int = 5000) -> str:
    """
    Handle very long text:
    1. Split into chunks
    2. Summarize each chunk
    3. Combine summaries
    4. Optionally summarize combined summary
    """
    if not text.strip():
        return "No text provided."

    lines = text.split("\n")
    chunks = []
    current = ""
    for line in lines:
        if len(current) + len(line) + 1 > chunk_size:
            chunks.append(current.strip())
            current = ""
        current += line + "\n"
    if current.strip():
        chunks.append(current.strip())

    chunk_summaries = []
    for chunk in chunks:
        chunk_summaries.append(generate_summary(chunk))

    
    combined_summary = "\n\n".join(chunk_summaries)

   
    if len(chunks) > 1:
        final_summary = generate_summary(combined_summary)
        return final_summary

    return combined_summary
