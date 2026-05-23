# Combined workflow + hierarchy diagram with profile-card nodes (avatar + name plate).
# Rendered with PIL at high resolution + supersampling for clean, crisp edges.
from PIL import Image, ImageDraw, ImageFont, ImageChops
import math, os

# ---------- config ----------
W, H = 1600, 680          # logical canvas
S = 3                     # supersample build factor
OUT = 1.5                 # final output scale (relative to logical)

# colors
GREEN   = (56, 131, 90)
LGREEN  = (220, 233, 226)
DARK    = (26, 46, 31)
WHITE   = (255, 255, 255)
BORDER  = (203, 222, 211)
SUB     = (107, 142, 122)
GOLD    = (196, 138, 46)
GREY    = (150, 159, 153)
# external (supplier)
EBG, ERING, ESIL, ENAME, ESUB = (238,239,238),(181,189,184),(150,159,153),(95,95,95),(125,125,125)

FONTDIR = r"C:\Windows\Fonts"
def font(name, size):
    try:
        return ImageFont.truetype(os.path.join(FONTDIR, name), int(size*S))
    except Exception:
        return ImageFont.load_default()
f_name  = font("arialbd.ttf", 19)
f_sub   = font("arial.ttf",   14)
f_title = font("arialbd.ttf", 23)
f_leg   = font("arial.ttf",   14)

img = Image.new("RGBA", (W*S, H*S), (255,255,255,255))
d   = ImageDraw.Draw(img)

def sc(v): return v*S
def P(p): return (p[0]*S, p[1]*S)

# ---------- profile card ----------
PW, PH, RAD = 234, 74, 16     # plate size + corner radius
AR, RINGW   = 46, 3           # avatar outer radius + ring width

def avatar(cx, cy, bg, ring, sil):
    r_out = AR
    d.ellipse([sc(cx-r_out), sc(cy-r_out), sc(cx+r_out), sc(cy+r_out)], fill=ring)
    r_in = r_out - RINGW
    d.ellipse([sc(cx-r_in), sc(cy-r_in), sc(cx+r_in), sc(cy+r_in)], fill=bg)
    # silhouette tile
    w = int(sc(2*r_in))
    tile = Image.new("RGBA", (w, w), (0,0,0,0))
    td = ImageDraw.Draw(tile)
    hr = w*0.20; hcx, hcy = w/2, w*0.34
    td.ellipse([hcx-hr, hcy-hr, hcx+hr, hcy+hr], fill=sil)          # head
    bw = w*0.66; btop = w*0.60; bh = w*1.30
    td.ellipse([w/2-bw/2, btop, w/2+bw/2, btop+bh], fill=sil)       # shoulders (clipped)
    mask = Image.new("L", (w, w), 0)
    ImageDraw.Draw(mask).ellipse([0,0,w-1,w-1], fill=255)
    alpha = ImageChops.multiply(tile.split()[3], mask)
    img.paste(tile, (int(sc(cx)-w/2), int(sc(cy)-w/2)), alpha)

def plate(cx, cy, fill, border, name, sub, name_col, sub_col):
    d.rounded_rectangle([sc(cx-PW/2), sc(cy-PH/2), sc(cx+PW/2), sc(cy+PH/2)],
                        radius=sc(RAD), fill=fill, outline=border, width=max(1,int(sc(1.6))))
    d.text(P((cx, cy-9)), name, font=f_name, fill=name_col, anchor="mm")
    d.text(P((cx, cy+15)), sub,  font=f_sub,  fill=sub_col,  anchor="mm")

def card(cx, cy, name, sub, kind="normal"):
    if kind == "admin":
        avatar(cx, cy-52, (245,250,247), GREEN, GREEN)
        plate(cx, cy, GREEN, GREEN, name, sub, WHITE, (214,231,221))
    elif kind == "ext":
        avatar(cx, cy-52, EBG, ERING, ESIL)
        plate(cx, cy, (250,250,250), (220,222,221), name, sub, ENAME, ESUB)
    else:
        avatar(cx, cy-52, LGREEN, GREEN, GREEN)
        plate(cx, cy, WHITE, BORDER, name, sub, DARK, SUB)

# ---------- connectors ----------
def bez(p0, c, p2, n=46):
    pts = []
    for i in range(n+1):
        t = i/n
        x = (1-t)**2*p0[0] + 2*(1-t)*t*c[0] + t*t*p2[0]
        y = (1-t)**2*p0[1] + 2*(1-t)*t*c[1] + t*t*p2[1]
        pts.append((sc(x), sc(y)))
    return pts

def arrowhead(p_from, p_to, color, size=12):
    ang = math.atan2(p_to[1]-p_from[1], p_to[0]-p_from[0])
    s = sc(size)
    a = (p_to[0]-s*math.cos(ang-0.42), p_to[1]-s*math.sin(ang-0.42))
    b = (p_to[0]-s*math.cos(ang+0.42), p_to[1]-s*math.sin(ang+0.42))
    d.polygon([p_to, a, b], fill=color)

def connect(p0, p2, c=None, color=GREEN, width=2.4, dashed=False, arrow=True):
    if c is None: c = ((p0[0]+p2[0])/2, (p0[1]+p2[1])/2)
    pts = bez(p0, c, p2)
    w = max(1, int(sc(width)))
    if dashed:
        on = True; acc = 0; dash, gap = sc(13), sc(9)
        for i in range(len(pts)-1):
            seg = math.dist(pts[i], pts[i+1])
            if on: d.line([pts[i], pts[i+1]], fill=color, width=w)
            acc += seg
            if (on and acc >= dash) or ((not on) and acc >= gap):
                on = not on; acc = 0
    else:
        d.line(pts, fill=color, width=w, joint="curve")
    if arrow: arrowhead(pts[-3], pts[-1], color, 12)

# ---------- layout ----------
C = {
    'supplier':   (150, 430),
    'collector':  (455, 430),
    'panel':      (775, 300),
    'lab':        (775, 560),
    'supervisor': (1100, 430),
    'admin':      (1425, 300),
}
def R(n): cx,cy=C[n]; return (cx+PW/2, cy)
def L(n): cx,cy=C[n]; return (cx-PW/2, cy)
def T(n): cx,cy=C[n]; return (cx, cy-PH/2)

# title
d.text(P((W/2, 42)), "Acteurs et flux du processus  —  Al Jazeera STCA",
       font=f_title, fill=DARK, anchor="mm")

# workflow connectors (green) -- drawn before cards so they sit behind
connect(R('supplier'), L('collector'))
connect((C['collector'][0]+PW/2, C['collector'][1]-12), L('panel'), c=(610, 348))
connect((C['collector'][0]+PW/2, C['collector'][1]+12), L('lab'),   c=(610, 512))
connect(R('panel'), (C['supervisor'][0]-PW/2, C['supervisor'][1]-12), c=(945, 345))
connect(R('lab'),   (C['supervisor'][0]-PW/2, C['supervisor'][1]+12), c=(945, 515))
connect(R('supervisor'), L('admin'), c=(1270, 352))

# hierarchy connector (gold dashed, arched high) : Supervisor supervises Panel Member
connect((C['supervisor'][0], C['supervisor'][1]-PH/2),
        (C['panel'][0]+30, C['panel'][1]-PH/2),
        c=(930, 215), color=GOLD, width=2.2, dashed=True)
d.text(P((915, 205)), "supervise", font=f_sub, fill=GOLD, anchor="mm")

# small flow labels
def lbl(x, y, t): d.text(P((x, y)), t, font=f_sub, fill=SUB, anchor="mm")
lbl(300, 414, "échantillon")
lbl(600, 408, "échantillon")
lbl(600, 470, "échantillon")
lbl(950, 360, "score sensoriel")
lbl(950, 500, "résultats labo")
lbl(1268, 415, "évaluation")

# ---------- cards ----------
card(*C['supplier'],   "Supplier",         "Fournisseur (externe)", "ext")
card(*C['collector'],  "Collector",        "Collecteur")
card(*C['panel'],      "Panel Member",     "Dégustateur")
card(*C['lab'],        "Lab Technician",   "Technicien Labo")
card(*C['supervisor'], "Panel Supervisor", "Chef Dégustateur")
card(*C['admin'],      "Administrator",    "Directeur", "admin")

# ---------- legend ----------
lx, ly = 70, 640
d.line([P((lx, ly)), P((lx+34, ly))], fill=GREEN, width=max(1,int(sc(2.4))))
arrowhead(P((lx+24, ly)), P((lx+34, ly)), GREEN, 9)
d.text(P((lx+44, ly)), "Flux du processus", font=f_leg, fill=DARK, anchor="lm")
lx2 = lx+250
for i in range(0,34,18):
    d.line([P((lx2+i, ly)), P((lx2+i+10, ly))], fill=GOLD, width=max(1,int(sc(2.2))))
d.text(P((lx2+44, ly)), "Hiérarchie (supervise)", font=f_leg, fill=DARK, anchor="lm")
lx3 = lx2+260
d.ellipse([sc(lx3-6), sc(ly-6), sc(lx3+6), sc(ly+6)], fill=EBG, outline=ERING, width=max(1,int(sc(1.4))))
d.text(P((lx3+16, ly)), "Acteur externe", font=f_leg, fill=DARK, anchor="lm")

# ---------- save ----------
final = img.resize((int(W*OUT), int(H*OUT)), Image.LANCZOS).convert("RGB")
out = os.path.join(os.path.dirname(__file__), "4_roles_combined.png")
final.save(out, "PNG")
print("saved", out, final.size)
