"""SERVICE 2 (SOIL MAP) - STEP 1: THE SOIL MAP OF TUNISIA (one file, ready for the map page).

Source: ISRIC SOTER database for Tunisia, scale 1:1 million (ISRIC = World Soil Information, Netherlands).
        Tunisia is cut into ~750 zones (polygons). Each zone has one ID (SUID) and its soil values.
        ISRIC record: https://data.isric.org/geonetwork/srv/eng/catalog.search#/metadata/be18fb28-4f85-41d0-a448-6d56fba8bd3b
        Soil values (SOTWIS): https://data.isric.org/geonetwork/srv/eng/catalog.search#/metadata/ec96be43-c10a-4580-8b6f-4db46ec29bbd
        Our copy comes from the FarmWise project (soil_composition/static_geo/), as 3 GeoJSON files:
          raw/params.geojson   soil values: pH, salinity, limestone, nitrogen... (codes below)
          raw/soter.geojson    terrain: elevation, slope, relief, rock type
          raw/units.geojson    main soil group (FAO code: CL = Calcisol...)

This script joins the 3 files by zone ID (SUID) and makes:
  output/tunisia_soil.geojson    the map (1 shape per zone, all values together)

Run (from the ai-service/ folder):  python -m services.soil_map.step1_soil_map
"""
import json

from common import SOIL_MAP

RAW = SOIL_MAP / "raw"
OUT = SOIL_MAP / "output"

# Code -> (name, unit). Definitions and units: ISRIC Report 2010/01 "Soil property estimates for Tunisia derived from
# SOTER and WISE (SOTWIS-Tunisia)", N.H. Batjes, Appendix 4 - https://www.isric.org/sites/default/files/isric_report_2010_01.pdf
# Our values = the DOMINANT soil of each zone, top layer 0-20 cm (the table ISRIC made for maps, appendix 4 note 3).
VARIABLES = {
    "PHAQ": ("pH (in water)", ""),
    "ELCO": ("Salinity ECe (electrical conductivity)", "dS/m"),
    "ESP": ("Exchangeable sodium", "%"),
    "TCEQ": ("Limestone (carbonate equivalent)", "g/kg"),
    "GYPS": ("Gypsum", "g/kg"),
    "TOTC": ("Organic carbon", "g/kg"),
    "TOTN": ("Total nitrogen", "g/kg"),
    "TAWC": ("Available water capacity", "vol % = cm per m of soil"),
    "CECS": ("Cation exchange capacity (fertility)", "cmol/kg"),
    "BSAT": ("Base saturation", "%"),
    "BULK": ("Bulk density", "kg/dm3"),
    "CFRAG": ("Coarse fragments (stones)", "% volume"),
    "ALSA": ("Aluminium saturation", "%"),
    "Elev_med": ("Elevation (median)", "m"),
    "Slope_med": ("Slope (median)", "%"),
    "Relief_med": ("Relief (median)", "m"),
    "DomFAOgrou": ("Main soil group (FAO)", ""),
    "Lithology": ("Rock type (SOTER code)", ""),
}

# FAO soil group codes (FAO soil legend / World Reference Base) -> simple name.
SOIL_GROUPS = {
    "CL": "Calcisol (limestone soil)", "CM": "Cambisol (young soil)", "LP": "Leptosol (shallow, stony)",
    "FL": "Fluvisol (river deposits)", "RG": "Regosol (weakly developed)", "SC": "Solonchak (salty soil)",
    "GY": "Gypsisol (gypsum soil)", "VR": "Vertisol (heavy clay)", "AR": "Arenosol (sand)",
    "LV": "Luvisol (clay-enriched)", "SN": "Solonetz (sodic soil)", "GL": "Gleysol (waterlogged)",
    "KS": "Kastanozem (steppe soil)", "AL": "Alisol (acid clay soil)", "PL": "Planosol (seasonally wet)",
    "WT": "Water (lake, lagoon)",
}


def load(name: str) -> dict:
    with open(RAW / f"{name}.geojson", encoding="utf-8") as f:
        return json.load(f)


def values_by_zone(geo: dict, keys) -> dict:
    """{SUID: {code: value}} for the wanted codes."""
    return {ft["properties"]["SUID"]: {k: ft["properties"].get(k) for k in keys} for ft in geo["features"]}


def point_in_zone(lon: float, lat: float, polygon: list) -> bool:
    """Is the point inside the polygon? (ray casting; ring 0 = border, other rings = holes)."""
    def in_ring(ring):
        inside = False
        for (x1, y1), (x2, y2) in zip(ring, ring[1:] + ring[:1]):
            if (y1 > lat) != (y2 > lat) and lon < (x2 - x1) * (lat - y1) / (y2 - y1) + x1:
                inside = not inside
        return inside
    return in_ring(polygon[0]) and not any(in_ring(hole) for hole in polygon[1:])


def soil_at(lat: float, lon: float, geo: dict):
    """Soil values of the zone that contains the point, or None (sea, outside Tunisia)."""
    for ft in geo["features"]:
        if point_in_zone(lon, lat, ft["geometry"]["coordinates"]):
            return ft["properties"]
    return None


def main():
    terrain = load("soter")
    params = values_by_zone(load("params"), [k for k in VARIABLES if k.isupper() and k != "DomFAOgrou"])
    groups = values_by_zone(load("units"), ["DomFAOgrou"])

    features = []
    for ft in terrain["features"]:
        suid = ft["properties"]["SUID"]
        props = {"SUID": suid, **{k: ft["properties"].get(k) for k in ("Elev_med", "Slope_med", "Relief_med", "Lithology")},
                 **params.get(suid, {}), **groups.get(suid, {})}
        props["soil_group"] = SOIL_GROUPS.get(props.get("DomFAOgrou"), props.get("DomFAOgrou"))
        rings = [[[round(x, 4), round(y, 4)] for x, y in ring] for ring in ft["geometry"]["coordinates"]]
        features.append({"type": "Feature", "properties": props, "geometry": {"type": "Polygon", "coordinates": rings}})
    geo = {"type": "FeatureCollection", "features": features}
    with open(OUT / "tunisia_soil.geojson", "w", encoding="utf-8") as f:
        json.dump(geo, f, separators=(",", ":"))
    print(f"  saved services/soil_map/output/tunisia_soil.geojson ({len(features)} zones)")

if __name__ == "__main__":
    main()
