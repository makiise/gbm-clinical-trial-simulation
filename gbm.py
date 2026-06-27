"""

GBM Clinical Trial Simulation 

"""

import time
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp
from scipy.optimize import brentq
from lifelines import KaplanMeierFitter, CoxPHFitter
from lifelines.statistics import logrank_test
import pandas as pd

PARAMS = {
    "lambda_C": {"mean": 0.272,    "sd": 0.114},    # /day      tumor growth
    "C_max":    {"mean": 1.87e7,   "sd": 1.48e7},   # cells     carrying capacity
    "eta":      {"mean": 1.84e-7,  "sd": 1.86e-7},  # /(cell d) T-cell kill rate
    "a_T":      {"mean": 2.48e6,   "sd": 1.45e6},   # cells/day T activation
    "s_T":      {"mean": 5.73e6,   "sd": 2.63e6},   # /(cell d) tumor->T stim
    "rho":      {"mean": 0.223,    "sd": 0.142},    # PD-L1/PD-1 inhibition
    "eps_C":    {"mean": 37.5,     "sd": 29.3},     # PD-L1 expr tumor vs T
    "r":        {"mean": 2.85e-5,  "sd": 2.76e-5},  # /(cell d) MDSC->T inhib
    "d_T":      {"mean": 0.402,    "sd": 0.213},    # /day      T-cell death
    "s_M":      {"mean": 0.0476,   "sd": 0.0040},   # /day      tumor->MDSC recruit
    "d_M":      {"mean": 0.258,    "sd": 0.143},    # /day      MDSC death
}
PARAM_ORDER = list(PARAMS.keys())           # 11 parameters


C0, T0, M0 = 35_000.0, 100.0, 0.0

T_SIM_DAYS = 200          
EVENT_FRAC = 0.75          
N_PER_ARM  = 1000
RNG_SEED   = 42


P_NON_RESPONDER      = 0.30
RESPONDER_FACTOR     = (0.8, 1.0)
NON_RESPONDER_FACTOR = (0.0, 0.3)
P_DROPOUT            = 0.15
DROPOUT_MEDIAN_DAYS  = 90.0


ARMS = [
    ("No Treatment",    0.0, 0.0),
    ("Anti-PD-1",       0.7, 0.0),
    ("CCR2 Antagonist", 0.0, 0.7),
    ("Combination",     0.7, 0.7),
]


RTOL_SINGLE, ATOL_SINGLE = 1e-8, 1e-10
RTOL_MC,     ATOL_MC     = 1e-6, 1e-8


# 2. ODE SYSTEM   

def gbm_odes(t, y, u1, u2, p):
    C, T, M = max(y[0], 0.0), max(y[1], 0.0), max(y[2], 0.0)
    dC = p["lambda_C"] * C * (1.0 - C / p["C_max"]) - p["eta"] * T * C
    num = p["a_T"] + p["s_T"] * T * C
    den = 1.0 + p["rho"] * (1.0 - u1) * T * (T + p["eps_C"] * C)
    dT = num / den - p["r"] * T * M - p["d_T"] * T
    dM = p["s_M"] * (1.0 - u2) * C - p["d_M"] * M
    return [dC, dT, dM]


def resting_T_equilibrium(p):
    """Resting T-cell level with no tumor (C=0, M=0): a_T/(1+rho T^2) = d_T T.
    NOT used as an initial condition (authors use T(0)=100); reported only as
    an analysis quantity (demonstrates numerical root-finding)."""
    f = lambda T: p["a_T"] / (1.0 + p["rho"] * T**2) - p["d_T"] * T
    return brentq(f, 1.0, 1e9)


# 3. VIRTUAL-PATIENT SAMPLING
def lognormal_mu_sigma(mean, sd):
    if mean <= 0 or sd <= 0:
        return np.log(max(mean, 1e-12)), 0.0
    s2 = np.log(1.0 + (sd / mean) ** 2)
    return np.log(mean) - 0.5 * s2, np.sqrt(s2)

_LN = {k: lognormal_mu_sigma(v["mean"], v["sd"]) for k, v in PARAMS.items()}

def sample_patient(rng):
    return {k: float(rng.lognormal(*_LN[k])) for k in PARAM_ORDER}

def sample_responder(rng):
    if rng.random() < P_NON_RESPONDER:
        return rng.uniform(*NON_RESPONDER_FACTOR)
    return rng.uniform(*RESPONDER_FACTOR)

def sample_dropout(rng):
    if rng.random() < P_DROPOUT:
        return float(rng.exponential(DROPOUT_MEDIAN_DAYS / np.log(2.0)))
    return np.inf


# 4. SINGLE-PATIENT SIMULATION + EVENT/CENSORING LOGIC

def simulate_patient(p, u1, u2, method="LSODA"):
    thresh = EVENT_FRAC * p["C_max"]

    def hit(t, y, u1, u2, p):
        return y[0] - thresh
    hit.terminal = True
    hit.direction = 1

    sol = solve_ivp(gbm_odes, (0.0, T_SIM_DAYS), [C0, T0, M0],
                    args=(u1, u2, p), method=method, events=hit,
                    dense_output=False, rtol=RTOL_MC, atol=ATOL_MC, max_step=5.0)
    if sol.t_events[0].size > 0:
        return float(sol.t_events[0][0]), True
    return float(T_SIM_DAYS), False


def patient_outcome(p, u1, u2, rfac, dropout):
    """Apply responder scaling, then resolve event vs. censoring."""
    t_event, observed = simulate_patient(p, u1 * rfac, u2 * rfac)
    t_cens = min(dropout, T_SIM_DAYS)
    if observed and t_event <= t_cens:
        return t_event, 1                      # progression observed
    return min(t_cens, t_event), 0             # censored


# 5. PAIRED COHORT  (same virtual patients evaluated under every arm)
def sample_cohort(n, seed):
    """Draw n virtual patients ONCE: parameters, responder factor, dropout time.
    The same cohort is run through all arms so that between-arm differences
    reflect treatment alone, not sampling noise (paired design)."""
    rng = np.random.default_rng(seed)
    cohort = []
    for _ in range(n):
        cohort.append((sample_patient(rng), sample_responder(rng),
                       sample_dropout(rng)))
    return cohort

def run_arm_paired(cohort, u1, u2):
    times = np.empty(len(cohort))
    events = np.empty(len(cohort), dtype=int)
    for i, (p, rfac, drop) in enumerate(cohort):
        times[i], events[i] = patient_outcome(p, u1, u2, rfac, drop)
    return times, events


# 6. SOLVER BENCHMARK  (reference patient = mean params, combination arm)
def benchmark_solvers():
    mean_p = {k: PARAMS[k]["mean"] for k in PARAM_ORDER}
    out = {}
    for m in ["RK45", "LSODA", "Radau"]:
        reps, t_best = 5, np.inf
        for _ in range(reps):
            t0 = time.perf_counter()
            solve_ivp(gbm_odes, (0, T_SIM_DAYS), [C0, T0, M0],
                      args=(0.7, 0.7, mean_p), method=m,
                      rtol=RTOL_SINGLE, atol=ATOL_SINGLE)
            t_best = min(t_best, time.perf_counter() - t0)
        out[m] = t_best * 1e3  
    return out  


# 7. MAIN

def main():
    mean_p = {k: PARAMS[k]["mean"] for k in PARAM_ORDER}
    print("="*68)
    print("GBM CLINICAL TRIAL SIMULATION")
    print("="*68)
    print(f"Resting T-cell equilibrium T* (analysis only) = "
          f"{resting_T_equilibrium(mean_p):.1f} cells")
    print(f"Initial conditions: C0={C0:.0f}, T0={T0:.0f}, M0={M0:.0f}")
    print(f"Cohort: {N_PER_ARM} shared patients (paired) x {len(ARMS)} arms "
          f"= {N_PER_ARM*len(ARMS)} simulations\n")

    # ---- solver benchmark ----
    bench = benchmark_solvers()
    print("Solver benchmark (reference patient, ms):")
    for m, ms in sorted(bench.items(), key=lambda kv: kv[1]):
        print(f"   {m:6s}: {ms:7.2f} ms")
    print()

    #  cohort 
    results = {}
    summary = {}                                  
    cohort = sample_cohort(N_PER_ARM, RNG_SEED)   
    for label, u1, u2 in ARMS:
        t, e = run_arm_paired(cohort, u1, u2)
        results[label] = (t, e)
        kmf = KaplanMeierFitter().fit(t, event_observed=e)
        med = kmf.median_survival_time_                
        surv200 = float(kmf.predict(T_SIM_DAYS))         
        med_str = "not reached" if not np.isfinite(med) else f"{med:5.1f} d"
        summary[label] = {
            "arm": label, "u1": u1, "u2": u2,
            "events": int(e.sum()), "censored": int((e == 0).sum()),
            "median_PFS_days": ("NA" if not np.isfinite(med) else round(float(med), 1)),
            "PFS_at_200d": round(surv200, 3),
            "logrank_p_vs_notx": "", "hazard_ratio": "",
            "HR_CI_low": "", "HR_CI_high": "",
        }
        print(f"{label:16s}: events={int(e.sum()):4d}/{N_PER_ARM}  "
              f"censored={int((e==0).sum()):4d}  "
              f"median PFS={med_str:>11s}  PFS@200d={surv200:.2f}")
    print()

    #  KM + log-rank vs no-treatment 
    fig, ax = plt.subplots(figsize=(7.2, 5.0))
    colors = {"No Treatment": "#5A6472", "Anti-PD-1": "#2E9E5B",
              "CCR2 Antagonist": "#8E5BA6", "Combination": "#E2574C"}
    base_t, base_e = results["No Treatment"]
    print("Log-rank vs No Treatment:")
    for label, _, _ in ARMS:
        t, e = results[label]
        kmf = KaplanMeierFitter()
        kmf.fit(t, event_observed=e, label=label)
        kmf.plot_survival_function(ax=ax, ci_show=True, color=colors[label], lw=2)
        if label != "No Treatment":
            lr = logrank_test(base_t, t, event_observed_A=base_e, event_observed_B=e)
            summary[label]["logrank_p_vs_notx"] = f"{lr.p_value:.3e}"
            print(f"   {label:16s}: p = {lr.p_value:.3e}")
    print()

    #  hazard ratios vs No Treatment (Cox proportional hazards)
    print("Hazard ratios vs No Treatment (Cox PH; HR<1 favours treatment):")
    for label, _, _ in ARMS:
        if label == "No Treatment":
            continue
        t, e = results[label]
        df = pd.DataFrame({
            "duration": np.concatenate([base_t, t]),
            "event":    np.concatenate([base_e, e]),
            "treated":  np.concatenate([np.zeros(N_PER_ARM), np.ones(N_PER_ARM)]),
        })
        cph = CoxPHFitter().fit(df, duration_col="duration", event_col="event")
        hr = float(np.exp(cph.params_["treated"]))
        lo, hi = np.exp(cph.confidence_intervals_.loc["treated"].values)
        summary[label]["hazard_ratio"] = round(hr, 3)
        summary[label]["HR_CI_low"] = round(float(lo), 3)
        summary[label]["HR_CI_high"] = round(float(hi), 3)
        print(f"   {label:16s}: HR = {hr:.3f}  (95% CI {lo:.3f}–{hi:.3f})")
    print()

  
    summary_df = pd.DataFrame([summary[a[0]] for a in ARMS])
    summary_df.to_csv("summary.csv", index=False)
    print("saved summary.csv")

    rows = []
    for pid in range(N_PER_ARM):
        for label, *_ in ARMS:
            t, e = results[label]
            rows.append({"patient_id": pid, "arm": label,
                         "time_days": round(float(t[pid]), 2),
                         "event": int(e[pid])})   
    pd.DataFrame(rows).to_csv("patients.csv", index=False)
    print("saved patients.csv")


    pd.DataFrame([{"solver": s, "time_ms": round(bench[s], 2)}
                  for s in ["LSODA", "RK45", "Radau"]]).to_csv("solvers.csv", index=False)
    print("saved solvers.csv")
    ax.set_xlabel("Time (days)"); ax.set_ylabel("Progression-free survival")
    ax.set_title("Kaplan–Meier survival by treatment arm")
    ax.set_xlim(0, T_SIM_DAYS); ax.set_ylim(0, 1.02)
    ax.legend(loc="upper right", frameon=False)
    ax.spines[["top", "right"]].set_visible(False)
    fig.tight_layout()
    fig.savefig("km_corrected.png", dpi=160)
    print("saved km_corrected.png")


    np.savez("km_data.npz",
             **{f"{lab}_t": results[lab][0] for lab in results},
             **{f"{lab}_e": results[lab][1] for lab in results},
             bench=np.array([bench["RK45"], bench["LSODA"], bench["Radau"]]))
    print("saved km_data.npz")


if __name__ == "__main__":
    main()