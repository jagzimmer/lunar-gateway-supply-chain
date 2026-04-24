"""
milp_optimization_gurobi.py
Gurobi-backed version of the Gateway MILP (Section 4.3).

Solves the same 12-month demo model as milp_optimization.py, but uses
Gurobi directly through gurobipy. Falls back to PuLP + CBC if Gurobi
is unavailable so the script never hard-fails.

Run:
    python3 milp_optimization_gurobi.py
"""
import os, time, sys

# ── Solver selection ────────────────────────────────────────────────────────
USE_GUROBI = True
try:
    import gurobipy as gp
    from gurobipy import GRB
except ImportError:
    USE_GUROBI = False
    print("[warn] gurobipy not installed — falling back to PuLP + CBC")
    print("       Install with:  pip install gurobipy")

# ── Problem data (same calibration as milp_optimization.py) ────────────────
T          = 12                       # months
VEHICLES   = ['FH', 'VC']
CAP        = {'FH': 5000.0, 'VC': 3200.0}    # kg per mission
COST       = {'FH': 113.4,  'VC': 97.2}      # $M all-in per mission
DEMAND     = 835.0                     # kg/month
SS_MIN     = 193.0                     # kg safety stock floor
I_INIT     = 5000.0 + SS_MIN           # initial Gateway inventory
HOLD_RATE  = 0.000115                  # $M / kg / month
SHORT_PEN  = 50.0                      # $M / kg shortage penalty
BUDGET     = 400.0                     # $M demo budget cap


def solve_with_gurobi():
    """Native gurobipy build."""
    env = gp.Env(empty=True)
    env.start()
    m = gp.Model("Gateway_MILP_Demo", env=env)
    m.Params.OutputFlag = 1
    m.Params.MIPGap     = 0.001
    m.Params.TimeLimit  = 60

    x   = m.addVars(VEHICLES, T, vtype=GRB.BINARY,       name="x")
    mv  = m.addVars(VEHICLES, T, lb=0,                   name="m")
    inv = m.addVars(T,           lb=0,                   name="I")
    sh  = m.addVars(T,           lb=0,                   name="S")

    launch = gp.quicksum(COST[v] * x[v, t] for v in VEHICLES for t in range(T))
    hold   = gp.quicksum(HOLD_RATE * inv[t] for t in range(T))
    pen    = gp.quicksum(SHORT_PEN * sh[t]  for t in range(T))
    m.setObjective(launch + hold + pen, GRB.MINIMIZE)

    for t in range(T):
        prev = I_INIT if t == 0 else inv[t - 1]
        m.addConstr(inv[t] == prev
                    + gp.quicksum(mv[v, t] for v in VEHICLES)
                    - DEMAND + sh[t], name=f"bal_{t}")
        m.addConstr(inv[t] >= SS_MIN,                         name=f"ss_{t}")
        m.addConstr(inv[t] >= 7 * (DEMAND / 30.0),            name=f"cov_{t}")
        for v in VEHICLES:
            m.addConstr(mv[v, t] <= CAP[v] * x[v, t],         name=f"cap_{v}_{t}")
        m.addConstr(gp.quicksum(x[v, t] for v in VEHICLES) <= 1, name=f"slot_{t}")
    m.addConstr(launch <= BUDGET, name="budget")

    t0 = time.time()
    m.optimize()
    dt = time.time() - t0

    if m.Status != GRB.OPTIMAL:
        print(f"[gurobi] non-optimal status: {m.Status}")
    print(f"\n  Solver       : Gurobi {gp.gurobi.version()}")
    print(f"  Status       : {m.Status}  ({'OPTIMAL' if m.Status == GRB.OPTIMAL else 'SEE GRB STATUS CODES'})")
    print(f"  Obj (total$M): {m.ObjVal:,.2f}")
    print(f"  MIP gap      : {m.MIPGap*100:.3f}%")
    print(f"  Solve time   : {dt:.2f}s")
    print(f"  Missions:")
    for t in range(T):
        for v in VEHICLES:
            if x[v, t].X > 0.5:
                print(f"    Month {t+1:>2}: {v} | {mv[v,t].X:>5,.0f} kg | ${COST[v]:.1f}M | Inv: {inv[t].X:>5,.0f} kg")
    return m.ObjVal


def solve_with_cbc():
    """Fallback build using PuLP + CBC (same as existing script)."""
    import pulp
    p = pulp.LpProblem("Gateway_MILP_Demo", pulp.LpMinimize)
    x = {v: {t: pulp.LpVariable(f"x_{v}_{t}", cat='Binary') for t in range(T)} for v in VEHICLES}
    mv = {v: {t: pulp.LpVariable(f"m_{v}_{t}", lowBound=0) for t in range(T)} for v in VEHICLES}
    I = {t: pulp.LpVariable(f"I_{t}", lowBound=0) for t in range(T)}
    S = {t: pulp.LpVariable(f"S_{t}", lowBound=0) for t in range(T)}
    launch = pulp.lpSum(COST[v]*x[v][t] for v in VEHICLES for t in range(T))
    p += launch + pulp.lpSum(HOLD_RATE*I[t] for t in range(T)) + pulp.lpSum(SHORT_PEN*S[t] for t in range(T))
    for t in range(T):
        prev = I_INIT if t == 0 else I[t-1]
        p += I[t] == prev + pulp.lpSum(mv[v][t] for v in VEHICLES) - DEMAND + S[t]
        p += I[t] >= SS_MIN
        p += I[t] >= 7*(DEMAND/30.0)
        for v in VEHICLES:
            p += mv[v][t] <= CAP[v]*x[v][t]
        p += pulp.lpSum(x[v][t] for v in VEHICLES) <= 1
    p += launch <= BUDGET
    t0 = time.time(); p.solve(pulp.PULP_CBC_CMD(msg=False, timeLimit=30)); dt = time.time() - t0
    print(f"  Solver       : CBC (PuLP)")
    print(f"  Status       : {pulp.LpStatus[p.status]}")
    print(f"  Obj (total$M): {pulp.value(p.objective):,.2f}")
    print(f"  Solve time   : {dt:.2f}s")
    return pulp.value(p.objective)


if __name__ == "__main__":
    print("=" * 60)
    print("MILP — Gateway Supply Chain (Section 4.3)")
    print("=" * 60)
    if USE_GUROBI:
        try:
            solve_with_gurobi()
        except gp.GurobiError as e:
            print(f"[gurobi] error: {e}")
            print("Falling back to CBC.")
            solve_with_cbc()
    else:
        solve_with_cbc()
    print("\nDone.")
