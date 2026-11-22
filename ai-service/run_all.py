"""Runs every step of the 4 services in order, then tells you how to start the prototype.

Run (from the ai-service/ folder):  python run_all.py
"""
import subprocess
import sys

STEPS = [
    "services.rainfall.step1_download",       # service 1: real weather (Open-Meteo)
    "services.rainfall.step2_rain_forecast",  # service 1: rain 2026-2027 (SARIMA)
    "services.rainfall.step3_crop_need",      # service 1: ET0 per month (crop need = ET0 x Kc)
    "services.rainfall.step4_water_to_add",   # service 1: test of the formula
    "services.rainfall.step5_evaluate",       # service 1: test of the rain forecast on past years
    "services.soil_map.step1_soil_map",              # service 2: soil map of Tunisia (ISRIC SOTER)
    "services.soil_map.step2_soil_by_region",        # service 2: soil of each governorate (whole area)
    "services.soil_map.step3_evaluate",              # service 2: evaluation (24 areas + SoilGrids comparison)
    "services.crop_suitability.step1_train_model",   # service 3: train the AI model (Kaggle data)
    "services.crop_suitability.step2_predict",       # service 3: test a prediction
    "services.crop_suitability.step3_evaluate",      # service 3: evaluation (simple models, noise, EcoCrop, Tunisia)
    "services.market.step1_download",                # service 4: FAOSTAT production, trade, prices (Tunisia)
    "services.market.step2_forecast",                # service 4: forecast to 2027 (Theta) + backtest
    "services.market.step3_money",                   # service 4: farm price 2025 x yield = revenue per hectare
    "services.market.step4_planting_calendar",       # service 4: FAO crop calendar (can it be sown this month?)
    "services.energy.step1_download",                # service 5: PVGIS solar per governorate + Tunisia electricity (OWID)
    "services.energy.step2_pumping",                 # service 5: test of the pumping energy / solar calculator
    "services.chatbot.step1_index",                  # chatbot: energy + rotation documents -> chunks -> E5/MiniLM vectors
    "services.chatbot.step3_evaluate",               # chatbot: which retriever is best (24 test questions)
]

for step in STEPS:
    print(f"\n=== {step} ===")
    subprocess.run([sys.executable, "-m", step], check=True)

print("\nDone. Start the prototype:  uvicorn app:app --port 8000")
print("  http://localhost:8000           service 1: rainfall + water to add")
print("  http://localhost:8000/soil-map  service 2: soil map")
print("  http://localhost:8000/crops     service 3: crop suitability")
print("  http://localhost:8000/market    service 4: market forecast")
print("  http://localhost:8000/chat      service 5: Khiratna chatbot (energy + crop rotation)")
