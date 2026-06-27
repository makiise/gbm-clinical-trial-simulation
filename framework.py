"""
Computational Framework Figure for GBM Clinical Trial Simulation

"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch, Circle, Ellipse, Rectangle
from matplotlib.lines import Line2D
from scipy.integrate import solve_ivp
from scipy.optimize import brentq

#  0. REAL MODEL  
P = dict(lambda_C=0.272, C_max=1.87e7, eta=1.84e-7,
         a_T=2.48e6, s_T=5.73e6, rho=0.223, eps_C=37.5,
         r=2.85e-5, d_T=0.402, s_M=0.0476, d_M=0.258)
C0, T0 = 35_000.0, 100.0

def gbm_odes(t, y, u1, u2):
    C, T, M = max(y[0], 0), max(y[1], 0), max(y[2], 0)
    dC = P['lambda_C']*C*(1 - C/P['C_max']) - P['eta']*T*C
    num = P['a_T'] + P['s_T']*T*C
    den = 1 + P['rho']*(1 - u1)*T*(T + P['eps_C']*C)
    dT = num/den - P['r']*T*M - P['d_T']*T
    dM = P['s_M']*(1 - u2)*C - P['d_M']*M
    return [dC, dT, dM]

sol = solve_ivp(gbm_odes, [0, 200], [C0, T0, 0.0], args=(0.0, 0.0),
                method='LSODA', dense_output=True, rtol=1e-8, atol=1e-10)
tt = np.linspace(0, 200, 400)
CC, TT, MM = sol.sol(tt)
CC = np.clip(CC, 0, None); TT = np.clip(TT, 0, None); MM = np.clip(MM, 0, None)


from lifelines import KaplanMeierFitter as _KMF
_km = np.load('km_data.npz')
BENCH = _km['bench']  # [RK45, LSODA, Radau] in ms

TUMOR   = '#E2574C'; TUMOR_L = '#F6C9C4'
TCELL   = '#2E9E5B'; TCELL_L = '#BfE6CC'
MDSC    = '#8E5BA6'; MDSC_L  = '#DCC9E6'
DRUG    = '#E08E2B'; DRUG_L  = '#F7DBB0'

L1      = '#2D6CB0'; L1_BG = '#E8F1FB'   
L2      = '#7E4FA8'; L2_BG = '#F0E9F7'   
L3      = '#138A72'; L3_BG = '#E0F2EE'  
INP     = '#5A6472'; INP_BG = '#EEF1F4'  

INK     = '#1c2530'; SUB = '#5b6672'
GOLD    = '#D4A017'

plt.rcParams.update({'font.family': 'DejaVu Sans', 'font.size': 9})


W, H = 120.0, 162.0
fig = plt.figure(figsize=(12, 16.2), dpi=200)
ax = fig.add_axes([0, 0, 1, 1]); ax.set_xlim(0, W); ax.set_ylim(0, H)
ax.set_aspect('equal'); ax.axis('off')

def f2(x, y):           
    return [x/W, y/H]


def panel(x, y, w, h, fc, ec, lw=1.4, rad=2.2, z=1, alpha=1.0):
    ax.add_patch(FancyBboxPatch((x, y), w, h,
                 boxstyle=f"round,pad=0,rounding_size={rad}",
                 fc=fc, ec=ec, lw=lw, zorder=z, alpha=alpha))

def box(x, y, w, h, fc='white', ec=INK, lw=1.0, rad=1.4, z=3, alpha=1.0):
    ax.add_patch(FancyBboxPatch((x, y), w, h,
                 boxstyle=f"round,pad=0,rounding_size={rad}",
                 fc=fc, ec=ec, lw=lw, zorder=z, alpha=alpha))

def txt(x, y, s, size=9, color=INK, ha='center', va='center',
        weight='normal', style='normal', z=6, rot=0):
    ax.text(x, y, s, fontsize=size, color=color, ha=ha, va=va,
            fontweight=weight, fontstyle=style, zorder=z, rotation=rot)

def arrow(x1, y1, x2, y2, color=INK, lw=1.6, z=5, style='-|>', ms=11,
          rad=0.0, ls='-'):
    ax.add_patch(FancyArrowPatch((x1, y1), (x2, y2),
                 arrowstyle=style, mutation_scale=ms, lw=lw, color=color,
                 connectionstyle=f"arc3,rad={rad}", zorder=z, ls=ls,
                 shrinkA=0, shrinkB=0))

def inhibit(x1, y1, x2, y2, color=INK, lw=1.6, z=5, rad=0.0):

    ax.add_patch(FancyArrowPatch((x1, y1), (x2, y2),
                 arrowstyle='-[', mutation_scale=14, lw=lw, color=color,
                 connectionstyle=f"arc3,rad={rad}", zorder=z,
                 shrinkA=2, shrinkB=2))

def cell(x, y, rx, color, edge, ry=None, nucleus=True):
    ry = ry or rx
    ax.add_patch(Ellipse((x, y), 2*rx, 2*ry, fc=color, ec=edge, lw=1.4, zorder=4))
    if nucleus:
        ax.add_patch(Ellipse((x, y), rx*0.9, ry*0.9, fc=edge, ec='none',
                     alpha=0.30, zorder=4))

def flow(x, y_top, y_bot, color=GOLD):
    arrow(x, y_top, x, y_bot, color=color, lw=3.4, ms=20, z=2)


# TITLE
txt(W/2, H-5.0, "A Computational Framework for Clinical Trial Simulation of "
    "Glioblastoma Immunotherapy", size=15.5, weight='bold')
txt(W/2, H-9.6, "Three-layer in silico pipeline: deterministic tumor-immune ODE core  →  "
    "stochastic virtual-patient cohort  →  survival analysis",
    size=10.2, color=SUB, style='italic')


# (a) INPUTS
ax_y, ax_h = H-32.0, 18.5
panel(4, ax_y, W-8, ax_h, INP_BG, INP, lw=1.6)
txt(7.5, ax_y+ax_h-2.4, "a", size=12, weight='bold', color='white')
ax.add_patch(Circle((7.5, ax_y+ax_h-2.4), 1.7, fc=INP, ec='none', zorder=5))
txt(15.5, ax_y+ax_h-2.4, "INPUTS", size=11, weight='bold', color=INP, ha='left')

side_pad = 5            
gap      = 4           
ix       = 4 + side_pad                                 
cw       = (W - 8 - 2*side_pad - 2*gap) / 3              
def input_card(x, title, lines, accent):
    box(x, ax_y+1.8, cw, ax_h-6.2, 'white', accent, lw=1.3)
    txt(x+cw/2, ax_y+ax_h-6.2, title, size=9.4, weight='bold', color=accent)
    for k, ln in enumerate(lines):
        txt(x+cw/2, ax_y+ax_h-9.0-k*2.55, ln, size=8.0, color=INK)
def input_card(x, title, lines, accent, line_size=8.0, line_step=2.55):
    box(x, ax_y+1.8, cw, ax_h-6.2, 'white', accent, lw=1.3)
    txt(x+cw/2, ax_y+ax_h-6.2, title, size=9.4, weight='bold', color=accent)
    for k, ln in enumerate(lines):
        txt(x+cw/2, ax_y+ax_h-9.0-k*line_step, ln, size=line_size, color=INK)
input_card(ix, "Model parameters",
           ["Anderson 2024 (ABC posterior);  \n11 parameters (mean + SD):",
            r"$\lambda_C, C_{max}, \eta, a_T, s_T, \rho$",
            r"$\varepsilon_C, r, d_T, s_M, d_M$"], INP)
input_card(ix+cw+6, "Initial conditions",
           [r"$C_0 = 35{,}000$ cells", r"$T_0 = 100$ cells",
            r"$M_0 = 0$ cells"], INP)
input_card(ix+2*(cw+6), "Treatment arms (4)",
           [r"No Tx  $(u_1{=}0,\,u_2{=}0)$",
            r"Anti-PD-1  $(u_1{=}0.7,\,u_2{=}0)$",
            r"CCR2  $(u_1{=}0,\,u_2{=}0.7)$",
            r"Combination  $(0.7,\,0.7)$"],
           INP, line_size=6.8, line_step=1.95)

# (b) LAYER 1 — DETERMINISTIC CORE

b_y, b_h = H-92.0, 56.0
panel(4, b_y, W-8, b_h, L1_BG, L1, lw=1.8)
ax.add_patch(Circle((7.5, b_y+b_h-2.6), 1.7, fc=L1, ec='none', zorder=5))
txt(7.5, b_y+b_h-2.6, "b", size=12, weight='bold', color='white')
txt(15.5, b_y+b_h-2.6, "LAYER 1 — Deterministic core (ODE model)",
    size=11, weight='bold', color=L1, ha='left')
txt(W-7, b_y+b_h-2.6, "same parameters → same trajectory", size=8.2,
    color=L1, ha='right', style='italic')


mx, my, mw, mh = 7.5, b_y+2.0, 56, b_h-7.5
box(mx, my, mw, mh, '#FBFDFF', L1, lw=1.2, rad=1.6)
_bio = plt.imread('anderson_bio.png')
_asp = _bio.shape[1] / _bio.shape[0]          
_iw = 50.0
_ih = _iw / _asp                               
_ix = mx + (mw - _iw) / 2.0
_iy = my + 2.2
ax_bio = fig.add_axes(f2(_ix, _iy) + [_iw / W, _ih / H], zorder=8)
ax_bio.imshow(_bio)
ax_bio.axis('off')
txt(mx + mw/2, _iy + _ih + 2.4,
    "Tumor-immune interactions in GBM under treatment",
    size=8.4, color=L1, weight='bold')
txt(mx + mw/2, _iy + _ih + 0.4,
    "reproduced from Anderson et al. (2024), CC-BY 4.0",
    size=6.8, color=SUB, style='italic')


ex, ey, ew, eh = mx+mw+3.5, b_y+2.0, W-8-(mw+3.5)-7, b_h-7.5
box(ex, ey, ew, eh, '#FBFDFF', L1, lw=1.2, rad=1.6)
txt(ex+ew/2, ey+eh-2.3, "System of ordinary differential equations",
    size=8.8, color=L1, weight='bold')

eqs = [
    r"$\dfrac{dC}{dt}=\lambda_C C\!\left(1-\dfrac{C}{C_{max}}\right)-\eta\,T\,C$",
    r"$\dfrac{dT}{dt}=\dfrac{a_T+s_T\,T\,C}"
    r"{1+\rho\,(1-u_1)\,T\,(T+\varepsilon_C C)}-r\,T\,M-d_T\,T$",
    r"$\dfrac{dM}{dt}=s_M(1-u_2)\,C-d_M\,M$",
]
ey0 = ey+eh-10.0
for k, e in enumerate(eqs):
    txt(ex+ew/2, ey0-k*8.0, e, size=11.0 if k != 1 else 9.8, color=INK)

txt(ex+ew/2, ey+13.0, r"$C$ tumor   ·   $T$ T cells   ·   $M$ MDSCs",
    size=7.8, color=SUB)
box(ex+2, ey+1.6, ew-4, 7.2, L1_BG, L1, lw=1.0, rad=1.0)
txt(ex+ew/2, ey+5.2, "numerical solvers used for per patient: \n LSODA / RK45 / Radau benchmarked  (event detection)",
    size=7.6, color=L1)

# (c) LAYER 2 — STOCHASTIC VIRTUAL COHORT

c_y, c_h = H-125.0, 29.0
panel(4, c_y, W-8, c_h, L2_BG, L2, lw=1.8)
ax.add_patch(Circle((7.5, c_y+c_h-2.6), 1.7, fc=L2, ec='none', zorder=5))
txt(7.5, c_y+c_h-2.6, "c", size=12, weight='bold', color='white')
txt(15.5, c_y+c_h-2.6, "LAYER 2 — Stochastic layer  (virtual-patient cohort, Monte Carlo)",
    size=11, weight='bold', color=L2, ha='left')
 
s1x = 8
box(s1x, c_y+2.2, 26, c_h-7.0, 'white', L2, lw=1.2)
txt(s1x+13, c_y+c_h-6.2, "Log-normal sampling", size=8.4, weight='bold', color=L2)
axd = fig.add_axes(f2(s1x+3.5, c_y+3.4) + [22/W, 9.5/H]); axd.axis('off')
xs = np.linspace(0, 4, 200)
mu, sig = -0.2, 0.55
pdf = np.exp(-(np.log(xs+1e-9)-mu)**2/(2*sig**2))/((xs+1e-9)*sig*np.sqrt(2*np.pi))
axd.fill_between(xs, pdf, color=L2, alpha=0.30)
axd.plot(xs, pdf, color=L2, lw=1.6)
for q in (0.7, 1.3, 2.1):
    axd.axvline(q, color=L2, ls=':', lw=0.8, alpha=0.7)
axd.set_xlim(0, 4); axd.set_ylim(0, pdf.max()*1.15)
txt(s1x+13, c_y+3.0, "draw 11 params / patient", size=7.2, color=SUB)
 
arrow(s1x+26.6, c_y+c_h/2-0.5, s1x+30.6, c_y+c_h/2-0.5, color=L2, lw=2.0)
 
s2x = s1x+31
box(s2x, c_y+2.2, 30, c_h-7.0, 'white', L2, lw=1.2)
txt(s2x+15, c_y+c_h-6.2, "1000 patients × 4 arms", size=8.4, weight='bold', color=L2)
 
def person_icon(cx, cy, color, scale=1.0):
    """Tiny stick-figure: head (circle) + body (rounded rect)."""
    hr = 0.42 * scale            
    bw, bh = 1.2 * scale, 1.55 * scale     
    ax.add_patch(Circle((cx, cy + bh*0.55 + hr*0.6), hr,
                        fc=color, ec='none', zorder=5))
    ax.add_patch(FancyBboxPatch((cx - bw/2, cy - bh/2),
                                bw, bh,
                                boxstyle="round,pad=0,rounding_size=0.35",
                                fc=color, ec='none', zorder=5))
 
NONRESP = '#BFA8D1'   
RESP    = L2          
gx0, gy0 = s2x+3.2, c_y+c_h-10.2
cols, rows = 10, 3
dx, dy = 2.45, 3.0
total = cols*rows                    
nonresp_idx = set(range(total-9, total))
k = 0
for rr in range(rows):
    for cc in range(cols):
        is_nr = k in nonresp_idx
        person_icon(gx0+cc*dx, gy0-rr*dy, NONRESP if is_nr else RESP, scale=1.0)
        k += 1
 

ly = c_y+4.8
person_icon(s2x+3.6, ly, RESP, scale=0.85)
txt(s2x+5.6, ly, "responder", size=6.6, color=INK, ha='left')
person_icon(s2x+16.4, ly, NONRESP, scale=0.85)
txt(s2x+18.4, ly, "non-responder", size=6.6, color=INK, ha='left')
txt(s2x+15, c_y+2.9, "= 4000 ODE simulations", size=6.6, color=SUB)
 
arrow(s2x+30.6, c_y+c_h/2-0.5, s2x+34.6, c_y+c_h/2-0.5, color=L2, lw=2.0)
 

s3x = s2x+35
box(s3x, c_y+2.2, W-8-(s3x-4)-3, c_h-7.0, 'white', L2, lw=1.2)
sw = W-8-(s3x-4)-3
txt(s3x+sw/2, c_y+c_h-6.2, "Clinical-realism layers", size=8.4, weight='bold', color=L2)
txt(s3x+3, c_y+c_h-9.6, "•", size=9, color=L2, ha='left')
txt(s3x+5, c_y+c_h-9.6,
    "Responder heterogeneity (70% / 30%, shown in cohort)",
    size=7.0, color=INK, ha='left')
txt(s3x+3, c_y+c_h-12.6, "•", size=9, color=L2, ha='left')
txt(s3x+5, c_y+c_h-12.6,
    "Right-censoring — 15% dropout (median 90 d)",
    size=7.0, color=INK, ha='left')
txt(s3x+3, c_y+c_h-15.6, "•", size=9, color=L2, ha='left')
txt(s3x+5, c_y+c_h-15.6,
    r"Per-patient drug-effect scaling on $u_1,u_2$",
    size=7.0, color=INK, ha='left')
 

# (d) LAYER 3 — ANALYSIS
d_y, d_h = H-158.0, 30.0
panel(4, d_y, W-8, d_h, L3_BG, L3, lw=1.8)
ax.add_patch(Circle((7.5, d_y+d_h-2.6), 1.7, fc=L3, ec='none', zorder=5))
txt(7.5, d_y+d_h-2.6, "d", size=12, weight='bold', color='white')
txt(15.5, d_y+d_h-2.6, "LAYER 3 — Analysis layer  (survival outcomes & solver benchmark)",
    size=11, weight='bold', color=L3, ha='left')

e1x = 8; e1w = 30
box(e1x, d_y+2.2, e1w, d_h-7.0, 'white', L3, lw=1.2)
txt(e1x+e1w/2, d_y+d_h-6.2, "Event detection", size=8.4, weight='bold', color=L3)
axe = fig.add_axes(f2(e1x+3.5, d_y+3.2) + [(e1w-6)/W, 11/H])
axe.plot(tt, CC/P['C_max'], color=TUMOR, lw=1.8)
axe.axhline(0.75, color=L3, ls='--', lw=1.2)
axe.set_xlim(0, 200); axe.set_ylim(0, 1.05)
axe.set_xticks([]); axe.set_yticks([0.75]); axe.set_yticklabels(['75%'], fontsize=6)
axe.text(78, 0.80, r'progression = 75% $C_{max}$', fontsize=6, color=L3)
for s in axe.spines.values(): s.set_color('#cccccc')

e2x = e1x+e1w+3.5; e2w = 32
box(e2x, d_y+2.2, e2w, d_h-7.0, 'white', L3, lw=1.2)
txt(e2x+e2w/2, d_y+d_h-6.2, "Kaplan–Meier survival", size=8.4, weight='bold', color=L3)
axk = fig.add_axes(f2(e2x+4.0, d_y+3.2) + [(e2w-7)/W, 11/H])
arm_map = [('No Treatment', INP, 'No Tx'), ('Anti-PD-1', TCELL, 'Anti-PD-1'),
           ('CCR2 Antagonist', MDSC, 'CCR2'), ('Combination', TUMOR, 'Combo')]
for key, col, lab in arm_map:
    kmf = _KMF(); kmf.fit(_km[f'{key}_t'], event_observed=_km[f'{key}_e'])
    sf = kmf.survival_function_
    axk.step(sf.index.values, sf.iloc[:, 0].values, where='post',
             color=col, lw=1.5, label=lab)
axk.set_xlim(0, 200); axk.set_ylim(0, 1.02)
axk.set_xlabel('days', fontsize=6); axk.tick_params(labelsize=6)
axk.legend(fontsize=5.0, loc='upper right', frameon=False, ncol=1,
           handlelength=1.0, labelspacing=0.2)
for s in axk.spines.values(): s.set_color('#cccccc')

e3x = e2x+e2w+3.5; e3w = W-8-(e3x-4)-3
box(e3x, d_y+2.2, e3w, d_h-7.0, 'white', L3, lw=1.2)
txt(e3x+e3w/2, d_y+d_h-6.2, "Statistics & solver benchmark", size=8.4,
    weight='bold', color=L3)
axb = fig.add_axes(f2(e3x+5.0, d_y+3.0) + [(e3w-9)/W, 9/H])
ms_map = {'RK45': float(BENCH[0]), 'LSODA': float(BENCH[1]), 'Radau': float(BENCH[2])}
order = sorted(ms_map, key=ms_map.get)
vals = [ms_map[k] for k in order]
cmap = {'LSODA': L3, 'RK45': L1, 'Radau': MDSC}
axb.barh(order[::-1], vals[::-1], color=[cmap[k] for k in order][::-1], height=0.62)
for i, v in enumerate(vals[::-1]):
    axb.text(v + max(vals)*0.03, i, f'{v:.1f} ms', va='center', fontsize=6, color=INK)
axb.set_xlim(0, max(vals)*1.28); axb.tick_params(labelsize=6); axb.set_xticks([])
for s in axb.spines.values(): s.set_color('#cccccc')


flow(W/2, ax_y-0.3, b_y+b_h+0.3)
flow(W/2, b_y-0.3, c_y+c_h+0.3)
flow(W/2, c_y-0.3, d_y+d_h+0.3)


txt(W/2, 2.4, "Model: Anderson et al. (2024a, 2024b).  Implementation: Python "
    "(scipy.integrate, scipy.optimize, lifelines).  Endpoint: progression-free "
    "survival.  Reproducible (seed = 42).",
    size=7.4, color=SUB, style='italic')

fig.savefig('framework_figure.png', dpi=200,
            bbox_inches='tight', facecolor='white', pad_inches=0.15)
fig.savefig('framework_figure.pdf',
            bbox_inches='tight', facecolor='white', pad_inches=0.15)
print("saved")