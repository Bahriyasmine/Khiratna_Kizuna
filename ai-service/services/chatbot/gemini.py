"""Small Gemini client (Google AI REST API, no extra library) with several API keys.

Keys are read from ai-service/.env (GEMINI_API_KEYS=key1,key2,...). When a key hits its limit (HTTP 429)
or cannot use the model (403/404), the next key is used.

  embed(texts, task)      -> list of vectors (768 numbers each)   model gemini-embedding-001
  generate(contents, ...) -> raw response                          model gemini-2.5-flash, no thinking (backups if busy)
"""
import json
import os
import ssl
import time
import urllib.error
import urllib.request

from common import ROOT

BASE = "https://generativelanguage.googleapis.com/v1beta/models/"
# fastest first, "thinking" switched off (tested: gemini-2.5-flash 1 s; gemini-flash-latest with thinking 36-130 s)
CHAT_MODELS = {"gemini-2.5-flash": {"thinkingBudget": 0},
               "gemini-flash-lite-latest": {"thinkingLevel": "minimal"},
               "gemini-flash-latest": {"thinkingBudget": 0}}
EMBED_MODEL = "gemini-embedding-001"
DIMENSIONS = 768          # pgvector index works up to 2000 dimensions; 768 is recommended by Google
_SSL = ssl.create_default_context()


def env(name: str) -> str:
    """Reads a value from ai-service/.env (or from the real environment)."""
    if os.getenv(name):
        return os.environ[name]
    if not (ROOT / ".env").exists():
        raise RuntimeError("ai-service/.env is missing: copy .env.example to .env and put the Gemini keys in it")
    for line in (ROOT / ".env").read_text(encoding="utf-8").splitlines():
        if line.startswith(name + "="):
            return line.split("=", 1)[1].strip()
    raise RuntimeError(f"{name} missing in ai-service/.env")


KEYS = [k.strip() for k in env("GEMINI_API_KEYS").split(",") if k.strip()]


def _post(path: str, body: dict, rounds: int = 2, timeout: int = 60) -> dict:
    last = None
    for attempt in range(rounds * len(KEYS)):
        key = KEYS[attempt % len(KEYS)]
        req = urllib.request.Request(BASE + path, data=json.dumps(body).encode(),
                                     headers={"Content-Type": "application/json", "x-goog-api-key": key})
        try:
            with urllib.request.urlopen(req, context=_SSL, timeout=timeout) as r:
                return json.loads(r.read())
        except urllib.error.HTTPError as e:
            last = f"HTTP {e.code}: {e.read()[:200]!r}"
            if e.code in (403, 404, 429, 500, 503):
                if attempt % len(KEYS) == len(KEYS) - 1:
                    time.sleep(5)            # all keys tried once: short pause
                continue
            raise RuntimeError(last)
        except (TimeoutError, urllib.error.URLError) as e:          # slow network: try again with the next key
            last = f"network: {e}"
    raise RuntimeError(f"Gemini failed with every key: {last}")


def embed(texts: list, task: str) -> list:
    """task = RETRIEVAL_DOCUMENT (for the documents) or RETRIEVAL_QUERY (for a question)."""
    vectors = []
    for i in range(0, len(texts), 50):
        body = {"requests": [{"model": f"models/{EMBED_MODEL}", "content": {"parts": [{"text": t}]},
                              "taskType": task, "outputDimensionality": DIMENSIONS} for t in texts[i:i + 50]]}
        vectors += [e["values"] for e in _post(f"{EMBED_MODEL}:batchEmbedContents", body)["embeddings"]]
    return vectors


def generate(contents: list, system: str, tools: list = None) -> dict:
    body = {"contents": contents, "systemInstruction": {"parts": [{"text": system}]}}
    if tools:
        body["tools"] = [{"functionDeclarations": tools}]
    error = None
    for model, thinking in CHAT_MODELS.items():   # a busy or slow model -> try the next one
        body["generationConfig"] = {"temperature": 0.2, "thinkingConfig": thinking}
        try:
            return _post(f"{model}:generateContent", body, rounds=1, timeout=20)
        except RuntimeError as e:
            error = e
    raise error
