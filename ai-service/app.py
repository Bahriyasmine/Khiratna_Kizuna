"""THE PROTOTYPE: one test page per service + the API (the same API Yassine's NestJS backend will call).

Run (from the ai-service/ folder):   uvicorn app:app --port 8000
Open:  http://localhost:8000            service 1: rainfall forecast + water to add
       http://localhost:8000/soil-map   service 2: soil map of Tunisia
       http://localhost:8000/crops      service 3: crop suitability
       http://localhost:8000/market     service 4: market forecast
       http://localhost:8000/chat       service 5: Khiratna chatbot (energy + crop rotation, voice)
       http://localhost:8000/docs     the API, to test each endpoint
"""
import json
import os
from functools import lru_cache

# where the embedding model is saved after its 1st download (not read via huggingface_hub: importing it
# before setting HF_HUB_OFFLINE would freeze the "online" mode)
HF_CACHE = os.getenv("HF_HUB_CACHE") or os.path.join(
    os.getenv("HF_HOME") or os.path.join(os.path.expanduser("~"), ".cache", "huggingface"), "hub")
if os.path.isdir(os.path.join(HF_CACHE, "models--intfloat--multilingual-e5-small")):
    os.environ.setdefault("HF_HUB_OFFLINE", "1")      # model already on this PC: no internet check at start
# else (new PC, e.g. Yassine's): the model (~470 MB) is downloaded once at the first start
os.environ.setdefault("TF_CPP_MIN_LOG_LEVEL", "3")

from fastapi import FastAPI, HTTPException, Request
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse

from common import FIRST_MONTH, GOVERNORATES, LAST_MONTH, ROOT, SOIL_MAP
from services.rainfall.step3_crop_need import CROPS
from services.rainfall.step4_water_to_add import water_to_add
from services.soil_map.step1_soil_map import VARIABLES
from services.soil_map.step2_soil_by_region import region_soil, simple
from services.crop_suitability.step2_predict import predict, report
from services.market.step3_money import history, overview

app = FastAPI(title="Farm data API: rainfall, soil map, crop suitability, market forecast")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["GET", "POST"], allow_headers=["*"])


@app.on_event("startup")
def warm_up_chatbot():
    """Loads the E5 embedding model + the index in the background at start (else the 1st question waits ~25 s)."""
    import threading

    def load():
        try:
            from services.chatbot.rag import retrieve
            retrieve("warm up")
            from services.chatbot.step4_speech import model
            model()                                  # Whisper speech-to-text model
        except Exception as e:                       # chatbot index not built yet: the other services still work
            print(f"Chatbot not ready: {e}")
    threading.Thread(target=load, daemon=True).start()


def run(function, *args, **kwargs):
    """Runs a service; a wrong input becomes a clear 400 error."""
    try:
        return function(*args, **kwargs)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/api/health")
def health():
    """To check that NestJS can reach this API."""
    return {"status": "ok"}


# ---------- pages ----------
def page_file(name: str) -> FileResponse:
    """An HTML page, in UTF-8, never cached (the browser always shows the newest version)."""
    return FileResponse(ROOT / "web" / name, media_type="text/html; charset=utf-8",
                        headers={"Cache-Control": "no-store"})


@app.get("/", include_in_schema=False)
def rainfall_page():
    return page_file("rainfall.html")


@app.get("/soil-map", include_in_schema=False)
def soil_map_page():
    return page_file("soil_map.html")


@app.get("/market", include_in_schema=False)
def market_page():
    return page_file("market.html")


@app.get("/chat", include_in_schema=False)
def chat_page():
    return page_file("chat.html")


@app.get("/crops", include_in_schema=False)
def crops_page():
    return page_file("crops.html")


# ---------- service 1: rainfall forecast + water to add ----------
@app.get("/api/rainfall/options")
def rainfall_options():
    """The lists for the dropdowns: regions, crops, first and last month."""
    return {
        "regions": list(GOVERNORATES),
        "crops": [{"id": c.crop, "name": c.crop.replace("_peach", " / peach").replace("_", " ").capitalize(), "type": c.type} for c in CROPS.itertuples()],
        "months": {"first": FIRST_MONTH, "last": LAST_MONTH},
    }


@app.get("/api/rainfall/forecast")
def rainfall_forecast(region: str, crop: str, start: str, end: str):
    """Month by month: rain, crop need, water to add.  Example: ?region=Kasserine&crop=potato&start=2026-02&end=2026-06"""
    return run(water_to_add, region, crop, start, end)


# ---------- service 2: soil map ----------
@app.get("/api/soil/options")
def soil_options():
    """The soil variables (code, name, unit) and the 24 governorates."""
    return {"variables": [{"code": k, "name": n, "unit": u} for k, (n, u) in VARIABLES.items()],
            "regions": [{"name": g, "lat": la, "lon": lo} for g, (la, lo) in GOVERNORATES.items()]}


@app.get("/api/soil/map")
def soil_map_file():
    """The soil map of Tunisia (GeoJSON, ~750 zones, ISRIC SOTER)."""
    return FileResponse(SOIL_MAP / "output" / "tunisia_soil.geojson", media_type="application/geo+json")


@lru_cache
def _borders() -> dict:
    with open(SOIL_MAP / "raw" / "governorates.geojson", encoding="utf-8") as f:
        geo = json.load(f)
    for ft in geo["features"]:
        ft["properties"] = {"name": simple(ft["properties"]["shapeName"])}
    return geo


@app.get("/api/soil/borders")
def soil_borders():
    """The borders of the 24 governorates (geoBoundaries / OpenStreetMap)."""
    return _borders()


@app.get("/api/soil/region")
def soil_region(name: str):
    """Typical soil of one governorate, over its whole area.  Example: ?name=Kairouan"""
    return run(region_soil, name)


# ---------- service 3: crop suitability ----------
@app.get("/api/crops/predict")
def crops_predict(N: float, P: float, K: float, temperature: float, humidity: float, ph: float, rainfall: float):
    """The 22 crops sorted by suitability (Random Forest trained on the Kaggle Crop Recommendation dataset).
    Example: ?N=90&P=42&K=43&temperature=21&humidity=82&ph=6.5&rainfall=203"""
    return run(predict, N, P, K, temperature, humidity, ph, rainfall)


@app.get("/api/crops/model")
def crops_model():
    """Accuracy of the model, the crops it knows, and the range of each input in the training data."""
    return report()


# ---------- service 4: market forecast ----------
@app.get("/api/market/overview")
def market_overview(region: str = "Kairouan", planting_month: int = 3):
    """What Tunisia will lack (2024 -> 2027 forecast) and what earns the farmer most (per hectare, per m3 of water).
    The water (m3/ha) is computed for this governorate and planting month (service 1)."""
    return run(overview, region, planting_month)


@app.get("/api/market/history")
def market_history(product: str):
    """One product, year by year 2000-2027: production, imports, exports, consumption (observed then forecast)."""
    return run(history, product)


@app.get("/api/market/backtest")
def market_backtest():
    """Error of the forecast model on past years, compared with the naive forecast."""
    import pandas as pd
    from common import MARKET
    bt = pd.read_csv(MARKET / "output" / "backtest.csv")
    return {"median_error_percent": bt.groupby("series")[["model_error_percent", "naive_error_percent"]]
            .median().round(1).to_dict(orient="index")}


# ---------- service 5: Khiratna chatbot (energy + crop rotation) ----------
class Question(BaseModel):
    question: str


@app.post("/api/chat")
def chat(q: Question):
    """Farm advisor chatbot: energy of irrigation + crop rotation (RAG: multilingual E5 vectors, Gemini).
    Body: {"question": "..."}"""
    from services.chatbot.step2_chat import answer
    if not q.question.strip():
        raise HTTPException(status_code=400, detail="Empty question")
    try:
        return answer(q.question)
    except RuntimeError as e:
        raise HTTPException(status_code=503, detail=f"The AI service is busy, try again in a minute ({e})")


@app.post("/api/stt")
async def speech_to_text(request: Request):
    """Speech to text for Khiratna (Whisper small, local, English). Body: the raw audio recorded by the browser or
    the phone (webm, ogg, mp4, wav...). Returns {"text": "..."}; then send the text to /api/chat."""
    from services.chatbot.step4_speech import transcribe
    audio = await request.body()
    if len(audio) < 1000:
        raise HTTPException(status_code=400, detail="No audio received")
    try:
        return {"text": transcribe(audio)}
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Could not read the audio ({type(e).__name__})")
