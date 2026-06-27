"""
Results-chapter statistics figures, generated from the verified simulation.
Produces:
  fig_trajectories.png  - C(t), T(t), M(t) per arm (mechanism of action)
  fig_forest.png        - hazard ratios with 95% CI (forest plot)
  fig_solver.png        - solver benchmark (speed)
  fig_paramdist.png     - the 11 sampled parameter distributions
  fig_pfs_bars.png       - PFS@200d and event counts per arm
KM curve is produced by gbm_simulation.py (km_corrected.png).
"""
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp
from lifelines import KaplanMeierFitter, CoxPHFitter
import pandas as pd

# ---- model + params (verified, Anderson 2024b) ----
PARAMS = {
    "lambda_C": (0.272, 0.114), "C_max": (1.87e7, 1.48e7), "eta": (1.84e-7, 1.86e-7),
    "a_T": (2.48e6, 1.45e6), "s_T": (5.73e6, 2.63e6), "rho": (0.223, 0.142),
    "eps_C": (37.5, 29.3), "r": (2.85e-5, 2.76e-5), "d_T": (0.402, 0.213),
    "s_M": (0.0476, 0.0040), "d_M": (0.258, 0.143),
}
LABELS = {"lambda_C": r"$\lambda_C$", "C_max": r"$C_{max}$", "eta": r"$\eta$",
          "a_T": r"$a_T$", "s_T": r"$s_T$", "rho": r"$\rho$", "eps_C": r"$\varepsilon_C$",
          "r": r"$r$", "d_T": r"$d_T$", "s_M": r"$s_M$", "d_M": r"$d_M$"}
mean = {k: v[0] for k, v in PARAMS.items()}
C0, T0, M0, T_SIM = 35000.0, 100.0, 0.0, 200.0

def odes(t, y, u1, u2, p):
    C, T, M = max(y[0], 0), max(y[1], 0), max(y[2], 0)
    dC = p["lambda_C"]*C*(1-C/p["C_max"]) - p["eta"]*T*C
    dT = (p["a_T"]+p["s_T"]*T*C)/(1+p["rho"]*(1-u1)*T*(T+p["eps_C"]*C)) - p["r"]*T*M - p["d_T"]*T
    dM = p["s_M"]*(1-u2)*C - p["d_M"]*M
    return [dC, dT, dM]

ARMS = [("No Treatment", 0.0, 0.0, "#5A6472"),
        ("Anti-PD-1", 0.7, 0.0, "#2E9E5B"),
        ("CCR2 Antagonist", 0.0, 0.7, "#8E5BA6"),
        ("Combination", 0.7, 0.7, "#E2574C")]

plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 11,
                     "axes.spines.top": False, "axes.spines.right": False})

# ============================================================ 1. TRAJECTORIES
fig, axes = plt.subplots(1, 3, figsize=(14, 4.3))
tt = np.linspace(0, T_SIM, 600)
for label, u1, u2, col in ARMS:
    s = solve_ivp(odes, [0, T_SIM], [C0, T0, M0], args=(u1, u2, mean),
                  method="LSODA", dense_output=True, rtol=1e-8, atol=1e-10)
    C, T, M = s.sol(tt); C, T, M = np.clip(C, 1, None), np.clip(T, 1, None), np.clip(M, 0, None)
    axes[0].plot(tt, C, color=col, lw=2, label=label)
    axes[1].plot(tt, T, color=col, lw=2, label=label)
    axes[2].plot(tt, M/1e6, color=col, lw=2, label=label)
axes[0].set_yscale("log"); axes[0].set_ylabel("Glioma cells $C(t)$")
axes[0].axhline(0.75*mean["C_max"], color="k", ls=":", lw=1)
axes[0].text(5, 0.78*mean["C_max"], "75% $C_{max}$ (event)", fontsize=8)
axes[0].set_title("(a) Tumor burden")
axes[1].set_yscale("log"); axes[1].set_ylabel("T cells $T(t)$"); axes[1].set_title("(b) T cells")
axes[2].set_ylabel(r"MDSCs $M(t)$  ($\times10^6$)"); axes[2].set_title("(c) MDSCs")
for ax in axes:
    ax.set_xlabel("Time (days)"); ax.set_xlim(0, T_SIM)
axes[0].legend(fontsize=8, loc="lower right", frameon=False)
fig.suptitle("Reference-patient dynamics by treatment arm (mean parameters)", fontweight="bold")
fig.tight_layout()
fig.savefig("fig_trajectories.png", dpi=160); plt.close(fig)
print("saved fig_trajectories.png")


km = np.load("km_data.npz")
base_t, base_e = km["No Treatment_t"], km["No Treatment_e"]

rows = []
for label, *_ in [a for a in ARMS if a[0] != "No Treatment"]:
    t, e = km[f"{label}_t"], km[f"{label}_e"]
    df = pd.DataFrame({"duration": np.concatenate([base_t, t]),
                       "event": np.concatenate([base_e, e]),
                       "treated": np.concatenate([np.zeros(len(base_t)), np.ones(len(t))])})
    cph = CoxPHFitter().fit(df, "duration", "event")
    hr = float(np.exp(cph.params_["treated"]))
    lo, hi = np.exp(cph.confidence_intervals_.loc["treated"].values)
    rows.append((label, hr, lo, hi))

fig, ax = plt.subplots(figsize=(8, 3.2))
ypos = np.arange(len(rows))[::-1]
cmap = {a[0]: a[3] for a in ARMS}
for y, (label, hr, lo, hi) in zip(ypos, rows):
    ax.plot([lo, hi], [y, y], color=cmap[label], lw=2.5)
    ax.plot(hr, y, "o", color=cmap[label], ms=9)
    ax.text(hi+0.02, y, f"{hr:.2f} ({lo:.2f}–{hi:.2f})", va="center", fontsize=9)
ax.axvline(1.0, color="k", ls="--", lw=1)
ax.set_yticks(ypos); ax.set_yticklabels([r[0] for r in rows])
ax.set_xlim(0.3, 1.25); ax.set_xlabel("Hazard ratio vs No Treatment (95% CI)")
ax.set_title("Progression hazard ratios  (HR < 1 favours treatment)",
             fontweight="bold", pad=12)
fig.tight_layout(); fig.savefig("fig_forest.png", dpi=160); plt.close(fig)
print("saved fig_forest.png")

bench = km["bench"] 
names = ["RK45", "LSODA", "Radau"]; pairs = sorted(zip(names, bench), key=lambda x: x[1])
fig, ax = plt.subplots(figsize=(7, 3.0))
cols = {"LSODA": "#138A72", "RK45": "#2D6CB0", "Radau": "#8E5BA6"}
bars = ax.barh([p[0] for p in pairs][::-1], [p[1] for p in pairs][::-1],
               color=[cols[p[0]] for p in pairs][::-1], height=0.6)
for p in pairs:
    ax.text(p[1]+max(bench)*0.02, [q[0] for q in pairs][::-1].index(p[0]),
            f"{p[1]:.1f} ms", va="center", fontsize=9)
ax.set_xlabel("Wall-clock time per simulation (ms, best of 5)")
ax.set_xlim(0, max(bench)*1.2)
ax.set_title("ODE solver benchmark (reference patient)", fontweight="bold")
fig.tight_layout(); fig.savefig("fig_solver.png", dpi=160); plt.close(fig)
print("saved fig_solver.png")

fig, axes = plt.subplots(3, 4, figsize=(13, 7.5))
rng = np.random.default_rng(0)
for ax, (k, (m, sd)) in zip(axes.ravel(), PARAMS.items()):
    s2 = np.log(1+(sd/m)**2); mu, sig = np.log(m)-0.5*s2, np.sqrt(s2)
    samp = rng.lognormal(mu, sig, 20000)
    hi = np.percentile(samp, 99)
    ax.hist(samp, bins=60, range=(0, hi), color="#7E4FA8", alpha=0.55, density=True)
    ax.axvline(m, color="#E2574C", lw=1.6, label="mean")
    ax.set_title(LABELS[k], fontsize=12); ax.set_yticks([]); ax.tick_params(labelsize=7)
    ax.xaxis.set_major_locator(plt.MaxNLocator(4))
    ax.ticklabel_format(axis="x", style="sci", scilimits=(-2, 4))
axes.ravel()[-1].axis("off")
axes.ravel()[0].legend(fontsize=8, frameon=False)
fig.suptitle("Virtual-patient parameter distributions (log-normal, mean ± SD from ABC posterior)",
             fontweight="bold")
fig.tight_layout(); fig.savefig("fig_paramdist.png", dpi=160); plt.close(fig)
print("saved fig_paramdist.png")

fig, (a1, a2) = plt.subplots(1, 2, figsize=(11, 3.6))
labels = [a[0] for a in ARMS]; colors = [a[3] for a in ARMS]
pfs200 = []; nev = []
for lab in labels:
    t, e = km[f"{lab}_t"], km[f"{lab}_e"]
    kmf = KaplanMeierFitter().fit(t, e); pfs200.append(float(kmf.predict(T_SIM)))
    nev.append(int(e.sum()))
a1.bar(range(4), pfs200, color=colors); a1.set_xticks(range(4))
a1.set_xticklabels(labels, rotation=18, ha="right", fontsize=8.5)
a1.set_ylabel("PFS rate at day 200"); a1.set_ylim(0, 0.65)
for i, v in enumerate(pfs200): a1.text(i, v+0.01, f"{v:.0%}", ha="center", fontsize=9)
a1.set_title("(a) Progression-free survival at trial end", fontsize=11)
a2.bar(range(4), nev, color=colors); a2.set_xticks(range(4))
a2.set_xticklabels(labels, rotation=18, ha="right", fontsize=8.5)
a2.set_ylabel("Progression events / 1000")
for i, v in enumerate(nev): a2.text(i, v+8, str(v), ha="center", fontsize=9)
a2.set_title("(b) Progression events", fontsize=11)
fig.tight_layout(); fig.savefig("fig_pfs_bars.png", dpi=160); plt.close(fig)
print("saved fig_pfs_bars.png")