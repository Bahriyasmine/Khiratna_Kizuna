"""STEP 1 - Download the real weather history of the 24 regions.

Source: Open-Meteo Historical Weather API (free, no key) - https://open-meteo.com/en/docs/historical-weather-api
        It gives ERA5 data (the European climate service Copernicus), one value per day.

Creates:
  raw/rain_history.csv   rain of every day since 2000 (mm)                                -> step 2
  raw/et0_history.csv    ET0 of every day since 2010 (mm): how much water the sun,       -> step 3
                         heat and wind take from a field (Open-Meteo computes it with
                         the official FAO-56 Penman-Monteith formula)

Run (from the ai-service/ folder):  python -m services.rainfall.step1_download            (skips files that already exist)
      python -m services.rainfall.step1_download --refresh  (downloads again, to get the newest months)
"""
import sys
from datetime import date, timedelta

import pandas as pd

from common import GOVERNORATES, RAINFALL, get_json

URL = "https://archive-api.open-meteo.com/v1/archive"
END = (date.today() - timedelta(days=6)).isoformat()  # the archive is ~5 days behind today


def download(file_name: str, variable: str, first_day: str):
    """Downloads one daily variable for the 24 regions and saves it in raw/."""
    path = RAINFALL / "raw" / file_name
    if path.exists() and "--refresh" not in sys.argv:
        print(f"  [skip] raw/{file_name} already exists")
        return
    frames = []
    for i, (region, (lat, lon)) in enumerate(GOVERNORATES.items(), 1):
        print(f"  {variable}: {region} ({i}/24)")
        data = get_json(URL, {"latitude": lat, "longitude": lon, "start_date": first_day, "end_date": END,
                              "daily": variable, "timezone": "Africa/Tunis"})
        df = pd.DataFrame(data["daily"]).rename(columns={"time": "date"})
        df.insert(0, "governorate", region)
        frames.append(df)
    pd.concat(frames).to_csv(path, index=False)
    print(f"  saved raw/{file_name}")


def main():
    download("rain_history.csv", "precipitation_sum", "2000-01-01")
    download("et0_history.csv", "et0_fao_evapotranspiration", "2010-01-01")


if __name__ == "__main__":
    main()
