import 'package:khiratna_frontend/model/smart_maps/governorate_map_data.dart';
import 'package:khiratna_frontend/model/smart_maps/map_parameter.dart';

final soilParameters = [
  SoilParameter(
    name: "Soil Salinity",
    description:
        "Measures dissolved salts present in soils affecting crop growth.",
    whyImportant:
        "High salinity reduces water uptake and lowers yield.",
    legendItems: [
      "Low",
      "Moderate",
      "High",
    ],
  ),

  SoilParameter(
    name: "Soil Sodicity",
    description:
        "Measures exchangeable sodium content in soil.",
    whyImportant:
        "Excess sodium damages soil structure and roots.",
    legendItems: [
      "Normal",
      "Moderate",
      "Critical",
    ],
  ),

  SoilParameter(
    name: "Soil pH",
    description:
        "Indicates acidity or alkalinity of soil.",
    whyImportant:
        "pH influences nutrient availability.",
    legendItems: [
      "Acidic",
      "Neutral",
      "Alkaline",
    ],
  ),
];

final governorateData = [
  GovernorateSoilData(
    governorate: "Zaghouan",
    salinity: 0.56,
    ph: 8.12,
    organicCarbon: 7.0,
    nitrogen: 0.75,
    mainSoils: [
      "Cambisol",
      "Calcisol",
      "Fluvisol",
    ],
  ),

  GovernorateSoilData(
    governorate: "Sfax",
    salinity: 1.34,
    ph: 7.8,
    organicCarbon: 5.8,
    nitrogen: 0.61,
    mainSoils: [
      "Calcisol",
      "Regosol",
    ],
  ),
];