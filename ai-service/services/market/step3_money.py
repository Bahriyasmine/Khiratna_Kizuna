"""SERVICE 4 (MARKET FORECAST) - STEP 3: WHICH CROPS EARN THE FARMER MORE MONEY?

For each product (FAOSTAT, step 1):
    farm price 2025 (TND/tonne) = price paid to the Tunisian farmer, brought up to 2025:
            last real price ("Producer Price (LCU/tonne)", most series stop in 2022)
            x  Producer Price Index 2025 / Producer Price Index of that year
            (the FAOSTAT index goes to 2025; its 2023-2025 values are FAO estimates, flag "E")
    price change (% per year)   = average yearly change of the price index over 2015-2025
    yield (tonnes/ha)           = average of 2022-2024
        YIELD CHECK: if the Tunisian yield is more than 2x the median of Morocco, Algeria and Egypt, the
        FAOSTAT value is not credible (watermelon: 103 t/ha vs 38 t/ha; the harvested area is probably
        under-reported) -> we use the neighbours' median and say it.
    revenue (TND/ha)            = yield x farm price   (GROSS revenue: costs are not included)
    import price (USD/tonne)    = import value / import quantity, 2022-2024 (only if >= 100 t were imported)
                                  = what Tunisia pays abroad: the market a local farmer could take

Then, for one governorate and planting month, with the water of service 1
(only crops that the FAO crop calendar of Tunisia allows to sow in that month, step 4):
    water to add (m3/ha)        = service 1, 12 months after planting
    dinars per m3 of water      = revenue / water   -> the best use of scarce water

Creates  output/crop_money.csv

Run (from the ai-service/ folder):  python -m services.market.step3_money
"""
from functools import lru_cache

import numpy as np
import pandas as pd

from common import GOVERNORATES, MARKET
from services.market.step2_forecast import PRODUCTS
from services.market.step4_planting_calendar import status as planting_status
from services.rainfall.step4_water_to_add import water_to_add

PRICE_YEAR = 2025      # prices are brought up to this year with the FAOSTAT producer price index


def last_values(s: pd.Series, n: int = 3) -> tuple:
    """Average of the last n years that have a value, and the last year."""
    s = s.dropna()
    return (float(s.iloc[-n:].mean()), int(s.index[-1])) if len(s) else (np.nan, None)


def main():
    prod = pd.read_csv(MARKET / "raw" / "tunisia_production.csv")
    trade = pd.read_csv(MARKET / "raw" / "tunisia_trade.csv")
    prices = pd.read_csv(MARKET / "raw" / "tunisia_prices.csv")
    nb = pd.read_csv(MARKET / "raw" / "neighbours_yield.csv")
    nb = nb[nb["year"].between(2022, 2024)].groupby(["item", "country"])["value"].mean().groupby("item").median() / 1000
    rows = []
    for pid, (item, name, crop) in PRODUCTS.items():
        mine = prices[prices["item"] == item]
        pr = mine[mine["element"] == "Producer Price (LCU/tonne)"].set_index("year")["value"].dropna()
        index = mine[mine["element"] == "Producer Price Index (2014-2016 = 100)"].set_index("year")["value"].dropna()
        price, price_year, change = np.nan, None, np.nan
        if len(pr):
            price_year = int(pr.index[-1])
            price = float(pr.iloc[-1])
            if PRICE_YEAR in index.index and price_year in index.index:     # bring the price up to 2025
                price = price * index[PRICE_YEAR] / index[price_year]
                price_year = PRICE_YEAR
        if 2015 in index.index and PRICE_YEAR in index.index:
            change = ((index[PRICE_YEAR] / index[2015]) ** (1 / (PRICE_YEAR - 2015)) - 1) * 100

        y = prod[(prod["item"] == item) & (prod["element"] == "Yield")].set_index("year")["value"]
        yield_t = y.loc[2022:2024].mean() / 1000 if len(y.loc[2022:2024]) else np.nan       # kg/ha -> t/ha
        yield_note = ""
        if item in nb.index and yield_t > 2 * nb[item]:
            yield_note = (f"FAOSTAT yield {yield_t:.0f} t/ha is {yield_t / nb[item]:.1f}x Morocco/Algeria/Egypt: "
                          f"not credible, we use their median {nb[item]:.0f} t/ha")
            yield_t = nb[item]

        t = trade[trade["item"] == item]
        qty = t[t["element"] == "Import quantity"].set_index("year")["value"].loc[2022:2024].sum()
        val = t[t["element"] == "Import value"].set_index("year")["value"].loc[2022:2024].sum()   # 1000 USD
        import_price = val * 1000 / qty if qty >= 100 and val > 0 else np.nan   # too small = not meaningful

        rows.append({"product": pid, "name": name, "water_crop": crop,
                     "farm_price_tnd_per_t": price, "price_year": price_year,
                     "price_change_percent_per_year": change, "yield_t_per_ha": yield_t,
                     "revenue_tnd_per_ha": yield_t * price, "import_price_usd_per_t": import_price,
                     "yield_note": yield_note})
    out = pd.DataFrame(rows).round({"farm_price_tnd_per_t": 0, "price_change_percent_per_year": 1, "yield_t_per_ha": 2,
                                    "revenue_tnd_per_ha": 0, "import_price_usd_per_t": 0})
    out.to_csv(MARKET / "output" / "crop_money.csv", index=False)
    print(f"  saved services/market/output/crop_money.csv ({len(out)} products)")
    print(out.sort_values("revenue_tnd_per_ha", ascending=False)[
        ["product", "farm_price_tnd_per_t", "price_year", "yield_t_per_ha", "revenue_tnd_per_ha",
         "price_change_percent_per_year", "import_price_usd_per_t"]].to_string(index=False))


@lru_cache
def money() -> pd.DataFrame:
    return pd.read_csv(MARKET / "output" / "crop_money.csv").set_index("product")


@lru_cache
def forecast() -> pd.DataFrame:
    return pd.read_csv(MARKET / "output" / "market_forecast.csv")


def water_12_months(region: str, crop: str, planting_month: int) -> float:
    """Water to add (m3/ha) during the 12 months after planting in 2026 (service 1)."""
    start = f"2026-{planting_month:02d}"
    end = (pd.Timestamp(start + "-01") + pd.DateOffset(months=11)).strftime("%Y-%m")
    return water_to_add(region, crop, start, end)["total"]["water_to_add_m3_per_ha"]


def overview(region: str = "Kairouan", planting_month: int = 3) -> dict:
    """Every product: what Tunisia lacks (2024 and 2027) + what it earns, with water for one governorate."""
    if region not in GOVERNORATES:
        raise ValueError(f"Unknown region '{region}'. Choose one of: {', '.join(GOVERNORATES)}")
    if not 1 <= planting_month <= 12:
        raise ValueError("planting_month must be 1 to 12")
    f = forecast()
    products = []
    for pid, m in money().iterrows():
        now = f[(f["product"] == pid) & (f["year"] == 2024)].iloc[0]
        later = f[(f["product"] == pid) & (f["year"] == 2027)].iloc[0]
        water = water_12_months(region, m.water_crop, planting_month) if isinstance(m.water_crop, str) else None
        revenue = None if pd.isna(m.revenue_tnd_per_ha) else float(m.revenue_tnd_per_ha)
        products.append({
            "product": pid, "name": m["name"],   # m.name would be the row label (the product id)
            "production_2024_t": now.production, "consumption_2024_t": now.consumption,
            "self_sufficiency_2024": None if pd.isna(now.self_sufficiency) else now.self_sufficiency,
            "self_sufficiency_2027": None if pd.isna(later.self_sufficiency) else later.self_sufficiency,
            "missing_2024_t": max(now.gap, 0), "missing_2027_t": max(later.gap, 0),
            "exports_2024_t": now.exports,
            "farm_price_tnd_per_t": None if pd.isna(m.farm_price_tnd_per_t) else m.farm_price_tnd_per_t,
            "price_year": None if pd.isna(m.price_year) else int(m.price_year),
            "price_change_percent_per_year": None if pd.isna(m.price_change_percent_per_year) else m.price_change_percent_per_year,
            "yield_t_per_ha": None if pd.isna(m.yield_t_per_ha) else m.yield_t_per_ha,
            "revenue_tnd_per_ha": revenue,
            "import_price_usd_per_t": None if pd.isna(m.import_price_usd_per_t) else m.import_price_usd_per_t,
            "water_m3_per_ha": water,
            "tnd_per_m3_water": round(revenue / water, 2) if revenue and water else None,
            # Tunisia really lacks it: below 90 % self-sufficiency and at least 1 000 t missing in 2027
            "tunisia_lacks_it": bool(later.self_sufficiency < 90 and later.gap >= 1000),
            # Tunisia already produces all it needs: more production can push the price down
            "market_full": bool(later.self_sufficiency >= 100),
            "yield_note": m.yield_note if isinstance(m.yield_note, str) else "",
            # FAO crop calendar of Tunisia (step 4): can it be sown in this month?
            "planting_status": planting_status(pid, planting_month, region),
        })
    lacks = sorted([p for p in products if p["tunisia_lacks_it"]], key=lambda p: -p["missing_2027_t"])
    earns = sorted([p for p in products if p["revenue_tnd_per_ha"]], key=lambda p: -p["revenue_tnd_per_ha"])
    ranked = sorted([p for p in products if p["tnd_per_m3_water"]], key=lambda p: -p["tnd_per_m3_water"])
    # only crops that can really be sown in the open field this month (or trees already in the field)
    per_water = [p for p in ranked if p["planting_status"] in ("open_field", "tree")]
    protected = [p for p in ranked if p["planting_status"] == "protected"]           # tunnel / greenhouse only
    not_in_season = [p["product"] for p in ranked if p["planting_status"] == "not_in_season"]
    frost_risk = [p["product"] for p in ranked if p["planting_status"] == "frost_risk"]
    return {"region": region, "planting_month": planting_month, "lacks": lacks, "earns": earns,
            "protected_only": protected, "not_in_season": not_in_season, "frost_risk": frost_risk,
            "per_water": per_water, "products": products}


def history(product: str) -> dict:
    """Year by year 2000-2027 for one product (for the chart)."""
    f = forecast()
    if product not in set(f["product"]):
        raise ValueError(f"Unknown product '{product}'. Choose one of: {', '.join(sorted(f['product'].unique()))}")
    rows = f[f["product"] == product].replace({np.nan: None})
    return {"product": product, "years": rows.to_dict(orient="records")}


if __name__ == "__main__":
    main()
