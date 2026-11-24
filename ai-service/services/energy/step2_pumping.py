"""SERVICE 5 (ENERGY) - STEP 2: HOW MUCH ENERGY AND MONEY DOES IRRIGATION COST? CAN SOLAR COVER IT?

Plugs into service 1 (water to add). For one governorate, crop, planting month and farm:

  1. water to add (m3)        = service 1, over the crop season, x hectares
  2. pumping energy (kWh)     = water x 0.00272 x pumping head (m) / pump efficiency
                                (0.00272 kWh lifts 1 m3 of water by 1 m: 1000 kg x 9.81 m/s2 x 1 m / 3.6e6)
  3. grid cost (TND)          = energy x electricity price (STEG, millimes/kWh; default 291 = medium-voltage
                                uniform tariff 2022, + VAT 7 % irrigation + 5 municipal surtax; change it with your bill)
  4. solar size (kWp)         = energy of the busiest month / solar production of that month per kWp (PVGIS)
                                -> the panels cover the hardest month, so all the other months too
  5. subsidy (TND)            = FTE / ANME PROSOL-ELEC off-grid agriculture table (per kWp, cap 50 000 TND)
  6. payback (years)          = (installation price - subsidy) / grid cost saved per year
                                ONLY if the farmer gives the installer's price: no official price per kWp exists.

Pumping head and pump efficiency depend on the farm (well depth, pump): the farmer enters them.
Defaults: 30 m and 50 % (typical small pump + motor, FAO "Benefits and risks of solar-powered irrigation" 2018).

Run (from the ai-service/ folder):  python -m services.energy.step2_pumping
"""
from functools import lru_cache

import pandas as pd

from common import ENERGY, GOVERNORATES
from services.rainfall.step3_crop_need import CROPS
from services.rainfall.step4_water_to_add import water_to_add

KWH_PER_M3_PER_M = 0.00272
DEFAULT_PRICE_MILLIMES = 291          # STEG medium voltage, uniform, from 01/10/2022 (hors taxes)
VAT, SURTAX = 0.07, 5                 # irrigation VAT 7 %, municipal surtax 5 millimes/kWh
SUBSIDY = [(0.25, 6000), (0.5, 4500), (2, 3500), (5, 3000), (10, 1500), (float("inf"), 1000)]   # kWp, TND/kWp
SUBSIDY_CAP = 50000


@lru_cache
def pvgis() -> pd.DataFrame:
    return pd.read_csv(ENERGY / "raw" / "pvgis_tunisia.csv").set_index("governorate")


def subsidy_tnd(kwp: float) -> float:
    """FTE subsidy for off-grid agricultural PV: the rate of the size band x kWp, capped."""
    rate = next(r for limit, r in SUBSIDY if kwp <= limit)
    return min(kwp * rate, SUBSIDY_CAP)


def irrigation_energy(region: str, crop: str, planting_month: int, hectares: float = 1.0, head_m: float = 30,
                      pump_efficiency: float = 0.5, price_millimes_per_kwh: float = DEFAULT_PRICE_MILLIMES,
                      solar_price_tnd_per_kwp: float = None) -> dict:
    """Energy, grid cost, solar size, subsidy and (if a price is given) payback for one crop season."""
    if region not in GOVERNORATES:
        raise ValueError(f"Unknown region '{region}'. Choose one of: {', '.join(GOVERNORATES)}")
    if crop not in set(CROPS["crop"]):
        raise ValueError(f"Unknown crop '{crop}'. Choose one of: {', '.join(CROPS['crop'])}")
    if not (1 <= planting_month <= 12 and hectares > 0 and head_m > 0 and 0 < pump_efficiency <= 1):
        raise ValueError("Check the inputs: month 1-12, hectares > 0, head > 0 m, efficiency between 0 and 1")

    start = f"2026-{planting_month:02d}"
    end = (pd.Timestamp(start + "-01") + pd.DateOffset(months=11)).strftime("%Y-%m")
    water = water_to_add(region, crop, start, end)
    kwh_per_m3 = KWH_PER_M3_PER_M * head_m / pump_efficiency
    price_tnd = (price_millimes_per_kwh + SURTAX) * (1 + VAT) / 1000

    months, peak_kwp = [], 0.0
    for m in water["months"]:
        m3 = m["water_to_add_m3_per_ha"] * hectares
        kwh = m3 * kwh_per_m3
        month_no = int(m["month"][5:7])
        solar_per_kwp = pvgis().loc[region, f"kwh_per_kwp_m{month_no:02d}"]
        need_kwp = kwh / solar_per_kwp
        peak_kwp = max(peak_kwp, need_kwp)
        months.append({"month": m["month"], "water_m3": round(m3), "energy_kwh": round(kwh),
                       "grid_cost_tnd": round(kwh * price_tnd, 1), "solar_kwh_per_kwp": solar_per_kwp,
                       "kwp_needed": round(need_kwp, 2)})

    total_m3 = sum(x["water_m3"] for x in months)
    total_kwh = sum(x["energy_kwh"] for x in months)
    grid_cost = total_kwh * price_tnd
    kwp = round(peak_kwp, 2)
    sub = round(subsidy_tnd(kwp)) if kwp > 0 else 0
    result = {
        "region": region, "crop": crop, "planting_month": planting_month, "hectares": hectares,
        "assumptions": {"pumping_head_m": head_m, "pump_efficiency": pump_efficiency,
                        "electricity_price_millimes_per_kwh": price_millimes_per_kwh,
                        "price_with_taxes_tnd_per_kwh": round(price_tnd, 4)},
        "total": {"water_m3": total_m3, "energy_kwh": total_kwh, "kwh_per_m3": round(kwh_per_m3, 3),
                  "grid_cost_tnd": round(grid_cost), "grid_cost_tnd_per_m3": round(grid_cost / total_m3, 3) if total_m3 else 0,
                  "solar_kwp_needed": kwp, "solar_kwh_per_kwp_year": int(pvgis().loc[region, "kwh_per_kwp_year"]),
                  "fte_subsidy_tnd": sub},
        "months": months,
        "sources": {"water": "service 1 (Open-Meteo + FAO-56)", "solar": "PVGIS (EU JRC)",
                    "price": "STEG tariffs 2022", "subsidy": "FTE / ANME PROSOL-ELEC off-grid agriculture"},
    }
    if solar_price_tnd_per_kwp:
        cost = kwp * solar_price_tnd_per_kwp
        result["total"]["solar_installation_tnd"] = round(cost)
        if sub > cost:                     # a subsidy can never pay more than the installation itself
            result["total"]["fte_subsidy_tnd"] = sub = round(cost)
            result["total"]["subsidy_note"] = ("The FTE table gives more than this price, so the subsidy is limited to "
                                               "the installation price. Check the real amount with ANME and the installer.")
        result["total"]["solar_cost_after_subsidy_tnd"] = round(cost - sub)
        result["total"]["payback_years"] = round((cost - sub) / grid_cost, 1) if grid_cost else None
    return result


if __name__ == "__main__":
    r = irrigation_energy("Kebili", "tomato", 3, hectares=2, head_m=60)
    print(r["assumptions"]); print(r["total"])
