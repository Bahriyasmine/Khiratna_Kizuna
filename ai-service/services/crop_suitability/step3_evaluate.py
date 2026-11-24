"""SERVICE 3 (CROP SUITABILITY) - STEP 3: AN HONEST EVALUATION OF THE 99.4 %.

TEST 1 - Is the dataset just too easy?
    Same 5-fold cross-validation with simple models (1 decision tree, k-nearest neighbours, logistic regression).
    If they also reach ~99 %, the high score comes from the data, not from a clever model.

TEST 2 - What if the measures are not perfect? (noise test)
    Real soil tests and weather values have errors. We add random noise of 10 % and 20 % to the 7 inputs
    of the TEST rows only, and measure the accuracy again.

TEST 3 - Does the data agree with agronomy? (FAO EcoCrop)
    For each of the 22 crops: % of its rows whose temperature and pH are inside the FAO ECOCROP limits
    for that crop (https://gaez.fao.org/pages/ecocrop, CSV: raw/EcoCrop_DB.csv, OpenCLIM copy).

TEST 4 - Plausibility on Tunisia (24 governorates)
    Inputs from real Tunisian data: temperature and humidity = yearly average 2001-2025 (NASA POWER climatology,
    https://power.larc.nasa.gov - free, no key),
    rainfall = average yearly rain 2000-2025 (service 1), pH = typical soil of the governorate (service 2),
    N, P, K = median of the dataset (no Tunisian NPK map exists). We look at the crop it recommends.

Creates  output/evaluation_crops.json, output/evaluation_tunisia.csv, output/evaluation_ecocrop.csv
         raw/climate_nasa_power.csv (downloaded once)

Run (from the ai-service/ folder):  python -m services.crop_suitability.step3_evaluate
"""
import json

import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import StratifiedKFold, cross_val_score
from sklearn.neighbors import KNeighborsClassifier
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.tree import DecisionTreeClassifier

from common import CROP_SUITABILITY, GOVERNORATES, RAINFALL, get_json
from services.crop_suitability.step1_train_model import FEATURES
from services.soil_map.step2_soil_by_region import region_soil

RAW, OUT = CROP_SUITABILITY / "raw", CROP_SUITABILITY / "output"
ECOCROP_NAMES = {
    "rice": "Oryza sativa", "maize": "Zea mays", "chickpea": "Cicer arietinum", "kidneybeans": "Phaseolus vulgaris",
    "pigeonpeas": "Cajanus cajan", "mothbeans": "Vigna aconitifolia", "mungbean": "Vigna radiata",
    "blackgram": "Vigna mungo", "lentil": "Lens culinaris", "pomegranate": "Punica granatum",
    "banana": "Musa acuminata", "mango": "Mangifera indica", "grapes": "Vitis vinifera",
    "watermelon": "Citrullus lanatus", "muskmelon": "Cucumis melo", "apple": "Malus domestica",
    "orange": "Citrus sinensis", "papaya": "Carica papaya", "coconut": "Cocos nucifera",
    "cotton": "Gossypium hirsutum", "jute": "Corchorus capsularis", "coffee": "Coffea arabica",
}


def test_models(X, y) -> dict:
    cv = StratifiedKFold(5, shuffle=True, random_state=0)
    models = {
        "random_forest (our model)": RandomForestClassifier(300, random_state=0),
        "one decision tree": DecisionTreeClassifier(random_state=0),
        "k-nearest neighbours": make_pipeline(StandardScaler(), KNeighborsClassifier(5)),
        "logistic regression": make_pipeline(StandardScaler(), LogisticRegression(max_iter=3000)),
    }
    return {name: round(float(cross_val_score(m, X, y, cv=cv).mean()) * 100, 1) for name, m in models.items()}


def test_noise(X, y) -> dict:
    """Train on clean rows, test on rows with +/- noise (gaussian, sd = level x value)."""
    rng = np.random.default_rng(0)
    cv = StratifiedKFold(5, shuffle=True, random_state=0)
    out = {}
    for level in (0.0, 0.1, 0.2):
        scores = []
        for tr, te in cv.split(X, y):
            m = RandomForestClassifier(300, random_state=0).fit(X.iloc[tr], y.iloc[tr])
            Xt = X.iloc[te].to_numpy(float)
            Xt = Xt * (1 + rng.normal(0, level, Xt.shape))
            scores.append((m.predict(pd.DataFrame(Xt, columns=FEATURES)) == y.iloc[te]).mean())
        out[f"{int(level * 100)}% noise"] = round(float(np.mean(scores)) * 100, 1)
    return out


def test_ecocrop(data: pd.DataFrame) -> pd.DataFrame:
    eco = pd.read_csv(RAW / "EcoCrop_DB.csv", encoding="latin1").set_index("ScientificName")
    rows = []
    for crop, sci in ECOCROP_NAMES.items():
        e, d = eco.loc[sci], data[data["label"] == crop]
        rows.append({"crop": crop, "ecocrop_name": sci,
                     "data_temperature": f"{d.temperature.min():.0f}-{d.temperature.max():.0f}",
                     "ecocrop_temperature_limits": f"{e.TMIN:.0f}-{e.TMAX:.0f}",
                     "rows_inside_temperature_limits_percent": round(d.temperature.between(e.TMIN, e.TMAX).mean() * 100),
                     "data_ph": f"{d.ph.min():.1f}-{d.ph.max():.1f}", "ecocrop_ph_limits": f"{e.PHMIN:.1f}-{e.PHMAX:.1f}",
                     "rows_inside_ph_limits_percent": round(d.ph.between(e.PHMIN, e.PHMAX).mean() * 100)})
    return pd.DataFrame(rows)


def climate() -> pd.DataFrame:
    """Yearly average temperature (C) and relative humidity (%) 2001-2025 per governorate (NASA POWER, downloaded once)."""
    path = RAW / "climate_nasa_power.csv"
    if not path.exists():
        rows = []
        for region, (lat, lon) in GOVERNORATES.items():
            p = get_json("https://power.larc.nasa.gov/api/temporal/climatology/point",
                         {"parameters": "T2M,RH2M", "community": "AG", "longitude": lon, "latitude": lat,
                          "format": "JSON"})["properties"]["parameter"]
            rows.append({"governorate": region, "temperature": p["T2M"]["ANN"], "humidity": p["RH2M"]["ANN"]})
        pd.DataFrame(rows).to_csv(path, index=False)
        print("  saved services/crop_suitability/raw/climate_nasa_power.csv")
    return pd.read_csv(path).set_index("governorate")


def test_tunisia(model, data: pd.DataFrame) -> pd.DataFrame:
    clim = climate()
    rain = pd.read_csv(RAINFALL / "raw" / "rain_history.csv", parse_dates=["date"])
    rain = rain[rain["date"].dt.year.between(2000, 2025)]
    yearly = rain.groupby(["governorate", rain["date"].dt.year])["precipitation_sum"].sum().groupby(level=0).mean()
    med = data[["N", "P", "K"]].median()
    rows = []
    for g in GOVERNORATES:
        x = {"N": med.N, "P": med.P, "K": med.K, "temperature": clim.loc[g, "temperature"],
             "humidity": clim.loc[g, "humidity"], "ph": float(region_soil(g)["ph"]), "rainfall": yearly[g]}
        p = model.predict_proba(pd.DataFrame([x], columns=FEATURES))[0]
        top = np.argsort(p)[::-1][:3]
        rows.append({"governorate": g, **{k: round(v, 1) for k, v in x.items()},
                     "top_1": f"{model.classes_[top[0]]} {p[top[0]] * 100:.0f}%",
                     "top_2": f"{model.classes_[top[1]]} {p[top[1]] * 100:.0f}%",
                     "top_3": f"{model.classes_[top[2]]} {p[top[2]] * 100:.0f}%"})
    return pd.DataFrame(rows)


def main():
    data = pd.read_csv(RAW / "Crop_recommendation.csv")
    X, y = data[FEATURES], data["label"]
    models = test_models(X, y)
    noise = test_noise(X, y)
    eco = test_ecocrop(data)
    eco.to_csv(OUT / "evaluation_ecocrop.csv", index=False)
    model = RandomForestClassifier(300, random_state=0).fit(X, y)
    tn = test_tunisia(model, data)
    tn.to_csv(OUT / "evaluation_tunisia.csv", index=False)
    summary = {"accuracy_by_model_percent": models, "random_forest_accuracy_with_noisy_inputs_percent": noise,
               "ecocrop_rows_inside_temperature_limits_percent": round(eco["rows_inside_temperature_limits_percent"].mean(), 1),
               "ecocrop_rows_inside_ph_limits_percent": round(eco["rows_inside_ph_limits_percent"].mean(), 1),
               "tunisia_top_crop_count": tn["top_1"].str.split().str[0].value_counts().to_dict()}
    with open(OUT / "evaluation_crops.json", "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2)
    print(json.dumps(summary, indent=2))
    print(eco.to_string(index=False))
    print(tn.to_string(index=False))


if __name__ == "__main__":
    main()
