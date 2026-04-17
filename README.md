# ACE

## Project Overview

**ACE** is an AI-powered academic support application designed to help students study more efficiently by automating key learning tasks such as text extraction, summarization, flashcard generation, study planning, and mood tracking.

Students often rely on multiple tools to manage their academic workflow—scanning notes, summarizing content, creating revision materials, organizing study schedules, and monitoring their learning progress. This fragmented process can be time-consuming, inefficient, and mentally exhausting.

ACE addresses this challenge by integrating these essential study functions into a single intelligent platform. By allowing users to extract text from images, generate concise summaries, create flashcards automatically, plan study sessions, and track their mood, ACE simplifies the learning process and improves study productivity.

The goal of ACE is to reduce the manual effort involved in preparing study materials while promoting better organization, consistency, and engagement in students’ academic routines.

## Features

- **OCR Text Extraction** – Extract text from uploaded PDFs or images.
- **AI Summarization** – Generate concise summaries from extracted study materials.
- **Flashcard Generation** – Automatically create flashcards for revision.
- **Study Planner** – Organize and schedule study sessions efficiently.
- **Mood Tracking** – Record study mood to monitor learning patterns.
- **User Authentication** – Secure registration and login functionality.

---

## Tech Stack

### Frontend
- **Flutter** – Cross-platform mobile app development

### Backend
- **FastAPI** – Backend API development
- **SQLite** – Local database management
- **Python** – Core backend language

### AI Features
- OCR processing
- Text summarization
- Flashcard generation logic

---

## Installation

To run ACE locally, clone the repository, start the backend server, and run the Flutter frontend.

### 1. Clone the repository

```bash
git clone https://github.com/okochapraise/ace.git
cd ace

Start the backend server

cd backend
source venv/bin/activate
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

Run the flutter frontend
flutter pub get
flutter run