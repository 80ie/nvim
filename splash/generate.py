#!/usr/bin/env python3
"""./splash/generate.py [source_dir]   (needs numpy and Pillow)

With source_dir: read the stitch grid of each PNG (round dots on a regular lattice) into
splash/stitches/<name>.txt ('#' = stitch). Always: draw preview PNGs into splash/img and
braille art into splash/art/<name>.<tier>.txt, where every stitch is a whole number of dots.
"""
import re, sys
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
TIERS = {  # tier -> function(stitch bool grid) -> dot bool grid
    "half": lambda s: block_down(s),
    "1x": lambda s: s,
    "2x": lambda s: np.kron(s, np.ones((2, 2), bool)),
    "3x": lambda s: spread(s, [[1, 1, 0], [1, 1, 0], [0, 0, 0]]),
}


def block_down(s):
    h, w = s.shape
    p = np.zeros((h + h % 2, w + w % 2), bool)
    p[:h, :w] = s
    return p.reshape(p.shape[0] // 2, 2, p.shape[1] // 2, 2).sum(axis=(1, 3)) >= 2


def spread(s, pat):
    k = len(pat)
    out = np.zeros((s.shape[0] * k, s.shape[1] * k), bool)
    for dy in range(k):
        for dx in range(k):
            if pat[dy][dx]:
                out[dy::k, dx::k] = s
    return out


def slug(path):
    return re.sub(r"[^A-Za-z0-9]+", "_", re.sub(r"^[^_]*_\d+_", "", path.stem)).lower()


def read_stitches(path):
    im = Image.open(path).convert("RGBA")
    bg = Image.new("RGBA", im.size, (0, 0, 0, 255))
    bg.alpha_composite(im)
    a = np.asarray(bg.convert("L")).astype(float) / 255
    ys, xs = np.where(a > 0.5)
    a = a[ys.min() : ys.max() + 1, xs.min() : xs.max() + 1]

    def lattice(n, prof):  # best pitch/offset: lit at stitch centers, dark between
        best = None
        for p in np.arange(4.0, 7.01, 0.05):
            for off in np.arange(0, p, 0.25):
                c = np.arange(off, n, p)
                on = prof[np.clip(np.round(c).astype(int), 0, n - 1)].mean()
                off_ = prof[np.clip(np.round(c + p / 2).astype(int), 0, n - 1)].mean()
                if best is None or on - off_ > best[0]:
                    best = (on - off_, p, off)
        return best[1], best[2]

    h, w = a.shape
    px, ox = lattice(w, a.sum(axis=0))
    py, oy = lattice(h, a.sum(axis=1))
    cx, cy = np.arange(ox, w, px), np.arange(oy, h, py)
    g = np.zeros((len(cy), len(cx)), bool)
    for j, y in enumerate(cy):
        for i, x in enumerate(cx):
            y0, y1 = int(max(0, round(y - 1))), int(min(h, round(y + 2)))
            x0, x1 = int(max(0, round(x - 1))), int(min(w, round(x + 2)))
            g[j, i] = a[y0:y1, x0:x1].mean() > 0.45
    r, c = np.where(g.any(1))[0], np.where(g.any(0))[0]
    return g[r.min() : r.max() + 1, c.min() : c.max() + 1]


def braille(bits):
    h, w = bits.shape
    H, W = -(-h // 4) * 4, -(-w // 2) * 2
    b = np.zeros((H, W), bool)
    b[:h, :w] = bits
    vals = np.array([[1, 8], [2, 16], [4, 32], [64, 128]])
    rows = []
    for r in range(0, H, 4):
        rows.append("".join(chr(0x2800 + v) if (v := int((b[r : r + 4, c : c + 2] * vals).sum())) else " "
                            for c in range(0, W, 2)))
    while rows and not rows[-1].strip():
        rows.pop()
    lead = min(len(r) - len(r.lstrip()) for r in rows if r.strip())
    width = max(len(r.rstrip()) for r in rows) - lead
    return [r[lead:].rstrip().ljust(width) for r in rows]


def preview(st, path):
    s = 8
    im = Image.new("L", (st.shape[1] * s + 2 * s, st.shape[0] * s + 2 * s), 0)
    d = ImageDraw.Draw(im)
    for j, i in zip(*np.where(st)):
        d.ellipse([(i + 1) * s + 0.5, (j + 1) * s + 0.5, (i + 2) * s - 1.5, (j + 2) * s - 1.5], fill=255)
    im.save(path)


def main():
    stitches, img, art = HERE / "stitches", HERE / "img", HERE / "art"
    for d in (stitches, img, art):
        d.mkdir(exist_ok=True)
    if len(sys.argv) > 1:
        for f in sorted(Path(sys.argv[1]).expanduser().glob("*.png")):
            st = read_stitches(f)
            (stitches / f"{slug(f)}.txt").write_text("\n".join("".join("#" if v else "." for v in r) for r in st) + "\n")
    for f in art.glob("*.txt"):
        f.unlink()
    for f in sorted(stitches.glob("*.txt")):
        st = np.array([[c == "#" for c in line] for line in f.read_text().split()])
        preview(st, img / f"{f.stem}.png")
        sizes = []
        for tier, fn in TIERS.items():
            lines = braille(fn(st))
            (art / f"{f.stem}.{tier}.txt").write_text("\n".join(lines) + "\n")
            sizes.append(f"{tier}={len(lines[0])}x{len(lines)}")
        print(f"{f.stem}: {st.shape[1]}x{st.shape[0]} stitches; " + " ".join(sizes))


main()
