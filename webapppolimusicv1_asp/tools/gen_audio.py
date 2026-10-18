# -*- coding: utf-8 -*-
"""
Genera pistas de audio originales (sintetizadas) para la demo de SONORA.
No usa samples externos: todo se calcula con senos y ruido, asi que no hay
ningun problema de derechos de autor.
"""
import math
import os
import random
import wave

SR = 16000
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "audio")

NOTE = {'C': 0, 'C#': 1, 'D': 2, 'D#': 3, 'E': 4, 'F': 5,
        'F#': 6, 'G': 7, 'G#': 8, 'A': 9, 'A#': 10, 'B': 11}

QUAL = {
    'maj': [0, 4, 7],
    'min': [0, 3, 7],
    'maj7': [0, 4, 7, 11],
    'min7': [0, 3, 7, 10],
    'sus4': [0, 5, 7],
    'dom7': [0, 4, 7, 10],
}


def f_of(name, octave):
    semi = NOTE[name] + (octave - 4) * 12
    return 440.0 * (2.0 ** ((semi - 9) / 12.0))


def add(buf, t0, dur, freq, amp, bright=0.35, attack=0.008, decay=3.0):
    n = int(dur * SR)
    i0 = int(t0 * SR)
    w = 2.0 * math.pi * freq / SR
    for i in range(n):
        idx = i0 + i
        if idx >= len(buf) or idx < 0:
            break
        t = i / SR
        env = min(1.0, t / attack) * math.exp(-decay * t / max(dur, 1e-6))
        s = (math.sin(w * i)
             + 0.32 * bright * math.sin(2 * w * i)
             + 0.14 * bright * math.sin(3 * w * i))
        buf[idx] += amp * env * s


def add_noise(buf, t0, dur, amp, decay=60.0):
    n = int(dur * SR)
    i0 = int(t0 * SR)
    for i in range(n):
        idx = i0 + i
        if idx >= len(buf):
            break
        t = i / SR
        env = math.exp(-decay * t)
        buf[idx] += amp * env * (random.random() * 2 - 1)


def render(track):
    bpm = track['bpm']
    beat = 60.0 / bpm
    bar = beat * 4
    chords = track['chords']
    total = track['seconds']
    buf = [0.0] * int(total * SR + SR)

    t = 0.0
    ci = 0
    while t < total - 0.05:
        root, quality = chords[ci % len(chords)]
        ci += 1
        tones = QUAL[quality]
        base_oct = track.get('octave', 4)

        # ---- pad (acorde sostenido) ----
        for k, iv in enumerate(tones):
            add(buf, t, bar * 0.98, f_of(root, base_oct - 1 + 0), 0.10, bright=0.15,
                attack=0.25, decay=1.1)
            add(buf, t, bar * 0.98, f_of(root, base_oct - 1) * (2 ** (iv / 12.0)), 0.075,
                bright=0.12, attack=0.3, decay=1.0)

        # ---- bajo ----
        add(buf, t, beat * 1.7, f_of(root, 2), 0.34, bright=0.6, attack=0.005, decay=2.4)
        add(buf, t + beat * 2, beat * 1.5, f_of(root, 2), 0.24, bright=0.6,
            attack=0.005, decay=2.6)

        # ---- arpegio / melodia ----
        steps = 8
        for s in range(steps):
            tt = t + s * (bar / steps)
            if tt >= total:
                break
            iv = tones[s % len(tones)]
            octv = base_oct + (1 if (s // len(tones)) % 2 == 1 else 0)
            amp = 0.16 if s % 2 == 0 else 0.11
            add(buf, tt, bar / steps * 0.9, f_of(root, octv) * (2 ** (iv / 12.0)), amp,
                bright=0.5, attack=0.006, decay=4.0)

        # ---- percusion suave ----
        for b in range(4):
            add_noise(buf, t + b * beat + beat * 0.5, 0.06, 0.05, decay=70)
            if b in (0, 2):
                add(buf, t + b * beat, 0.14, 68, 0.30, bright=0.2, attack=0.002, decay=18)

        t += bar

    peak = max(1e-9, max(abs(v) for v in buf))
    scale = 0.88 / peak
    frames = bytearray()
    for v in buf:
        x = v * scale
        x = max(-1.0, min(1.0, x))
        frames += int(x * 32767).to_bytes(2, 'little', signed=True)
    return bytes(frames), len(buf)


TRACKS = [
    ("track1", dict(bpm=112, seconds=26, octave=4,
                    chords=[('A', 'min'), ('F', 'maj'), ('C', 'maj'), ('G', 'maj')])),
    ("track2", dict(bpm=84, seconds=30, octave=4,
                    chords=[('D', 'min7'), ('G', 'dom7'), ('C', 'maj7'), ('A', 'min7')])),
    ("track3", dict(bpm=126, seconds=24, octave=5,
                    chords=[('E', 'min'), ('C', 'maj'), ('G', 'maj'), ('D', 'maj')])),
    ("track4", dict(bpm=96, seconds=32, octave=4,
                    chords=[('G', 'maj'), ('D', 'maj'), ('E', 'min'), ('C', 'maj')])),
    ("track5", dict(bpm=104, seconds=28, octave=4,
                    chords=[('A', 'min'), ('G', 'maj'), ('F', 'maj'), ('E', 'maj')])),
    ("track6", dict(bpm=138, seconds=23, octave=4,
                    chords=[('E', 'min'), ('G', 'maj'), ('A', 'min'), ('B', 'min')])),
    ("track7", dict(bpm=72, seconds=34, octave=4,
                    chords=[('C', 'maj7'), ('A', 'min7'), ('F', 'maj7'), ('G', 'sus4')])),
    ("track8", dict(bpm=118, seconds=27, octave=5,
                    chords=[('F', 'maj'), ('C', 'maj'), ('D', 'min'), ('A#', 'maj')])),
]


def fmt(seconds):
    m = int(seconds) // 60
    s = int(round(seconds - m * 60))
    if s == 60:
        m += 1
        s = 0
    return "%d:%02d" % (m, s)


if __name__ == "__main__":
    random.seed(7)
    os.makedirs(OUT, exist_ok=True)
    for name, cfg in TRACKS:
        frames, nsamples = render(cfg)
        path = os.path.join(OUT, name + ".wav")
        with wave.open(path, 'wb') as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(SR)
            w.writeframes(frames)
        print("%-8s %5.1fs  %s  %6.1f KB" % (name, nsamples / SR, fmt(nsamples / SR),
                                             os.path.getsize(path) / 1024))
