@echo off
REM Starts the Python API (double-click). Keep this window OPEN while you use the pages.
cd /d %~dp0
python -c "import pandas, numpy, statsmodels, matplotlib, sklearn, joblib, fastapi, uvicorn, pypdf, psycopg2, sentence_transformers, faster_whisper" 2>nul || python -m pip install -r requirements.txt
echo.
echo  Open in your browser:
echo    http://localhost:8000            service 1: rainfall + water to add
echo    http://localhost:8000/soil-map   service 2: soil map
echo    http://localhost:8000/crops      service 3: crop suitability
echo    http://localhost:8000/market     service 4: market forecast
echo    http://localhost:8000/chat       service 5: Khiratna chatbot
if not exist .env echo  WARNING: .env is missing - Khiratna needs it. Copy .env.example to .env and add the Gemini keys.
echo.
python -m uvicorn app:app --host 0.0.0.0 --port 8000
pause
