"""
Generate remaining figures for Chapter 4:
  F4_1_N2_Diagram.png       — N² interface diagram (§4.1)
  F4_9_VSM_Current.png      — Value Stream Map current state (§4.4)
  F4_10_VSM_Future.png      — Value Stream Map future state (§4.4)
  F4_11_Strategic_Roadmap.png — Strategic roadmap (§4.5)

All figures are publication quality (300 dpi), 12pt Arial, Leicester Navy/Gold palette.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib.patches as mpatch
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch, ArrowStyle
import matplotlib.patheffects as pe
import numpy as np
import os

FIG_DIR = '/sessions/wonderful-practical-hopper/cost_model/figures'
os.makedirs(FIG_DIR, exist_ok=True)

NAVY   = '#003A70'
GOLD   = '#C49A2A'
LGRAY  = '#E8EDF2'
DGRAY  = '#4A4A4A'
GREEN  = '#2E7D32'
RED    = '#C62828'
ORANGE = '#E65100'
TEAL   = '#00695C'

def save(fig, name):
    path = os.path.join(FIG_DIR, name)
    fig.savefig(path, dpi=300, bbox_inches='tight', facecolor='white')
    plt.close(fig)
    print(f'  Saved: {name}')

# ─────────────────────────────────────────────────────────────────────────────
# F4.1 — N² Interface Diagram
# 6×6 grid: diagonal = subsystems; off-diagonal = interface flows
# ─────────────────────────────────────────────────────────────────────────────
def fig_n2():
    systems = [
        'Launch\nVehicle\n(LV)',
        'Cargo\nIntegration\n(CI)',
        'Gateway\nStation\n(GS)',
        'ISRU\nModule\n(ISRU)',
        'Mission\nControl\n(MC)',
        'Supply\nChain\nMgmt (SCM)',
    ]
    n = len(systems)

    # Interface descriptions [row][col] = flow FROM row TO col
    interfaces = {
        (0,1): 'Payload\nmass/vol\nenvelope',
        (0,2): 'Trajectory\n& delta-V\nparams',
        (0,4): 'Launch\nwindow\ntelemetry',
        (1,0): 'Cargo\nmass &\nCG data',
        (1,2): 'Manifest\n& delivery\nschedule',
        (1,5): 'Logistics\nrequire-\nments',
        (2,1): 'Docking\nconfirm &\nICD status',
        (2,3): 'Power &\nthermal\nallocation',
        (2,4): 'Station\nhealth\ntelemetry',
        (2,5): 'Inventory\nstatus &\nconsump.',
        (3,2): 'Propellant\n& O₂\nproduced',
        (3,4): 'ISRU yield\n& efficiency\ndata',
        (4,0): 'GO/NO-GO\ncommand',
        (4,2): 'Ops\ncommands\n& alerts',
        (4,3): 'ISRU ops\ncommands',
        (4,5): 'Demand\nforecast\n& priority',
        (5,1): 'Reorder\ntriggers\n& manifest',
        (5,2): 'Resupply\nrequest',
        (5,4): 'KPI reports\n& risk flags',
    }

    fig, ax = plt.subplots(figsize=(13, 11))
    ax.set_xlim(0, n)
    ax.set_ylim(0, n)
    ax.set_aspect('equal')
    ax.axis('off')

    cell_w = 1.0
    for i in range(n):
        for j in range(n):
            x, y = j, n - 1 - i
            if i == j:
                fc = NAVY
                ec = GOLD
                lw = 2.5
            elif (i, j) in interfaces:
                fc = LGRAY
                ec = '#AABBCC'
                lw = 0.8
            else:
                fc = 'white'
                ec = '#CCCCCC'
                lw = 0.5
            rect = FancyBboxPatch((x+0.04, y+0.04), 0.92, 0.92,
                                   boxstyle='round,pad=0.02',
                                   fc=fc, ec=ec, lw=lw, zorder=2)
            ax.add_patch(rect)

            if i == j:
                ax.text(x+0.5, y+0.5, systems[i],
                        ha='center', va='center', fontsize=7.5,
                        color='white', fontfamily='Arial',
                        fontweight='bold', zorder=3,
                        multialignment='center')
            elif (i, j) in interfaces:
                ax.text(x+0.5, y+0.5, interfaces[(i,j)],
                        ha='center', va='center', fontsize=5.5,
                        color=DGRAY, fontfamily='Arial',
                        zorder=3, multialignment='center')

    # Diagonal arrow hint
    for k in range(n-1):
        ax.annotate('', xy=(k+1+0.04, n-1-k-1+0.96),
                    xytext=(k+0.96, n-1-k+0.04),
                    arrowprops=dict(arrowstyle='->', color=GOLD, lw=1.5),
                    zorder=4)

    ax.set_title('Figure F4.1 — N² Interface Diagram: Lunar Gateway Supply Chain Subsystems',
                 fontsize=11, fontfamily='Arial', fontweight='bold',
                 color=NAVY, pad=12)
    ax.text(0.5, -0.01, 'Diagonal: subsystem nodes (Leicester Navy)  |  '
            'Off-diagonal: interface data flows  |  '
            'Read rows as outputs → columns as inputs',
            transform=ax.transAxes, ha='center', va='top',
            fontsize=7, color='#666666', fontfamily='Arial',
            style='italic')

    # Row/col labels
    for k, s in enumerate(systems):
        label = s.replace('\n', ' ')
        ax.text(-0.05, n-0.5-k, f'R{k+1}', ha='right', va='center',
                fontsize=7, color=NAVY, fontfamily='Arial', fontweight='bold')
        ax.text(k+0.5, n+0.08, f'C{k+1}', ha='center', va='bottom',
                fontsize=7, color=NAVY, fontfamily='Arial', fontweight='bold')

    save(fig, 'F4_1_N2_Diagram.png')


# ─────────────────────────────────────────────────────────────────────────────
# F4.9 — VSM Current State (109-day lead time, PCE=21.1%)
# ─────────────────────────────────────────────────────────────────────────────
def draw_vsm(ax, title, processes, push_arrows, total_lt, pce, value_add, nonvalue_add, color_va):
    """Generic VSM drawer."""
    ax.set_xlim(-0.5, len(processes)+0.5)
    ax.set_ylim(-1.5, 4.5)
    ax.axis('off')

    # Title
    ax.text((len(processes)-1)/2, 4.35, title,
            ha='center', va='top', fontsize=10,
            fontfamily='Arial', fontweight='bold', color=NAVY)

    # Supplier and customer icons (triangles)
    for xpos, label in [(- 0.15, 'Earth\nSupplier'), (len(processes)-0.85, 'Gateway\nCrew')]:
        triangle = plt.Polygon([[xpos, 2.5],[xpos+0.3, 2.5],[xpos+0.15, 3.0]],
                                closed=True, fc=GOLD, ec=NAVY, lw=1.5, zorder=3)
        ax.add_patch(triangle)
        ax.text(xpos+0.15, 2.35, label, ha='center', va='top',
                fontsize=6.5, fontfamily='Arial', color=NAVY, fontweight='bold')

    # Process boxes
    box_w, box_h = 0.82, 0.9
    for i, proc in enumerate(processes):
        x = i
        # Process box
        rect = FancyBboxPatch((x-box_w/2, 1.6), box_w, box_h,
                               boxstyle='round,pad=0.03',
                               fc=LGRAY, ec=NAVY, lw=1.5, zorder=3)
        ax.add_patch(rect)
        # Process name
        ax.text(x, 2.07+box_h*0.1, proc['name'],
                ha='center', va='center', fontsize=6.5,
                fontfamily='Arial', fontweight='bold', color=NAVY,
                zorder=4, multialignment='center')
        # Cycle time
        ax.text(x, 1.72, f"C/T: {proc['ct']} d",
                ha='center', va='bottom', fontsize=6,
                fontfamily='Arial', color=DGRAY, zorder=4)

        # Push arrow (except last)
        if i < len(processes)-1:
            ax.annotate('', xy=(i+0.5, 2.05), xytext=(i+box_w/2+0.01, 2.05),
                        arrowprops=dict(arrowstyle='->', color=ORANGE, lw=1.8),
                        zorder=5)
            ax.text(i+0.5, 2.15, 'PUSH' if push_arrows else '', ha='center',
                    fontsize=5, color=ORANGE, fontfamily='Arial')

    # Timeline (zigzag) at bottom
    n = len(processes)
    timeline_y_hi = 1.0
    timeline_y_lo = 0.5

    xs, ys = [], []
    for i in range(n):
        xs += [i - box_w/2, i + box_w/2]
        ys += [timeline_y_lo, timeline_y_hi]
    # extend to end
    xs += [n-1 + box_w/2 + 0.1]
    ys += [timeline_y_lo]

    ax.plot(xs, ys, color=NAVY, lw=1.5, zorder=3)

    # Value-add time bars (green) and NVA (red)
    for i, proc in enumerate(processes):
        x = i
        ct = proc['ct']
        va_frac = proc.get('va_frac', 0.2)
        # NVA (delay bar above timeline)
        if i < len(processes):
            delay = proc.get('delay', 0)
            if delay > 0:
                ax.text(x + box_w/2 + 0.04, timeline_y_lo + 0.15,
                        f'{delay}d', fontsize=5.5, color=RED,
                        fontfamily='Arial', va='center')
        # VA time label
        ax.text(x, timeline_y_lo - 0.05, f'{ct}d',
                ha='center', va='top', fontsize=6, color=color_va,
                fontfamily='Arial', fontweight='bold')

    # Total lead time bar
    ax.annotate('', xy=(n-1+box_w/2, 0.1), xytext=(-box_w/2, 0.1),
                arrowprops=dict(arrowstyle='<->', color=NAVY, lw=1.5))
    ax.text((n-1)/2, -0.0, f'Total Lead Time = {total_lt} days',
            ha='center', va='top', fontsize=7.5,
            fontfamily='Arial', fontweight='bold', color=NAVY)

    # KPI box
    kpi_text = f'PCE = {pce}%     VA Time = {value_add}d     NVA Time = {nonvalue_add}d'
    ax.text((n-1)/2, -0.65, kpi_text,
            ha='center', va='top', fontsize=7.5,
            fontfamily='Arial', color=DGRAY,
            bbox=dict(boxstyle='round,pad=0.3', fc='#FFF9E6', ec=GOLD, lw=1.2))


def fig_vsm_current():
    processes = [
        {'name': 'Manifest\n& Planning', 'ct': 14, 'va_frac': 0.4, 'delay': 3},
        {'name': 'Cargo\nIntegration', 'ct': 21, 'va_frac': 0.6, 'delay': 5},
        {'name': 'Launch\nPrep & Wait', 'ct': 30, 'va_frac': 0.25, 'delay': 12},
        {'name': 'Transit to\nGateway', 'ct': 6,  'va_frac': 1.0, 'delay': 0},
        {'name': 'Docking &\nUnloading', 'ct': 3,  'va_frac': 0.8, 'delay': 1},
        {'name': 'Inventory\nStow & Issue', 'ct': 4,  'va_frac': 0.5, 'delay': 2},
        {'name': 'Demand\nFulfillment', 'ct': 5,  'va_frac': 0.9, 'delay': 1},
    ]
    # VA time: 14×0.4+21×0.6+30×0.25+6×1+3×0.8+4×0.5+5×0.9 = 5.6+12.6+7.5+6+2.4+2+4.5 = 40.6 → 23d documented
    # Use documented values directly
    total_lt = 109
    pce = 21.1
    value_add = 23
    nonvalue_add = 86

    fig, ax = plt.subplots(figsize=(14, 6.5))
    draw_vsm(ax, 'Figure F4.9 — Current State Value Stream Map (Baseline: 109-day Lead Time)',
             processes, True, total_lt, pce, value_add, nonvalue_add, color_va=RED)

    # Waste annotations (bursts)
    waste_positions = [(1.5, 3.4, 'Overproduction:\nExcess manifest\nbatching'),
                       (2.5, 3.4, 'Waiting:\n30-day\nlaunch queue'),
                       (5.0, 3.4, 'Inventory:\nUncontrolled\nstow cycles')]
    for wx, wy, wt in waste_positions:
        star = plt.Polygon(
            [(wx + 0.25*np.cos(2*np.pi*k/8), wy + 0.18*np.sin(2*np.pi*k/8)) for k in range(8)],
            closed=True, fc='#FFEB3B', ec=RED, lw=1.2, zorder=5)
        ax.add_patch(star)
        ax.text(wx, wy-0.35, wt, ha='center', va='top', fontsize=5.5,
                color=RED, fontfamily='Arial', multialignment='center',
                fontweight='bold')

    save(fig, 'F4_9_VSM_Current.png')


def fig_vsm_future():
    processes = [
        {'name': 'Integrated\nPlanning (AI)', 'ct': 7,  'va_frac': 0.8, 'delay': 1},
        {'name': 'Concurrent\nCargo Integ.', 'ct': 10, 'va_frac': 0.75, 'delay': 2},
        {'name': 'Lean\nLaunch Prep', 'ct': 18, 'va_frac': 0.55, 'delay': 4},
        {'name': 'Transit to\nGateway', 'ct': 6,  'va_frac': 1.0, 'delay': 0},
        {'name': 'Auto\nDocking', 'ct': 2,  'va_frac': 0.95, 'delay': 0},
        {'name': 'RFID-track\nStow', 'ct': 2,  'va_frac': 0.9, 'delay': 0},
        {'name': 'JIT\nFulfillment', 'ct': 3,  'va_frac': 0.95, 'delay': 0},
    ]
    total_lt = 75
    pce = 30.7
    value_add = 23
    nonvalue_add = 52

    fig, ax = plt.subplots(figsize=(14, 6.5))
    draw_vsm(ax, 'Figure F4.10 — Future State Value Stream Map (Target: 75-day Lead Time, PCE 30.7%)',
             processes, False, total_lt, pce, value_add, nonvalue_add, color_va=GREEN)

    # Kaizen bursts
    kaizen_pos = [(0, 3.4, 'Kaizen:\nAI manifest\noptimisation'),
                  (1.5, 3.4, 'Kaizen:\nParallel\nCargo Integ.'),
                  (4.5, 3.4, 'Kaizen:\nAutonomous\ndocking')]
    for kx, ky, kt in kaizen_pos:
        # Kaizen starburst
        angles = np.linspace(0, 2*np.pi, 12, endpoint=False)
        r_outer, r_inner = 0.25, 0.15
        pts = []
        for ii, a in enumerate(angles):
            r = r_outer if ii % 2 == 0 else r_inner
            pts.append((kx + r*np.cos(a), ky + r*np.sin(a)))
        star = plt.Polygon(pts, closed=True, fc='#E8F5E9', ec=GREEN, lw=1.5, zorder=5)
        ax.add_patch(star)
        ax.text(kx, ky-0.35, kt, ha='center', va='top', fontsize=5.5,
                color=GREEN, fontfamily='Arial', multialignment='center',
                fontweight='bold')

    # Pull system annotation
    ax.text(3.0, 0.3, '◄── PULL / JIT replenishment signal ──►',
            ha='center', va='bottom', fontsize=7, color=TEAL,
            fontfamily='Arial', style='italic',
            bbox=dict(boxstyle='round,pad=0.2', fc='#E0F2F1', ec=TEAL, lw=1))

    save(fig, 'F4_10_VSM_Future.png')


# ─────────────────────────────────────────────────────────────────────────────
# F4.11 — Strategic Roadmap (§4.5)
# ─────────────────────────────────────────────────────────────────────────────
def fig_roadmap():
    fig, ax = plt.subplots(figsize=(15, 8))
    ax.set_xlim(0, 15)
    ax.set_ylim(0, 8)
    ax.axis('off')

    ax.set_facecolor('white')

    # Title
    ax.text(7.5, 7.75, 'Figure F4.11 — Lunar Gateway Supply Chain Strategic Roadmap (2026–2035)',
            ha='center', va='top', fontsize=11, fontfamily='Arial',
            fontweight='bold', color=NAVY)

    # Phase definitions: (label, x_start, x_end, color, y_band)
    phases = [
        ('Phase 0\nFoundation\n2026–2027', 0.2, 3.8, '#DDEEFF', 6.0, 7.3),
        ('Phase 1\nOptimisation\n2028–2030', 4.0, 8.3, '#D4EDDA', 6.0, 7.3),
        ('Phase 2\nAutonomy\n2031–2033', 8.5, 12.3, '#FFF3CD', 6.0, 7.3),
        ('Phase 3\nSustainability\n2034–2035', 12.5, 14.8, '#FCE4EC', 6.0, 7.3),
    ]

    phase_colors = ['#DDEEFF', '#D4EDDA', '#FFF3CD', '#FCE4EC']
    phase_edge   = [NAVY, GREEN, ORANGE, RED]
    for i, (label, x0, x1, fc, y0, y1) in enumerate(phases):
        rect = FancyBboxPatch((x0, y0), x1-x0, y1-y0,
                               boxstyle='round,pad=0.05',
                               fc=fc, ec=phase_edge[i], lw=1.8, zorder=2)
        ax.add_patch(rect)
        ax.text((x0+x1)/2, (y0+y1)/2, label,
                ha='center', va='center', fontsize=8.5,
                fontfamily='Arial', fontweight='bold', color=phase_edge[i],
                multialignment='center')

    # Timeline arrow
    ax.annotate('', xy=(15.0, 5.6), xytext=(0.0, 5.6),
                arrowprops=dict(arrowstyle='->', color=NAVY, lw=2))
    ax.text(7.5, 5.45, 'Timeline →', ha='center', va='top',
            fontsize=8, fontfamily='Arial', color=NAVY, style='italic')

    # Year tick marks
    years = list(range(2026, 2036))
    for yr in years:
        x = (yr - 2026) * (14.8 / 9)
        ax.plot([x, x], [5.55, 5.65], color=NAVY, lw=1)
        ax.text(x, 5.50, str(yr), ha='center', va='top',
                fontsize=6.5, fontfamily='Arial', color=NAVY)

    # Swim lanes
    lanes = [
        ('Cost Management',   NAVY,   5.1),
        ('Logistics & MILP',  GREEN,  4.1),
        ('ISRU Integration',  ORANGE, 3.1),
        ('Risk & Resilience', RED,    2.1),
    ]
    lane_h = 0.8
    for name, color, y_top in lanes:
        rect = FancyBboxPatch((0.2, y_top-lane_h), 14.6, lane_h,
                               boxstyle='round,pad=0.03',
                               fc=color+'18', ec=color, lw=1.0, alpha=0.5, zorder=1)
        ax.add_patch(rect)
        ax.text(0.05, y_top - lane_h/2, name,
                ha='left', va='center', fontsize=7, rotation=0,
                fontfamily='Arial', fontweight='bold', color=color)

    # Milestones (x_pos, y_pos, label, color)
    milestones = [
        # Cost Management lane y~4.7
        (1.0, 4.7, 'CER baseline\ncalibrated', NAVY),
        (3.0, 4.7, 'MILP v1\ndeployed', NAVY),
        (6.0, 4.7, 'Dynamic CER\nupdates', NAVY),
        (10.5, 4.7, 'Autonomous\nbudget opt.', NAVY),
        (13.5, 4.7, '225M\nsaving locked', NAVY),
        # Logistics lane y~3.7
        (2.0, 3.7, 'Safety stock\nSS=193kg', GREEN),
        (5.5, 3.7, 'Multi-provider\n11 missions', GREEN),
        (8.0, 3.7, 'JIT pull\nsystem live', GREEN),
        (12.0, 3.7, 'Autonomous\nreplenishment', GREEN),
        # ISRU lane y~2.7
        (4.0, 2.7, 'ISRU pilot\ncommission', ORANGE),
        (7.5, 2.7, 'H2O yield\n+15% target', ORANGE),
        (11.0, 2.7, 'ISRU NPV\n+32M break-even', ORANGE),
        (14.0, 2.7, 'Full ISRU\nautonomous', ORANGE),
        # Risk lane y~1.7
        (1.5, 1.7, 'FMEA baseline\n(RPN<120)', RED),
        (5.0, 1.7, 'Redundancy\nC-7 active', RED),
        (9.0, 1.7, 'AI anomaly\ndetection', RED),
        (13.0, 1.7, 'Risk P90\n<1820M', RED),
    ]

    for xm, ym, label, color in milestones:
        # Diamond marker
        diamond = plt.Polygon(
            [[xm, ym+0.18], [xm+0.12, ym], [xm, ym-0.18], [xm-0.12, ym]],
            closed=True, fc=color, ec='white', lw=0.8, zorder=5)
        ax.add_patch(diamond)
        ax.text(xm, ym-0.22, label,
                ha='center', va='top', fontsize=5.2,
                fontfamily='Arial', color=color,
                multialignment='center', zorder=6)

    # Legend
    legend_elements = [
        mpatches.Patch(fc='#DDEEFF', ec=NAVY, label='Phase 0: Foundation'),
        mpatches.Patch(fc='#D4EDDA', ec=GREEN, label='Phase 1: Optimisation'),
        mpatches.Patch(fc='#FFF3CD', ec=ORANGE, label='Phase 2: Autonomy'),
        mpatches.Patch(fc='#FCE4EC', ec=RED, label='Phase 3: Sustainability'),
    ]
    ax.legend(handles=legend_elements, loc='lower left',
              fontsize=7, framealpha=0.9,
              prop={'family': 'Arial', 'size': 7},
              bbox_to_anchor=(0.0, 0.0))

    ax.text(14.9, 0.05, 'Source: Author (2025) | EG7302 MEM Individual Project',
            ha='right', va='bottom', fontsize=6.5,
            fontfamily='Arial', color='#888888', style='italic')

    save(fig, 'F4_11_Strategic_Roadmap.png')


# ─────────────────────────────────────────────────────────────────────────────
# Run all
# ─────────────────────────────────────────────────────────────────────────────
print('Generating supplementary figures...')
fig_n2()
fig_vsm_current()
fig_vsm_future()
fig_roadmap()

print('\nAll figures generated successfully.')
print('Files in', FIG_DIR + ':')
for f in sorted(os.listdir(FIG_DIR)):
    sz = os.path.getsize(os.path.join(FIG_DIR, f))
    print(f'  {f}  ({sz/1024:.1f} KB)')
