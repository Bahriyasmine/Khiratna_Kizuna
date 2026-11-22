"""STEP 3 - WATER NEED OF EACH PLANT (no rain here).

Official FAO-56 method (FAO Irrigation and Drainage Paper 56, chapter 6):

    crop need ETc (mm) = ET0 x Kc

  ET0 = how much water the sun, heat and wind take from a field. Depends on the REGION and the MONTH.
        -> real value for months already passed (step 1),
           otherwise the usual value of that month (median of 2010-2025).
  Kc  = how thirsty the plant is compared to grass. Depends on the CROP and its AGE:
        small after planting (Kc initial), highest when fully grown (Kc mid), lower before harvest (Kc end).
        -> crop_kc.csv, copied from FAO-56 Table 12 (Kc) and Table 11 (days of each stage).
           Link: https://www.fao.org/4/x0490e/x0490e0b.htm

This script makes the ET0 file. The Kc part is computed when the user picks a crop and a planting month,
because the plant's age changes month by month after planting.

Input:   raw/et0_history.csv, crop_kc.csv
Output:  output/et0_2026_2027.csv   (24 regions x 24 months)
         columns: governorate, month, et0_source (observed/normal), et0_mm

Run (from the ai-service/ folder):  python -m services.rainfall.step3_crop_need
"""
import numpy as np
import pandas as pd

from common import GOVERNORATES, MONTHS, RAINFALL, monthly_totals

CROPS = pd.read_csv(RAINFALL / "crop_kc.csv")


def kc_curve(c) -> np.ndarray:
    """Kc of every day of one season (FAO-56 figure 25): flat (initial), rising (development),
    flat (mid), falling (late)."""
    return np.concatenate([
        np.full(int(c.days_initial), c.kc_initial),
        np.linspace(c.kc_initial, c.kc_mid, int(c.days_development)),
        np.full(int(c.days_mid), c.kc_mid),
        np.linspace(c.kc_mid, c.kc_end, int(c.days_late)),
    ])


def daily_to_monthly(days: pd.Series) -> pd.Series:
    """Daily Kc -> average Kc of each month."""
    kc = days.groupby(days.index.to_period("M")).mean()
    kc.index = kc.index.to_timestamp()
    return kc


def kc_per_month(crop: str, start: str, end: str) -> pd.Series:
    """Average Kc of each month from `start` to `end` (YYYY-MM). 3 kinds of crops (column `type`):

    annual    (tomato, wheat...): planted on day 1 of `start`, follows the FAO curve,
              then Kc = 0 after harvest (no crop in the field, no water needed).
    tree      (citrus, grapes, almond...): the FAO curve starts every year in `season_start_month`
              (Table 11). Outside the season the tree has no leaves: Kc = kc_dormant
              (FAO Table 12 footnote 18). Citrus keeps its leaves: its season lasts the 365 days.
    all_year  (olive, date palm, alfalfa): FAO Kc mid every month.
    """
    c = CROPS.set_index("crop").loc[crop]
    months = pd.date_range(start + "-01", end + "-01", freq="MS")

    if c.type == "all_year":
        return pd.Series(c.kc_mid, index=months)

    if c.type == "tree":
        rest = 0.0 if pd.isna(c.kc_dormant) else c.kc_dormant
        days = pd.Series(rest, index=pd.date_range("2025-01-01", "2028-12-31", freq="D"))
        curve = kc_curve(c)
        for year in (2025, 2026, 2027):
            season = pd.date_range(f"{year}-{int(c.season_start_month):02d}-01", periods=len(curve), freq="D")
            days.loc[season] = curve
        return daily_to_monthly(days).reindex(months)

    # annual
    curve = kc_curve(c)
    days = pd.Series(0.0, index=pd.date_range(months[0], months[-1] + pd.offsets.MonthEnd(0), freq="D"))
    n = min(len(curve), len(days))
    days.iloc[:n] = curve[:n]
    return daily_to_monthly(days)


def main():
    et0 = monthly_totals(RAINFALL / "raw" / "et0_history.csv", "et0_fao_evapotranspiration")
    rows = []
    for region in GOVERNORATES:
        e = et0[et0["governorate"] == region].set_index("month")["value"]
        past = e[(e.index.year >= 2010) & (e.index.year <= 2025)]
        usual = past.groupby(past.index.month).median()
        for m in MONTHS:
            real = m in e.index
            rows.append({"governorate": region, "month": m.strftime("%Y-%m"),
                         "et0_source": "observed" if real else "normal",
                         "et0_mm": round(float(e[m] if real else usual[m.month]), 1)})
    pd.DataFrame(rows).to_csv(RAINFALL / "output" / "et0_2026_2027.csv", index=False)
    print(f"  saved output/et0_2026_2027.csv ({len(rows)} rows)")


if __name__ == "__main__":
    main()
