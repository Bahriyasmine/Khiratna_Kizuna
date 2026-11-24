# 5 services pour l'agriculteur tunisien

| # | Service | Question de l'agriculteur | Dossier | Page |
|---|---|---|---|---|
| 1 | **Prévision de pluie → eau à ajouter** | « Combien d'eau dois-je ajouter chaque mois ? » | `rainfall/` | http://localhost:8000 |
| 2 | **Carte du sol de la Tunisie** | « Quel est le sol de ma région ? » | `soil_map/` | http://localhost:8000/soil-map |
| 3 | **Cultures adaptées au sol** | « Quelles cultures conviennent à mon sol ? » | `crop_suitability/` | http://localhost:8000/crops |
| 4 | **Prévision du marché tunisien** | « Que va-t-il manquer en 2027, et qu'est-ce qui rapporte le plus ? » | `market/` | http://localhost:8000/market |
| 5 | **Khiratna, le chatbot (énergie + rotation des cultures)** | « Combien coûte mon pompage ? Que planter après la pastèque ? » | `chatbot/` (+ calculateur `energy/`) | http://localhost:8000/chat |

Parties 1 à 9 : service 1. Parties 10 à 14 : service 2. Parties 15 à 20 : service 3. Parties 21 à 26 : service 4.

---

# SERVICE 1 : Prévision de pluie + besoin en eau → eau à ajouter

« Dans ma région, pour ma culture, **combien d'eau dois-je ajouter chaque mois** en 2026-2027 ? »

On répond en 3 parties, chacune avec des données réelles et une source officielle :

```
1. LA PLUIE        combien il va pleuvoir                    (Open-Meteo + modèle d'IA SARIMA)
2. LE BESOIN       combien d'eau la plante va consommer      (Open-Meteo + guide FAO-56)
3. LA FORMULE      eau à ajouter = besoin − pluie utile
```

Le résultat est donné **par hectare**, donc il n'est pas nécessaire de connaître la taille du champ.

---

## 1. Lancer le projet

```
cd data
pip install -r requirements.txt
python run_all.py                  # toutes les étapes des 4 services
uvicorn app:app --port 8000        # démarre le prototype
```

Ouvrir ensuite :
- **http://localhost:8000** : service 1 (région, culture, mois de début, mois de fin → graphique + tableau)
- **http://localhost:8000/soil-map** : service 2 (carte du sol, valeurs de chaque gouvernorat)
- **http://localhost:8000/crops** : service 3 (gouvernorat → liste des cultures classées)
- **http://localhost:8000/docs** : l'API, que le backend NestJS de Yassine appelle

⚠️ Il faut garder le terminal de `uvicorn` ouvert pendant l'utilisation de la page. Sinon, la page affiche « The Python server is not running ».

---

## 2. Les mots à connaître (expliqués simplement)

| Mot | Explication simple | Unité |
|---|---|---|
| **ET0** | L'eau que la météo (soleil, chaleur, vent, air sec) retire d'un champ de gazon. Elle dépend de la **région** et du **mois**, pas de la plante. | mm |
| **Kc** | La soif de la plante comparée au gazon. Kc = 1,15 : la plante boit 15 % de plus que le gazon. Kc = 0,5 : elle boit moitié moins. Il dépend de la **plante** et de son **âge**. | sans unité |
| **ETc** | Le **besoin en eau de la plante**. ETc = ET0 × Kc. | mm |
| **Pluie utile** | La partie de la pluie que la plante utilise vraiment. On prend 80 % ; le reste ruisselle ou s'évapore. | mm |
| **Eau à ajouter** | Ce que l'agriculteur doit irriguer : ETc − pluie utile. | mm et m³/ha |
| **1 mm** | 1 litre par m², soit **10 m³ par hectare** | |
| **SARIMA** | Un modèle d'IA pour les séries dans le temps. Il apprend le cycle de chaque année (hiver pluvieux, été sec) à partir de 26 ans de pluie, puis prévoit les mois suivants. | |
| **FAO** | L'Organisation des Nations Unies pour l'alimentation et l'agriculture (Rome). La Tunisie en est membre. | |
| **FAO-56** | Le guide officiel de la FAO pour calculer le besoin en eau des cultures. C'est la référence mondiale. | |
| **ERA5** | Les données météo du service européen Copernicus, reconstruites à partir de mesures réelles (stations, satellites). | |

---

## Évaluation de la prévision de pluie (test sur le passé)

On cache la vraie pluie après une date, SARIMA prévoit les 14 mois suivants, puis on compare avec la pluie réellement tombée (3 périodes × 24 gouvernorats, `services/rainfall/step5_evaluate.py`) :

| Méthode | Erreur sur le total de 14 mois | Erreur moyenne par mois |
|---|---|---|
| **SARIMA sur la racine carrée de la pluie (notre modèle)** | **11 %** | 17 mm |
| Moyenne habituelle du mois (méthode simple) | 14 % | 16 mm |
| Ancienne version (SARIMA sur log, sans correction) | 36 % | 16 mm |

Le modèle est meilleur que la méthode simple sur le total de la saison, et à peu près égal mois par mois. La pluie d'un mois précis reste difficile à prévoir (±17 mm).

## 3. La formule

```
besoin de la plante (ETc, mm)  = ET0 × Kc
pluie utile (mm)               = 0,8 × pluie
eau à ajouter (mm)             = ETc − pluie utile        (jamais en dessous de 0)
eau à ajouter (m³/ha)          = mm × 10
```

### Exemple réel : pomme de terre à Tunis, plantée en janvier 2027

| | Janvier 2027 | Février 2027 | Total |
|---|---|---|---|
| ET0 (météo habituelle de Tunis) | 58,0 mm | 62,8 mm | |
| Kc (soif de la pomme de terre) | 0,51 (jeune plante) | 0,93 (en pleine croissance) | |
| **Besoin ETc** = ET0 × Kc | 29,6 mm | 58,3 mm | 87,9 mm |
| Pluie prévue | 35,8 mm | 35,2 mm | 71 mm |
| **Pluie utile** = 80 % | 28,6 mm | 28,2 mm | |
| **Eau à ajouter** | **1,0 mm = 10 m³/ha** | **30,2 mm = 302 m³/ha** | **312 m³/ha** |

**Lecture :** en janvier, la pluie suffit presque. En février, la plante est deux fois plus assoiffée, donc il faut irriguer environ 302 m³ par hectare, soit environ 11 m³ par hectare et par jour.

### Comment on obtient le Kc d'un mois

La FAO découpe la vie d'une culture annuelle en 4 stades. Exemple de la pomme de terre, plantée le 1er janvier :

```
jours 1–25     stade initial          Kc = 0,50          (petite plante)
jours 26–55    développement          Kc monte 0,50 → 1,15
jours 56–100   mi-saison              Kc = 1,15          (plante adulte)
jours 101–130  fin de saison          Kc descend 1,15 → 0,75, puis récolte
après          champ vide             Kc = 0             (pas de besoin)
```

Le Kc d'un mois est la **moyenne des Kc de ses jours**. Pour janvier, on obtient 0,51 ; pour février, 0,93.

---

## 4. Les fichiers, dans l'ordre

```
ai-service/                           le Python de Yasmine : IA + données + API (FastAPI)
├── README.md                         ce fichier
├── app.py                            le serveur : les pages de test + l'API (port 8000)
├── common.py                         partagé : dossiers, 24 gouvernorats, mois 2026-2027, téléchargement
├── run_all.py                        relance toutes les étapes de tous les services
├── start_api.bat                     double-clic : installe et démarre l'API
├── requirements.txt                  bibliothèques Python
├── docker-compose.yml                optionnel : PostgreSQL + pgvector (pas utilisé pour l'instant)
├── .env                              clés Gemini (privé, jamais dans Git)
│
├── web/                              une page de test par service
│   ├── rainfall.html  soil_map.html  crops.html  market.html  energy.html
│   └── chat.html                     le chatbot Khiratna (voix 🎤 / 🔊)
│
└── services/
    ├── rainfall/                     SERVICE 1  pluie prévue → eau à ajouter
    │   ├── step1_download.py         ÉTAPE 1  télécharge la vraie météo
    │   ├── step2_rain_forecast.py    ÉTAPE 2  la pluie prévue (SARIMA)
    │   ├── step3_crop_need.py        ÉTAPE 3  le besoin de la plante (ET0 × Kc, FAO-56)
    │   ├── step4_water_to_add.py     ÉTAPE 4  la formule : eau à ajouter
    │   ├── step5_evaluate.py         TEST     la prévision comparée à la vraie pluie
    │   ├── crop_kc.csv               Kc des 18 cultures (FAO-56)
    │   └── raw/  output/
    │
    ├── soil_map/                     SERVICE 2  carte du sol de la Tunisie
    │   ├── step1_soil_map.py         ÉTAPE 1  la carte du sol ISRIC en un fichier
    │   ├── step2_soil_by_region.py   ÉTAPE 2  le sol de chaque gouvernorat
    │   ├── step3_evaluate.py         TEST     surfaces officielles + comparaison SoilGrids
    │   └── raw/  output/
    │
    ├── crop_suitability/             SERVICE 3  quelles cultures conviennent
    │   ├── step1_train_model.py      ÉTAPE 1  entraîne le modèle (Random Forest, Kaggle)
    │   ├── step2_predict.py          ÉTAPE 2  prédit les cultures classées
    │   ├── step3_evaluate.py         TEST     modèles simples, bruit, EcoCrop
    │   └── raw/  model/  output/
    │
    ├── market/                       SERVICE 4  marché tunisien 2027
    │   ├── step1_download.py         ÉTAPE 1  FAOSTAT (production, commerce, prix)
    │   ├── step2_forecast.py         ÉTAPE 2  prévision 2027 (Theta) + test sur le passé
    │   ├── step3_money.py            ÉTAPE 3  revenu par hectare et par m³ d'eau
    │   ├── step4_planting_calendar.py         calendrier FAO + risque de gel
    │   └── raw/  output/
    │
    ├── energy/                       SERVICE 5  énergie de l'irrigation
    │   ├── step1_download.py         ÉTAPE 1  PVGIS (soleil) + électricité de la Tunisie
    │   ├── step2_pumping.py          ÉTAPE 2  kWh, coût STEG, panneaux solaires, subvention
    │   └── raw/
    │
    └── chatbot/                      SERVICE 6  Khiratna (énergie + rotation des cultures)
        ├── docs/                     les 5 documents sources (FAO, IRENA, SARE, fiches)
        ├── gemini.py                 client Gemini (plusieurs clés)
        ├── rag.py                    la recherche (E5, BM25, hybride, pgvector)
        ├── step1_index.py            ÉTAPE 1  découpage + vecteurs
        ├── step2_chat.py             ÉTAPE 2  la réponse (Gemini + calculateur)
        ├── step3_evaluate.py         TEST     quel moteur de recherche est le meilleur
        ├── step4_speech.py           voix → texte (Whisper)
        └── output/
```

Lancer une étape seule (depuis `ai-service/`) : `python -m services.rainfall.step2_rain_forecast`, `python -m services.soil_map.step1_soil_map`, `python -m services.crop_suitability.step2_predict`...

---

## 5. Chaque fichier de données : contenu, origine, rôle

### `services/rainfall/raw/rain_history.csv`, pluie réelle de chaque jour
- **Contenu :** 24 gouvernorats × chaque jour depuis le 01/01/2000 (environ 5 jours de retard sur aujourd'hui)
- **Colonnes :** `governorate`, `date`, `precipitation_sum` (mm de pluie ce jour-là)
- **Source :** Open-Meteo Historical Weather API (données ERA5 de Copernicus). Gratuit, sans clé. https://open-meteo.com/en/docs/historical-weather-api
- **Comment :** téléchargé automatiquement par `services/rainfall/step1_download.py`, aux coordonnées du chef-lieu de chaque gouvernorat
- **Utilisé par :** l'étape 2, pour entraîner le modèle de prévision de pluie

### `services/rainfall/raw/et0_history.csv`, ET0 réelle de chaque jour
- **Contenu :** 24 gouvernorats × chaque jour depuis le 01/01/2010
- **Colonnes :** `governorate`, `date`, `et0_fao_evapotranspiration` (mm)
- **Source :** Open-Meteo, même API. Open-Meteo calcule l'ET0 avec la **formule officielle FAO-56 Penman-Monteith**, à partir de la température, du soleil, du vent et de l'humidité.
- **Comment :** téléchargé automatiquement par `services/rainfall/step1_download.py`
- **Utilisé par :** l'étape 3

### `services/rainfall/output/rain_forecast_2026_2027.csv`, LA PLUIE
- **Contenu :** 24 gouvernorats × 24 mois (janvier 2026 → décembre 2027), soit 576 lignes. **Aucune culture ici.**
- **Colonnes :**
  - `month` : le mois
  - `source` : `observed` = pluie réelle mesurée ; `forecast` = pluie prévue par le modèle
  - `rain_mm` : pluie du mois (mm)
  - `rain_dry_year_mm` : pluie de ce mois une année sèche (20 % des années 2000-2025 ont eu moins)
  - `rain_normal_mm` : pluie de ce mois une année normale (médiane 2000-2025)
  - `rain_wet_year_mm` : pluie de ce mois une année humide (20 % des années ont eu plus)
- **Comment :** pluie réelle jusqu'à octobre 2026 (dernier mois complet), puis prévision SARIMA pour les 14 mois suivants
- **Modèle :** SARIMA (bibliothèque `statsmodels`), entraîné sur la pluie mensuelle depuis 2000. Réglages : `order=(1,0,0)`, `seasonal_order=(1,0,1,12)`. Il travaille sur log(pluie + 1) pour ne jamais prévoir une pluie négative.

### `services/rainfall/output/et0_2026_2027.csv`, la partie météo du besoin
- **Contenu :** 24 gouvernorats × 24 mois, soit 576 lignes
- **Colonnes :**
  - `et0_source` : `observed` = valeur réelle ; `normal` = valeur habituelle du mois (médiane 2010-2025)
  - `et0_mm` : ET0 du mois (mm)
- **Comment :** valeur réelle pour les mois passés ; pour les mois futurs, la médiane du même mois sur 2010-2025. L'ET0 change très peu d'une année à l'autre, contrairement à la pluie.

### `services/rainfall/crop_kc.csv`, la partie plante du besoin (18 cultures)
- **Source :** guide **FAO-56** (FAO Irrigation and Drainage Paper 56, Allen et al., 1998), chapitre 6 : https://www.fao.org/4/x0490e/x0490e0b.htm
  - **Table 12** : les valeurs de Kc (`kc_initial`, `kc_mid`, `kc_end`)
  - **Table 11** : la durée de chaque stade en jours (`days_initial`, `days_development`, `days_mid`, `days_late`)
- **Comment :** copié à la main depuis les tables, puis **vérifié valeur par valeur** sur la page de la FAO. La colonne `source` donne la ligne exacte utilisée dans chaque table.
- **Colonnes :**
  - `type` : `annual` = plantée chaque année ; `tree` = arbre fruitier avec une saison ; `all_year` = au champ toute l'année
  - `kc_dormant` : Kc des arbres en hiver, sans feuilles (0,20 : note 18 de la table 12 de la FAO)
  - `season_start_month` : mois où la saison de l'arbre commence (table 11)

| Culture | Type | Kc début / milieu / fin | Jours des 4 stades | Source FAO-56 |
|---|---|---|---|---|
| Tomate | annuelle | 0,60 / 1,15 / 0,80 | 30 / 40 / 45 / 30 | T12 « Tomato » ; T11 « Mediterranean » |
| Poivron | annuelle | 0,60 / 1,05 / 0,90 | 30 / 35 / 40 / 20 | T12 « Sweet Peppers (bell) » ; T11 « Europe and Medit. » |
| Pomme de terre | annuelle | 0,50 / 1,15 / 0,75 | 25 / 30 / 45 / 30 | T12 « Potato » ; T11 « (Semi) Arid Climate » |
| Oignon | annuelle | 0,70 / 1,05 / 0,75 | 15 / 25 / 70 / 40 | T12 « Onions - dry » ; T11 « Mediterranean » |
| Carotte | annuelle | 0,70 / 1,05 / 0,95 | 30 / 40 / 60 / 20 | T12 « Carrots » ; T11 « Mediterranean » |
| Laitue | annuelle | 0,70 / 1,00 / 0,95 | 30 / 40 / 25 / 10 | T12 « Lettuce » ; T11 « Mediterranean » |
| Pastèque | annuelle | 0,40 / 1,00 / 0,75 | 20 / 30 / 30 / 30 | T12 « Watermelon » ; T11 « Italy » |
| Melon | annuelle | 0,50 / 1,05 / 0,75 | 25 / 35 / 40 / 20 | T12 « Sweet Melons » ; T11 « Mediterranean » |
| Blé | annuelle | 0,70 / 1,15 / 0,30 | 30 / 140 / 40 / 30 | T12 « Winter Wheat - non-frozen soils » ; T11 « Mediterranean » |
| Sorgho | annuelle | 0,30 / 1,05 / 0,55 | 20 / 35 / 40 / 30 | T12 « Sorghum - grain » ; T11 « USA, Pakis., Med. » |
| Agrumes | arbre (toujours vert) | 0,65 / 0,60 / 0,65 | 60 / 90 / 120 / 95 (janvier) | T12 « Citrus, no ground cover, 50% canopy » ; T11 « Citrus - Mediterranean » |
| Raisin de table | arbre | 0,30 / 0,85 / 0,45 | 20 / 50 / 75 / 60 (mars) | T12 « Grapes - Table or Raisin » ; T11 « Grapes - Calif., USA » |
| Amandier | arbre | 0,40 / 0,90 / 0,65 | 30 / 50 / 130 / 30 (mars) | T12 « Almonds, no ground cover » ; T11 « Deciduous Orchard - Calif., USA » |
| Abricotier / pêcher | arbre | 0,55 / 0,90 / 0,65 | 30 / 50 / 130 / 30 (mars) | T12 « Apricots, Peaches, Stone Fruit - no frosts » ; T11 « Deciduous Orchard - Calif., USA » |
| Pistachier | arbre | 0,40 / 1,10 / 0,45 | 20 / 60 / 30 / 40 (février) | T12 « Pistachios, no ground cover » ; T11 « Pistachios - Mediterranean » |
| Luzerne | toute l'année | 0,95 tous les mois | | T12 « Alfalfa Hay - averaged cutting effects » |
| Olivier | toute l'année | 0,70 tous les mois | | T12 « Olives (40 to 60% ground coverage) » |
| Palmier dattier | toute l'année | 0,95 tous les mois | | T12 « Date Palms » |

---

## 6. Les 3 types de cultures dans le calcul

| Type | Exemples | Comment le Kc est calculé |
|---|---|---|
| **Annuelle** | tomate, blé, carotte | Plantée le 1er jour du **mois de début** choisi par l'utilisateur. Elle suit la courbe FAO (4 stades), puis Kc = 0 après la récolte. |
| **Arbre** | agrumes, raisin, amandier | La saison recommence **chaque année** au mois de la table 11. En hiver (sans feuilles) : Kc = 0,20. Les agrumes gardent leurs feuilles, donc ils n'ont pas de repos. Les mois choisis servent seulement à afficher la période. |
| **Toute l'année** | olivier, palmier, luzerne | Le Kc « mid » de la FAO est utilisé pour chaque mois. |

Exemple de l'amandier sur une année :

| Mois | Jan | Mar | Mai | Juil | Sep | Nov |
|---|---|---|---|---|---|---|
| Kc | 0,20 | 0,40 | 0,84 | 0,90 | 0,90 | 0,20 |

---

## 7. L'API (pour le backend NestJS)

| Endpoint | Rôle | Exemple |
|---|---|---|
| `GET /api/rainfall/options` | Listes pour les menus déroulants : 24 régions, 18 cultures, premier et dernier mois | `/api/rainfall/options` |
| `GET /api/rainfall/forecast` | Le calcul complet, mois par mois | `/api/rainfall/forecast?region=Tunis&crop=potato&start=2027-01&end=2027-02` |

Réponse de `/api/rainfall/forecast` :
- `total` : pluie, besoin, eau à ajouter (mm et m³/ha) sur toute la période
- `months` : une ligne par mois. Champs :
  - `rain_mm`, `rain_source`, `useful_rain_mm`
  - `et0_mm`, `kc`, `crop_need_mm`
  - `water_to_add_mm`, `water_to_add_m3_per_ha`
- `kc_source` : la ligne FAO utilisée pour cette culture

Si une entrée est fausse (région inconnue, mois hors 2026-2027), l'API répond une **erreur 400** avec un message clair.

---

## 8. Toutes les sources

| Donnée | Source | Lien |
|---|---|---|
| Pluie de chaque jour depuis 2000 | Open-Meteo Historical Weather API, données ERA5 (Copernicus) | https://open-meteo.com/en/docs/historical-weather-api |
| ET0 de chaque jour depuis 2010 | Open-Meteo, formule FAO-56 Penman-Monteith | https://open-meteo.com/en/docs/historical-weather-api |
| Données ERA5 | Copernicus Climate Change Service (Union européenne) | https://cds.climate.copernicus.eu/datasets/reanalysis-era5-single-levels |
| Kc des cultures | FAO-56, table 12 | https://www.fao.org/4/x0490e/x0490e0b.htm |
| Durée des stades | FAO-56, table 11 | https://www.fao.org/4/x0490e/x0490e0b.htm |
| Kc des arbres en hiver (0,20) | FAO-56, note 18 de la table 12 | https://www.fao.org/4/x0490e/x0490e0b.htm |
| Formule ETc = ET0 × Kc | FAO-56, chapitre 6 | https://www.fao.org/4/x0490e/x0490e0b.htm |
| Pluie utile = 80 % | Méthode « pourcentage fixe » de FAO CROPWAT (le taux de 80 % est notre choix) | https://www.fao.org/land-water/databases-and-software/cropwat/en/ |
| Carte du sol de la Tunisie | ISRIC SOTER Tunisie 1:1M + SOTWIS (ISRIC Report 2010/01) | https://www.isric.org/sites/default/files/isric_report_2010_01.pdf |
| Frontières des gouvernorats | geoBoundaries TUN ADM1 (OpenStreetMap) | https://www.geoboundaries.org |
| Tolérance au sel des cultures | FAO-29 « Water quality for agriculture », table 4 | https://www.fao.org/4/t0234e/T0234E03.htm |
| Modèle SARIMA | Bibliothèque statsmodels (Python) | https://www.statsmodels.org/stable/generated/statsmodels.tsa.statespace.sarimax.SARIMAX.html |

---

## 9. Ce qu'il faut dire honnêtement au jury

- **Pluie :** **réelle** jusqu'à octobre 2026. Après, c'est une **prévision** du modèle SARIMA (en pointillés sur le graphique, « forecast » dans le tableau). La pluie de chaque mois précis ne peut pas être prévue avec certitude. On montre donc aussi la plage année sèche / année humide.
- **ET0 des mois futurs :** c'est la valeur **habituelle** du mois (médiane 2010-2025), pas une prévision.
- **Pluie utile à 80 % :** le taux est **notre choix**, avec la méthode « pourcentage fixe » de l'outil FAO CROPWAT.
- **Chaque mois est calculé séparément :** la pluie en trop d'un mois n'est pas gardée dans le sol pour le mois suivant. Le résultat est donc un peu plus élevé que la réalité, ce qui est prudent pour l'agriculteur.
- **Résultat mensuel :** l'agriculteur n'irrigue pas une fois par mois. Il divise ce total sur ses irrigations, tous les 1 à 3 jours. Exemple : 302 m³/ha en février ≈ 11 m³/ha par jour.
- **Raisin, amandier, abricotier / pêcher :** la FAO n'a pas de ligne « Méditerranée » pour la durée des stades. On a pris la ligne « Californie », qui a un climat méditerranéen.
- **Pistachier :** on suit exactement la ligne « Mediterranean » de la FAO, avec une saison de 150 jours qui finit en juin. En vrai, les vergers tunisiens arrosent parfois plus longtemps.
- **Cultures absentes :** l'orge et le pois chiche n'ont pas de durée de stades pour notre climat dans la FAO. Le figuier et le grenadier ne sont pas dans la table 12. Ils ont été laissés de côté pour ne rien inventer.
- **Localisation :** une région = la météo de son chef-lieu. Les différences à l'intérieur d'un même gouvernorat ne sont pas prises en compte.

---

# SERVICE 2 : Carte du sol de la Tunisie

Page : **http://localhost:8000/soil-map** · Dossier : `soil_map/`

## 10. L'idée et l'utilité

> « Quel est le sol de ma région ? »

La carte montre le sol de toute la Tunisie : **sel** (le grand problème des sols tunisiens), pH, calcaire, gypse, carbone organique, azote, réserve en eau et type de sol. Elle sert **avant de planter, d'acheter ou de louer une terre**.

| Entrée | Sortie |
|---|---|
| Une variable du sol à afficher | La carte colorée selon cette variable, avec les frontières des 24 gouvernorats |
| Un clic sur la carte | Le sol de cette zone |
| Le choix d'un gouvernorat | Son **sol typique sur toute sa surface**, son % de surface salée et ses 3 types de sol principaux |

## 11. La méthode (calcul géographique, pas d'IA)

1. **`step1_soil_map.py`** réunit les 3 fichiers ISRIC par numéro de zone (`SUID`) en une seule carte de 752 zones.
2. **`step2_soil_by_region.py`** calcule le sol de chaque gouvernorat :
   - On pose **un point tous les 0,02°** (environ 2 km) sur la Tunisie, soit 37 722 points.
   - Pour chaque point, on trouve son **gouvernorat** (frontières officielles) et sa **zone de sol** (carte ISRIC).
   - Tous les points ont la même surface. Compter des points revient donc à mesurer des surfaces.
   - **Valeur typique** = la **médiane** des points du gouvernorat : la moitié de la surface est en dessous, l'autre moitié au-dessus.
   - **Surface salée** = % des points avec ECe ≥ 4 dS/m. **Surface sodique** = % des points avec sodium ESP ≥ 15 %.
   - Les lacs et lagunes (zones « WT ») sont exclus.

**Vérification :** les surfaces calculées correspondent aux vraies. Tataouine donne 38 064 km² pour environ 38 900 km² en réalité, et Kébili 22 274 km² pour environ 22 100 km². Les résultats correspondent aussi à ce que l'on sait : Tozeur est salé à 56 % (Chott el Jérid), Kébili est sableux à 51 % (les dunes), Béja et Jendouba ont des sols argileux lourds.

## 12. Les fichiers du service 2

### `services/soil_map/raw/params.geojson`, `soter.geojson`, `units.geojson` : la carte du sol
- **Source :** base **ISRIC SOTER Tunisie** (échelle 1:1 000 000, faite pour le programme LADA de la FAO) et ses valeurs **SOTWIS-Tunisie**. ISRIC est le centre mondial d'information sur les sols (Pays-Bas).
  - **Rapport officiel :** Batjes N.H. (2010), *Soil property estimates for Tunisia derived from SOTER and WISE (SOTWIS-Tunisia, version 1.0)*, ISRIC Report 2010/01 : https://www.isric.org/sites/default/files/isric_report_2010_01.pdf
  - Fiche SOTER Tunisie : https://data.isric.org/geonetwork/srv/api/records/be18fb28-4f85-41d0-a448-6d56fba8bd3b
  - Fiche SOTWIS Tunisie : https://data.isric.org/geonetwork/srv/eng/catalog.search#/metadata/ec96be43-c10a-4580-8b6f-4db46ec29bbd
- **Comment :** notre copie vient du projet FarmWise (`soil_composition/static_geo/`).
- **Ce que représentent les valeurs (vérifié dans le rapport) :** le **sol principal** de chaque zone, **couche du dessus (0-20 cm)**. C'est la table qu'ISRIC a préparée « pour faciliter la visualisation » (annexe 4, note 3). Les zones « WT » (numéro -9) sont des **plans d'eau**.

| Code | Signification (rapport ISRIC, annexe 4) | Unité |
|---|---|---|
| `PHAQ` | pH mesuré dans l'eau | |
| `ELCO` | **Salinité ECe** (conductivité électrique) | dS/m |
| `ESP` | Sodium échangeable (≥ 15 % = sol sodique) | % de la CEC |
| `TCEQ` | Calcaire (équivalent carbonate) | g/kg |
| `GYPS` | Gypse | g/kg |
| `TOTC` | Carbone **organique** (pas le carbone total) | g/kg |
| `TOTN` | Azote total | g/kg |
| `TAWC` | Eau disponible pour la plante | % du volume (= cm d'eau par m de sol) |
| `CECS` | Capacité d'échange cationique (fertilité) | cmol/kg |
| `BSAT` | Saturation en bases | % de la CEC |
| `BULK` | Densité apparente | kg/dm³ |
| `CFRAG` | Cailloux (> 2 mm) | % du volume |
| `ALSA` | Saturation en aluminium | % de la CEC effective |
| `Elev_med`, `Slope_med`, `Relief_med` | Altitude, pente, relief (médianes) | m, %, m |
| `DomFAOgrou` | Grand type de sol : CL = calcisol, SC = solonchak (salé), FL = fluvisol, WT = eau... | |

### `services/soil_map/raw/governorates.geojson` : les frontières des 24 gouvernorats
- **Source :** geoBoundaries, « TUN ADM1 » (données OpenStreetMap, licence ODbL) : https://www.geoboundaries.org
- **Comment :** téléchargé depuis https://github.com/wmgeolab/geoBoundaries (dossier `releaseData/gbOpen/TUN/ADM1/`)

### `services/soil_map/output/tunisia_soil.geojson` : la carte prête à afficher
- Les 3 fichiers ISRIC réunis. Coordonnées arrondies à 4 décimales (environ 10 m).

### `services/soil_map/output/soil_samples.csv` : les 37 722 points
- Pour chaque point : gouvernorat, latitude, longitude et toutes les valeurs du sol de sa zone

### `services/soil_map/output/soil_by_region.csv` : le sol de chaque gouvernorat
- `area_km2` : surface de terre (sans les lacs)
- `<code>_median` : la valeur typique de chaque variable
- `salty_area_percent`, `sodic_area_percent` : % de surface salée et sodique
- `main_soils` : les 3 types de sol les plus présents, avec leur %

## 13. L'API du service 2

| Endpoint | Rôle |
|---|---|
| `GET /api/soil/options` | Les variables du sol (code, nom, unité) et les 24 gouvernorats |
| `GET /api/soil/map` | La carte du sol (GeoJSON, 752 zones) |
| `GET /api/soil/borders` | Les frontières des 24 gouvernorats (GeoJSON) |
| `GET /api/soil/region?name=Kairouan` | Le sol typique d'un gouvernorat sur toute sa surface |

## 14. Ce qu'il faut dire honnêtement au jury (service 2)

- **Échelle 1:1 000 000 :** ISRIC dit que ces données sont faites pour l'échelle nationale. Une zone couvre souvent des dizaines de km². Pour une parcelle précise, il faut un **test de sol**.
- **Valeurs estimées par ISRIC :** ISRIC estime les valeurs à partir de profils de sol mesurés (base WISE), par type de sol (méthode « taxotransfer »). C'est pourquoi plusieurs zones du même type de sol ont exactement les mêmes valeurs. ISRIC les présente comme les « meilleures estimations » disponibles.
- **Sol principal seulement :** une zone contient jusqu'à 4 sols différents. La carte montre le principal.

---

# SERVICE 3 : Cultures adaptées (modèle d'IA, comme FarmWise)

Page : **http://localhost:8000/crops** · Dossier : `crop_suitability/`

## 15. L'idée

> « Avec ce sol et ce climat, quelle culture planter ? »

Le formulaire est le même que dans FarmWise : **azote (N), phosphore (P), potassium (K), température, humidité, pH du sol, pluie**. La page renvoie **les 22 cultures classées**, chacune avec un %.

## 16. Les données (Kaggle)

| Dataset | Contenu | Utilisé ? | Lien |
|---|---|---|---|
| **Crop Recommendation** (Atharva Ingle, 2020, licence Apache 2.0) | 2 200 lignes, soit 100 par culture pour 22 cultures. Colonnes : N, P, K, température, humidité, pH, pluie → culture | ✅ **Oui** : entraîne le modèle | https://www.kaggle.com/datasets/atharvaingle/crop-recommendation-dataset |
| Crop and Soil Dataset (shankar, 2025) | 8 000 lignes : température, humidité, humidité du sol, type de sol, culture, N, P, K → 7 engrais | ❌ **Non** : un modèle n'atteint que **14 %** de précision, ce qui revient à deviner au hasard (1 chance sur 7). Les engrais sont attribués au hasard dans ces données. | https://www.kaggle.com/datasets/shankarpriya2913/crop-and-soil-dataset |
| Soil Fertility Dataset (utilisé par le notebook « Soil Fertility Prediction ») | 880 lignes : N, P, K, pH, EC, OC, S, Zn, Fe, Cu, Mn, B → classe de fertilité | ❌ **Pas dans ce formulaire** : ses N, P, K sont dans d'autres unités (N moyen 247, contre 50 dans le premier dataset) | https://www.kaggle.com/datasets/rahuljaiswalonkaggle/soil-fertility-dataset · notebook : https://www.kaggle.com/code/nouraalgohary/soil-fertility-prediction |

Les 3 datasets ont été téléchargés depuis l'API publique de Kaggle et testés avec le même modèle (Random Forest, validation croisée en 5 parties).

## 17. Le modèle d'IA : Random Forest

- **Ce que c'est :** 300 arbres de décision (bibliothèque scikit-learn). Chaque arbre apprend des règles du type « beaucoup de pluie + forte humidité → riz ».
- **Le résultat :** pour les valeurs saisies, chaque arbre vote pour une culture. Le **%** d'une culture est la part des 300 arbres qui ont voté pour elle.
- **Précision : 99,4 %.** Le test est une validation croisée en 5 parties : on entraîne sur 80 % des lignes et on teste sur les 20 % restantes, 5 fois.
- **Entrées les plus importantes :** pluie 23 %, humidité 22 %, potassium 17 %, phosphore 15 %, azote 10 %, température 7 %, pH 5 %.
- **Avertissement automatique :** si une valeur sort de ce que le modèle a vu à l'entraînement, la page prévient que le résultat est moins fiable. Sous chaque champ, la page affiche la plage des données.

**Exemple (les valeurs de la capture FarmWise) :** N=15, P=133, K=199, 23 °C, 91 %, pH 5,8, 117 mm → **pommier 99,7 %**, vigne 0,3 %.

## 18. Les fichiers du service 3

| Fichier | Rôle |
|---|---|
| `raw/Crop_recommendation.csv` | Le dataset Kaggle |
| `step1_train_model.py` | Entraîne le modèle, mesure la précision → `model/crop_model.joblib` + `output/model_report.json` |
| `step2_predict.py` | Prédit les cultures classées pour des valeurs données |

## 19. L'API du service 3

| Endpoint | Rôle |
|---|---|
| `GET /api/crops/predict?N=90&P=42&K=43&temperature=21&humidity=82&ph=6.5&rainfall=203` | Les 22 cultures classées avec leur % |
| `GET /api/crops/model` | La précision, la liste des cultures et la plage de chaque entrée |

## 20. Ce qu'il faut dire honnêtement au jury (service 3)

- **D'où viennent les données :** la description du dataset dit « built by augmenting datasets of rainfall, climate and fertilizer data available for **India** ». Ce sont donc des conditions indiennes, pas des mesures tunisiennes. C'est pour cela que la précision est si haute : les données sont très « propres ».
- **Les cultures :** le modèle connaît 22 cultures, dont des cultures tropicales (riz, café, mangue...). Certaines grandes cultures tunisiennes (olivier, blé, palmier dattier) n'y sont pas.
- **Les unités ne sont pas définies :** le dataset ne précise ni l'unité de N, P et K, ni la période de la pluie. Il faut saisir des valeurs dans les plages affichées.

---

# SERVICE 4 : Prévision du marché tunisien (2027)

Page : **http://localhost:8000/market** · Dossier : `market/`

## 21. L'idée

> « Qu'est-ce que la Tunisie va manquer en 2027, et quelle culture rapporte le plus pour mon eau ? »

- **Entrée :** gouvernorat + mois de plantation (pour calculer l'eau)
- **Sortie :**
  1. les produits qui vont manquer en 2027 (autosuffisance 2024 → 2027, tonnes manquantes)
  2. les 10 cultures qui rapportent le plus de **dinars par m³ d'eau**
  3. le graphique d'un produit de 2000 à 2027

## 22. Les données : FAOSTAT (statistiques officielles de la FAO, ONU)

| Données | Années | Lien |
|---|---|---|
| Production, surface, rendement | 2000-2024 | https://www.fao.org/faostat/en/#data/QCL |
| Importations et exportations | 2000-2024 | https://www.fao.org/faostat/en/#data/TCL |
| Prix payé à l'agriculteur (TND/t) + indice des prix au producteur | prix réels jusqu'en 2022, indice jusqu'en 2025 | https://www.fao.org/faostat/en/#data/PP |

`step1_download.py` télécharge les fichiers gratuits de FAOSTAT (https://bulks-faostat.fao.org/production/) et garde seulement la Tunisie. Le service couvre 30 produits.

## 23. Les formules

```
consommation    = production + importations − exportations
autosuffisance  = production ÷ consommation × 100        (moins de 100 % = la Tunisie importe)
manque          = consommation − production
prix 2025       = dernier prix réel × indice 2025 ÷ indice de cette année   (indice FAOSTAT)
revenu par ha   = rendement × prix au producteur 2025     (revenu brut)
dinars par m³   = revenu par ha ÷ eau à ajouter (service 1)
```

## 24. La prévision : le modèle Theta

- **La méthode :** une série temporelle entraînée sur 2000-2024, qui prévoit 2025, 2026 et 2027.
- **Le choix du modèle :** nous avons testé 7 modèles sur le passé et gardé le meilleur.
- **Le test :** le modèle est entraîné jusqu'en 2018 et jusqu'en 2021, puis il prévoit les 3 années suivantes. Erreur moyenne : **production 6,5 %, consommation 9,8 %**, à peu près la même que la prévision « naïve » (même valeur que la dernière année).

## 25. Résultats

| Ce qui va manquer en 2027 | Autosuffisance 2024 → 2027 | Manque en 2027 |
|---|---|---|
| **Blé** | 45 % → **36 %** | **1,78 Mt** |
| **Maïs** | 0 % | 1,03 Mt |
| **Orge** | 39 % → **34 %** | **0,81 Mt** |
| Pomme de terre | 95 % → 94 % | 29 400 t |
| Pois chiche | 46 % → 49 % | 10 700 t |
| Lentille | 23 % → 23 % | 6 300 t |

**Ce qui rapporte le plus par m³ d'eau :** la pastèque, la laitue, le piment, la tomate et l'orange. Le classement exact dépend du gouvernorat et du mois choisis.

## Contrôles de qualité des données (marché)

- **Rendement non crédible :** si le rendement tunisien de FAOSTAT dépasse 2 fois la médiane du Maroc, de l'Algérie et de l'Égypte, on utilise cette médiane et la page l'affiche. Seule la **pastèque** est concernée : FAOSTAT donne 103 t/ha, contre 38 t/ha chez les voisins. La surface récoltée déclarée est probablement sous-estimée.
- **« La Tunisie en manque » :** seulement si l'autosuffisance 2027 est **inférieure à 90 %** et qu'il manque au moins 1 000 t. La liste est donc : blé, maïs, orge, pois chiche, lentille. La pomme de terre (94 %, importée surtout en semences) n'en fait plus partie.
- **« Marché déjà plein » :** quand l'autosuffisance atteint 100 % ou plus, produire davantage peut faire baisser le prix.

## Garde-fous : peut-on vraiment semer ce mois-ci ? (`services/market/step4_planting_calendar.py`)

Le classement en dinars par m³ suppose que la culture peut pousser le mois choisi. Par exemple, la pastèque semée dehors en décembre à Sidi Bouzid gèlerait. Deux contrôles :

1. **Calendrier cultural FAO de la Tunisie, par zone** (chaque gouvernorat utilise les dates de sa zone agro-écologique ; si la zone n'a pas de dates pour une culture, on prend la zone de référence « Nord-Est et Cap Bon » ; par exemple le melon en décembre n'est permis que dans la zone chaude du Sud, pas à Bizerte) (https://cropcalendar.apps.fao.org, 86 entrées, `services/market/raw/fao_crop_calendar_tunisia.json`). Pour chaque culture et chaque mois :
   - **plein champ** → la culture est classée
   - **seulement sous tunnel / serre / brise-vent** → affichée à part (coûts en plus, non inclus)
   - **hors saison** → non classée
   - Les arbres sont déjà en terre.
2. **Gel par gouvernorat** (NASA POWER, jours de gel par mois, `services/market/raw/nasa_frost_days.csv`). Une culture sensible au gel est exclue si les jours de gel du mois de semis et du mois suivant dépassent 0,5 en moyenne. Les cultures sensibles au gel sont celles dont la température minimale FAO EcoCrop est d'au moins 7 °C : pastèque, melon, tomate, piment, pomme de terre, sorgho.

Exemple : à Sidi Bouzid en décembre, la pastèque et la tomate passent « seulement sous tunnel », le piment et le melon sont exclus pour « risque de gel », et le classement devient orange, oignon, carotte.

## 26. Limites

- **Prix au producteur 2025 :** le dernier prix réel FAOSTAT (2022, ou 2016 pour certains produits) est mis à jour jusqu'en 2025 avec l'indice des prix au producteur de FAOSTAT. Les valeurs de l'indice pour 2023-2025 sont des **estimations de la FAO** (code « E »).
- **Revenu brut :** les coûts ne sont pas comptés.
- **Produits transformés :** la farine et l'huile ne sont pas comptées dans la consommation du produit brut.

---

# SERVICE 5 : Khiratna, le chatbot (énergie + rotation des cultures)

Page : **http://localhost:8000/chat** · Dossiers : `chatbot/` (RAG, voix) et `energy/` (le calculateur que Khiratna appelle, il n'a plus de page à lui)

## 27. Le calculateur (`services/energy/step2_pumping.py`)

```
eau à pomper (m³)      = eau à ajouter (service 1) × hectares
énergie (kWh)          = eau × 0,00272 × profondeur du puits (m) ÷ rendement de la pompe
coût STEG (TND)        = énergie × (prix STEG + 5 millimes de surtaxe) × 1,07 (TVA irrigation 7 %)
panneaux solaires (kWc)= énergie du mois le plus chargé ÷ production solaire de ce mois (PVGIS)
subvention (TND)       = barème FTE / ANME PROSOL-ELEC hors réseau agricole (par kWc, plafond 50 000 TND)
retour sur invest.     = (prix installateur − subvention) ÷ coût STEG économisé par an   (si l'agriculteur donne un devis)
```

Les valeurs par défaut sont 30 m de profondeur, 50 % de rendement et 291 millimes/kWh (tarif STEG moyenne tension uniforme, 2022). L'agriculteur les remplace par les siennes. Aucun prix officiel par kWc n'existe : il faut saisir le devis de l'installateur.

## 28. Les données (`services/energy/raw/`, `services/chatbot/docs/`)

| Donnée | Source | Fichier |
|---|---|---|
| Production solaire par gouvernorat (kWh/kWc, par mois) | PVGIS (Commission européenne, JRC) https://re.jrc.ec.europa.eu/pvg_tools/en/ | `services/energy/raw/pvgis_tunisia.csv` |
| Électricité de la Tunisie (95 % gaz, 2,5 % solaire en 2025) | Our World in Data https://github.com/owid/energy-data | `services/energy/raw/tunisia_electricity.csv` |
| Tarifs STEG (2022), subventions FTE/ANME, production solaire ANME | steg.com.tn, fte-anme.tn, anme.tn (URL dans le fichier) | `services/chatbot/docs/tunisia_energy_facts.md` |
| Guide FAO « solar-powered irrigation » (2018, 87 p.) | https://www.fao.org/3/i9047en/I9047EN.pdf | `services/chatbot/docs/fao_solar_irrigation_2018.pdf` |
| Guide IRENA « Solar pumping for irrigation » (2016, 36 p.) | irena.org | `services/chatbot/docs/irena_solar_pumping_2016.pdf` |

## 29. Le chatbot (RAG)

1. **`services/chatbot/step1_index.py`** : les documents sont découpés en 363 passages, puis chaque passage devient un vecteur de 768 nombres (Gemini `gemini-embedding-001`).
2. **Stockage :** les vecteurs vont dans **PostgreSQL + pgvector** (table `energy_chunks`, index HNSW cosinus). Une copie locale est toujours gardée (`services/chatbot/output/index.npz`) et sert quand PostgreSQL ne tourne pas.
3. **`services/chatbot/step2_chat.py`** : la question devient un vecteur, puis on cherche les 6 passages les plus proches, plus toujours les 2 meilleurs passages tunisiens. Gemini répond uniquement à partir de ces passages, avec les sources.
4. **Questions chiffrées :** si la question demande un coût ou un nombre de panneaux, Gemini **appelle le calculateur** (function calling) au lieu d'inventer.

Les clés Gemini sont dans `ai-service/.env` (`GEMINI_API_KEYS`, plusieurs clés : si une est bloquée, on passe à la suivante). Ce fichier n'est **jamais sur GitHub** (`.gitignore`). Si le modèle principal est surchargé, le chatbot utilise un modèle de secours.

**pgvector sans Docker :** il faut mettre dans `DATABASE_URL` (fichier `ai-service/.env`) l'adresse d'un PostgreSQL qui a l'extension pgvector, puis relancer `python -m services.chatbot.step1_index`. Sans base, le chatbot fonctionne avec la copie locale.

## 30. API

| Endpoint | Rôle |
|---|---|
| `POST /api/chat` corps `{"question": "..."}` | Réponse de Khiratna (anglais) + sources + calculs faits |
| `POST /api/stt` corps = l'audio enregistré | La voix devient du texte (Whisper) : `{"text": "..."}` |
