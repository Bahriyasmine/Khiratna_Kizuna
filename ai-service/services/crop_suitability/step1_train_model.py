"""SERVICE 3 (CROP SUITABILITY) - STEP 1: TRAIN THE AI MODEL (like FarmWise).

Data:  Kaggle "Crop Recommendation Dataset" (Atharva Ingle, 2020, licence Apache 2.0)
       https://www.kaggle.com/datasets/atharvaingle/crop-recommendation-dataset   -> raw/Crop_recommendation.csv
       2 200 rows = 22 crops x 100 rows. For each row:
         N, P, K       nitrogen, phosphorus, potassium in the soil (ratio, as given by the dataset)
         temperature   C
         humidity      relative humidity, %
         ph            soil pH
         rainfall      mm
         label         the crop that suits these conditions
       Origin (dataset description): "built by augmenting datasets of rainfall, climate and fertilizer data
       available for India" -> Indian conditions, not Tunisian measurements.

Model: Random Forest (300 decision trees, scikit-learn). Each tree votes for a crop;
       % of votes = how well the crop suits the conditions.
Test:  5-fold cross-validation = train on 80 % of the rows, test on the other 20 %, 5 times.

Creates  model/crop_model.joblib     the trained model
         output/model_report.json    accuracy + the range of each input in the data

Run (from the ai-service/ folder):  python -m services.crop_suitability.step1_train_model
"""
import json

import joblib
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import cross_val_score

from common import CROP_SUITABILITY

FEATURES = ["N", "P", "K", "temperature", "humidity", "ph", "rainfall"]


def main():
    data = pd.read_csv(CROP_SUITABILITY / "raw" / "Crop_recommendation.csv")
    X, y = data[FEATURES], data["label"]
    model = RandomForestClassifier(n_estimators=300, random_state=0)

    accuracy = cross_val_score(model, X, y, cv=5).mean()
    print(f"  test accuracy (5-fold cross-validation): {accuracy:.1%}")

    model.fit(X, y)
    (CROP_SUITABILITY / "model").mkdir(exist_ok=True)
    joblib.dump(model, CROP_SUITABILITY / "model" / "crop_model.joblib")

    report = {
        "accuracy": round(float(accuracy), 4),
        "rows": len(data), "crops": sorted(y.unique().tolist()),
        "input_ranges": {f: [round(float(X[f].min()), 1), round(float(X[f].max()), 1)] for f in FEATURES},
        "importance": dict(sorted(((f, round(float(i), 3)) for f, i in zip(FEATURES, model.feature_importances_)),
                                  key=lambda t: -t[1])),
    }
    with open(CROP_SUITABILITY / "output" / "model_report.json", "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2)
    print("  saved model/crop_model.joblib and output/model_report.json")
    print("  importance of each input:", report["importance"])


if __name__ == "__main__":
    main()
