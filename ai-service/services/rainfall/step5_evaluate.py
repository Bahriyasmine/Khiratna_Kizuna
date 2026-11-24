"""SERVICE 1 - STEP 5: HOW GOOD IS THE RAIN FORECAST? (test on the past = backtest)

We hide the real rain after a date, let SARIMA forecast the next 14 months (like our real forecast
Nov 2026 -> Dec 2027), and compare with the rain that really fell.

  3 tests, 24 governorates each:
    trained up to Oct 2022 -> forecast Nov 2022 - Dec 2023
    trained up to Oct 2023 -> forecast Nov 2023 - Dec 2024
    trained up to Oct 2024 -> forecast Nov 2024 - Dec 2025

  Errors (mm of rain per month, then over the whole 14 months):
    MAE monthly        = average of |forecast - real| for each month
    error on the total = |forecast total - real total| / real total (%)
  Compared with the simplest method: "normal" = average rain of that month in past years.

Creates  output/rain_backtest.csv

Run (from the ai-service/ folder):  python -m services.rainfall.step5_evaluate
"""
import numpy as np
import pandas as pd

from common import GOVERNORATES, RAINFALL, monthly_totals
from services.rainfall.step2_rain_forecast import sarima_forecast


def main():
    rain = monthly_totals(RAINFALL / "raw" / "rain_history.csv", "precipitation_sum")
    rows = []
    for cut in ("2022-10-01", "2023-10-01", "2024-10-01"):
        cut = pd.Timestamp(cut)
        months = pd.date_range(cut + pd.DateOffset(months=1), periods=14, freq="MS")
        for region in GOVERNORATES:
            r = rain[rain["governorate"] == region].set_index("month")["value"].asfreq("MS")
            train, real = r[r.index <= cut], r.reindex(months).to_numpy()
            sarima = sarima_forecast(train.dropna(), len(months))
            past = train[train.index.year >= 2000]
            normal = past.groupby(past.index.month).mean().reindex([m.month for m in months]).to_numpy()
            rows.append({
                "trained_until": cut.strftime("%Y-%m"), "governorate": region,
                "real_total_mm": round(real.sum()),
                "sarima_total_mm": round(sarima.sum()), "normal_total_mm": round(normal.sum()),
                "sarima_mae_mm_per_month": round(np.mean(np.abs(sarima - real)), 1),
                "normal_mae_mm_per_month": round(np.mean(np.abs(normal - real)), 1),
                "sarima_total_error_percent": round(abs(sarima.sum() - real.sum()) / real.sum() * 100, 1),
                "normal_total_error_percent": round(abs(normal.sum() - real.sum()) / real.sum() * 100, 1),
            })
    out = pd.DataFrame(rows)
    out.to_csv(RAINFALL / "output" / "rain_backtest.csv", index=False)
    print("  saved services/rainfall/output/rain_backtest.csv")
    cols = ["sarima_mae_mm_per_month", "normal_mae_mm_per_month", "sarima_total_error_percent", "normal_total_error_percent"]
    print(out.groupby("trained_until")[cols].median().to_string())
    print("  all tests, median:", out[cols].median().round(1).to_dict())
    print("  average real rain per month in the tests:", round(out["real_total_mm"].mean() / 14, 1), "mm")


if __name__ == "__main__":
    main()
