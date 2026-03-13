import warnings
warnings.filterwarnings("ignore", category=UserWarning, module="pdfminer")

import io
import re
import imghdr
import concurrent.futures
import multiprocessing
from PIL import Image
import pytesseract
from pdf2image import convert_from_bytes
import docx
import fitz  # PyMuPDF
from autocorrect import Speller

pytesseract.pytesseract.tesseract_cmd = "/opt/homebrew/bin/tesseract"
spell = Speller(lang="en")


def clean_text(text: str) -> str:
    """Normalize text: remove non-ASCII chars, extra spaces, and multiple newlines."""
    text = re.sub(r"[^\x20-\x7E\n]", "", text)
    text = re.sub(r"\n+", "\n", text)
    text = re.sub(r"[ ]+", " ", text)
    return text.strip()


def ocr_page_image(image: Image.Image) -> str:
    """Run OCR on a single PIL image."""
    return pytesseract.image_to_string(image)


def extract_text_from_image(file_bytes: bytes) -> str:
    try:
        with Image.open(io.BytesIO(file_bytes)) as img:
            return clean_text(pytesseract.image_to_string(img))
    except Exception as e:
        return f"Error reading image: {e}"


def extract_text_from_pdf(file_bytes: bytes) -> str:
    """Extract text from PDF; OCR for scanned pages only."""
    text, ocr_pages = [], []

    try:
        with fitz.open(stream=file_bytes, filetype="pdf") as pdf:
            for i, page in enumerate(pdf):
                page_text = page.get_text("text")
                if page_text.strip():
                    text.append(page_text)
                else:
                    ocr_pages.append(i)

            if ocr_pages:
                images = convert_from_bytes(
                    file_bytes,
                    dpi=150,
                    thread_count=multiprocessing.cpu_count(),
                    first_page=min(ocr_pages) + 1,
                    last_page=max(ocr_pages) + 1,
                )
                with concurrent.futures.ThreadPoolExecutor(max_workers=multiprocessing.cpu_count()) as executor:
                    ocr_results = list(executor.map(ocr_page_image, images))
                for idx, page_idx in enumerate(ocr_pages):
                    text.insert(page_idx, ocr_results[idx])

    except Exception as e:
        return f"Error reading PDF: {e}"

    return clean_text("\n".join(text))


def stream_text_from_pdf(file_bytes: bytes):
    """Stream text page-by-page for large PDFs, with OCR fallback."""
    try:
        with fitz.open(stream=file_bytes, filetype="pdf") as pdf:
            total_pages = len(pdf)
            for i, page in enumerate(pdf, start=1):
                page_text = page.get_text("text").strip()
                if not page_text:
                    img = Image.open(io.BytesIO(page.get_pixmap(dpi=150).tobytes("png")))
                    page_text = pytesseract.image_to_string(img)

                yield f"\n\n--- Page {i}/{total_pages} ---\n{clean_text(page_text)}\n"
    except Exception as e:
        yield f"Error streaming PDF: {e}"


def extract_text_from_docx(file_bytes: bytes) -> str:
    try:
        doc = docx.Document(io.BytesIO(file_bytes))
        return clean_text("\n".join(p.text for p in doc.paragraphs))
    except Exception as e:
        return f"Error reading DOCX: {e}"


def extract_text_from_txt(file_bytes: bytes) -> str:
    try:
        return clean_text(file_bytes.decode("utf-8", errors="ignore"))
    except Exception as e:
        return f"Error reading TXT: {e}"


def extract_text(file_bytes: bytes, filename: str, mime_type: str) -> str:
    """Universal text extraction based on extension, MIME type, and content."""
    filename, mime_type = (filename or "").lower(), (mime_type or "").lower()

    if filename.endswith(".pdf") or mime_type == "application/pdf" or file_bytes.startswith(b"%PDF"):
        return extract_text_from_pdf(file_bytes)

    if filename.endswith(".docx") or mime_type == "application/vnd.openxmlformats-officedocument.wordprocessingml.document" \
       or (file_bytes[:2] == b"PK" and b"[Content_Types].xml" in file_bytes):
        return extract_text_from_docx(file_bytes)

    if filename.endswith(".txt") or mime_type == "text/plain" \
       or all(32 <= b <= 126 or b in (9, 10, 13) for b in file_bytes[:100]):
        return extract_text_from_txt(file_bytes)

    if filename.endswith((".png", ".jpg", ".jpeg", ".tiff", ".bmp", ".gif")) \
       or mime_type.startswith("image/") \
       or imghdr.what(None, h=file_bytes):
        return extract_text_from_image(file_bytes)

    return "Unsupported file type"


def should_stream_pdf(file_bytes: bytes, max_pages=50, max_size_mb=10) -> bool:
    """Decide if a PDF should be streamed based on page count or size."""
    try:
        size_mb = len(file_bytes) / (1024 * 1024)
        with fitz.open(stream=file_bytes, filetype="pdf") as pdf:
            return len(pdf) > max_pages or size_mb > max_size_mb
    except:
        return False
