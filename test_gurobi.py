"""test_gurobi.py — quick smoke test that the WLS license works end-to-end."""
import gurobipy as gp
from gurobipy import GRB

m = gp.Model("license_test")
x = m.addVar(lb=0, name="x")
y = m.addVar(lb=0, name="y")
m.setObjective(x + y, GRB.MAXIMIZE)
m.addConstr(x + 2 * y <= 4)
m.addConstr(3 * x + y <= 6)
m.optimize()

print("\n--- RESULT ---")
print(f"Status : {m.Status}  (2 = OPTIMAL)")
print(f"x      = {x.X:.4f}")
print(f"y      = {y.X:.4f}")
print(f"obj    = {m.ObjVal:.4f}")
print("If you see Status 2 and an objective value, your Gurobi license is working.")
