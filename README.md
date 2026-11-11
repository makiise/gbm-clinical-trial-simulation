# Computational Framework for GBM Immunotherapy Simulation

Bachelor's thesis code: Mariami Garuchava, Kutaisi International University, 2026.

Three-layer in-silico clinical-trial simulation of glioblastoma immunotherapy,
built on the tumor-immune ODE model of Anderson et al. (2024).

## Requirements

Python 3.10+ and the following packages:

` ` `
pip install numpy scipy matplotlib lifelines pandas pillow
` ` `

Here's the complete README.md. Copy everything between the lines below into a new file called README.md in your D:\Desktop\gbm folder. 

markdown# Computational Framework for GBM Immunotherapy Simulation

Bachelor's thesis code: Mariami Garuchava, Kutaisi International University, 2026.

A three-layer in-silico clinical-trial simulation of glioblastoma immunotherapy, built on the tumor-immune ODE model of Anderson et al. (2024).

## Requirements

Python 3.10 or newer, and the following packages:

```
pip install numpy scipy matplotlib lifelines pandas pillow
```

## Running the simulation

```
python gbm.py
python results_figures.py
python framework.py
```

The first script runs the full 1000-patient cohort across all four treatment arms (about 30 seconds), prints summary statistics, and writes the Kaplan-Meier survival figure, CSV tables, and a serialized `.npz` data file. The second script regenerates the auxiliary results figures from the saved data. The third generates the overview framework figure used in the thesis.

## Outputs

- `km_corrected.png` — Kaplan-Meier survival curves for the four arms
- `fig_trajectories.png` — single-patient C(t), T(t), M(t) trajectories
- `fig_forest.png` — hazard-ratio forest plot
- `fig_pfs_bars.png` — PFS rate and event counts per arm
- `fig_paramdist.png` — sampled parameter distributions
- `fig_solver.png` — ODE solver benchmark
- `framework_figure.pdf`, `framework_figure.png` — three-layer framework overview
- `summary.csv`, `solvers.csv`, `patients.csv` — tabular outputs

## Reproducibility

All randomness is seeded (`RNG_SEED = 42`). The cohort outcomes are identical on every run. only solver timings are differrent and dependent on hardware.

## Model source

Anderson HG, Takacs GP, Harrison JK, Rong L, Stepien TL (2024). *Optimal control of combination immunotherapy for a virtual murine cohort in a glioblastoma-immune dynamics model.* Journal of Theoretical Biology, 595, 111951. DOI: 10.1016/j.jtbi.2024.111951

The ODE equations and parameter values are taken from the authors' published MATLAB implementation: https://github.com/stepien-lab/glioma-Tcell-MDSC-treatment

