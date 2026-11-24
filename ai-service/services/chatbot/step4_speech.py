"""CHATBOT - STEP 4: SPEECH TO TEXT (the farmer speaks, Khiratna reads the question).

Model: OpenAI Whisper "small", run locally with faster-whisper (CPU, int8): free, offline after the first download
       (~480 MB), English only (language="en"). The browser's own speech recognition was not reliable
       (needs Google servers, fails silently in Edge / VS Code).
Hint:  Whisper does not know Tunisian place names ("Kairouan" -> "carawa"), so the 24 governorates and the crop
       words are given as a hint (initial_prompt). Test: "What should I plant after watermelon in Kairouan?"
       -> transcribed exactly, in ~2 s.
Input: any audio the browser or the phone records (webm, ogg, mp4, wav...), decoded by PyAV.

Text to speech is done on the device (browser speechSynthesis, Flutter flutter_tts): no server needed.

Run (from the ai-service/ folder):  python -m services.chatbot.step4_speech question.wav
"""
import io
import sys
from functools import lru_cache

from common import GOVERNORATES

MODEL = "small"
HINT = ("Tunisian farming question. Governorates: " + ", ".join(GOVERNORATES) + ". Crops: tomato, pepper, potato, "
        "onion, carrot, lettuce, watermelon, melon, wheat, barley, sorghum, chickpea, faba bean, citrus, grapes, almond, "
        "olive, date palm, alfalfa. Energy: STEG, ANME, FTE, kWp, kWh, solar pump, diesel pump, well depth.")


@lru_cache
def model():
    from faster_whisper import WhisperModel
    return WhisperModel(MODEL, device="cpu", compute_type="int8")


def transcribe(audio: bytes) -> str:
    segments, _ = model().transcribe(io.BytesIO(audio), language="en", beam_size=1, vad_filter=True,
                                     initial_prompt=HINT)
    return "".join(s.text for s in segments).strip()


if __name__ == "__main__":
    print(transcribe(open(sys.argv[1], "rb").read()))
