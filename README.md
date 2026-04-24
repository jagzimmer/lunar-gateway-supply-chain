# Lunar Gateway Supply Chain Optimisation

EG7302 MEM Individual Project — University of Leicester (Jan 2026 start).
All Python, MATLAB, Draw.io, Excel, Word and figure outputs produced for the
dissertation *"Lunar Gateway Supply Chain Optimisation: Integrated MILP,
Monte‑Carlo and Value‑Stream Approach (2028–2035)"*.

> **Target year:** 2026  ·  **Mission window modelled:** 2028–2035  ·  **Solver:** Gurobi 13.0.1 (WLS) / MATLAB R2019b+

---

## Repository layout

```
lunar-gateway-supply-chain/
├── README.md                     ← you are here
├── LICENSE                       ← MIT
├── .gitignore
├── python/                       ← MILP + CER + Monte‑Carlo + cost‑model scripts
├── matlab/                       ← MATLAB equivalents + figure generators
│   └── figures/                  ← PNGs produced by the .m files
├── drawio/                       ← editable VSM + Onion of Research diagrams
├── figures/                      ← final chapter‑4 figures (PNG)
├── html/                         ← interactive Gantt + roadmap pages
├── data/                         ← cost models + project plans (XLSX)
├── docs/
│   ├── chapters/                 ← Ch 1–7 Word documents + draft PDF
│   ├── appendices/               ← Appendices A, C, E (DOCX + PDF)
│   ├── qfd/                      ← Quality Function Deployment worksheet
│   └── references/               ← .ris bibliographies (RefWorks/Zotero/EndNote)
├── wall_trackers/                ← five A3 printable progress sheets
├── setup/                        ← Gurobi licence installer + smoke test
└── assignment_brief/             ← original EG7302 briefs (reference only)
```

---

## File index

### `python/` — optimisation, regression and cost‑model scripts
| File | Purpose |
|---|---|
| `milp_optimization.py` | PuLP/CBC implementation of the mission‑selection MILP (baseline solver path). |
| `milp_optimization_gurobi.py` | Gurobi 13.0.1 WLS version of the same MILP — produces the $1,247M optimal FH×9 + VC×2 solution. |
| `cer_regression.py` | Ordinary‑least‑squares regression + bootstrapped 95% CIs for CER‑1, CER‑2, CER‑3. |
| `monte_carlo.py` | 10,000‑trial LCC Monte‑Carlo and Sobol first‑order index calculator. |
| `generate_figures.py` | One‑click driver that regenerates every F4_* PNG from the raw data. |
| `build_cost_model_xlsx.py` | Emits `Gateway_Cost_Model_Interactive.xlsx` with live formulas (no hard‑coded totals). |

### `matlab/` — equivalents of the above plus visual‑design scripts
| File | Purpose |
|---|---|
| `milp_optimization.m` | MATLAB `intlinprog` / Gurobi‑via‑MEX version of the MILP. |
| `milp_dashboard_gateway.m` | 2×4 dashboard figure (7 panels + 1 intentionally empty slot). NASA/Berkeley‑Earth palette; matches `F4_5_All_CER_CIs.png`. |
| `cer_regression.m` | Produces `F4_5_All_CER_CIs.png` — the style reference used everywhere. |
| `monte_carlo.m` | LCC distribution + tornado + Sobol plots. |
| `mission_cost_comparison.m` | Bar chart of FH vs VC vs Starship scenarios. |
| `n2_diagram.m` / `n2_diagram_updated.m` | N² interaction diagram for systems engineering. |
| `vsm_diagrams.m` | Current and future value‑stream map figures. |
| `strategic_roadmap.m` | 2028–2035 capability roadmap figure. |
| `generate_figures.m` | Batch driver that renders every F4_* image. |
| `setup_gurobi_matlab.m` | One‑shot script to wire Gurobi into MATLAB's path. |
| `figures/` | Every MATLAB‑produced PNG (17 files). |

### `drawio/` — editable diagrams
| File | Purpose |
|---|---|
| `Onion Research.drawio` | Research‑methodology onion (Saunders et al. 2019) adapted for Gateway. |
| `F4_9_VSM_Current_State.drawio` | As‑is value‑stream map (2026 resupply cadence). |
| `F4_10_VSM_Future_State.drawio` | Future‑state VSM with MILP‑optimised flow and ISRU tap‑in. |

### `figures/` — final chapter‑4 PNGs
| File | Used in |
|---|---|
| `F4_1_N2_Diagram.png` | §4.1 systems architecture |
| `F4_2_CER1_Regression.png` | §4.2 CER‑1 launch‑cost model |
| `F4_3_Monte_Carlo_LCC.png` | §4.2.3 uncertainty analysis |
| `F4_4_Tornado_Diagram.png` | §4.2.4 sensitivity |
| `F4_5_All_CER_CIs.png` | §4.2.5 combined CER 95% CIs (**style reference for dashboard**) |
| `F4_6_MILP_Gantt.png` / `Figure_4_6_MILP_Gantt.png` | §4.3.4 optimal mission schedule |
| `F4_7_LCC_Waterfall.png` | §4.3.5 cost‑saving waterfall ($1,472 M → $1,247 M) |
| `F4_8_Safety_Stock_Tradeoff.png` | §4.4 safety‑stock optimisation |
| `F4_9_VSM_Current.png` / `F4_10_VSM_Future.png` | §4.5 value‑stream transformation |
| `F4_11_Strategic_Roadmap.png` | §4.6 capability roadmap |

### `html/` — interactive pages
| File | Purpose |
|---|---|
| `MILP_Gantt_Chart.html` | Browser‑native interactive Gantt (vanilla JS). |
| `MILP_Gantt_ProjectLibre_Style.html` | Alternate styling that mirrors ProjectLibre exports. |
| `F4_11_Strategic_Roadmap.html` | Interactive 2028–2035 roadmap with hover tool‑tips. |

### `data/` — Excel models and plans
| File | Purpose |
|---|---|
| `Gateway_Cost_Model_Interactive.xlsx` | Live LCC model; every cell is a formula, no hard‑codes. |
| `Lunar_Gateway_Project_Plan_Professional.xlsx` | Full WBS / timeline (weeks 1–16). |
| `Lunar_Gateway_Project_Plan_Compressed.xlsx` | Compressed variant tuned for A3 printing. |
| `lunar_gateway_project_plan.xlsx` | Earlier draft kept for diff/version history. |

### `docs/chapters/` — report Word documents
| File | Purpose |
|---|---|
| `Gateway_Chapter1_Introduction.docx` | Chapter 1 — introduction & problem statement. |
| `Gateway_Revised_Chapter1.docx` | Post‑review rewrite of Ch 1. |
| `Gateway_Sections_1_2_3.docx` | Consolidated Ch 1–3 snapshot. |
| `Gateway_Chapters_3_4.docx` | Ch 3 methodology + Ch 4 results (draft). |
| `Gateway_Chapter4_Results_Analysis.docx` | Stand‑alone Ch 4 with MILP, Monte‑Carlo, Sobol, VSM. |
| `Gateway_Sections_5_6_7.docx` | Discussion / Conclusions / Reflective statement. |
| `Gateway_Sections_5_6_7_v2.docx` / `_FINAL.docx` | Revision trail. |
| `Gateway_Revised_TOC.docx` / `_v3.docx` | Tables of contents for supervisor review. |
| `Gateway_Cost_Model_Technical_Reference.docx` | Engineering reference that documents every cell and formula in the interactive model. |
| `Figure_4_6_and_Table_4_11.docx` | MILP Pareto figure + table extracted together. |
| `Lunar_Gateway_Dissertation_Draft.pdf` | Compiled full‑dissertation PDF (latest draft). |

### `docs/appendices/`
| File | Purpose |
|---|---|
| `Gateway_AppendixA_Decision_Support_Tool.docx` | Appendix A — interactive DST walkthrough. |
| `Gateway_AppendixC_FMEA_Complete.docx` | Appendix C — full FMEA (severity × occurrence × detection). |
| `Gateway_AppendixE_Timeline_Jira.docx` | Appendix E — Jira‑style timeline export. |
| `Gateway_Appendix_Complete.docx` | Combined appendix bundle. |
| `Appendix C.pdf` / `Appendix E.pdf` | Print‑ready PDF versions. |

### `docs/qfd/`
| File | Purpose |
|---|---|
| `QFD_Lunar_Gateway_Supply_Chain.xlsx` | Quality Function Deployment House of Quality (6 needs × 5 ECs, 1/3/9 matrix, RANK formulas + declared‑vs‑computed importance rows). |

### `docs/references/`
| File | Purpose |
|---|---|
| `Gateway_References.ris` | Master reference library. |
| `Gateway_Chapter4_References.ris` | Subset used only in Chapter 4. |
| `Saunders_Lewis_Thornhill_2019.ris` | Research‑methodology textbook (for the onion diagram). |
| `Shishko_et_al_2004.ris` | Original CER textbook entry. |

### `wall_trackers/` — A3 printable progress posters
| File | Purpose |
|---|---|
| `01_Project_Timeline_A3.pdf` | Gantt‑style 16‑week plan. |
| `02_Chapter_Figure_Progress_A3.pdf` | Ch × figure completion matrix. |
| `03_Results_Dashboard_A3.pdf` | One‑sheet summary of MILP / MC / Sobol results. |
| `04_Weekly_Habit_Tracker_A3.pdf` | Writing / code / review habit grid. |
| `05_NASA_Mission_Images_A3.pdf` | NASA/Artemis imagery reference poster. |

### `setup/` — Gurobi + licence utilities
| File | Purpose |
|---|---|
| `GUROBI_SETUP.md` | Step‑by‑step setup for macOS (Gurobi 13.0.1 WLS). |
| `install_gurobi_license.command` | Double‑click installer that writes `gurobi.lic` to the right place and chmods it. |
| `test_gurobi.py` | 10‑line smoke test — solves a tiny LP and prints solver version. |

> **Note:** the actual `gurobi.lic` file is **not** committed — `.gitignore`
> excludes it. Use the installer in `setup/` with your own WLS key.

### `assignment_brief/` — module context (optional)
The original EG7302 briefs, handbook and proposal template, kept for
reproducibility. Not required to run any of the code.

---

## Reproducing the key results

```bash
# 1. Clone
git clone https://github.com/<your-username>/lunar-gateway-supply-chain.git
cd lunar-gateway-supply-chain

# 2. Set up Python environment
python3 -m venv .venv
source .venv/bin/activate
pip install numpy pandas matplotlib scipy scikit-learn openpyxl python-docx pulp gurobipy

# 3. Install your Gurobi WLS licence
bash setup/install_gurobi_license.command
python setup/test_gurobi.py          # should print "Optimal objective: 1.0"

# 4. Re‑run the MILP and regenerate figures
python python/milp_optimization_gurobi.py
python python/monte_carlo.py
python python/cer_regression.py
python python/generate_figures.py
```

MATLAB equivalents live in `matlab/`; open `matlab/milp_dashboard_gateway.m`
and press **Run** to reproduce the 2×4 dashboard used in Chapter 4.

---

## Headline results

| Metric | Value | Source |
|---|---:|---|
| Baseline LCC (2028–2035) | **$1,472 M** | `python/milp_optimization_gurobi.py` |
| MILP‑optimal LCC | **$1,247 M** | same |
| **Saving** | **$225 M (15.3%)** | waterfall panel, `F4_7_LCC_Waterfall.png` |
| Optimal mission mix | **FH × 9 + VC × 2** | Chapter 4, Table 4.11 |
| Dominant Sobol driver | Launch cost, **S₁ = 0.412** | `monte_carlo.py` |
| MILP MIP gap | **< 0.1%** | Gurobi log |
| Mission‑success probability at optimum | **Pₛ = 0.912** | Pareto panel |

---

## Citation

If you reference or reuse any artefact, please cite as:

> Jagzimmer (2026). *Lunar Gateway Supply Chain Optimisation: Integrated
> MILP, Monte‑Carlo and Value‑Stream Approach (2028–2035).* MEM individual
> project, University of Leicester, EG7302.

---

## Licence

MIT — see [`LICENSE`](LICENSE). NASA imagery used in figures is public domain
(NASA Media Usage Guidelines).
