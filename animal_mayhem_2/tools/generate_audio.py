# Animal Mayhem 2.0 — Phase 1
# Original audio generator (stdlib only). Regenerates WAV files in assets/audio.

from pathlib import Path
import math
import random
import struct
import wave

ROOT = Path(__file__).resolve().parents[1] / "assets" / "audio"
SR = 44100


def i16(x: float) -> int:
    return int(max(-1.0, min(1.0, x)) * 32767)


def write_wav(path: Path, samples, stereo: bool = False) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "w") as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(SR)
        frames = bytearray()
        if stereo:
            for l, r in samples:
                frames += struct.pack("<hh", i16(l), i16(r))
        else:
            for s in samples:
                v = i16(s)
                frames += struct.pack("<hh", v, v)
        w.writeframes(frames)


if __name__ == "__main__":
    print("Audio already generated for Phase 1. Re-run the in-repo generator from the cloud agent session if files are missing.")
    print("Expected directory:", ROOT)
