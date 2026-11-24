"""STEP 4 - THE FORMULA: how much water the farmer must add, month by month.

    crop need (mm)          = ET0 x Kc                     step 3 (FAO-56)
    useful rain (mm)        = 80% of the rain              the other 20% runs off or evaporates
                                                           (FAO CROPWAT 'fixed percentage' effective-rain method)
    water to add (mm)       = crop need - useful rain      never below 0
    water to add (m3/ha)    = mm x 10                      1 mm of water on 1 hectare = 10 m3

Results are per hectare, so the field size is not needed.

Used by the prototype (app.py). Test alone:  python -m services.rainfall.step4_water_to_add
"""
from functools import lru_cache

import pandas as pd

from common import FIRST_MONTH, GOVERNORATES, LAST_MONTH, RAINFALL
from services.rainfall.step3_crop_need import CROPS, kc_per_month

USEFUL_RAIN = 0.8


@lru_cache
def rain_table() -> pd.DataFrame:
    """Step 2 result: rain per region and month."""
    return pd.read_csv(RAINFALL / "output" / "rain_forecast_2026_2027.csv")


@lru_cache
def et0_table() -> pd.DataFrame:
    """Step 3 result: ET0 per region and month."""
    return pd.read_csv(RAINFALL / "output" / "et0_2026_2027.csv")


def check_inputs(region: str, crop: str, start: str, end: str):
    """Stops with a clear message if an input is wrong."""
    if region not in GOVERNORATES:
        raise ValueError(f"Unknown region '{region}'. Choose one of: {', '.join(GOVERNORATES)}")
    if crop not in set(CROPS["crop"]):
        raise ValueError(f"Unknown crop '{crop}'. Choose one of: {', '.join(CROPS['crop'])}")
    if not (FIRST_MONTH <= start <= end <= LAST_MONTH):
        raise ValueError(f"Months must be YYYY-MM between {FIRST_MONTH} and {LAST_MONTH}, start before end")


def water_to_add(region: str, crop: str, start: str, end: str) -> dict:
    """Rain + crop need -> water to add, for one region and one crop, from `start` to `end`.
    Annual crops are planted in `start`; trees are already in the field."""
    check_inputs(region, crop, start, end)
    rain = rain_table()[rain_table()["governorate"] == region].set_index("month")
    et0 = et0_table()[et0_table()["governorate"] == region].set_index("month")
    kc = kc_per_month(crop, start, end)

    months = []
    for m, kc_m in kc.items():
        key = m.strftime("%Y-%m")
        rain_mm = float(rain.loc[key, "rain_mm"])
        crop_need = float(et0.loc[key, "et0_mm"]) * kc_m
        add_mm = max(crop_need - USEFUL_RAIN * rain_mm, 0) if kc_m > 0 else 0.0
        months.append({
            "month": key,
            "rain_mm": round(rain_mm, 1),
            "rain_source": rain.loc[key, "source"],            # observed / forecast
            "rain_dry_year_mm": float(rain.loc[key, "rain_dry_year_mm"]),
            "rain_wet_year_mm": float(rain.loc[key, "rain_wet_year_mm"]),
            "et0_mm": float(et0.loc[key, "et0_mm"]),
            "et0_source": et0.loc[key, "et0_source"],          # observed / normal
            "kc": round(float(kc_m), 2),
            "crop_need_mm": round(crop_need, 1),
            "useful_rain_mm": round(USEFUL_RAIN * rain_mm, 1),
            "water_to_add_mm": round(add_mm, 1),
            "water_to_add_m3_per_ha": round(add_mm * 10),
        })

    total = lambda col: round(sum(r[col] for r in months), 1)
    return {
        "region": region, "crop": crop, "start": start, "end": end,
        "total": {"rain_mm": total("rain_mm"), "crop_need_mm": total("crop_need_mm"),
                  "water_to_add_mm": total("water_to_add_mm"),
                  "water_to_add_m3_per_ha": round(total("water_to_add_m3_per_ha"))},
        "months": months,
        "kc_source": CROPS.set_index("crop").loc[crop, "source"],
    }


if __name__ == "__main__":
    result = water_to_add("Kasserine", "potato", "2026-02", "2026-06")
    print(pd.DataFrame(result["months"])[["month", "rain_mm", "rain_source", "crop_need_mm", "water_to_add_mm",
                                          "water_to_add_m3_per_ha"]].to_string(index=False))
    print("TOTAL:", result["total"])
