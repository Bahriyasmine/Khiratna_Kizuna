"""STEP 2 - RAIN FORECAST 2026-2027 for each region (no crops here: rain depends only on region + month).

  * months already passed  -> the REAL rain (Open-Meteo, step 1)
  * the next months        -> FORECAST by an AI model (SARIMA) trained on the monthly rain since 2000
  * for each month also the normal range seen 2000-2025:
        dry year  = 20% of years had less rain
        normal    = the middle (median) year
        wet year  = 20% of years had more rain

SARIMA = a classic time-series model that learns the yearly rain cycle (wet winter, dry summer)
         and the recent trend. Library: statsmodels. It works on the square root of the rain.
Tested on the past: services/rainfall/step5_evaluate.py.

Input:   raw/rain_history.csv
Output:  output/rain_forecast_2026_2027.csv   (24 regions x 24 months)
         columns: governorate, month, source (observed/forecast), rain_mm,
                  rain_dry_year_mm, rain_normal_mm, rain_wet_year_mm

Run (from the ai-service/ folder):  python -m services.rainfall.step2_rain_forecast
"""
import warnings

import numpy as np
import pandas as pd
from statsmodels.tsa.statespace.sarimax import SARIMAX

from common import GOVERNORATES, MONTHS, RAINFALL, monthly_totals

warnings.filterwarnings("ignore")  # statsmodels prints many technical warnings


def sarima_forecast(monthly_rain: pd.Series, steps: int) -> np.ndarray:
    """Forecasts the next `steps` months of rain (mm).

    Works on the SQUARE ROOT of the rain (rain is skewed: many dry months, a few very wet ones),
    then converts back with a bias correction: rain = mean^2 + variance (otherwise it under-forecasts).
    Chosen after a test on 3 past periods (see step5_evaluate.py): error on the 14-month total 11 %,
    better than log(rain) (16 %, 36 % without correction) and than the monthly average (14 %).
    """
    model = SARIMAX(np.sqrt(monthly_rain.values), order=(1, 0, 0), seasonal_order=(1, 0, 1, 12), trend="c")
    forecast = model.fit(disp=False).get_forecast(steps)
    return np.clip(forecast.predicted_mean ** 2 + forecast.var_pred_mean, 0, None)


def main():
    rain = monthly_totals(RAINFALL / "raw" / "rain_history.csv", "precipitation_sum")
    rows = []
    for region in GOVERNORATES:
        r = rain[rain["governorate"] == region].set_index("month")["value"].asfreq("MS")
        past = r[(r.index.year >= 2000) & (r.index.year <= 2025)]
        normal = past.groupby(past.index.month).quantile([0.2, 0.5, 0.8]).unstack()

        last_real = r.index.max()
        future = [m for m in MONTHS if m > last_real]
        forecast = dict(zip(future, sarima_forecast(r.dropna(), len(future))))

        for m in MONTHS:
            real = m <= last_real
            rows.append({
                "governorate": region,
                "month": m.strftime("%Y-%m"),
                "source": "observed" if real else "forecast",
                "rain_mm": round(float(r[m] if real else forecast[m]), 1),
                "rain_dry_year_mm": round(normal.loc[m.month, 0.2], 1),
                "rain_normal_mm": round(normal.loc[m.month, 0.5], 1),
                "rain_wet_year_mm": round(normal.loc[m.month, 0.8], 1),
            })
        print(f"  {region}: real rain up to {last_real:%Y-%m}, SARIMA forecast for {len(future)} months")

    pd.DataFrame(rows).to_csv(RAINFALL / "output" / "rain_forecast_2026_2027.csv", index=False)
    print(f"  saved output/rain_forecast_2026_2027.csv ({len(rows)} rows)")


if __name__ == "__main__":
    main()
