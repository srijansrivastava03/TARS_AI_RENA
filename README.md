# TARS AI RENA — AgriScan Backend

Plant disease detection API powered by YOLO + RAG (Retrieval-Augmented Generation) with multilingual support.

## Features

- 🌿 **YOLO Plant Disease Detection** — 34 disease classes using a trained YOLOv8/v11 model
- 🎯 **Primary Detection Tracking** — Identifies the most consistent detection across frames
- 🧠 **RAG Diagnosis** — Disease info via local knowledge base + Gemini/OpenAI fallback
- 🌐 **Multilingual** — English, Hindi, Kannada support
- 💾 **Offline Support** — SQLite caching for offline diagnosis
- 📜 **History** — Per-user detection history with full CRUD

## Quick Start

```bash
cd Backend
python -m venv venv
source venv/bin/activate   # macOS/Linux
# venv\Scripts\activate    # Windows

pip install -r requirements.txt

# Copy and configure environment
cp .env.example .env
# Edit .env with your API keys

python api/app.py
```

Server starts at `http://localhost:5001`

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health` | Health check |
| GET | `/api/info` | API information |
| POST | `/api/detect` | Detect disease in image (base64) |
| POST | `/api/detect/continuous` | Real-time detection with tracking |
| POST | `/api/detect/reset-tracking` | Reset primary detection tracker |
| GET | `/api/diagnose/<disease>` | Get disease diagnosis |
| POST | `/api/diagnose` | Get diagnosis (POST) |
| GET | `/api/diseases` | List all diseases |
| GET | `/api/diseases/search?q=...` | Search diseases |
| GET | `/api/history/<user_id>` | Get user history |
| POST | `/api/history` | Save detection |
| DELETE | `/api/history/<id>` | Delete detection |

## Environment Variables

See `.env.example` for all configuration options.

## Deployment

Includes `Procfile` and `render.yaml` for Render cloud deployment.
