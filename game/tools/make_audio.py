"""MARGIN - chiptune music and sound effects made in code (Claude, AI - declared in CREDITS).
Outputs WAV, then converted to OGG with ffmpeg."""
import numpy as np, wave, os, sys

SR = 32000
OUT = sys.argv[1] if len(sys.argv) > 1 else "out"
os.makedirs(OUT, exist_ok=True)

def note(n):  # midi -> Hz
    return 440.0 * 2 ** ((n - 69) / 12)

NAMES = {"C":0,"C#":1,"D":2,"D#":3,"E":4,"F":5,"F#":6,"G":7,"G#":8,"A":9,"A#":10,"B":11}
def m(s):  # "A4" -> midi
    return 12 * (int(s[-1]) + 1) + NAMES[s[:-1]]

def env(n, a=0.005, d=0.08, s=0.6, r=0.05):
    e = np.ones(n) * s
    na, nd, nr = int(a*SR), int(d*SR), int(r*SR)
    na = max(na, 1)
    e[:na] = np.linspace(0, 1, na)
    if na + nd < n: e[na:na+nd] = np.linspace(1, s, nd)
    if nr < n: e[-nr:] *= np.linspace(1, 0, nr)
    return e

def osc(kind, f, dur, duty=0.5, vib=0.0):
    t = np.arange(int(dur*SR)) / SR
    ph = f * t + (vib * np.sin(2*np.pi*5*t) / 5 if vib else 0)
    p = ph % 1.0
    if kind == "sq": return np.where(p < duty, 1.0, -1.0)
    if kind == "tri": return 4 * np.abs(p - 0.5) - 1
    if kind == "saw": return 2 * p - 1
    if kind == "sin": return np.sin(2*np.pi*ph)
    if kind == "noise": return np.random.uniform(-1, 1, len(t))

def lowpass(x, a=0.1):
    y = np.zeros_like(x); acc = 0.0
    for i in range(len(x)):
        acc += a * (x[i] - acc); y[i] = acc
    return y

def add(buf, x, start):
    i = int(start * SR)
    end = min(len(buf), i + len(x))
    buf[i:end] += x[:end - i]

def save(name, x, vol=0.8):
    x = x / max(1e-9, np.max(np.abs(x))) * vol
    data = (x * 32767).astype(np.int16)
    p = os.path.join(OUT, name + ".wav")
    with wave.open(p, "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(data.tobytes())

# ---------------------------------------------------------------- music
def song(bpm, bars, chords, melody, bass_pat, arp_duty, mood_pad, drums):
    beat = 60.0 / bpm
    total = bars * 4 * beat
    buf = np.zeros(int(total * SR) + 1)
    # pad (soft triangle chords, whole bar)
    for b in range(bars):
        ch = chords[b % len(chords)]
        for n in ch:
            x = osc("tri", note(n), 4*beat) * env(int(4*beat*SR), a=0.4, d=0.5, s=0.7, r=0.4) * 0.09 * mood_pad
            add(buf, x, b*4*beat)
    # arpeggio (thin square, 16ths)
    for b in range(bars):
        ch = chords[b % len(chords)]
        seq = [ch[0]+12, ch[1]+12, ch[2]+12, ch[1]+12]
        for k in range(16):
            n = seq[k % 4]
            d = beat/4
            x = osc("sq", note(n), d, duty=arp_duty) * env(int(d*SR), a=0.002, d=0.05, s=0.3, r=0.02) * 0.05
            add(buf, x, b*4*beat + k*d)
    # bass
    for b in range(bars):
        root = chords[b % len(chords)][0] - 12
        for k, (off, length) in enumerate(bass_pat):
            d = length*beat
            x = osc("tri", note(root), d) * env(int(d*SR), a=0.003, d=0.1, s=0.8, r=0.03) * 0.28
            add(buf, x, b*4*beat + off*beat)
    # melody (square 25%, vibrato) - list of (bar, beat, midi, length_beats)
    for (bar, bt, n, ln) in melody:
        d = ln*beat
        x = osc("sq", note(n), d, duty=0.25, vib=0.004) * env(int(d*SR), a=0.01, d=0.15, s=0.55, r=0.08) * 0.11
        add(buf, x, bar*4*beat + bt*beat)
    # drums: soft kick + hat
    if drums:
        for b in range(bars):
            for k in range(4):
                t0 = b*4*beat + k*beat
                if k in (0, 2):
                    n = int(0.12*SR); tt = np.arange(n)/SR
                    kick = np.sin(2*np.pi*(90*np.exp(-tt*25))*tt*3) * np.exp(-tt*30) * 0.35
                    add(buf, kick, t0)
                n = int(0.03*SR)
                hat = lowpass(osc("noise", 0, 0.03), 0.6) * np.exp(-np.arange(n)/SR*120)[:n] * 0.04
                hat = osc("noise", 0, 0.03) * np.exp(-np.arange(n)/SR*150) * 0.035
                add(buf, hat, t0 + beat/2)
    return buf[:int(total*SR)]

A3,C4,D4,E4,F3,G3,A4,B4,C5,D5,E5,G4,F4 = [m(x) for x in ["A3","C4","D4","E4","F3","G3","A4","B4","C5","D5","E5","G4","F4"]]
# chords as midi triads (root position, around 3rd octave)
Am = [m("A3"), m("C4"), m("E4")]
F  = [m("F3"), m("A3"), m("C4")]
C  = [m("C4"), m("E4"), m("G4")]
G  = [m("G3"), m("B3"), m("D4")]
Em = [m("E3"), m("G3"), m("B3")]
Dm = [m("D3"), m("F3"), m("A3")]

# THEME (title + design): hopeful, 96 bpm, 16 bars
mel = []
phrase1 = [(0,0,"E5",1.5),(0,1.5,"D5",0.5),(0,2,"C5",1),(0,3,"A4",1),
           (1,0,"C5",1.5),(1,1.5,"D5",0.5),(1,2,"E5",2),
           (2,0,"G5",1),(2,1,"E5",1),(2,2,"D5",1),(2,3,"C5",1),
           (3,0,"D5",3)]
phrase2 = [(0,0,"E5",1.5),(0,1.5,"D5",0.5),(0,2,"C5",1),(0,3,"E5",1),
           (1,0,"A5",2),(1,2,"G5",1),(1,3,"E5",1),
           (2,0,"G5",1),(2,1,"E5",1),(2,2,"D5",1),(2,3,"B4",1),
           (3,0,"A4",3)]
for base, ph in [(4, phrase1), (8, phrase2), (12, phrase1)]:
    for (b, bt, n, ln) in ph:
        mel.append((base + b, bt, m(n), ln))
theme = song(96, 16, [Am, F, C, G], mel, [(0, 1.5), (1.5, 0.5), (2, 1.5), (3.5, 0.5)], 0.5, 1.0, True)
save("music_theme", theme, 0.7)

# SURFACE: slower, tense, sparse, 84 bpm, 16 bars, no drums first half feel
mel2 = []
mot = [(0,0,"E5",3),(1,0,"F5",1),(1,1,"E5",1),(1,2,"C5",2),(2,0,"B4",3),(3,0,"A4",4)]
for base in (4, 12):
    for (b, bt, n, ln) in mot:
        mel2.append((base + b, bt, m(n), ln))
surface = song(84, 16, [Am, Am, F, Em, Dm, Dm, F, Em], mel2, [(0, 0.75), (1, 0.75), (2, 0.75), (3, 0.5), (3.5, 0.5)], 0.125, 1.3, True)
# wind layer
wind = lowpass(osc("noise", 0, len(surface)/SR), 0.02) * (0.6 + 0.4*np.sin(2*np.pi*np.arange(len(surface))/SR/7.0))
surface = surface + wind * 0.25
save("music_surface", surface, 0.7)

# REPORT: short calm loop 8 bars
report = song(90, 8, [F, C, G, Am], [(b, 0, n, 4) for b, n in enumerate([m("A4"), m("G4"), m("B4"), m("C5")])] +
              [(b+4, 0, n, 4) for b, n in enumerate([m("C5"), m("E5"), m("D5"), m("E5")])], [(0, 2), (2, 2)], 0.5, 1.2, False)
save("music_report", report, 0.6)

# ---------------------------------------------------------------- sfx
def seq_tones(tones, kind="sq", duty=0.5, gap=0.0):
    parts = []
    for f, d in tones:
        x = osc(kind, f, d, duty) * env(int(d*SR), a=0.002, d=0.04, s=0.6, r=0.02)
        parts.append(x)
        if gap: parts.append(np.zeros(int(gap*SR)))
    return np.concatenate(parts)

save("sfx_click", seq_tones([(1320, 0.035)], duty=0.25), 0.35)
save("sfx_place", seq_tones([(660, 0.05), (990, 0.07)], duty=0.25), 0.4)
save("sfx_pick", seq_tones([(990, 0.04), (740, 0.05)], duty=0.25), 0.35)
save("sfx_error", seq_tones([(140, 0.09), (110, 0.14)], kind="saw"), 0.4)
save("sfx_success", seq_tones([(note(m(n)), 0.07) for n in ["C5", "E5", "G5", "C6"]], duty=0.25), 0.45)
save("sfx_alarm", seq_tones([(880, 0.18), (660, 0.18)] * 3, kind="sq", duty=0.5), 0.35)
save("sfx_next", seq_tones([(523, 0.05), (784, 0.09)], duty=0.5), 0.35)
# landing rumble: filtered noise swelling then thump
n = int(3.5 * SR); t = np.arange(n) / SR
rum = lowpass(np.random.uniform(-1, 1, n), 0.03) * np.minimum(1, t / 2.5) * np.where(t < 3.0, 1, np.exp(-(t - 3) * 8))
thump = np.zeros(n); k = int(3.0 * SR); tt = np.arange(n - k) / SR
thump[k:] = np.sin(2*np.pi*60*tt) * np.exp(-tt*10)
save("sfx_landing", rum * 0.7 + thump * 0.8, 0.6)
# scanner ping
save("sfx_ping", np.sin(2*np.pi*1760*np.arange(int(0.05*SR))/SR) * np.exp(-np.arange(int(0.05*SR))/SR*60), 0.35)
# robot motor loop (seamless 0.5 s) and crew footstep
_n = int(0.5*SR); _t = np.arange(_n)/SR
motor = (np.sign(np.sin(2*np.pi*110*_t)) * 0.25 + np.sin(2*np.pi*55*_t) * 0.5) * (0.8 + 0.2*np.sin(2*np.pi*8*_t))
motor = lowpass(motor, 0.15)
save("sfx_motor", motor, 0.25)
_m = int(0.07*SR)
step = lowpass(np.random.uniform(-1, 1, _m), 0.08) * np.exp(-np.arange(_m)/SR*45)
save("sfx_step", step, 0.35)
# robot servo whine (seamless 1 s loop: integer cycles) and rover rumble
_n = SR; _t = np.arange(_n)/SR
servo = (osc("saw", 330, 1.0) * 0.35 + osc("sq", 660, 1.0, 0.3) * 0.15) * (0.75 + 0.25*np.sin(2*np.pi*6*_t))
servo += lowpass(np.random.uniform(-1, 1, _n), 0.3) * 0.15
save("sfx_motor_robot", lowpass(servo, 0.25), 0.22)
rumble = np.sin(2*np.pi*48*_t) * 0.6 + osc("sq", 96, 1.0, 0.2) * 0.2 + lowpass(np.random.uniform(-1, 1, _n), 0.04) * 1.2
rumble *= (0.8 + 0.2*np.sin(2*np.pi*12*_t))
save("sfx_motor_rover", lowpass(rumble, 0.1), 0.4)
# robot "chirp" when selected / found
save("sfx_robot_chirp", seq_tones([(1400, 0.04), (1900, 0.05), (1600, 0.04)], duty=0.25), 0.3)
# ---- one sound per event ----
def _t(d): return np.arange(int(d*SR))/SR
def _noise(d): return np.random.uniform(-1, 1, int(d*SR))
# dust storm: wind whoosh swelling
t=_t(2.0); save("sfx_ev_dust", lowpass(_noise(2.0), 0.03) * np.sin(np.pi*t/2.0)**2 * (0.7+0.3*np.sin(2*np.pi*0.9*t)), 0.6)
# solar particle event: geiger counter clicks speeding up
g=np.zeros(int(1.8*SR)); tt=0.0
while tt < 1.75:
    i=int(tt*SR); g[i:i+60]+=np.random.uniform(-1,1,60)*np.exp(-np.arange(60)/12)
    tt += max(0.012, 0.18*(1-tt/1.8)**2) * np.random.uniform(0.4, 1.6)
save("sfx_ev_geiger", g, 0.5)
# equipment failure: metal clank + sparks
n=int(1.0*SR); t=np.arange(n)/SR
clank=(np.sin(2*np.pi*520*t)+0.6*np.sin(2*np.pi*1370*t)+0.4*np.sin(2*np.pi*2210*t))*np.exp(-t*9)
for k in range(6):
    i=int((0.25+k*0.09)*SR); clank[i:i+200]+=np.random.uniform(-1,1,200)*0.6*np.exp(-np.arange(200)/40)
save("sfx_ev_clank", clank, 0.5)
# medical: heart monitor beeps
save("sfx_ev_heart", seq_tones([(988,0.09),(1,0.45),(988,0.09),(1,0.45),(988,0.09)], kind="sin"), 0.4)
# relay missed: radio static burst
st=_noise(1.2)*(0.5+0.5*(np.random.rand(int(1.2*SR))>0.3)); save("sfx_ev_static", lowpass(st,0.5)*np.exp(-_t(1.2)*1.5), 0.4)
# walk events
t=_t(1.2); save("sfx_ev_whirl", lowpass(_noise(1.2),0.06)*(0.5+0.5*np.sin(2*np.pi*7*t))*np.sin(np.pi*t/1.2), 0.5)
t=_t(1.0); save("sfx_ev_hiss", (_noise(1.0)-lowpass(_noise(1.0),0.2))*np.minimum(1,t*8)*np.exp(-t*1.2), 0.35)
n=int(0.35*SR); t=np.arange(n)/SR; save("sfx_ev_thud", (np.sin(2*np.pi*80*t)+lowpass(np.random.uniform(-1,1,n),0.1))*np.exp(-t*14), 0.6)
save("sfx_ev_chime", seq_tones([(note(m(x)),0.12) for x in ["E6","B5","E6","G6"]], kind="sin"), 0.4)
t=_t(1.4); spin=osc("saw", 1, 1.4)*0; f=60+50*np.sin(2*np.pi*3*t); ph=np.cumsum(f)/SR
save("sfx_ev_spin", (np.sign(np.sin(2*np.pi*ph))*0.4+lowpass(_noise(1.4),0.05)*1.2)*np.sin(np.pi*t/1.4), 0.45)
# installations
save("sfx_beacon", seq_tones([(660,0.06),(880,0.06),(1320,0.12)], duty=0.25), 0.4)
t=_t(0.9); f=300+900*t; ph=np.cumsum(f)/SR
save("sfx_charge", np.sign(np.sin(2*np.pi*ph))*0.3*np.minimum(1,(0.9-t)*8), 0.3)
# radio beep (comms / summary)
save("sfx_radio", seq_tones([(1500, 0.06), (1500, 0.06)], gap=0.05) , 0.3)
# step / drive
save("sfx_drive", lowpass(np.random.uniform(-1, 1, int(0.6*SR)), 0.05) * env(int(0.6*SR), a=0.05, d=0.1, s=0.8, r=0.2), 0.3)
print("done")
