"""SERVICE 3 (CROP SUITABILITY) - STEP 2: PREDICT THE SUITABLE CROPS (sorted, like the FarmWise screen).

Input : N, P, K, temperature (C), humidity (%), soil pH, rainfall (mm)
Output: the 22 crops sorted by suitability (% of the 300 trees of the model that vote for each crop)
        + a warning when an input is outside what the model has seen (it cannot be trusted there).

Run (from the ai-service/ folder):  python -m services.crop_suitability.step2_predict
"""
import json
from functools import lru_cache

import joblib
import pandas as pd

from common import CROP_SUITABILITY
from services.crop_suitability.step1_train_model import FEATURES

NAMES = {
    "rice": "Rice", "maize": "Maize", "chickpea": "Chickpea", "kidneybeans": "Kidney beans", "pigeonpeas": "Pigeon peas",
    "mothbeans": "Moth beans", "mungbean": "Mung bean", "blackgram": "Black gram", "lentil": "Lentil",
    "pomegranate": "Pomegranate", "banana": "Banana", "mango": "Mango", "grapes": "Grapes", "watermelon": "Watermelon",
    "muskmelon": "Muskmelon", "apple": "Apple", "orange": "Orange", "papaya": "Papaya", "coconut": "Coconut",
    "cotton": "Cotton", "jute": "Jute", "coffee": "Coffee",
}


@lru_cache
def model():
    return joblib.load(CROP_SUITABILITY / "model" / "crop_model.joblib")


@lru_cache
def report() -> dict:
    with open(CROP_SUITABILITY / "output" / "model_report.json", encoding="utf-8") as f:
        return json.load(f)


def predict(N: float, P: float, K: float, temperature: float, humidity: float, ph: float, rainfall: float) -> dict:
    """Sorted crops with their suitability %."""
    values = {"N": N, "P": P, "K": K, "temperature": temperature, "humidity": humidity, "ph": ph, "rainfall": rainfall}
    if not 0 <= ph <= 14:
        raise ValueError("pH must be between 0 and 14")
    if not 0 <= humidity <= 100:
        raise ValueError("humidity must be between 0 and 100 %")

    probabilities = model().predict_proba(pd.DataFrame([values], columns=FEATURES))[0]
    crops = sorted(({"crop": c, "name": NAMES.get(c, c), "percent": round(float(p) * 100, 2)}
                    for c, p in zip(model().classes_, probabilities)), key=lambda c: -c["percent"])

    ranges = report()["input_ranges"]
    warnings = [f"{k} = {v:g} is outside the training data ({ranges[k][0]:g} to {ranges[k][1]:g}): "
                "the result is less reliable" for k, v in values.items() if not ranges[k][0] <= v <= ranges[k][1]]
    return {"inputs": values, "crops": crops, "warnings": warnings, "model_accuracy": report()["accuracy"]}


if __name__ == "__main__":
    r = predict(N=15, P=133, K=199, temperature=23, humidity=91, ph=5.8, rainfall=117)   # the FarmWise screenshot
    for c in r["crops"][:5]:
        print(f"  {c['crop']:12} {c['percent']:6.2f} %")
    print(r["warnings"])
