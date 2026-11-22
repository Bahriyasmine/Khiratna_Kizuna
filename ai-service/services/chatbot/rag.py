"""CHATBOT - THE RETRIEVAL ENGINE (shared by indexing, chat and evaluation).

Knowledge base (services/chatbot/docs/), 2 topics:
  energy   : fao_solar_irrigation_2018.pdf, irena_solar_pumping_2016.pdf, tunisia_energy_facts.md
  rotation : rotation_sare_organic_farms_manual.pdf, crop_rotation_rules.md

3 embedding models (turn a text into a vector of numbers):
  gemini  gemini-embedding-001 (Google API, 768 numbers, multilingual)
  minilm  sentence-transformers/all-MiniLM-L6-v2 (local, free, 384 numbers, trained mostly on English)
  e5      intfloat/multilingual-e5-small (local, free, 384 numbers, 100 languages incl. French and Arabic)

3 search modes:
  dense   cosine similarity between the question vector and the chunk vectors
  bm25    keyword search (BM25 = the classic search-engine formula: rare words that appear in a chunk score high)
  hybrid  dense + bm25 merged with Reciprocal Rank Fusion: score = 1/(60 + rank_dense) + 1/(60 + rank_bm25)
          -> a chunk found by both methods comes first; exact words (PROSOL, STEG, Fusarium) are not missed

The best model and mode are chosen by the evaluation (services/chatbot/step3_evaluate.py): see BEST below.
"""
import json
import math
import re
import unicodedata
from collections import Counter
from functools import lru_cache

import numpy as np

from common import ROOT

DOCS = ROOT / "services" / "chatbot" / "docs"
OUT = ROOT / "services" / "chatbot" / "output"
TOPIC = {"fao_solar_irrigation_2018.pdf": "energy", "irena_solar_pumping_2016.pdf": "energy",
         "tunisia_energy_facts.md": "energy", "rotation_sare_organic_farms_manual.pdf": "rotation",
         "crop_rotation_rules.md": "rotation"}
CURATED = ("tunisia_energy_facts.md", "crop_rotation_rules.md")   # short, sourced sheets: always 2 best passages added
LOCAL_MODELS = {"minilm": "sentence-transformers/all-MiniLM-L6-v2", "e5": "intfloat/multilingual-e5-small"}
BEST = {"embedder": "e5", "mode": "dense"}   # winner of step3_evaluate: Hit@6 100 %, MRR 0.92 (EN and FR)


# ---------- embeddings ----------
@lru_cache
def local_model(name: str):
    from sentence_transformers import SentenceTransformer
    return SentenceTransformer(LOCAL_MODELS[name])


def embed(texts: list, embedder: str, kind: str) -> np.ndarray:
    """kind = 'passage' (documents) or 'query' (question). Returns normalised vectors (cosine = dot product)."""
    if embedder == "gemini":
        from services.chatbot.gemini import embed as gemini_embed
        v = np.array(gemini_embed(texts, "RETRIEVAL_DOCUMENT" if kind == "passage" else "RETRIEVAL_QUERY"), dtype=np.float32)
    else:
        if embedder == "e5":                       # e5 was trained with these prefixes
            texts = [f"{kind}: {t}" for t in texts]
        v = local_model(embedder).encode(texts, batch_size=32, show_progress_bar=False, convert_to_numpy=True)
        v = v.astype(np.float32)
    return v / np.linalg.norm(v, axis=1, keepdims=True)


# ---------- BM25 (keyword search) ----------
def tokens(text: str) -> list:
    text = unicodedata.normalize("NFKD", text.lower()).encode("ascii", "ignore").decode()
    return [w for w in re.findall(r"[a-z0-9]+", text) if len(w) > 1]


class BM25:
    def __init__(self, docs: list, k1: float = 1.5, b: float = 0.75):
        self.k1, self.b = k1, b
        self.docs = [Counter(tokens(d)) for d in docs]
        self.lengths = np.array([sum(d.values()) for d in self.docs], dtype=float)
        self.avg = self.lengths.mean()
        df = Counter(w for d in self.docs for w in d)
        n = len(docs)
        self.idf = {w: math.log(1 + (n - f + 0.5) / (f + 0.5)) for w, f in df.items()}

    def scores(self, query: str) -> np.ndarray:
        out = np.zeros(len(self.docs))
        for w in set(tokens(query)):
            if w not in self.idf:
                continue
            tf = np.array([d.get(w, 0) for d in self.docs], dtype=float)
            out += self.idf[w] * tf * (self.k1 + 1) / (tf + self.k1 * (1 - self.b + self.b * self.lengths / self.avg))
        return out


# ---------- the index ----------
@lru_cache
def chunks() -> list:
    return json.loads((OUT / "chunks.json").read_text(encoding="utf-8"))


@lru_cache
def vectors(embedder: str) -> np.ndarray:
    return np.load(OUT / f"vectors_{embedder}.npz")["vectors"]


@lru_cache
def bm25() -> BM25:
    return BM25([f"{c['source']} {c['content']}" for c in chunks()])


@lru_cache
def pg():
    """Connection to PostgreSQL + pgvector (table rag_chunks made by step1_index), or None -> local files."""
    try:
        import psycopg2
        from services.chatbot.gemini import env
        conn = psycopg2.connect(env("DATABASE_URL"), connect_timeout=2)
        conn.autocommit = True
        with conn.cursor() as cur:
            cur.execute("SELECT count(*) FROM rag_chunks")
            if cur.fetchone()[0] != len(chunks()):
                return None                                  # table older than chunks.json: use the files
        return conn
    except Exception:
        return None


def dense_order(question: str, embedder: str) -> list:
    """Chunk numbers by cosine similarity. pgvector (HNSW index) when the database is there, else numpy."""
    q = embed([question], embedder, "query")[0]
    if embedder == BEST["embedder"] and pg() is not None:
        vec = str(q.tolist())
        with pg().cursor() as cur:                           # <=> = cosine distance of pgvector
            cur.execute("SELECT id FROM rag_chunks ORDER BY embedding <=> %s::vector LIMIT 50", (vec,))
            top = [r[0] for r in cur.fetchall()]
            cur.execute("SELECT id FROM rag_chunks WHERE source = ANY(%s) ORDER BY embedding <=> %s::vector",
                        (list(CURATED), vec))
            return top + [r[0] for r in cur.fetchall() if r[0] not in top]
    return list(np.argsort(-(vectors(embedder) @ q)))


def store() -> str:
    return "pgvector (PostgreSQL)" if pg() is not None else "local files (numpy)"


def ranking(question: str, embedder: str, mode: str) -> list:
    """All chunk numbers, best first."""
    if mode in ("dense", "hybrid"):
        dense = dense_order(question, embedder)
    if mode in ("bm25", "hybrid"):
        sparse = list(np.argsort(-bm25().scores(question)))
    if mode == "dense":
        return dense
    if mode == "bm25":
        return sparse
    fused = Counter()                                         # Reciprocal Rank Fusion
    for order in (dense, sparse):
        for rank, i in enumerate(order):
            fused[i] += 1 / (60 + rank + 1)
    return [i for i, _ in fused.most_common()]


def retrieve(question: str, k: int = 6, k_curated: int = 2, embedder: str = None, mode: str = None) -> list:
    """The k best chunks + the k_curated best chunks of the short sourced sheets (Tunisian energy facts, rotation rules)."""
    embedder, mode = embedder or BEST["embedder"], mode or BEST["mode"]
    order = ranking(question, embedder, mode)
    picked = order[:k] + [i for i in order if chunks()[i]["source"] in CURATED][:k_curated]
    seen, out = set(), []
    for rank, i in enumerate(picked):
        if i not in seen:
            seen.add(i)
            out.append({**chunks()[i], "rank": rank + 1})
    return out
