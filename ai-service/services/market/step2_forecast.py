"""SERVICE 4 (MARKET FORECAST) - STEP 2: WHAT WILL TUNISIA LACK UNTIL 2027?

For each product, every year (FAOSTAT, step 1):
    consumption (demand)   = production + imports - exports          (tonnes, "apparent consumption")
    self-sufficiency (%)   = production / consumption x 100           (100 % = Tunisia covers its own needs)
    gap (missing tonnes)   = consumption - production                  (> 0 = Tunisia must import)

FORECAST 2025-2027 (time-series model): the THETA model (statsmodels; winner of the M3 forecasting competition).
    It mixes 2 lines: the long-term trend of 2000-2024, and a smoothed recent level (simple exponential smoothing).
    Production and consumption are forecast separately.
    Why Theta: we tested 7 models on the past (see backtest); models with a strong trend (Holt, linear trend)
    made 14-21 % error because Tunisian harvests jump with drought years; Theta / smoothing made about 11 %.

TEST (backtest): the model is trained up to 2018 and up to 2021, then it forecasts the next 3 years (like 2025-2027)
    and we compare with the real values -> average error (MAPE). Compared with a "naive" forecast (= last known year).

Creates  output/market_forecast.csv   product x year (2000-2027): production, imports, exports, consumption,
                                       self_sufficiency, gap, source (observed / forecast)
         output/backtest.csv          error of the model vs the naive forecast, for each product

Run (from the ai-service/ folder):  python -m services.market.step2_forecast
"""
import warnings

import numpy as np
import pandas as pd
from statsmodels.tsa.forecasting.theta import ThetaModel

from common import MARKET

warnings.filterwarnings("ignore")
FIRST, LAST, HORIZON = 2000, 2024, 2027

# Our id -> (FAOSTAT product name, French name, crop id of service 1 for the water, or None)
PRODUCTS = {
    "wheat": ("Wheat", "Wheat", "wheat"),
    "barley": ("Barley", "Barley", None),
    "maize": ("Maize (corn)", "Maize", None),
    "sorghum": ("Sorghum", "Sorghum", "sorghum"),
    "potato": ("Potatoes", "Potato", "potato"),
    "tomato": ("Tomatoes", "Tomato", "tomato"),
    "onion": ("Onions and shallots, dry (excluding dehydrated)", "Onion", "onion"),
    "pepper": ("Chillies and peppers, green (Capsicum spp. and Pimenta spp.)", "Pepper", "pepper"),
    "carrot": ("Carrots and turnips", "Carrot", "carrot"),
    "lettuce": ("Lettuce and chicory", "Lettuce", "lettuce"),
    "watermelon": ("Watermelons", "Watermelon", "watermelon"),
    "melon": ("Cantaloupes and other melons", "Melon", "melon"),
    "artichoke": ("Artichokes", "Artichoke", None),
    "strawberry": ("Strawberries", "Strawberry", None),
    "chickpea": ("Chick peas, dry", "Chickpea", None),
    "faba_bean": ("Broad beans and horse beans, dry", "Faba bean", None),
    "lentil": ("Lentils, dry", "Lentil", None),
    "orange": ("Oranges", "Orange", "citrus"),
    "tangerine": ("Tangerines, mandarins, clementines", "Tangerine", "citrus"),
    "lemon": ("Lemons and limes", "Lemon", "citrus"),
    "grapes": ("Grapes", "Grapes", "grapes"),
    "almond": ("Almonds, in shell", "Almond", "almond"),
    "apricot": ("Apricots", "Apricot", "apricot_peach"),
    "peach": ("Peaches and nectarines", "Peach", "apricot_peach"),
    "apple": ("Apples", "Apple", None),
    "fig": ("Figs", "Fig", None),
    "pistachio": ("Pistachios, in shell", "Pistachio", "pistachio"),
    "olive": ("Olives", "Olive", "olive"),
    "olive_oil": ("Olive oil", "Olive oil", None),
    "dates": ("Dates", "Dates", "date_palm"),
}


def series(table: pd.DataFrame, item: str, element: str) -> pd.Series:
    """One FAOSTAT series, every year 2000-2024 (missing year = 0)."""
    s = table[(table["item"] == item) & (table["element"] == element)].set_index("year")["value"]
    return s.reindex(range(FIRST, LAST + 1)).fillna(0.0)


def theta(values: pd.Series, steps: int) -> np.ndarray:
    """Theta forecast for a yearly series. Never below 0. If the series is all zero, the forecast is zero."""
    if values.max() == 0:
        return np.zeros(steps)
    y = pd.Series(values.to_numpy(float), index=pd.RangeIndex(len(values)))
    fit = ThetaModel(y, period=1, deseasonalize=False).fit()
    return np.clip(fit.forecast(steps).to_numpy(), 0, None)


def mape(real: np.ndarray, pred: np.ndarray) -> float:
    """Mean absolute percentage error, on the years where the real value is not 0."""
    ok = real > 0
    return float(np.mean(np.abs(pred[ok] - real[ok]) / real[ok]) * 100) if ok.any() else np.nan


def main():
    prod = pd.read_csv(MARKET / "raw" / "tunisia_production.csv")
    trade = pd.read_csv(MARKET / "raw" / "tunisia_trade.csv")
    rows, tests = [], []
    future = list(range(LAST + 1, HORIZON + 1))

    for pid, (item, name, _) in PRODUCTS.items():
        p = series(prod, item, "Production")
        i = series(trade, item, "Import quantity")
        e = series(trade, item, "Export quantity")
        demand = (p + i - e).clip(lower=0)

        # backtest: train up to 2018 (test 2019-2021) and up to 2021 (test 2022-2024)
        for what, s in (("production", p), ("consumption", demand)):
            for cut in (2018, 2021):
                real = s.loc[cut + 1:cut + 3].to_numpy()
                tests.append({"product": pid, "series": what, "trained_until": cut,
                              "model_error_percent": round(mape(real, theta(s.loc[FIRST:cut], len(real))), 1),
                              "naive_error_percent": round(mape(real, np.full(len(real), s.loc[cut])), 1)})

        p_f, d_f = theta(p, len(future)), theta(demand, len(future))
        for y in range(FIRST, LAST + 1):
            rows.append({"product": pid, "name": name, "year": y, "source": "observed",
                         "production": p[y], "imports": i[y], "exports": e[y], "consumption": demand[y]})
        for k, y in enumerate(future):
            rows.append({"product": pid, "name": name, "year": y, "source": "forecast",
                         "production": p_f[k], "imports": np.nan, "exports": np.nan, "consumption": d_f[k]})

    out = pd.DataFrame(rows)
    out["gap"] = out["consumption"] - out["production"]
    out["self_sufficiency"] = np.where(out["consumption"] > 0, out["production"] / out["consumption"] * 100, np.nan)
    out = out.round({"production": 0, "imports": 0, "exports": 0, "consumption": 0, "gap": 0, "self_sufficiency": 1})
    out.to_csv(MARKET / "output" / "market_forecast.csv", index=False)

    bt = pd.DataFrame(tests)
    bt.to_csv(MARKET / "output" / "backtest.csv", index=False)
    print(f"  saved services/market/output/market_forecast.csv ({len(out)} rows, {len(PRODUCTS)} products, 2000-{HORIZON})")
    print("  backtest (2 test periods of 3 years), median error:")
    print(bt.groupby("series")[["model_error_percent", "naive_error_percent"]].median().to_string())

    last = out[out["year"].isin([LAST, HORIZON])].pivot(index="product", columns="year",
                                                       values=["self_sufficiency", "gap"])
    print(last.sort_values(("gap", HORIZON), ascending=False).head(10).to_string())


if __name__ == "__main__":
    main()
