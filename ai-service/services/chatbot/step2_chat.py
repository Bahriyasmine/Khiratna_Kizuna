"""CHATBOT - STEP 2: ANSWER A FARMER'S QUESTION (energy of irrigation + crop rotation).

  1. RETRIEVAL   rag.retrieve(): the 6 best passages (best retriever of step3_evaluate: multilingual E5 vectors)
                 + the 2 best passages of the short sourced sheets (Tunisian energy facts, crop rotation rules)
  2. GENERATION  Gemini (gemini-2.5-flash, thinking off = ~1-2 s) answers ONLY from these passages, in English,
                 short sentences (it can be read aloud); sources stay in the API response, not in the text
  3. TOOL        for costs / kWh / solar panels on a real farm, Gemini calls our calculator
                 (service 5, services/energy/step2_pumping.py) instead of guessing (function calling)

Run (from the ai-service/ folder):  python -m services.chatbot.step2_chat "What can I plant after tomatoes?"
"""
import json
import sys

from services.chatbot.gemini import generate
from services.chatbot.rag import BEST, retrieve, store
from services.energy.step2_pumping import irrigation_energy

SYSTEM = """You are Khiratna, a farming assistant for Tunisian farmers, on two topics:
1) ENERGY of irrigation: pumping cost, STEG electricity, solar pumping, ANME/FTE subsidies;
2) CROP ROTATION: which crop to plant before/after another, plant families, how many years to wait, diseases.
ALWAYS answer in English, even if the question is in French or Arabic. Answer simply and briefly (at most 5 short
sentences or bullets), like a friendly advisor talking to a farmer: the answer may be read aloud.
Use ONLY the CONTEXT passages and the calculator results, but NEVER mention them: no sources, no file names, no page
numbers, no "according to the context/document". If the answer is not in the context, say you do not know and suggest
asking the CRDA, STEG or ANME. Never invent prices, tariffs, subsidies, numbers of panels or numbers of years.
For a cost, an energy amount, solar panels, a subsidy or a payback on a real farm, ALWAYS call the tool
irrigation_energy first (it computes the payback when the farmer gives the installer price per kWp); never refuse,
never ask for the well depth: use 30 m. If the month is missing, use the usual planting month of the crop and say which month you used.
For "what to plant after/before X": give X's plant family and suggest crops of OTHER families from the context
(the family rule), never the same family.
Crops of the tool: tomato, pepper, potato, onion, carrot, lettuce, watermelon, melon, wheat, sorghum, citrus,
grapes, almond, apricot_peach, pistachio, alfalfa, olive, date_palm. Governorates: the 24 of Tunisia.
If the well depth is not given, say you used 30 m."""

TOOL = {
    "name": "irrigation_energy",
    "description": "Irrigation water, pumping energy (kWh), STEG grid cost (TND), solar panels needed (kWp) and "
                   "FTE subsidy for one crop season in one Tunisian governorate.",
    "parameters": {"type": "object", "properties": {
        "region": {"type": "string", "description": "Governorate, e.g. Kebili"},
        "crop": {"type": "string", "description": "Crop id, e.g. tomato"},
        "planting_month": {"type": "integer", "description": "1-12"},
        "hectares": {"type": "number"},
        "head_m": {"type": "number", "description": "Pumping head = well depth in metres (default 30)"},
        "solar_price_tnd_per_kwp": {"type": "number", "description": "Installer price per kWp, only if the farmer gives it"},
    }, "required": ["region", "crop", "planting_month"]},
}


def answer(question: str) -> dict:
    found = retrieve(question)
    context = "\n\n".join(f"[{c['source']} p.{c['page']}]\n{c['content']}" for c in found)
    contents = [{"role": "user", "parts": [{"text": f"CONTEXT:\n{context}\n\nQUESTION: {question}"}]}]
    tool_results = []
    sources = [{"source": c["source"], "page": c["page"], "topic": c["topic"]} for c in found]
    for _ in range(3):                                     # the model may call the calculator, then answer
        reply = generate(contents, SYSTEM, [TOOL])
        parts = reply["candidates"][0]["content"]["parts"]
        calls = [p["functionCall"] for p in parts if "functionCall" in p]
        if not calls:
            return {"answer": "".join(p.get("text", "") for p in parts).strip(), "sources": sources,
                    "retriever": f"{BEST['embedder']} {BEST['mode']}", "vector_store": store(), "calculator": tool_results}
        contents.append({"role": "model", "parts": parts})
        responses = []
        for call in calls:
            try:
                r = irrigation_energy(**call.get("args", {}))
                result = {"total": r["total"], "assumptions": r["assumptions"], "sources": r["sources"]}
            except (ValueError, TypeError) as e:
                result = {"error": str(e)}
            tool_results.append({"args": call.get("args", {}), "result": result})
            responses.append({"functionResponse": {"name": call["name"], "response": result}})
        contents.append({"role": "user", "parts": responses})
    return {"answer": "Sorry, I could not finish the calculation.", "sources": sources, "calculator": tool_results}


if __name__ == "__main__":
    q = " ".join(sys.argv[1:]) or "What can I plant after tomatoes?"
    print(json.dumps(answer(q), indent=2, ensure_ascii=False))
