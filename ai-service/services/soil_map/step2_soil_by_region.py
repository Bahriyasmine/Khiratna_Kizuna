"""SERVICE 2 (SOIL MAP) - STEP 2: THE SOIL OF EACH GOVERNORATE (over its whole area, not just one point).

How: we put a point every 0.02 degree (about 2 km) on Tunisia. For each point we find
     its governorate (official borders) and its soil zone (ISRIC map, step 1).
     Each point = the same area, so counting points = measuring areas.

Governorate borders: geoBoundaries "TUN ADM1" (from OpenStreetMap, licence ODbL)
     https://www.geoboundaries.org  -  file: raw/governorates.geojson

Creates:
  output/soil_samples.csv     every point: governorate, lat, lon, soil zone (used for crop ranking per region)
  output/soil_by_region.csv   for each governorate:
       area_km2                  land area covered by the soil map (lakes and lagoons left out)
       <code>_median             the TYPICAL value (half of the area is below, half above)
       salty_area_percent        % of the area with salinity ECe >= 4 dS/m (FAO-29: "saline")
       sodic_area_percent        % of the area with exchangeable sodium ESP >= 15 %
       main_soils                the 3 most common soil types and their % of the area

Run (from the ai-service/ folder):  python -m services.soil_map.step2_soil_by_region
"""
import json
import unicodedata
from functools import lru_cache

import numpy as np
import pandas as pd
from matplotlib.path import Path as Shape

from common import GOVERNORATES, SOIL_MAP
from services.soil_map.step1_soil_map import VARIABLES

STEP = 0.02                      # degrees between 2 points (about 2 km)
NUMERIC = [k for k in VARIABLES if k not in ("DomFAOgrou", "Lithology")]


def simple(name: str) -> str:
    """'Kébili' -> 'Kebili', 'El Kef' -> 'Kef' (to match our 24 names)."""
    name = unicodedata.normalize("NFKD", name).encode("ascii", "ignore").decode()
    return {"El Kef": "Kef"}.get(name, name)


def shapes_of(geometry: dict) -> list:
    """GeoJSON Polygon / MultiPolygon -> list of (border, holes) shapes."""
    polygons = [geometry["coordinates"]] if geometry["type"] == "Polygon" else geometry["coordinates"]
    return [(Shape(p[0]), [Shape(h) for h in p[1:]]) for p in polygons]


def inside(points: np.ndarray, shapes: list) -> np.ndarray:
    """True for each point that is inside one of the shapes (and not in a hole)."""
    result = np.zeros(len(points), bool)
    for border, holes in shapes:
        ok = border.contains_points(points)
        for h in holes:
            ok &= ~h.contains_points(points)
        result |= ok
    return result


def main():
    with open(SOIL_MAP / "raw" / "governorates.geojson", encoding="utf-8") as f:
        borders = json.load(f)
    with open(SOIL_MAP / "output" / "tunisia_soil.geojson", encoding="utf-8") as f:
        soil = json.load(f)

    lon, lat = np.meshgrid(np.arange(7.5, 11.7, STEP), np.arange(30.2, 37.6, STEP))
    pts = np.column_stack([lon.ravel(), lat.ravel()])

    region = np.full(len(pts), "", dtype=object)
    for ft in borders["features"]:
        name = simple(ft["properties"]["shapeName"])
        assert name in GOVERNORATES, name
        region[inside(pts, shapes_of(ft["geometry"]))] = name

    zone = np.full(len(pts), -1)
    for i, ft in enumerate(soil["features"]):
        todo = zone == -1
        zone[np.where(todo)[0][inside(pts[todo], shapes_of(ft["geometry"]))]] = i

    keep = (region != "") & (zone >= 0)
    props = pd.DataFrame([f["properties"] for f in soil["features"]])
    samples = props.iloc[zone[keep]].reset_index(drop=True)
    samples.insert(0, "governorate", region[keep])
    samples.insert(1, "lat", pts[keep, 1].round(3))
    samples.insert(2, "lon", pts[keep, 0].round(3))
    samples.to_csv(SOIL_MAP / "output" / "soil_samples.csv", index=False)
    print(f"  saved services/soil_map/output/soil_samples.csv ({len(samples)} points, 1 point = about 2 x 2 km)")

    rows = []
    for name in GOVERNORATES:
        s = samples[(samples["governorate"] == name) & (samples["DomFAOgrou"] != "WT")]   # land only, no lakes
        cell_km2 = (STEP * 111.32) ** 2 * np.cos(np.radians(s["lat"]))      # area of each point's square
        row = {"governorate": name, "area_km2": round(float(cell_km2.sum()))}
        for k in NUMERIC:
            row[f"{k}_median"] = round(float(s[k].median()), 2)
        row["salty_area_percent"] = round(100 * float(cell_km2[s["ELCO"] >= 4].sum() / cell_km2.sum()), 1)
        row["sodic_area_percent"] = round(100 * float(cell_km2[s["ESP"] >= 15].sum() / cell_km2.sum()), 1)
        share = cell_km2.groupby(s["soil_group"]).sum().sort_values(ascending=False) / cell_km2.sum() * 100
        row["main_soils"] = "; ".join(f"{g} {p:.0f}%" for g, p in share.head(3).items())
        rows.append(row)
    out = pd.DataFrame(rows)
    out.to_csv(SOIL_MAP / "output" / "soil_by_region.csv", index=False)
    print(f"  saved services/soil_map/output/soil_by_region.csv (24 governorates)")
    print(out[["governorate", "area_km2", "PHAQ_median", "ELCO_median", "salty_area_percent", "TCEQ_median",
               "main_soils"]].to_string(index=False))


@lru_cache
def regions() -> pd.DataFrame:
    """The result of this step: typical soil of each governorate."""
    return pd.read_csv(SOIL_MAP / "output" / "soil_by_region.csv").set_index("governorate")


def region_soil(region: str) -> dict:
    """The typical soil of one governorate (used by the map page and by service 3)."""
    if region not in GOVERNORATES:
        raise ValueError(f"Unknown region '{region}'. Choose one of: {', '.join(GOVERNORATES)}")
    r = regions().loc[region]
    return {"region": region, "area_km2": int(r.area_km2),
            "ece": r.ELCO_median, "ph": r.PHAQ_median, "esp": r.ESP_median, "limestone": r.TCEQ_median,
            "organic_carbon": r.TOTC_median, "nitrogen": r.TOTN_median, "water_capacity": r.TAWC_median,
            "salty_area_percent": r.salty_area_percent, "sodic_area_percent": r.sodic_area_percent,
            "main_soils": r.main_soils}


if __name__ == "__main__":
    main()
