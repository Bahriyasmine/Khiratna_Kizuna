"""SERVICE 5 (ENERGY) - STEP 1: DOWNLOAD THE ENERGY DATA OF TUNISIA.

1. Solar electricity per governorate - PVGIS (EU Joint Research Centre, free, no key)
   https://re.jrc.ec.europa.eu/pvg_tools/en/   API: https://re.jrc.ec.europa.eu/api/v5_2/PVcalc
   For 1 kWp of solar panels at the capital of each governorate (fixed, optimal angle, 14 % system losses):
   kWh produced per year and per month.                                    -> raw/pvgis_tunisia.csv
   (ANME gives the same order of size: 1 450 kWh/kWp in the north-west to 1 830 in the south-east)

2. Electricity of Tunisia - Our World in Data energy dataset (from Ember and the Energy Institute)
   https://github.com/owid/energy-data   CSV: owid-energy-data.csv
   Tunisia only: electricity demand and generation, share from gas, solar, wind, per year.   -> raw/tunisia_electricity.csv

Run (from the ai-service/ folder):  python -m services.energy.step1_download            (skips files that already exist)
"""
import io
import sys
import time
import urllib.request

import pandas as pd

from common import ENERGY, GOVERNORATES, _SSL, get_json

PVGIS = "https://re.jrc.ec.europa.eu/api/v5_2/PVcalc"
OWID = "https://raw.githubusercontent.com/owid/energy-data/master/owid-energy-data.csv"
OWID_COLUMNS = ["year", "electricity_demand", "electricity_generation", "gas_share_elec", "oil_share_elec",
                "solar_share_elec", "wind_share_elec", "renewables_share_elec", "solar_electricity", "wind_electricity",
                "net_elec_imports"]


def download_pvgis():
    path = ENERGY / "raw" / "pvgis_tunisia.csv"
    if path.exists() and "--refresh" not in sys.argv:
        print("  [skip] raw/pvgis_tunisia.csv already exists")
        return
    rows = []
    for region, (lat, lon) in GOVERNORATES.items():
        d = get_json(PVGIS, {"lat": lat, "lon": lon, "peakpower": 1, "loss": 14, "optimalangles": 1,
                             "outputformat": "json"})["outputs"]
        row = {"governorate": region, "kwh_per_kwp_year": round(d["totals"]["fixed"]["E_y"])}
        row.update({f"kwh_per_kwp_m{m['month']:02d}": round(m["E_m"], 1) for m in d["monthly"]["fixed"]})
        rows.append(row)
        print(f"  PVGIS: {region} {row['kwh_per_kwp_year']} kWh/kWp/year")
        time.sleep(0.3)
    pd.DataFrame(rows).to_csv(path, index=False)
    print("  saved services/energy/raw/pvgis_tunisia.csv")


def download_owid():
    path = ENERGY / "raw" / "tunisia_electricity.csv"
    if path.exists() and "--refresh" not in sys.argv:
        print("  [skip] raw/tunisia_electricity.csv already exists")
        return
    with urllib.request.urlopen(OWID, context=_SSL, timeout=300) as r:
        d = pd.read_csv(io.BytesIO(r.read()))
    t = d[(d["country"] == "Tunisia") & (d["year"] >= 2000)][OWID_COLUMNS]
    t.to_csv(path, index=False)
    print(f"  saved services/energy/raw/tunisia_electricity.csv ({len(t)} years)")


def main():
    download_pvgis()
    download_owid()


if __name__ == "__main__":
    main()
