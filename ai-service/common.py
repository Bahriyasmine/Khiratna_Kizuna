"""Things shared by all the scripts: folders, the 24 regions, the months, and 2 small helpers."""
import json
import ssl
import time
import urllib.parse
import urllib.request
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parent
RAINFALL = ROOT / "services" / "rainfall"   # service 1: rain + crop need -> water to add
SOIL_MAP = ROOT / "services" / "soil_map"                  # service 2: soil map of Tunisia
CROP_SUITABILITY = ROOT / "services" / "crop_suitability"  # service 3: which crops suit the soil
MARKET = ROOT / "services" / "market"                      # service 4: market forecast (what Tunisia will lack, what pays)
ENERGY = ROOT / "services" / "energy"                      # service 5: energy of irrigation (pumping cost, solar)
for service in (RAINFALL, SOIL_MAP, CROP_SUITABILITY, MARKET, ENERGY):
    (service / "raw").mkdir(parents=True, exist_ok=True)      # downloaded data (never edited by hand)
    (service / "output").mkdir(parents=True, exist_ok=True)   # files computed by the scripts

# The months shown in the app.
FIRST_MONTH, LAST_MONTH = "2026-01", "2027-12"
MONTHS = pd.date_range(FIRST_MONTH + "-01", LAST_MONTH + "-01", freq="MS")

# The 24 governorates of Tunisia, located at their capital city (latitude, longitude).
GOVERNORATES = {
    "Tunis": (36.806, 10.181), "Ariana": (36.862, 10.195), "Ben Arous": (36.753, 10.219),
    "Manouba": (36.808, 10.097), "Nabeul": (36.456, 10.737), "Zaghouan": (36.402, 10.142),
    "Bizerte": (37.274, 9.874), "Beja": (36.725, 9.182), "Jendouba": (36.501, 8.780),
    "Kef": (36.174, 8.705), "Siliana": (36.085, 9.371), "Sousse": (35.826, 10.636),
    "Monastir": (35.778, 10.826), "Mahdia": (35.505, 11.062), "Sfax": (34.740, 10.760),
    "Kairouan": (35.678, 10.096), "Kasserine": (35.168, 8.836), "Sidi Bouzid": (35.038, 9.484),
    "Gabes": (33.882, 10.098), "Medenine": (33.355, 10.505), "Tataouine": (32.929, 10.452),
    "Gafsa": (34.425, 8.784), "Tozeur": (33.919, 8.134), "Kebili": (33.704, 8.969),
}

_SSL = ssl.create_default_context()  # uses the Windows certificate store


def get_json(url: str, params: dict, retries: int = 6) -> dict:
    """Downloads JSON from a web API. If the API says 'too many requests' (429), waits 65 s and tries again."""
    full_url = url + "?" + urllib.parse.urlencode(params, safe=",")
    for attempt in range(retries):
        try:
            with urllib.request.urlopen(full_url, context=_SSL, timeout=90) as r:
                data = json.loads(r.read())
            time.sleep(0.4)
            return data
        except Exception as e:
            if attempt == retries - 1:
                raise RuntimeError(f"Download failed: {full_url}\n{e}") from e
            wait = 65 if "429" in str(e) else 3 * (attempt + 1)
            print(f"    (problem: {e} -> waiting {wait} s)")
            time.sleep(wait)


def monthly_totals(path: Path, column: str) -> pd.DataFrame:
    """Daily values -> one total per region and month. Keeps only COMPLETE months."""
    d = pd.read_csv(path, parse_dates=["date"])
    d["month"] = d["date"].dt.to_period("M").dt.to_timestamp()
    m = d.groupby(["governorate", "month"]).agg(value=(column, "sum"), days=("date", "count")).reset_index()
    return m[m["days"] == m["month"].dt.days_in_month].drop(columns="days")
