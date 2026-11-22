"""SERVICE 4 (MARKET FORECAST) - STEP 1: DOWNLOAD THE OFFICIAL FAO STATISTICS OF TUNISIA.

Source: FAOSTAT, the statistics database of the FAO (UN) - https://www.fao.org/faostat/en/#data
        Bulk files for Africa (free, no key): https://bulks-faostat.fao.org/production/
          Production_Crops_Livestock_E_Africa.zip   tonnes produced, hectares harvested, yield   (1961-2024)
          Trade_CropsLivestock_E_Africa.zip         imports and exports, tonnes and US dollars   (1961-2024)
          Prices_E_Africa.zip                       price paid to the farmer, dinars per tonne   (1991-2022)
        Each file is downloaded, only the TUNISIA rows are kept, the big file is deleted.

Creates:  raw/tunisia_production.csv, raw/tunisia_trade.csv, raw/tunisia_prices.csv
          columns: item, element, unit, year, value
          raw/neighbours_yield.csv   yields of Morocco, Algeria, Egypt (to check Tunisian yields, step 3)

Run (from the ai-service/ folder):  python -m services.market.step1_download            (skips files that already exist)
                              python -m services.market.step1_download --refresh  (downloads again)
"""
import io
import sys
import urllib.request
import zipfile

import pandas as pd

from common import MARKET, _SSL

BASE = "https://bulks-faostat.fao.org/production/"
FILES = {"production": "Production_Crops_Livestock_E_Africa", "trade": "Trade_CropsLivestock_E_Africa",
         "prices": "Prices_E_Africa"}


NEIGHBOURS = ["Morocco", "Algeria", "Egypt"]


def read_zip(zip_bytes: bytes, name: str) -> pd.DataFrame:
    with zipfile.ZipFile(io.BytesIO(zip_bytes)) as z:
        with z.open(f"{name}_NOFLAG.csv") as f:
            return pd.read_csv(f, encoding="latin1", low_memory=False)


def to_rows(d: pd.DataFrame) -> pd.DataFrame:
    """Turns the year columns (Y1961...) into rows."""
    years = [c for c in d.columns if c.startswith("Y") and c[1:].isdigit()]
    long = d.melt(id_vars=["Area", "Item", "Element", "Unit"], value_vars=years, var_name="year").dropna(subset=["value"])
    long["year"] = long["year"].str[1:].astype(int)
    return long.rename(columns={"Area": "country", "Item": "item", "Element": "element", "Unit": "unit"})


def tunisia_only(d: pd.DataFrame) -> pd.DataFrame:
    """Keeps Tunisia."""
    d = d[d["Area"] == "Tunisia"]
    return to_rows(d).drop(columns="country")


def main():
    for short, name in FILES.items():
        out = MARKET / "raw" / f"tunisia_{short}.csv"
        if out.exists() and "--refresh" not in sys.argv:
            print(f"  [skip] raw/{out.name} already exists")
            continue
        print(f"  downloading {name}.zip ...")
        req = urllib.request.Request(BASE + name + ".zip", headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, context=_SSL, timeout=300) as r:
            full = read_zip(r.read(), name)
        data = tunisia_only(full)
        data.to_csv(out, index=False)
        if short == "production":
            nb = full[full["Area"].isin(NEIGHBOURS) & (full["Element"] == "Yield")]
            to_rows(nb).to_csv(MARKET / "raw" / "neighbours_yield.csv", index=False)
            print("  saved services/market/raw/neighbours_yield.csv")
        print(f"  saved services/market/raw/{out.name} ({len(data)} rows, {data['item'].nunique()} products)")


if __name__ == "__main__":
    main()
