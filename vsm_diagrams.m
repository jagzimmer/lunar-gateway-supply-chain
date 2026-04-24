% =========================================================================
% VSM DIAGRAMS — Lunar Gateway Supply Chain
% Produces: F4_9_VSM_Current.png   (109 days, PCE=21.1%)
%           F4_10_VSM_Future.png   (75 days,  PCE=30.7%)
%
% Value Stream Map — Current State (8 steps) and Future State (7 steps)
% NASA/Berkeley Earth visualisation style
%   Process boxes · Push arrows · Waste bursts · Kaizen stars · Zigzag flow
%
% No toolboxes required — base MATLAB only
% =========================================================================

clearvars; clc;

OUT = fullfile(fileparts(mfilename('fullpath')), 'figures');
if ~exist(OUT,'dir'), mkdir(OUT); end
fprintf('Output folder: %s\n\n', OUT);

% ── NASA colour palette ───────────────────────────────────────────────────
BG      = [0.980, 0.980, 0.965];   % near-white warm background
DBLUE   = [0.133, 0.133, 0.533];   % NASA deep blue
RTREND  = [0.800, 0.000, 0.000];   % NASA red
BLACK   = [0.000, 0.000, 0.000];
DGRID   = [0.700, 0.700, 0.700];
GREEN   = [0.000, 0.502, 0.000];
ORANGE  = [0.859, 0.322, 0.000];
GOLD    = [0.902, 0.773, 0.302];
LGREY   = [0.880, 0.880, 0.880];
BOXBLU  = [0.220, 0.380, 0.620];   % process box fill
KAIZEN  = [0.100, 0.600, 0.200];   % kaizen star green

fprintf('============================================================\n');
fprintf('VSM DIAGRAMS — GATEWAY SUPPLY CHAIN\n');
fprintf('============================================================\n\n');

%% =========================================================================
%% FIGURE F4.9 — CURRENT STATE VSM
%% 8 process steps | 109 days total | VA=23d | NVA=86d | PCE=21.1%%
%% =========================================================================

% ── Process step data ─────────────────────────────────────────────────────
% Fields: {Name, CT(d), Wait(d), WasteLabel, WasteType}
% WasteType: 0=none, 1=overproduction(orange), 2=waiting(red), 3=inventory(yellow)
CS = {
    'Manifest &\nPlanning',      3,  14,  '',                         0;
    'Cargo\nIntegration',        5,  21,  {'Overproduction:','Excess manifest','buffering'},  1;
    'Launch Prep\n& Wait',       4,  30,  {'Waiting:','30-day','launch queue'},  2;
    'Transit to\nGateway',       4,   6,  '',                         0;
    'Docking &\nUnloading',      2,   6,  '',                         0;
    'Inventory\nStow & Issue',   2,   4,  {'Inventory:','Uncontrolled','stow cycle'},   3;
    'Issue &\nTracking',         1,   3,  '',                         0;
    'Demand\nFulfillment',       2,   2,  '',                         0;
};
nCS   = size(CS,1);
VA_cs = sum(cell2mat(CS(:,2)));   % =23
NVA_cs= sum(cell2mat(CS(:,3)));   % =86
TLT_cs= VA_cs + NVA_cs;          % =109
PCE_cs= VA_cs / TLT_cs * 100;    % =21.1%
fprintf('Current State: TLT=%dd  VA=%dd  NVA=%dd  PCE=%.1f%%\n', ...
    TLT_cs, VA_cs, NVA_cs, PCE_cs);

fig = figure('Position',[50 50 1400 560],'Color',[1 1 1]);
ax  = axes(fig,'Position',[0.03 0.08 0.94 0.82]);
hold(ax,'on'); axis(ax,'off');
ax.Color = BG;
xlim(ax,[0 1]); ylim(ax,[0 1]);

% ── Title ─────────────────────────────────────────────────────────────────
title(ax, {'Figure 4.9  \fontsize{13}Current State Value Stream Map  (Baseline: 109-day Lead Time)'}, ...
    'FontSize',13,'FontWeight','bold','Color',DBLUE,'Units','normalized', ...
    'Position',[0.5 1.01 0]);

% ── Layout parameters ─────────────────────────────────────────────────────
box_w = 0.085;  box_h = 0.18;
box_y = 0.58;   % top of process boxes
arr_y = box_y + box_h/2;
zz_y0 = 0.35;   % zigzag top baseline
step_x= linspace(0.06, 0.94, nCS);   % x centres of boxes

% ── Supplier icon (left) ──────────────────────────────────────────────────
draw_factory(ax, 0.025, box_y+box_h/2, DBLUE, BLACK, 'Mission\nAuthority');

% ── Customer icon (right) ────────────────────────────────────────────────
draw_factory(ax, 0.975, box_y+box_h/2, GREEN, BLACK, 'Gateway\nCrew');

% ── Process boxes + push arrows ───────────────────────────────────────────
waste_clr = {[], ORANGE, RTREND, GOLD};

for i = 1:nCS
    cx = step_x(i);

    % Process box
    draw_box(ax, cx, box_y, box_w, box_h, BOXBLU, BLACK, ...
        strsplit_nl(CS{i,1}), CS{i,2});

    % Push arrow between boxes
    if i < nCS
        ax_mid = (step_x(i) + step_x(i+1)) / 2;
        draw_push_arrow(ax, cx+box_w/2+0.005, arr_y, ...
            step_x(i+1)-box_w/2-0.005, arr_y, ORANGE, BLACK);
    end

    % Waste burst above box (if applicable)
    if CS{i,4} ~= 0 && ~isempty(CS{i,4})
        clr = waste_clr{CS{i,5}+1};
        draw_waste_burst(ax, cx, box_y+box_h+0.09, 0.065, clr, BLACK, CS{i,4});
    end
end

% ── Zigzag lead-time line ─────────────────────────────────────────────────
all_pts_x = []; all_pts_y = [];
cx_cur = step_x(1) - box_w/2;
for i = 1:nCS
    % Down to NVA level
    nva_h = zz_y0 - min(0.05 + CS{i,3}/100*0.18, 0.28);
    all_pts_x(end+1) = cx_cur;          all_pts_y(end+1) = zz_y0;
    all_pts_x(end+1) = cx_cur;          all_pts_y(end+1) = nva_h;
    % Horizontal NVA bar
    nva_end = step_x(i) + box_w/2;
    all_pts_x(end+1) = nva_end;         all_pts_y(end+1) = nva_h;
    % Wait time label
    text(ax, (cx_cur+nva_end)/2, nva_h-0.04, ...
        sprintf('%dd', CS{i,3}), 'FontSize',9,'Color',RTREND, ...
        'HorizontalAlignment','center','FontWeight','bold');
    % Up to VA level
    va_top = zz_y0;
    all_pts_x(end+1) = nva_end;         all_pts_y(end+1) = va_top;
    % CT label at top
    text(ax, step_x(i), zz_y0+0.04, sprintf('CT=%dd', CS{i,2}), ...
        'FontSize',8,'Color',GREEN,'HorizontalAlignment','center', ...
        'FontWeight','bold');
    cx_cur = nva_end;
end
plot(ax, all_pts_x, all_pts_y, '-', 'Color', DBLUE, 'LineWidth', 2.0);

% ── Lead time arrow ───────────────────────────────────────────────────────
annotation_arrow_h(ax, 0.06, 0.94, 0.08, DBLUE, BLACK, ...
    sprintf('Total Lead Time = %d days', TLT_cs));

% ── PCE summary box ───────────────────────────────────────────────────────
draw_summary_box(ax, 0.5, 0.04, ...
    sprintf('PCE = %.1f%%   |   VA Time = %dd   |   NVA Time = %dd', ...
    PCE_cs, VA_cs, NVA_cs), GOLD, BLACK);

exportgraphics(fig, fullfile(OUT,'F4_9_VSM_Current.png'),'Resolution',300);
close(fig);
fprintf('F4.9 saved\n');

%% =========================================================================
%% FIGURE F4.10 — FUTURE STATE VSM
%% 7 process steps | 75 days total | VA=23d | NVA=52d | PCE=30.7%%
%% =========================================================================

% Kaizen type: 0=none, 1=kaizen_green
FS = {
    'Integrated\nPlanning (AI)',    4,  7,  {'Kaizen:','AI Assist +','Automation'},    1;
    'Concurrent\nCargo Integ.',     6, 10,  {'Kaizen:','Parallel','Cargo Preps'},      1;
    'Lean\nLaunch Prep',            4, 16,  {'Kaizen:','Lean\nScheduling'},             1;
    'Transit to\nGateway',          4,  4,  '',                                          0;
    'Auto\nDocking',                2,  6,  {'Kaizen:','Autonomous\nDocking'},          1;
    'RFID-track\nStow',             2,  5,  '',                                          0;
    'JIT\nFulfillment',             1,  4,  '',                                          0;
};
nFS   = size(FS,1);
VA_fs = sum(cell2mat(FS(:,2)));   % =23
NVA_fs= sum(cell2mat(FS(:,3)));   % =52
TLT_fs= VA_fs + NVA_fs;          % =75
PCE_fs= VA_fs / TLT_fs * 100;    % =30.7%
fprintf('Future State:  TLT=%dd  VA=%dd  NVA=%dd  PCE=%.1f%%\n', ...
    TLT_fs, VA_fs, NVA_fs, PCE_fs);

fig = figure('Position',[50 50 1400 560],'Color',[1 1 1]);
ax  = axes(fig,'Position',[0.03 0.08 0.94 0.82]);
hold(ax,'on'); axis(ax,'off');
ax.Color = BG;
xlim(ax,[0 1]); ylim(ax,[0 1]);

title(ax, {'Figure 4.10  \fontsize{13}Future State Value Stream Map  (Target: 75-day Lead Time, PCE 30.7%)'}, ...
    'FontSize',13,'FontWeight','bold','Color',DBLUE,'Units','normalized', ...
    'Position',[0.5 1.01 0]);

step_xf = linspace(0.07, 0.93, nFS);

% Supplier + Customer
draw_factory(ax, 0.025, box_y+box_h/2, DBLUE, BLACK, 'Mission\nAuthority');
draw_factory(ax, 0.975, box_y+box_h/2, GREEN, BLACK, 'Gateway\nCrew');

% Process boxes, pull signals, kaizen bursts
for i = 1:nFS
    cx = step_xf(i);

    % Green box for future state (improved)
    box_clr_f = [0.18 0.45 0.25];   % lean green
    draw_box(ax, cx, box_y, box_w, box_h, box_clr_f, BLACK, ...
        strsplit_nl(FS{i,1}), FS{i,2});

    % Pull signal between boxes (different from push)
    if i < nFS
        if i == 4  % pull signal after transit
            draw_pull_signal(ax, cx+box_w/2+0.005, arr_y, ...
                step_xf(i+1)-box_w/2-0.005, arr_y, DBLUE, BLACK, ...
                'PULL/JIT\nreplenishment\nsignal');
        else
            draw_push_arrow(ax, cx+box_w/2+0.005, arr_y, ...
                step_xf(i+1)-box_w/2-0.005, arr_y, GREEN, BLACK);
        end
    end

    % Kaizen star burst (green — improvement)
    if FS{i,5} == 1
        draw_kaizen_star(ax, cx, box_y+box_h+0.09, 0.065, KAIZEN, BLACK, FS{i,4});
    end
end

% Zigzag
all_pts_x = []; all_pts_y = [];
cx_cur = step_xf(1) - box_w/2;
for i = 1:nFS
    nva_h = zz_y0 - min(0.05 + FS{i,3}/100*0.15, 0.22);
    all_pts_x(end+1) = cx_cur;          all_pts_y(end+1) = zz_y0;
    all_pts_x(end+1) = cx_cur;          all_pts_y(end+1) = nva_h;
    nva_end = step_xf(i) + box_w/2;
    all_pts_x(end+1) = nva_end;         all_pts_y(end+1) = nva_h;
    text(ax, (cx_cur+nva_end)/2, nva_h-0.04, ...
        sprintf('%dd', FS{i,3}), 'FontSize',9,'Color',RTREND, ...
        'HorizontalAlignment','center','FontWeight','bold');
    all_pts_x(end+1) = nva_end;         all_pts_y(end+1) = zz_y0;
    text(ax, step_xf(i), zz_y0+0.04, sprintf('CT=%dd', FS{i,2}), ...
        'FontSize',8,'Color',GREEN,'HorizontalAlignment','center', ...
        'FontWeight','bold');
    cx_cur = nva_end;
end
plot(ax, all_pts_x, all_pts_y, '-', 'Color', GREEN, 'LineWidth', 2.0);

% Lead time arrow
annotation_arrow_h(ax, 0.06, 0.94, 0.08, GREEN, BLACK, ...
    sprintf('Total Lead Time = %d days', TLT_fs));

% PCE summary
draw_summary_box(ax, 0.5, 0.04, ...
    sprintf('PCE = %.1f%%   |   VA Time = %dd   |   NVA Time = %dd', ...
    PCE_fs, VA_fs, NVA_fs), [0.7 0.95 0.7], BLACK);

exportgraphics(fig, fullfile(OUT,'F4_10_VSM_Future.png'),'Resolution',300);
close(fig);
fprintf('F4.10 saved\n');

fprintf('\n============================================================\n');
fprintf('VSM MODULE COMPLETE\n');
fprintf('  Current State: TLT=%dd  PCE=%.1f%%\n', TLT_cs, PCE_cs);
fprintf('  Future State:  TLT=%dd  PCE=%.1f%%\n', TLT_fs, PCE_fs);
fprintf('  Lead Time Reduction: %dd (%.0f%%)\n', TLT_cs-TLT_fs, ...
    (TLT_cs-TLT_fs)/TLT_cs*100);
fprintf('============================================================\n');


%% =========================================================================
%% LOCAL HELPER FUNCTIONS
%% =========================================================================

% ── Draw a process box ────────────────────────────────────────────────────
function draw_box(ax, cx, by, bw, bh, fc, ec, lines, ct)
    % Outer box
    rectangle(ax,'Position',[cx-bw/2, by, bw, bh], ...
        'FaceColor',fc,'EdgeColor',ec,'LineWidth',1.5);
    % Divider line for CT label area
    line(ax,[cx-bw/2, cx+bw/2],[by+bh*0.28, by+bh*0.28], ...
        'Color',ec,'LineWidth',1);
    % CT label
    text(ax, cx, by+bh*0.14, sprintf('CT: %dd', ct), ...
        'HorizontalAlignment','center','Color','white', ...
        'FontSize',8,'FontWeight','bold');
    % Step name
    for k = 1:numel(lines)
        text(ax, cx, by+bh*(0.42 + (numel(lines)-k)*0.20), lines{k}, ...
            'HorizontalAlignment','center','Color','white', ...
            'FontSize',8.5,'FontWeight','bold');
    end
end

% ── Draw push arrow (filled triangle on line) ─────────────────────────────
function draw_push_arrow(ax, x1, y, x2, ~, ac, ec)
    mid = (x1+x2)/2;
    plot(ax,[x1 x2],[y y],'-','Color',ac,'LineWidth',2);
    % Striped triangle (push symbol)
    tx = [mid-0.012, mid+0.012, mid+0.012, mid-0.012];
    ty = [y+0.025,   y+0.025,   y-0.025,   y-0.025];
    fill(ax, [mid mid+0.02 mid], [y+0.015 y y-0.015], ac, ...
        'EdgeColor',ec,'LineWidth',1);
    % P label
    text(ax, mid, y+0.04, 'PUSH', 'FontSize',6,'Color',ac, ...
        'HorizontalAlignment','center','FontWeight','bold');
end

% ── Draw pull signal (curved arrow) ──────────────────────────────────────
function draw_pull_signal(ax, x1, y, x2, ~, ac, ec, lbl)
    % Dashed curved pull arrow
    t = linspace(0,pi,30);
    xc = x1 + (x2-x1)/2 + (x2-x1)/2 * cos(t+pi);
    yc = y + 0.03*sin(t);
    plot(ax,xc,yc,'--','Color',ac,'LineWidth',2);
    fill(ax,[x2-0.015 x2 x2-0.015],[y+0.01 y y-0.01],ac,'EdgeColor',ec);
    mid = (x1+x2)/2;
    if ~isempty(lbl)
        ls = strsplit_nl(lbl);
        for k=1:numel(ls)
            text(ax, mid, y+0.05+(numel(ls)-k)*0.025, ls{k}, ...
                'FontSize',7,'Color',ac,'HorizontalAlignment','center', ...
                'FontWeight','bold');
        end
    end
end

% ── Draw waste burst (cloud shape — orange/red) ───────────────────────────
function draw_waste_burst(ax, cx, cy, r, fc, ec, lbls)
    % Approximate cloud with overlapping circles
    angles = 0:45:315;
    for a = angles
        xo = cx + r*0.55*cosd(a);
        yo = cy + r*0.35*sind(a);
        theta = linspace(0,2*pi,30);
        fill(ax, xo+r*0.45*cos(theta), yo+r*0.35*sin(theta), fc, ...
            'EdgeColor',ec,'LineWidth',0.8,'FaceAlpha',0.85);
    end
    % Labels
    if ~isempty(lbls) && iscell(lbls)
        for k = 1:numel(lbls)
            text(ax, cx, cy+(numel(lbls)/2-k+0.5)*0.038, lbls{k}, ...
                'HorizontalAlignment','center','FontSize',7.5, ...
                'Color',BLACK_local(),'FontWeight','bold');
        end
    end
end

% ── Draw kaizen star (green — future state improvement) ───────────────────
function draw_kaizen_star(ax, cx, cy, r, fc, ec, lbls)
    % 8-point star
    n  = 8;
    th = linspace(0, 2*pi, n*2+1);
    rr = repmat([r, r*0.45], 1, n+1);
    rr = rr(1:n*2);
    xs = cx + rr .* cos(th(1:n*2));
    ys = cy + rr .* sin(th(1:n*2));
    fill(ax, xs, ys, fc, 'EdgeColor',ec,'LineWidth',1.2,'FaceAlpha',0.90);
    % Labels
    if ~isempty(lbls) && iscell(lbls)
        for k = 1:numel(lbls)
            text(ax, cx, cy+(numel(lbls)/2-k+0.5)*0.038, lbls{k}, ...
                'HorizontalAlignment','center','FontSize',7.5, ...
                'Color','white','FontWeight','bold');
        end
    end
end

% ── Draw factory icon ─────────────────────────────────────────────────────
function draw_factory(ax, cx, cy, fc, ec, lbl)
    % Simple factory: rectangle + chimney
    bw=0.038; bh=0.12;
    rectangle(ax,'Position',[cx-bw/2, cy-bh/2, bw, bh], ...
        'FaceColor',fc,'EdgeColor',ec,'LineWidth',1.5);
    % Roof triangle
    fill(ax,[cx-bw/2-0.005, cx, cx+bw/2+0.005], ...
         [cy+bh/2, cy+bh/2+0.05, cy+bh/2], fc, 'EdgeColor',ec,'LineWidth',1);
    % Chimney
    rectangle(ax,'Position',[cx+bw/6, cy+bh/2+0.01, 0.008, 0.03], ...
        'FaceColor',fc,'EdgeColor',ec,'LineWidth',1);
    % Label below
    ls = strsplit(lbl,'\n');
    for k = 1:numel(ls)
        text(ax, cx, cy-bh/2-0.025-(numel(ls)-k)*0.022, ls{k}, ...
            'HorizontalAlignment','center','FontSize',8, ...
            'Color',ec,'FontWeight','bold');
    end
end

% ── Horizontal lead time arrow ────────────────────────────────────────────
function annotation_arrow_h(ax, x1, x2, y, ac, ec, lbl)
    % Arrow line
    plot(ax,[x1 x2],[y y],'-','Color',ac,'LineWidth',2.0);
    % Arrowheads
    fill(ax,[x1 x1+0.02 x1],[y+0.012 y y-0.012],ac,'EdgeColor',ec);
    fill(ax,[x2 x2-0.02 x2],[y+0.012 y y-0.012],ac,'EdgeColor',ec);
    % Label above
    text(ax,(x1+x2)/2, y+0.028, lbl, ...
        'HorizontalAlignment','center','FontSize',10, ...
        'Color',ac,'FontWeight','bold');
end

% ── Summary metrics box ───────────────────────────────────────────────────
function draw_summary_box(ax, cx, cy, lbl, fc, ec)
    w=0.52; h=0.055;
    rectangle(ax,'Position',[cx-w/2, cy-h/2, w, h], ...
        'FaceColor',fc,'EdgeColor',ec,'LineWidth',1.5,'Curvature',[0.1 0.3]);
    text(ax, cx, cy, lbl, 'HorizontalAlignment','center', ...
        'FontSize',10,'Color',ec,'FontWeight','bold');
end

% ── Split string by \n into cell array ───────────────────────────────────
function parts = strsplit_nl(s)
    parts = strsplit(s,'\n');
end

% ── Black colour helper (avoids variable scope issues) ────────────────────
function c = BLACK_local()
    c = [0 0 0];
end
