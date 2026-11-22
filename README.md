# Akatsuki.exe — smart farming for Tunisia

Hackathon water · energy · agriculture (Tunisia, 21–22 November 2026).
A farmer gets, for their governorate: how much water to add, their soil, the crops that suit it, what the Tunisian market
will lack in 2027, and **Khiratna**, a voice assistant for irrigation energy and crop rotation.

## Team

| Who | Role | Folder |
|---|---|---|
| Yasmine | Data / AI, Python API | `ai-service/` |
| Yassine | NestJS backend, PostgreSQL, Flutter app | `backend/`, `mobile/` |
| Akram | Design | `design/` |

## Structure

```
.
├── ai-service/      Python: the 5 AI/data services + FastAPI (port 8000) + test pages
│   ├── services/    rainfall · soil_map · crop_suitability · market · chatbot (+ energy calculator)
│   └── web/         one test page per service
├── backend/         NestJS API (port 3000), called by the app; forwards /farm/... to ai-service
├── mobile/          Flutter app
├── design/          mockups, logo, colors
├── integration/     how ai-service and NestJS connect (guide + ready NestJS files)
└── docs/            Services_Evaluation.pdf (data sources, models, evaluation of each service)
```

```
Flutter app ──► NestJS backend (:3000) ──► ai-service (:8000) ──► data + models + Gemini
                      └──► PostgreSQL (users, farms)
```

## The 5 services (`ai-service/services/`)

| # | Service | What it gives | Method · evaluation |
|---|---|---|---|
| 1 | `rainfall` | rain forecast → water to add per month | SARIMA + FAO-56 · 11.4 % season error (climatology 13.8 %) |
| 2 | `soil_map` | soil of each governorate | ISRIC SOTER map · areas within 3.5 % of official, SoilGrids check |
| 3 | `crop_suitability` | crops that suit N, P, K, pH, climate | Random Forest · 99.4 % cross-validation, EcoCrop agreement |
| 4 | `market` | what Tunisia will lack in 2027, revenue per ha and per m³ | FAOSTAT + Theta · 6.5 % production error; FAO calendar + frost check |
| 5 | `chatbot` | **Khiratna**: answers questions on irrigation energy and crop rotation, by voice, in English; computes pumping cost, solar panels and subsidy with the `energy` calculator | RAG (E5 vectors, 1 300 passages) + Gemini + Whisper · right passage found 100 % |

Details and sources: `ai-service/README.md` and `docs/Services_Evaluation.pdf`.

## Run the AI service

```bash
cd ai-service
pip install -r requirements.txt
# put the Gemini keys in ai-service/.env:  GEMINI_API_KEYS=key1,key2
python -m uvicorn app:app --port 8000      # or double-click start_api.bat
```

Open http://localhost:8000 (rainfall), `/soil-map`, `/crops`, `/market`, `/chat`, API docs at `/docs`.
To connect NestJS: `integration/README.md`.

## Git

Branches: `main` (demo version, changed only by Pull Request), `yasmine`, `yassine`, `akram`.
Never commit `.env` (the Gemini keys): it is in `.gitignore`.
