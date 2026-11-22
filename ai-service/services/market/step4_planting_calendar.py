"""SERVICE 4 (MARKET FORECAST) - STEP 4: CAN THIS CROP BE PLANTED IN THIS MONTH? (safeguard)

Problem: "dinars per m3" assumes the crop can grow in the month the farmer chose. Watermelon sown outdoors in
December would freeze, yet in winter it needs little water, so it would look like the best choice.

Source: FAO Crop Calendar - Tunisia (sowing windows per crop and agro-ecological zone, 86 entries, updated 2021)
        https://cropcalendar.apps.fao.org   API: https://api-cropcalendar.apps.fao.org/api/v1/countries/TN/cropCalendar
        -> raw/fao_crop_calendar_tunisia.json

REGIONAL: each governorate uses the sowing dates of ITS agro-ecological zone (GOV_ZONES below, our mapping from
the zone names of the FAO calendar). If its zone has no dates for a crop, the reference zone
"North East and Cap Bon" is used (the only zone with dates for most vegetables).
Example: melon can be sown in December only in the "hot zone with mild winters" (south), not in Bizerte.

For each governorate, crop and month:
    open_field   = the month is inside an open-field sowing window of at least one zone of Tunisia
    protected    = the month is only inside a window "sous serre / sous tunnels / sous brise vent"
                   (greenhouse, tunnel or windbreak: extra costs, not included in our revenue)
    not_in_season= the month is in no sowing window
    no_data      = the FAO calendar has no sowing dates for this crop (chickpea, broad bean)
    tree         = fruit trees, olive, dates: already in the field, the planting month does not apply

FROST CHECK per governorate (the FAO calendar is national: melon can be sown in December in the hot south,
not in Sidi Bouzid where it freezes):
    frost days per month = NASA POWER climatology 2001-2025 (https://power.larc.nasa.gov, free, no key)
    frost-sensitive crop = warm-season crop: FAO EcoCrop minimum temperature >= 7 C
                           (watermelon, melon, tomato, pepper, potato, sorghum)
    frost risk           = frost-sensitive crop AND at least 0.5 frost day on average in the planting month
                           + the next month (young plants)

Creates  output/planting_calendar.csv   (governorate x crop x 12 months -> status)
         raw/nasa_frost_days.csv        (governorate x 12 months, downloaded once)

Run (from the ai-service/ folder):  python -m services.market.step4_planting_calendar
"""
import json
import urllib.request
from functools import lru_cache

import pandas as pd

from common import CROP_SUITABILITY, GOVERNORATES, MARKET, _SSL, get_json

URL = "https://api-cropcalendar.apps.fao.org/api/v1/countries/TN/cropCalendar?language=en"
RAW = MARKET / "raw" / "fao_crop_calendar_tunisia.json"

# our product -> crop names in the FAO calendar
FAO_NAMES = {
    "wheat": ["Wheat, durum", "Wheat, bread"], "barley": ["Barley"], "sorghum": ["Sorghum"], "potato": ["Potato"],
    "tomato": ["Tomato"], "onion": ["Onion"], "pepper": ["Pepper, chili"], "carrot": ["Carrot"],
    "lettuce": ["Lettuce"], "watermelon": ["Watermelon"], "melon": ["Melon"], "artichoke": ["Artichoke"],
    "chickpea": ["Chick-pea"], "lentil": ["Lentil"], "faba_bean": ["Bean, broad"],
}
TREES = {"orange", "tangerine", "lemon", "grapes", "almond", "apricot", "peach", "apple", "fig", "pistachio",
         "olive", "olive_oil", "dates"}
PROTECTED_WORDS = ("serre", "tunnel", "brise")   # read in the label of each sowing session
ECOCROP = {"watermelon": "Citrullus lanatus", "melon": "Cucumis melo", "tomato": "Lycopersicon esculentum",
           "pepper": "Capsicum annuum", "potato": "Solanum tuberosum", "sorghum": "Sorghum bicolor",
           "onion": "Allium cepa", "carrot": "Daucus carota", "lettuce": "Lactuca sativa var. capitata",
           "wheat": "Triticum durum", "barley": "Hordeum vulgare", "artichoke": "Cynara scolymus",
           "lentil": "Lens culinaris", "chickpea": "Cicer arietinum", "faba_bean": "Vicia faba"}
MONTH_KEYS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
FROST_FILE = MARKET / "raw" / "nasa_frost_days.csv"

# Governorate -> FAO calendar zones, most specific first (our mapping from the zone names).
REFERENCE = "North East and Cap Bon (semi arid with mild winters)"
NORTH = ["Kroumirie - Mogods", "Sub-humid", "sub-wet and semi arid", "irrigated areas in the North"]
NORTH_EAST = [REFERENCE, "irrigated areas of Cap Bon and Central", "irrigated areas in central and Cap Bon"]
HIGH_TELL = ["Semiarid fresh winter", "upper semi-arid"]
SAHEL = ["Lower Steppe (arid with mild winters)", "irrigated areas of Cap Bon and Central"]
SOUTH = ["hot zone with mild winters", "Lower Steppe (arid with mild winters)"]
GOV_ZONES = {
    "Bizerte": NORTH, "Beja": NORTH, "Jendouba": NORTH,
    "Tunis": NORTH_EAST, "Ariana": NORTH_EAST, "Ben Arous": NORTH_EAST, "Manouba": NORTH_EAST,
    "Nabeul": NORTH_EAST, "Zaghouan": NORTH_EAST,
    "Kef": HIGH_TELL, "Siliana": HIGH_TELL,
    "Kairouan": ["Dorsal and Tell (Kairouan)", "irrigated areas in central and Cap Bon"],
    "Sidi Bouzid": ["Sidi Bouzid"] + HIGH_TELL, "Kasserine": ["Sidi Bouzid"] + HIGH_TELL, "Gafsa": ["Sidi Bouzid"],
    "Sousse": SAHEL, "Monastir": SAHEL, "Mahdia": SAHEL, "Sfax": SAHEL,
    "Gabes": SOUTH, "Medenine": SOUTH, "Tataouine": SOUTH, "Tozeur": SOUTH, "Kebili": SOUTH,
}


def months_between(first: int, last: int) -> set:
    """Sowing window as a set of months, also across the new year (10 -> 2 = Oct..Feb)."""
    return {(first - 1 + k) % 12 + 1 for k in range((last - first) % 12 + 1)}


def download() -> list:
    if not RAW.exists():
        with urllib.request.urlopen(URL, context=_SSL, timeout=120) as r:
            RAW.write_bytes(r.read())
        print("  saved services/market/raw/fao_crop_calendar_tunisia.json")
    with open(RAW, encoding="utf-8") as f:
        return json.load(f)


def download_frost() -> pd.DataFrame:
    """Average number of frost days per month and governorate (NASA POWER climatology), downloaded once."""
    if not FROST_FILE.exists():
        rows = []
        for region, (lat, lon) in GOVERNORATES.items():
            p = get_json("https://power.larc.nasa.gov/api/temporal/climatology/point",
                         {"parameters": "FROST_DAYS", "community": "AG", "longitude": lon, "latitude": lat,
                          "format": "JSON"})["properties"]["parameter"]["FROST_DAYS"]
            rows += [{"governorate": region, "month": i + 1, "frost_days": p[k]} for i, k in enumerate(MONTH_KEYS)]
        pd.DataFrame(rows).to_csv(FROST_FILE, index=False)
        print("  saved services/market/raw/nasa_frost_days.csv")
    return pd.read_csv(FROST_FILE)


def frost_sensitive_crops() -> dict:
    """Crop -> EcoCrop minimum temperature; frost-sensitive if >= 7 C."""
    eco = pd.read_csv(CROP_SUITABILITY / "raw" / "EcoCrop_DB.csv", encoding="latin1").set_index("ScientificName")
    return {crop: float(eco.loc[name, "TMIN"]) for crop, name in ECOCROP.items()}


def main():
    download_frost()
    tmin = frost_sensitive_crops()
    pd.DataFrame([{"product": c, "ecocrop_min_temperature": t, "frost_sensitive": t >= 7} for c, t in tmin.items()])         .to_csv(MARKET / "output" / "frost_sensitive_crops.csv", index=False)
    print("  frost-sensitive (EcoCrop min temperature >= 7 C):", [c for c, t in tmin.items() if t >= 7])
    calendar = download()

    def windows(product: str, zone: str):
        """Open-field and protected sowing months of a crop in one zone (None if the zone has no dates)."""
        open_field, protected = set(), set()
        for entry in calendar:
            if entry["crop"]["name"] not in FAO_NAMES[product] or entry["aez"]["name"] != zone:
                continue
            for s in entry["sessions"]:
                window = months_between(int(s["early_sowing"]["month"]), int(s["later_sowing"]["month"]))
                text = s.get("additional_information", "").lower()        # e.g. "Primeur sous tunnels"
                (protected if any(w in text for w in PROTECTED_WORDS) else open_field).update(window)
        return (open_field, protected) if (open_field or protected) else None

    rows = []
    for region in GOVERNORATES:
        for product in FAO_NAMES:
            found = next((w for z in GOV_ZONES[region] + [REFERENCE] if (w := windows(product, z))), None)
            for m in range(1, 13):
                if found is None:
                    status = "no_data"
                else:
                    open_field, protected = found
                    status = "open_field" if m in open_field else "protected" if m in protected else "not_in_season"
                rows.append({"governorate": region, "product": product, "month": m, "status": status})
        rows += [{"governorate": region, "product": t, "month": m, "status": "tree"} for t in TREES for m in range(1, 13)]
    out = pd.DataFrame(rows)
    out.to_csv(MARKET / "output" / "planting_calendar.csv", index=False)
    print(f"  saved services/market/output/planting_calendar.csv")
    for region in ("Bizerte", "Nabeul", "Kebili"):
        print(" ", region)
        t = out[(out["governorate"] == region) & out["product"].isin(["melon", "watermelon", "pepper", "tomato", "potato"])]
        print(t.pivot(index="product", columns="month", values="status")
              .replace({"open_field": "OK", "protected": "tun", "not_in_season": "-", "no_data": "?"}).to_string())


@lru_cache
def calendar_table() -> pd.DataFrame:
    return pd.read_csv(MARKET / "output" / "planting_calendar.csv").set_index(["governorate", "product", "month"])


@lru_cache
def frost_table() -> pd.DataFrame:
    return pd.read_csv(FROST_FILE).set_index(["governorate", "month"])


@lru_cache
def sensitive() -> set:
    t = pd.read_csv(MARKET / "output" / "frost_sensitive_crops.csv")
    return set(t.loc[t["frost_sensitive"], "product"])


def status(product: str, month: int, region: str) -> str:
    """open_field / frost_risk / protected / not_in_season / no_data / tree / unknown"""
    try:
        st = calendar_table().loc[(region, product, month), "status"]
    except KeyError:
        return "unknown"
    if st == "open_field" and product in sensitive():
        next_month = month % 12 + 1
        frost = frost_table().loc[(region, month), "frost_days"] + frost_table().loc[(region, next_month), "frost_days"]
        if frost >= 0.5:
            return "frost_risk"
    return st


if __name__ == "__main__":
    main()
