# Khiratna Kizuna

**Smart farming for Tunisia: water · energy · agriculture**

Team **Akatsuki.exe** · Hackathon Tunisia, 21–22 November 2026

---

## About the project

Tunisian farmers face **water scarcity**, **high pumping energy costs** and **uncertain markets**.
**Khiratna** gives every farmer, for their governorate:

- **How much water to add**: monthly irrigation needs from rain forecasts
- **Their soil**: an interactive soil map of the 24 governorates
- **The crops that suit them**: from soil nutrients (N, P, K, pH) and climate
- **What Tunisia will lack in 2027**: which crops pay best, per hectare and per m³ of water
- **Khiratna, a voice assistant**: answers questions on irrigation energy, solar pumping and crop rotation
- **A 3D farm simulation**: explore a virtual farm in Unity

---

## Architecture

```
 ┌───────────────────────────┐       ┌────────────────────────┐
 │  Flutter app (web+mobile) │       │  3D simulation         │
 │  khiratna_frontend/       │       │  Unity 6 · C# · Blender│
 └─────────────┬─────────────┘       └────────────────────────┘
               │ HTTP (JSON)
               ▼
 ┌───────────────────────────┐       ┌────────────────────────┐
 │  NestJS backend  :3000    │──────►│  PostgreSQL            │
 │  auth · users · /farm/*   │       │  users · farms         │
 └─────────────┬─────────────┘       │  + pgvector (chatbot)  │
               │ HTTP (JSON)         └────────────────────────┘
               ▼
 ┌───────────────────────────┐
 │  AI service (FastAPI)     │──► data · ML models · Gemini · Whisper
 │  ai-service/  :8000       │
 └───────────────────────────┘
```

---

## The 5 AI services (`ai-service/`)

| # | Service | What it gives | Method | Evaluation |
|---|---|---|---|---|
| 1 | **Rainfall** | Rain forecast → water to add per month | SARIMA + FAO-56 (ET0 × Kc) | 11.4 % season error (climatology: 13.8 %) |
| 2 | **Soil map** | Soil of each governorate | ISRIC SOTER map | Areas within 3.5 % of official figures |
| 3 | **Crop suitability** | Best crops for N, P, K, pH and climate | Random Forest | 99.4 % cross-validation, checked against FAO EcoCrop |
| 4 | **Market 2027** | What Tunisia will lack, revenue per ha and per m³ | FAOSTAT + Theta forecast | 6.5 % production error |
| 5 | **Khiratna chatbot** | Voice answers on energy and crop rotation | RAG (E5 + pgvector) + Gemini + Whisper | Right passage found 100 % (MRR 0.92) |

### How Khiratna works (RAG)

```
Voice ──► Whisper (speech → text)
              │
              ▼
      E5 embedding (384 numbers)
              │
              ▼
  pgvector: 6 closest passages out of 1,300
              │
              ▼
  Gemini 2.5 Flash ──► calls the energy calculator
              │        (pumping cost · solar panels · subsidy · payback)
              ▼
       Short English answer (read aloud)
```

---

## Tech stack

| Part | Technologies |
|---|---|
| **AI / Data** | Python · FastAPI · scikit-learn · statsmodels · sentence-transformers (E5) · faster-whisper · Gemini API |
| **Backend** | NestJS · TypeScript · PostgreSQL · pgvector |
| **Web & mobile** | Flutter · Riverpod · Dio · go_router · fl_chart · flutter_map |
| **3D simulation** | Unity 6 · C# · Blender |

---

## Project structure

```
Khiratna_Kizuna/
├── ai-service/          Python AI: 5 services + FastAPI (port 8000)
│   ├── services/        rainfall · soil_map · crop_suitability · market · chatbot
│   └── web/             test page for each service
├── integration/         how NestJS connects to the AI service
├── khiratna-backend/    NestJS API (port 3000)
├── khiratna_frontend/   Flutter app (web + Android + iOS)
└── simulation-3d/       Unity 6 project (farm scene, main menu)
```

---

## Getting started

### 1. AI service

```bash
cd ai-service
pip install -r requirements.txt
cp .env.example .env          # add your Gemini API keys
python -m uvicorn app:app --host 0.0.0.0 --port 8000
```

API docs: http://localhost:8000/docs

### 2. Backend

```bash
cd khiratna-backend
npm install
# in .env:  PYTHON_API_URL=http://localhost:8000
npm run start:dev
```

### 3. Flutter app

```bash
cd khiratna_frontend
flutter pub get
flutter run            # or: flutter run -d chrome
```

### 4. 3D simulation

Open `simulation-3d/` with **Unity 6** (6000.3), then open the scene `Assets/Akram/Scenes/Main Menu.unity` and press Play.

---

## Team Akatsuki.exe

| Member | Role | GitHub |
|---|---|---|
| **Yasmine Bahri** | Data & AI: 5 AI services, Khiratna chatbot | [Bahriyasmine](https://github.com/Bahriyasmine) |
| **Yassine Ben Mabrouk** | NestJS backend, web & mobile Flutter app | [YassineBM4](https://github.com/YassineBM4) |
| **Akram Louati** | Design & 3D simulation (Unity, Blender) | [louatiakram](https://github.com/louatiakram) |

---

## Data sources

FAOSTAT · FAO-56 · FAO EcoCrop · ISRIC SOTER / SoilGrids · NASA POWER · Tunisian Ministry of Agriculture.

---

Made in Tunisia by **Akatsuki.exe**
