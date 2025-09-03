import warnings
warnings.filterwarnings("ignore", category=UserWarning, module="pdfminer")

import pytesseract
from pdf2image import convert_from_bytes
from PIL import Image
import docx
import io
import re
import fitz  # PyMuPDF
from autocorrect import Speller
import concurrent.futures
import multiprocessing
import imghdr

spell = Speller(lang="en")

def clean_text(text: str) -> str:
    """Clean up OCR/text output."""
    text = re.sub(r'[^\x20-\x7E\n]', '', text)
    text = re.sub(r'\n+', '\n', text)
    text = re.sub(r'[ ]+', ' ', text)
    return text.strip()

def ocr_page_image(page_image):
    """Run OCR on a single page image."""
    return pytesseract.image_to_string(page_image)

def extract_text_from_image(file_bytes: bytes) -> str:
    try:
        image = Image.open(io.BytesIO(file_bytes))
        return clean_text(pytesseract.image_to_string(image))
    except Exception as e:
        return f"Error reading image: {e}"

def extract_text_from_pdf(file_bytes: bytes) -> str:
    """Extract text from PDF, OCR only on scanned pages."""
    text = []
    try:
        with fitz.open(stream=file_bytes, filetype="pdf") as pdf:
            pages_for_ocr = []
            for i, page in enumerate(pdf, start=1):
                page_text = page.get_text("text")
                if page_text.strip():
                    text.append(page_text)
                else:
                    pages_for_ocr.append(i - 1)

            if pages_for_ocr:
                pdf_bytes = io.BytesIO(file_bytes).getvalue()
                ocr_images = convert_from_bytes(
                    pdf_bytes,
                    dpi=150,
                    thread_count=multiprocessing.cpu_count(),
                    first_page=min(pages_for_ocr) + 1,
                    last_page=max(pages_for_ocr) + 1
                )
                with concurrent.futures.ThreadPoolExecutor(max_workers=multiprocessing.cpu_count()) as executor:
                    ocr_results = list(executor.map(ocr_page_image, ocr_images))

                for idx, page_index in enumerate(pages_for_ocr):
                    text.insert(page_index, ocr_results[idx])

    except Exception as e:
        return f"Error reading PDF: {e}"

    return clean_text("\n".join(text))

def stream_text_from_pdf(file_bytes: bytes):
    """Stream text page-by-page for large PDFs, with OCR fallback."""
    try:
        with fitz.open(stream=file_bytes, filetype="pdf") as pdf:
            total_pages = len(pdf)
            for i, page in enumerate(pdf, start=1):
                page_text = page.get_text("text")
                if not page_text.strip():
                    img = page.get_pixmap(dpi=150)
                    pil_img = Image.open(io.BytesIO(img.tobytes("png")))
                    page_text = pytesseract.image_to_string(pil_img)

                yield f"\n\n--- Page {i}/{total_pages} ---\n"
                yield clean_text(page_text) + "\n"
    except Exception as e:
        yield f"Error streaming PDF: {e}"

def extract_text_from_docx(file_bytes: bytes) -> str:
    try:
        doc = docx.Document(io.BytesIO(file_bytes))
        return clean_text("\n".join([para.text for para in doc.paragraphs]))
    except Exception as e:
        return f"Error reading DOCX: {e}"

def extract_text_from_txt(file_bytes: bytes) -> str:
    try:
        return clean_text(file_bytes.decode("utf-8", errors="ignore"))
    except Exception as e:
        return f"Error reading TXT: {e}"

def extract_text(file_bytes: bytes, filename: str, mime_type: str) -> str:
    """Universal text extraction with extension, MIME type, and content detection."""
    filename = (filename or "").lower()
    mime_type = (mime_type or "").lower()

    # PDF detection
    if filename.endswith(".pdf") or mime_type == "application/pdf" or file_bytes[:4] == b"%PDF":
        return extract_text_from_pdf(file_bytes)

    # DOCX detection
    elif filename.endswith(".docx") or mime_type == "application/vnd.openxmlformats-officedocument.wordprocessingml.document" \
         or (file_bytes[:2] == b"PK" and b"[Content_Types].xml" in file_bytes):
        return extract_text_from_docx(file_bytes)

    # TXT detection
    elif filename.endswith(".txt") or mime_type == "text/plain" \
         or all(32 <= b <= 126 or b in (9, 10, 13) for b in file_bytes[:100]):
        return extract_text_from_txt(file_bytes)

    # Image detection
    elif filename.endswith((".png", ".jpg", ".jpeg", ".tiff", ".bmp", ".gif")) \
         or mime_type.startswith("image/") \
         or imghdr.what(None, h=file_bytes) is not None:
        return extract_text_from_image(file_bytes)

    return "Unsupported file type"

def should_stream_pdf(file_bytes: bytes, threshold_pages=50, threshold_size_mb=10) -> bool:
    """Decide if PDF should be streamed based on pages & size."""
    try:
        size_mb = len(file_bytes) / (1024 * 1024)
        with fitz.open(stream=file_bytes, filetype="pdf") as pdf:
            if len(pdf) > threshold_pages or size_mb > threshold_size_mb:
                return True
        return False
    except:
        return False
