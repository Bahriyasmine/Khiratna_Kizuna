"""SERVICE 2 (SOIL MAP) - STEP 3: EVALUATION. Is our soil map correct?

Service 2 is not a prediction model: it SHOWS an official map (ISRIC SOTER) and computes a typical soil per
governorate. So we check 2 things:

TEST 1 - Is our regional calculation correct? (area of the 24 governorates)
    Our method: a point every 0.02 degree, inside the borders. Area = number of points x area of one point.
    Compared with:
      a) the exact area of the same border polygon (checks our point method only)
      b) the official area of each governorate (Wikipedia "Governorates of Tunisia", source: Tunisian industry
         portal tunisieindustrie.nat.tn) -> also checks the borders file (geoBoundaries / OpenStreetMap)

TEST 2 - Are the soil values credible? (comparison with an independent soil product)
    SoilGrids 2.0 (ISRIC, 250 m, machine learning on 240 000 soil profiles, Poggio et al. 2021) is made with a
    completely different method than SOTER (expert 1:1M map). We download pH and organic carbon for Tunisia
    (WCS service, free) and compare, governorate by governorate, with the SOTER values of our map.
    Correlation close to 1 = the 2 sources agree on which regions have more / less.
    (Not 100 % independent: both are ISRIC products, but they use different data and methods.)

Creates  output/evaluation_areas.csv, output/evaluation_soilgrids.csv, output/evaluation_summary.json
         raw/soilgrids_<property>_<depth>.tif (downloaded once)

Run (from the ai-service/ folder):  python -m services.soil_map.step3_evaluate
"""
import json
import urllib.request

import numpy as np
import pandas as pd
from PIL import Image

from common import GOVERNORATES, SOIL_MAP, _SSL
from services.soil_map.step2_soil_by_region import STEP, inside, shapes_of, simple

RAW, OUT = SOIL_MAP / "raw", SOIL_MAP / "output"

# Official areas (km2): https://en.wikipedia.org/wiki/Governorates_of_Tunisia (source cited: tunisieindustrie.nat.tn)
OFFICIAL_KM2 = {
    "Tunis": 288, "Ariana": 482, "Ben Arous": 761, "Manouba": 1137, "Nabeul": 2788, "Zaghouan": 2820,
    "Bizerte": 3750, "Beja": 3740, "Jendouba": 3102, "Kef": 4965, "Siliana": 4642, "Sousse": 2669,
    "Monastir": 1019, "Mahdia": 2966, "Sfax": 7545, "Kairouan": 6712, "Kasserine": 8260, "Sidi Bouzid": 7405,
    "Gabes": 7166, "Medenine": 9167, "Tataouine": 38889, "Gafsa": 7807, "Tozeur": 5593, "Kebili": 22454,
}

# SoilGrids WCS: Tunisia box, 0.01 degree pixels (about 1 km)
WCS = ("https://maps.isric.org/mapserv?map=/map/{prop}.map&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage"
       "&COVERAGEID={prop}_{depth}_mean&FORMAT=image/tiff&SUBSET=X(7.5,11.7)&SUBSET=Y(30.2,37.6)"
       "&SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326&OUTPUTCRS=http://www.opengis.net/def/crs/EPSG/0/4326"
       "&SCALESIZE=X(420),Y(740)")
X0, Y0, PIX = 7.5, 37.6, 0.01
DEPTHS = {"0-5cm": 5, "5-15cm": 10, "15-30cm": 5}      # cm of each layer inside 0-20 cm (SOTER topsoil = 0-20 cm)
PROPS = {"phh2o": ("PHAQ", 10), "soc": ("TOTC", 10)}  # SoilGrids name -> (SOTER code, divide by)


def polygon_km2(geometry: dict) -> float:
    """Area of a GeoJSON polygon (km2), lon/lat projected with cos(latitude): good to < 0.5 % here."""
    polys = [geometry["coordinates"]] if geometry["type"] == "Polygon" else geometry["coordinates"]
    total = 0.0
    for poly in polys:
        for k, ring in enumerate(poly):
            lon, lat = np.array(ring).T
            x = lon * 111.32 * np.cos(np.radians(lat.mean()))
            y = lat * 110.57
            a = abs(0.5 * (np.dot(x, np.roll(y, 1)) - np.dot(y, np.roll(x, 1))))
            total += a if k == 0 else -a
    return total


def test_areas() -> pd.DataFrame:
    with open(RAW / "governorates.geojson", encoding="utf-8") as f:
        borders = json.load(f)
    lon, lat = np.meshgrid(np.arange(7.5, 11.7, STEP), np.arange(30.2, 37.6, STEP))
    pts = np.column_stack([lon.ravel(), lat.ravel()])
    rows = []
    for ft in borders["features"]:
        name = simple(ft["properties"]["shapeName"])
        mask = inside(pts, shapes_of(ft["geometry"]))
        ours = float(((STEP * 111.32) ** 2 * np.cos(np.radians(pts[mask, 1]))).sum())
        polygon = polygon_km2(ft["geometry"])
        rows.append({"governorate": name, "our_points_km2": round(ours), "border_polygon_km2": round(polygon),
                     "official_km2": OFFICIAL_KM2[name],
                     "error_vs_polygon_percent": round((ours - polygon) / polygon * 100, 1),
                     "error_vs_official_percent": round((ours - OFFICIAL_KM2[name]) / OFFICIAL_KM2[name] * 100, 1)})
    return pd.DataFrame(rows)


def soilgrids(prop: str) -> np.ndarray:
    """0-20 cm depth-weighted value of a SoilGrids property on the 0.01 degree grid (NaN = no data)."""
    layers, weights = [], []
    for depth, w in DEPTHS.items():
        path = RAW / f"soilgrids_{prop}_{depth}.tif"
        if not path.exists():
            with urllib.request.urlopen(WCS.format(prop=prop, depth=depth), context=_SSL, timeout=300) as r:
                path.write_bytes(r.read())
            print(f"  downloaded services/soil_map/raw/{path.name}")
        a = np.array(Image.open(path)).astype(float)
        a[a <= 0] = np.nan
        layers.append(a / PROPS[prop][1])
        weights.append(w)
    return np.average(np.ma.masked_invalid(np.stack(layers)), axis=0, weights=weights).filled(np.nan)


def test_soilgrids() -> pd.DataFrame:
    s = pd.read_csv(OUT / "soil_samples.csv")
    s = s[s["DomFAOgrou"] != "WT"]
    col = np.clip(((s["lon"] - X0) / PIX).astype(int), 0, 419)
    row = np.clip(((Y0 - s["lat"]) / PIX).astype(int), 0, 739)
    rows = []
    for prop, (code, _) in PROPS.items():
        grid = soilgrids(prop)
        s[f"sg_{prop}"] = grid[row, col]
    for g, d in s.groupby("governorate"):
        rows.append({"governorate": g,
                     "soter_ph": round(d["PHAQ"].median(), 2), "soilgrids_ph": round(d["sg_phh2o"].median(), 2),
                     "soter_organic_carbon_g_kg": round(d["TOTC"].median(), 2),
                     "soilgrids_organic_carbon_g_kg": round(d["sg_soc"].median(), 2)})
    return pd.DataFrame(rows)


def main():
    areas = test_areas()
    areas.to_csv(OUT / "evaluation_areas.csv", index=False)
    sg = test_soilgrids()
    sg.to_csv(OUT / "evaluation_soilgrids.csv", index=False)

    summary = {
        "areas_mean_abs_error_vs_polygon_percent": round(areas["error_vs_polygon_percent"].abs().mean(), 2),
        "areas_mean_abs_error_vs_official_percent": round(areas["error_vs_official_percent"].abs().mean(), 2),
        "areas_median_abs_error_vs_official_percent": round(areas["error_vs_official_percent"].abs().median(), 2),
        "ph_correlation_24_governorates": round(sg["soter_ph"].corr(sg["soilgrids_ph"], method="spearman"), 2),
        "ph_mean_abs_difference": round((sg["soter_ph"] - sg["soilgrids_ph"]).abs().mean(), 2),
        "organic_carbon_correlation_24_governorates": round(
            sg["soter_organic_carbon_g_kg"].corr(sg["soilgrids_organic_carbon_g_kg"], method="spearman"), 2),
        "organic_carbon_mean_abs_difference_g_kg": round(
            (sg["soter_organic_carbon_g_kg"] - sg["soilgrids_organic_carbon_g_kg"]).abs().mean(), 2),
    }
    with open(OUT / "evaluation_summary.json", "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2)
    print(areas.to_string(index=False))
    print(sg.to_string(index=False))
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
