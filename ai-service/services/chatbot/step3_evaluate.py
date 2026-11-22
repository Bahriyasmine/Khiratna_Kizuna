"""CHATBOT - STEP 3: WHICH RETRIEVER IS BEST? (retrieval evaluation)

24 test questions (12 energy, 12 crop rotation; half in English, half in French). For each question we wrote
which documents contain the answer and which words a correct passage must contain.

For every embedding model (gemini if its vectors exist, minilm, e5) x every search mode (dense, bm25, hybrid):
  Hit@6  = % of questions where a correct passage is in the 6 passages given to the chatbot
  MRR@10 = mean of 1 / rank of the first correct passage (1.0 = always first; 0.5 = usually second)
Computed on the raw ranking (without the 2 curated passages that retrieve() always adds).

Creates  services/chatbot/output/retrieval_evaluation.csv
Run (from the ai-service/ folder):  python -m services.chatbot.step3_evaluate
"""
import pandas as pd

from services.chatbot.rag import OUT, chunks, ranking, tokens

FACTS, RULES = "tunisia_energy_facts.md", "crop_rotation_rules.md"
FAO, IRENA, SARE = "fao_solar_irrigation_2018.pdf", "irena_solar_pumping_2016.pdf", "rotation_sare_organic_farms_manual.pdf"
TESTS = [  # (question, language, topic, documents with the answer, words a correct passage contains)
    ("How much does STEG charge per kWh for medium voltage?", "en", "energy", [FACTS], ["291"]),
    ("Quel est le tarif STEG en moyenne tension ?", "fr", "energy", [FACTS], ["291"]),
    ("What subsidy does the FTE give per kWp for solar pumping?", "en", "energy", [FACTS], ["3 500", "6 000"]),
    ("Quelle subvention l'Etat donne pour une pompe solaire agricole ?", "fr", "energy", [FACTS], ["3 500", "6 000"]),
    ("How much electricity does 1 kWp of solar panels produce in Tunisia?", "en", "energy", [FACTS], ["1 450", "1 830", "1 537"]),
    ("D'où vient l'électricité en Tunisie ?", "fr", "energy", [FACTS], ["natural gas"]),
    ("What are the risks of solar irrigation for groundwater?", "en", "energy", [FAO, IRENA], ["groundwater", "aquifer"]),
    ("Quels sont les risques du pompage solaire pour les nappes d'eau souterraines ?", "fr", "energy", [FAO, IRENA], ["groundwater", "aquifer"]),
    ("Is solar pumping cheaper than a diesel pump over its lifetime?", "en", "energy", [FAO, IRENA], ["diesel"]),
    ("Pompe solaire ou pompe diesel : laquelle coûte le moins cher ?", "fr", "energy", [FAO, IRENA], ["diesel"]),
    ("Do I need batteries or a water tank for a solar irrigation pump?", "en", "energy", [FAO, IRENA], ["batter", "tank", "storage"]),
    ("Quels pays subventionnent les pompes solaires d'irrigation ?", "fr", "energy", [FAO, IRENA], ["subsid"]),
    ("How many years should I wait before planting tomatoes again in the same field?", "en", "rotation", [RULES, SARE], ["3 years", "three years", "year after year"]),
    ("Combien d'années attendre avant de replanter des tomates au même endroit ?", "fr", "rotation", [RULES, SARE], ["3 years", "three years", "year after year"]),
    ("Can I plant potatoes after tomatoes?", "en", "rotation", [RULES, SARE], ["solanaceae", "same family", "nightshade"]),
    ("Peut-on planter des pommes de terre après des tomates ?", "fr", "rotation", [RULES, SARE], ["solanaceae", "same family", "nightshade"]),
    ("What should I plant after tomato to control Verticillium wilt?", "en", "rotation", [RULES, SARE], ["verticillium"]),
    ("Quelle culture planter après la tomate contre la fusariose ?", "fr", "rotation", [RULES, SARE], ["fusarium"]),
    ("Which crops belong to the same family as watermelon?", "en", "rotation", [RULES, SARE], ["cucurbit"]),
    ("Why plant legumes before a demanding crop?", "en", "rotation", [RULES, SARE], ["nitrogen"]),
    ("Pourquoi planter des légumineuses comme le pois chiche avant le blé ?", "fr", "rotation", [RULES, SARE], ["nitrogen", "legume"]),
    ("How do cover crops help a crop rotation?", "en", "rotation", [SARE, RULES], ["cover crop"]),
    ("Comment lutter contre la gale commune de la pomme de terre par la rotation ?", "fr", "rotation", [RULES, SARE], ["scab"]),
    ("Donne-moi un exemple de rotation sur 3 ans", "fr", "rotation", [RULES, SARE], ["3-year", "three-year", "beans"]),
]


def relevant(chunk: dict, sources: list, words: list) -> bool:
    text = " ".join(tokens(chunk["content"]))
    return chunk["source"] in sources and any(" ".join(tokens(w)) in text for w in words)


def main():
    rows = []
    models = [m for m in ("gemini", "minilm", "e5") if (OUT / f"vectors_{m}.npz").exists()]
    for model in models:
        for mode in ("dense", "bm25", "hybrid"):
            if mode == "bm25" and model != models[0]:
                continue                                   # BM25 does not use embeddings: test it once
            for q, lang, topic, sources, words in TESTS:
                order = ranking(q, model, mode)[:10]
                ranks = [r for r, i in enumerate(order, 1) if relevant(chunks()[i], sources, words)]
                rows.append({"embedder": "-" if mode == "bm25" else model, "mode": mode, "language": lang,
                             "topic": topic, "question": q, "hit@6": bool(ranks and ranks[0] <= 6),
                             "rr@10": 1 / ranks[0] if ranks else 0.0})
    d = pd.DataFrame(rows)
    d.to_csv(OUT / "retrieval_evaluation.csv", index=False)
    summary = d.groupby(["embedder", "mode"]).agg(hit6=("hit@6", "mean"), mrr10=("rr@10", "mean"))
    by_lang = d.pivot_table(index=["embedder", "mode"], columns="language", values="hit@6", aggfunc="mean")
    by_lang.columns = [f"hit6_{c}" for c in by_lang.columns]
    out = (summary.join(by_lang) * 100).round(0).astype(int).sort_values(["hit6", "mrr10"], ascending=False)
    print("  % (Hit@6 = correct passage in the 6 given to the chatbot; MRR@10 x 100)")
    print(out.to_string())


if __name__ == "__main__":
    main()
