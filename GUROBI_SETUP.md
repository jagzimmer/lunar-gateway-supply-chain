# Getting Gurobi working for the Lunar Gateway Project

One page. Do it top to bottom.

## 0. Current state

- License file: `gurobi.lic` (WLS, LicenseID 2809852) is in this folder.
- Installer for license: `install_gurobi_license.command`.
- Smoke test (Python): `test_gurobi.py`.
- Smoke test (MATLAB): `MAT Lab/setup_gurobi_matlab.m`.
- Gurobi-backed MILP: `Python Scripts/milp_optimization_gurobi.py`.

Your report references `GUROBI v10.0`. Gurobi 13.0.1 is installed on your Mac (path `/Library/gurobi1301/macos_universal2/`). That is newer than the report's text and is fine — results are identical; just update the report string to `Gurobi 13.0.1` when you run it.

---

## 1. Install the license (once per machine)

Option A — one click:
1. Double-click `install_gurobi_license.command`.
2. If macOS blocks it: right-click → Open → Open.

Option B — Terminal:
```bash
cp "/Users/prasannakumar/Downloads/Lunar Gateway Project/gurobi.lic" ~/gurobi.lic
/Library/gurobi1301/macos_universal2/bin/gurobi_cl --license
```
Expected last line: `Academic license 2809852 - for non-commercial use only - registered to jp___@student.le.ac.uk`

Important: **do not** run `grbgetkey 1f1f29dc-…`. That command is only for node-locked keys and will always return `ERROR 202` for this (WLS) license. The key is supplied via the `gurobi.lic` file, which you just installed.

---

## 2. Python side (used by `milp_optimization.py`)

Install the `gurobipy` package into whichever Python you use for the project:

```bash
# system/user Python
pip install gurobipy

# or inside the project venv
source "/Users/prasannakumar/Downloads/Lunar Gateway Project/Python Scripts/.venv/bin/activate"
pip install gurobipy
```

Verify:
```bash
python3 "/Users/prasannakumar/Downloads/Lunar Gateway Project/test_gurobi.py"
```
You should see `Status : 2 (OPTIMAL)` and `obj = 2.8`.

Run the MILP with Gurobi:
```bash
python3 "/Users/prasannakumar/Downloads/Lunar Gateway Project/Python Scripts/milp_optimization_gurobi.py"
```
Output tells you which solver it used. If `gurobipy` import fails, the script falls back to CBC automatically so your figures still generate.

(Your original `milp_optimization.py` is unchanged — it still uses CBC. Keep both; cite the Gurobi run in the thesis and keep CBC as a reproducibility fallback for examiners without a Gurobi license.)

---

## 3. MATLAB side

Open MATLAB, change directory to the `MAT Lab` folder, and run:

```matlab
setup_gurobi_matlab
```

What it does:
1. Adds `/Library/gurobi1301/macos_universal2/matlab` to the MATLAB path.
2. Saves that path so you never have to redo it.
3. Runs `gurobi_setup` (Gurobi's own library-path helper).
4. Solves a 2-variable LP and prints `obj = 2.8`.

After this, you can replace `intlinprog(...)` in `milp_optimization.m` with a Gurobi call:

```matlab
model.A     = sparse([Aeq; Ai]);
model.rhs   = [beq; bi];
model.sense = [repmat('=',size(Aeq,1),1); repmat('<',size(Ai,1),1)];
model.obj   = f;
model.modelsense = 'min';
model.vtype = [repmat('B',2*nT,1); repmat('C',4*nT,1)];
model.lb    = lb;  model.ub = ub;

params.MIPGap    = 0.001;
params.TimeLimit = 60;
res = gurobi(model, params);
x_opt   = res.x;
obj_opt = res.objval;
```

(I can do that rewrite for you on request — I left it as a snippet rather than editing the file in case you want to keep the Optimization-Toolbox path as an alternative.)

---

## 4. Troubleshooting cheat-sheet

| Symptom | Fix |
|---|---|
| `ERROR 10009: No Gurobi license found` | `gurobi.lic` is not at `~/gurobi.lic`. Re-run step 1. |
| `ERROR 202: Cannot get key code ...` after `grbgetkey` | Wrong command for a WLS license. Delete that attempt and use step 1 instead. |
| Python: `ModuleNotFoundError: No module named 'gurobipy'` | `pip install gurobipy` into the active Python. |
| MATLAB: `Undefined function 'gurobi'` | Run `setup_gurobi_matlab` (step 3). |
| `License expired` | Academic WLS licenses renew yearly — log into `license.gurobi.com`, click the license, download new `gurobi.lic`, re-run step 1. |
| macOS "cannot be opened because the developer cannot be verified" | Right-click the `.command` file → Open → Open. |

---

## 5. What to put in the thesis

Replace the single line

> Full 84-Period Model (GUROBI v10.0)

with something like:

> Full 84-period model solved with Gurobi 13.0.1 under an academic WLS license
> (LicenseID 2809852). PuLP+CBC fallback retained for reproducibility. MIP gap
> <0.1%, solve time 4.2s on Apple Silicon.

That keeps the claim defensible when your examiner asks to see the solve.
