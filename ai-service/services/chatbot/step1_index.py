"""CHATBOT - STEP 1: BUILD THE KNOWLEDGE BASE (chunks + vectors), for energy AND crop rotation.

Documents (services/chatbot/docs/):
  energy
    fao_solar_irrigation_2018.pdf        FAO "The benefits and risks of solar-powered irrigation" (2018)
                                         https://www.fao.org/3/i9047en/I9047EN.pdf
    irena_solar_pumping_2016.pdf         IRENA "Solar pumping for irrigation" (2016), irena.org
    tunisia_energy_facts.md              STEG tariffs, FTE/ANME subsidies, PVGIS, electricity mix (official URLs inside)
  rotation
    rotation_sare_organic_farms_manual.pdf  SARE/USDA "Crop Rotation on Organic Farms: A Planning Manual" (2009/2020)
    crop_rotation_rules.md               plant families + rules + tomato/potato tables (Clemson HGIC, UC IPM; URLs inside)

Chunking:
  PDF       cleaned first: repeated page headers/footers and page numbers removed, words cut by a hyphen
            re-joined, line breaks removed. Then WHOLE sentences are packed up to ~1 000 characters, with the
            last 2 sentences repeated in the next chunk (overlap). Sentences flow across pages.
            Bibliography chunks (many years + "et al."/URLs) are dropped: they are not knowledge.
  markdown  one chunk per section (## title), so a topic is never cut
  each chunk keeps: source file, page, topic (energy / rotation)

Vectors: for the 3 embedding models of rag.py (gemini, minilm, e5) -> services/chatbot/output/vectors_<model>.npz
pgvector: the vectors of the BEST model also go to PostgreSQL table rag_chunks (HNSW cosine index) when
          DATABASE_URL in ai-service/.env points to a PostgreSQL with pgvector; otherwise the local files are used.

Run (from the ai-service/ folder):  python -m services.chatbot.step1_index            (all 3 models)
                              python -m services.chatbot.step1_index e5         (one model)
"""
import json
import re
import sys
from collections import Counter

import numpy as np
import pypdf

from services.chatbot.rag import BEST, DOCS, OUT, TOPIC, embed

CHUNK, OVERLAP_SENTENCES = 1000, 2
SENTENCE_END = re.compile(r"(?<=[.!?:])\s+(?=[A-Z0-9•\"(-])")


def pdf_pages(path) -> list:
    """(page, clean text) of a PDF: running headers/footers and page numbers removed, broken words re-joined."""
    raw = [page.extract_text() or "" for page in pypdf.PdfReader(path).pages]
    norm = lambda line: re.sub(r"\d+", "", line).strip().lower()
    seen = Counter(n for text in raw for n in {norm(l) for l in text.splitlines()} if n)
    header = {n for n, c in seen.items() if c >= max(3, len(raw) // 5) and len(n) < 100}
    out = []
    for i, text in enumerate(raw, 1):
        lines = [l for l in text.splitlines() if norm(l) not in header and not re.fullmatch(r"\s*\d{1,3}\s*", l)]
        text = re.sub(r"(\w)-\n(\w)", r"\1\2", "\n".join(lines))      # "irriga-" + "tion" -> "irrigation"
        text = re.sub(r"\s*\n\s*", " ", text)                          # PDF line breaks -> spaces
        out.append((i, re.sub(r"\s{2,}", " ", text).strip()))
    return out


def is_bibliography(text: str) -> bool:
    years = len(re.findall(r"(?:19|20)\d{2}", text))
    refs = len(re.findall(r"et al\.|https?://|www\.|doi|Retrieved|ISBN|pp\. \d", text))
    return years >= 6 and refs >= 2


def pdf_chunks(path) -> list:
    """Whole sentences packed up to ~1 000 characters; the last 2 sentences are repeated in the next chunk
    (overlap) so an idea cut between 2 chunks is still complete in one of them. Sentences flow across pages."""
    sentences = []                                                        # (page, sentence)
    for page, text in pdf_pages(path):
        for s in SENTENCE_END.split(text):
            while len(s) > CHUNK:                                         # very long list/table: cut at a space
                cut = s.rfind(" ", 0, CHUNK)
                sentences.append((page, s[:cut]))
                s = s[cut + 1:]
            if s.strip():
                sentences.append((page, s.strip()))
    chunks, current = [], []
    for page, s in sentences:
        if current and sum(len(x) + 1 for _, x in current) + len(s) > CHUNK:
            chunks.append(current)
            current = current[-OVERLAP_SENTENCES:] if len(current) > OVERLAP_SENTENCES else []
        current.append((page, s))
    if current:
        chunks.append(current)
    rows = []
    for c in chunks:
        text = " ".join(s for _, s in c)
        if len(text) >= 200 and not is_bibliography(text):
            rows.append((c[0][0], text))
    return rows


def md_chunks(path) -> list:
    """One chunk per section (## title), so a topic is never cut."""
    sections = path.read_text(encoding="utf-8").split("\n## ")
    return [(i, s.strip() if i == 1 else "## " + s.strip()) for i, s in enumerate(sections, 1) if len(s.strip()) > 80]


def build_chunks() -> list:
    rows = []
    for path in sorted(DOCS.iterdir()):
        if path.name in TOPIC:
            pieces = pdf_chunks(path) if path.suffix == ".pdf" else md_chunks(path)
            rows += [{"source": path.name, "page": page, "topic": TOPIC[path.name], "content": text}
                     for page, text in pieces]
    return rows


def save_pgvector(rows, vecs):
    import psycopg2
    from services.chatbot.gemini import env
    with psycopg2.connect(env("DATABASE_URL"), connect_timeout=5) as conn, conn.cursor() as cur:
        cur.execute("CREATE EXTENSION IF NOT EXISTS vector")
        cur.execute("DROP TABLE IF EXISTS rag_chunks")
        cur.execute(f"""CREATE TABLE rag_chunks (id int PRIMARY KEY, source text, page int, topic text, content text,
                                                 embedding vector({vecs.shape[1]}))""")
        cur.executemany("INSERT INTO rag_chunks VALUES (%s, %s, %s, %s, %s, %s::vector)",
                        [(i, r["source"], r["page"], r["topic"], r["content"], str(v.tolist()))
                         for i, (r, v) in enumerate(zip(rows, vecs))])
        cur.execute("CREATE INDEX ON rag_chunks USING hnsw (embedding vector_cosine_ops)")
    print(f"  saved {len(rows)} chunks in PostgreSQL table rag_chunks (pgvector)")


def main():
    rows = build_chunks()
    OUT.mkdir(exist_ok=True)
    (OUT / "chunks.json").write_text(json.dumps(rows, ensure_ascii=False), encoding="utf-8")
    counts = {s: sum(r["source"] == s for r in rows) for s in TOPIC}
    print(f"  {len(rows)} chunks: {counts}")
    models = sys.argv[1:] or ["gemini", "minilm", "e5"]
    texts = [f"{r['source']} page {r['page']}: {r['content']}" for r in rows]
    for m in models:
        vecs = embed(texts, m, "passage")
        np.savez_compressed(OUT / f"vectors_{m}.npz", vectors=vecs)
        print(f"  saved services/chatbot/output/vectors_{m}.npz ({vecs.shape[0]} x {vecs.shape[1]})")
        if m == BEST["embedder"]:
            try:
                save_pgvector(rows, vecs)
            except Exception as e:
                print(f"  pgvector not available ({type(e).__name__}): the chatbot uses the local files")
    for old in ("index.npz",):                     # files of the previous version
        (OUT / old).unlink(missing_ok=True)


if __name__ == "__main__":
    main()
