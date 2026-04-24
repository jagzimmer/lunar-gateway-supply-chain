% =========================================================================
% STRATEGIC ROADMAP — Lunar Gateway Supply Chain
% Produces: F4_11_Strategic_Roadmap.png
%
% Figure 4.11  Strategic Roadmap — Integrated Framework Implementation
%              Timeline (2026–2035)
%   Phase 1: Framework deployment & MILP activation       (2026–2028)
%   Phase 2: ISRU commissioning & lean implementation     (2028–2031)
%   Phase 3: Full operational optimisation — ISRU +
%            multi-provider contracts                     (2031–2035)
%   Key milestones:
%     S1 savings realised Month 1
%     S2 savings from Year 3
%     S3 full lean realised Year 2
%     S4 decision gate 2031 — Starship commercial reliability data
%
% NASA/Berkeley Earth visualisation style
%   Grey background · Phase bands · Diamond milestones · Black markers
% No toolboxes required — base MATLAB only
% =========================================================================

clearvars; clc;

OUT = fullfile(fileparts(mfilename('fullpath')), 'figures');
if ~exist(OUT,'dir'), mkdir(OUT); end
fprintf('Output folder: %s\n\n', OUT);

% ── NASA colour palette ───────────────────────────────────────────────────
BG     = [0.941, 0.941, 0.941];   % #F0F0F0
DBLUE  = [0.133, 0.133, 0.533];   % #222288 — Phase 1
GREEN  = [0.098, 0.475, 0.235];   % #197A3C — Phase 2
RED    = [0.800, 0.000, 0.000];   % #CC0000 — Phase 3 / S4
ORANGE = [0.859, 0.322, 0.000];   % #DB5200 — warning / S4
GOLD   = [0.902, 0.773, 0.302];   % #E6C44D — milestones
BLACK  = [0.000, 0.000, 0.000];
DGRID  = [0.700, 0.700, 0.700];
WHITE  = [1.000, 1.000, 1.000];

% Phase colours (fill + edge)
PH1_F  = DBLUE;   PH1_E  = DBLUE * 0.7;
PH2_F  = GREEN;   PH2_E  = GREEN * 0.7;
PH3_F  = RED;     PH3_E  = RED   * 0.7;

fprintf('============================================================\n');
fprintf('STRATEGIC ROADMAP — GATEWAY SUPPLY CHAIN 2026–2035\n');
fprintf('============================================================\n\n');

% ── Timeline setup ────────────────────────────────────────────────────────
YR0  = 2026;   YR1 = 2035;
yr2x = @(yr) yr - YR0;           % year → x-axis position

fig = figure('Position',[50 50 1500 780],'Color',WHITE);
ax  = axes(fig,'Position',[0.06 0.10 0.91 0.82]);
hold(ax,'on');
ax.Color      = BG;
ax.GridColor  = DGRID;
ax.GridAlpha  = 1.0;
ax.GridLineStyle = '--';
ax.XColor     = BLACK;
ax.YColor     = BLACK;
ax.FontSize   = 11;
ax.Box        = 'off';
ax.TickDir    = 'out';
ax.LineWidth  = 1.0;

xlim(ax, [-0.2, yr2x(YR1)+0.3]);
ylim(ax, [-0.5, 6.2]);
xticks(ax, 0:1:9);
xticklabels(ax, arrayfun(@(y)num2str(YR0+y), 0:9, 'UniformOutput', false));
yticks(ax, []);
grid(ax,'on');  ax.YGrid = 'off';

% ── Phase bands ───────────────────────────────────────────────────────────
% Phase 1: 2026–2028
ph1_x = yr2x(2026);  ph1_w = yr2x(2028) - ph1_x;
% Phase 2: 2028–2031
ph2_x = yr2x(2028);  ph2_w = yr2x(2031) - ph2_x;
% Phase 3: 2031–2035
ph3_x = yr2x(2031);  ph3_w = yr2x(2035) - ph3_x;

% Phase band rectangles (full height)
for ph = 1:3
    switch ph
        case 1; px=ph1_x; pw=ph1_w; fc=PH1_F; lbl={'Phase 1','Framework Deployment','& MILP Activation','2026–2028'};
        case 2; px=ph2_x; pw=ph2_w; fc=PH2_F; lbl={'Phase 2','ISRU Commissioning','& Lean Implementation','2028–2031'};
        case 3; px=ph3_x; pw=ph3_w; fc=PH3_F; lbl={'Phase 3','Full Operational','Optimisation','2031–2035'};
    end
    % Translucent background strip
    rectangle(ax,'Position',[px, -0.4, pw, 6.1], ...
        'FaceColor',[fc, 0.08],'EdgeColor',[fc, 0.35],'LineWidth',1.2);
    % Phase header block
    rectangle(ax,'Position',[px+0.02, 5.35, pw-0.04, 0.72], ...
        'FaceColor',fc,'EdgeColor',[fc*0.7],'LineWidth',1.5,'Curvature',[0.05 0.15]);
    % Phase label
    cx = px + pw/2;
    text(ax, cx, 5.95, lbl{1}, 'HorizontalAlignment','center', ...
        'Color',WHITE,'FontSize',11,'FontWeight','bold');
    text(ax, cx, 5.65, lbl{2}, 'HorizontalAlignment','center', ...
        'Color',WHITE,'FontSize',8.5,'FontWeight','bold');
    text(ax, cx, 5.43, [lbl{3} '  ' lbl{4}], 'HorizontalAlignment','center', ...
        'Color',[WHITE*0.9],'FontSize',8);
end

% ── Phase boundary vertical lines ─────────────────────────────────────────
for yr = [2028, 2031]
    xline(ax, yr2x(yr), '-', 'Color', DGRID, 'LineWidth', 2.0, 'Alpha', 1.0);
end

% ── Swim lane labels and horizontal dividers ───────────────────────────────
lanes = {
    4.8, 'Cost Management',   DBLUE;
    3.5, 'Logistics & MILP',  GREEN;
    2.2, 'ISRU Integration',  ORANGE;
    0.9, 'Risk & Resilience', RED;
};

for i = 1:size(lanes,1)
    ly   = lanes{i,1};
    lbl  = lanes{i,2};
    clr  = lanes{i,3};
    % Swim lane band
    rectangle(ax,'Position',[-0.2, ly-0.55, yr2x(YR1)+0.5, 1.05], ...
        'FaceColor',[clr, 0.07],'EdgeColor','none');
    % Left label strip
    rectangle(ax,'Position',[-0.20, ly-0.50, 0.18, 0.95], ...
        'FaceColor',clr,'EdgeColor','none','Curvature',[0.1 0.2]);
    text(ax, -0.11, ly, lbl, 'Rotation', 90, ...
        'HorizontalAlignment','center','Color',WHITE, ...
        'FontSize',8,'FontWeight','bold','Clipping','on');
    % Divider line
    if i < size(lanes,1)
        yline(ax, ly-0.55, '--', 'Color', DGRID, 'LineWidth', 0.8, 'Alpha', 0.8);
    end
end

% ──────────────────────────────────────────────────────────────────────────
% MILESTONE DEFINITIONS
% Fields: {year, lane_y, label_lines, colour, scenario_tag}
% ──────────────────────────────────────────────────────────────────────────
milestones = {
    % ── COST MANAGEMENT lane ──────────────────────────────────────────────
    2026.2, 4.8, {'S1: LCC savings','realised Month 1','$225M saving locked'},   GOLD,   'S1';
    2028.0, 4.8, {'MILP v1.0','deployed','intlinprog live'},                      DBLUE,  '';
    2031.0, 4.8, {'S2: Year 3','savings realised','$225M confirmed'},             GOLD,   'S2';
    2033.5, 4.8, {'Full LCC','target achieved','$1,247M'},                         GREEN,  '';

    % ── LOGISTICS & MILP lane ─────────────────────────────────────────────
    2026.5, 3.5, {'MILP framework','scope defined'},                              DBLUE,  '';
    2027.5, 3.5, {'S3: Full lean','realised Year 2','PCE 30.7%'},                 GOLD,   'S3';
    2028.5, 3.5, {'MILP v2.0','multi-provider','Vulcan Centaur +FH'},             GREEN,  '';
    2030.5, 3.5, {'11-mission','schedule locked','$548.7M Phase 1'},              GREEN,  '';
    2032.5, 3.5, {'Phase 2 MILP','698.3M budget','validated'},                    GREEN,  '';
    2034.5, 3.5, {'Final schedule','close-out','M-11 Nov 2034'},                  DBLUE,  '';

    % ── ISRU INTEGRATION lane ─────────────────────────────────────────────
    2028.0, 2.2, {'ISRU hardware','precursor','commissioned'},                    ORANGE, '';
    2030.2, 2.2, {'ISRU 25% active','160 kg/mo','M-5 trigger'},                   ORANGE, '';
    2031.5, 2.2, {'ISRU 75% active','480 kg/mo','16-mo gap enabled'},             ORANGE, '';
    2033.0, 2.2, {'ISRU FULL','642 kg/mo','Year 6 maturity'},                     GREEN,  '';
    2034.5, 2.2, {'Net demand =','SS only','193 kg/mo'},                           GREEN,  '';

    % ── RISK & RESILIENCE lane ────────────────────────────────────────────
    2026.3, 0.9, {'Risk baseline','P_fail = 32%','single provider'},              RED,    '';
    2029.0, 0.9, {'Dual-provider','activated','P_fail 18.4%'},                    GOLD,   '';
    2031.0, 0.9, {'S4 DECISION','GATE — Starship','commercial data'},             RED,    'S4';
    2032.5, 0.9, {'Resilience','target met','95% SL achieved'},                   GREEN,  '';
    2034.0, 0.9, {'Full SS model','validated','k_s=1.65 locked'},                 DBLUE,  '';
};

% ── Draw milestones ───────────────────────────────────────────────────────
for i = 1:size(milestones,1)
    yr   = milestones{i,1};
    ly   = milestones{i,2};
    lns  = milestones{i,3};
    clr  = milestones{i,4};
    stag = milestones{i,5};
    xp   = yr2x(yr);

    % Vertical stem line
    plot(ax, [xp xp], [ly-0.35, ly+0.35], '-', ...
        'Color', clr, 'LineWidth', 1.0);

    % Diamond marker
    d = 0.15;
    fill(ax, [xp-d, xp, xp+d, xp], [ly, ly+d*0.5, ly, ly-d*0.5], ...
        clr, 'EdgeColor', clr*0.7, 'LineWidth', 1.2);

    % Scenario tag badge
    if ~isempty(stag)
        rectangle(ax,'Position',[xp-0.18, ly+0.18, 0.36, 0.22], ...
            'FaceColor',clr,'EdgeColor',clr*0.7,'Curvature',[0.3 0.6],'LineWidth',1);
        text(ax, xp, ly+0.29, stag, 'HorizontalAlignment','center', ...
            'Color',WHITE,'FontSize',8,'FontWeight','bold');
    end

    % Label box — alternate above/below to avoid overlap
    if mod(i,2) == 0
        txt_y = ly - 0.42;
        va = 'top';
    else
        txt_y = ly + 0.42;
        va = 'bottom';
    end
    % White background box
    n = numel(lns);
    text(ax, xp, txt_y, lns, ...
        'HorizontalAlignment','center','VerticalAlignment',va, ...
        'FontSize',7.5,'Color',BLACK,'FontWeight','bold', ...
        'BackgroundColor',WHITE,'EdgeColor',clr,'Margin',2, ...
        'LineWidth',0.8,'Clipping','on');
end

% ── Key scenario legend box ───────────────────────────────────────────────
legend_x = yr2x(2035) - 0.05;
legend_y  = 5.20;
lbox_w = 1.30; lbox_h = 1.00;
rectangle(ax,'Position',[legend_x-lbox_w, legend_y-lbox_h, lbox_w, lbox_h], ...
    'FaceColor',WHITE,'EdgeColor',DBLUE,'LineWidth',1.5,'Curvature',[0.05 0.1]);
text(ax, legend_x-lbox_w/2, legend_y-0.08, 'Scenario Tags', ...
    'HorizontalAlignment','center','FontSize',9,'FontWeight','bold','Color',DBLUE);
sc = {{'S1','Month-1 LCC saving ($225M)',GOLD}; ...
      {'S2','Year-3 saving realised',GOLD}; ...
      {'S3','Full lean PCE=30.7% Yr 2',GOLD}; ...
      {'S4','Starship gate 2031 (pending)',RED}};
for k=1:4
    d=0.08; yk=legend_y-0.26-(k-1)*0.19;
    xk=legend_x-lbox_w+0.12;
    fill(ax,[xk-d,xk,xk+d,xk],[yk,yk+d*0.5,yk,yk-d*0.5],sc{k}{3},'EdgeColor',sc{k}{3}*0.7);
    text(ax,xk+0.18,yk,[sc{k}{1},'  ',sc{k}{2}], ...
        'VerticalAlignment','middle','FontSize',7.5,'Color',BLACK);
end

% ── Phase colour legend ───────────────────────────────────────────────────
lg_x = yr2x(2035) - 0.05;
lg_y  = 4.05;
lgd_w = 1.30; lgd_h = 0.75;
rectangle(ax,'Position',[lg_x-lgd_w, lg_y-lgd_h, lgd_w, lgd_h], ...
    'FaceColor',WHITE,'EdgeColor',DGRID,'LineWidth',1.0,'Curvature',[0.05 0.1]);
text(ax,lg_x-lgd_w/2, lg_y-0.08,'Phase Colour Key', ...
    'HorizontalAlignment','center','FontSize',9,'FontWeight','bold','Color',BLACK);
phleg = {{PH1_F,'Phase 1: Framework & MILP'},{PH2_F,'Phase 2: ISRU & Lean'},{PH3_F,'Phase 3: Full Optimisation'}};
for k=1:3
    yk=lg_y-0.24-(k-1)*0.18;
    xk=lg_x-lgd_w+0.08;
    fill(ax,[xk xk+0.22 xk+0.22 xk],[yk+0.06 yk+0.06 yk-0.06 yk-0.06], ...
        phleg{k}{1},'EdgeColor',phleg{k}{1}*0.7,'LineWidth',0.5);
    text(ax,xk+0.28,yk,phleg{k}{2},'VerticalAlignment','middle','FontSize',7.5,'Color',BLACK);
end

% ── Titles and annotations ────────────────────────────────────────────────
title(ax, ...
    {'Figure 4.11  ——  Strategic Roadmap: Integrated Framework Implementation Timeline (2026–2035)', ...
     'EG7302 MEM Individual Project  |  Jagathguru Pazhanaivel (249057008)  |  Supervisor: Dr. Udu Amadi  |  University of Leicester'}, ...
    'FontSize',12,'FontWeight','bold','Color',BLACK,'Interpreter','none');

xlabel(ax,'Timeline →','FontSize',12,'FontWeight','bold','Color',BLACK);

% Source credit
text(ax,yr2x(YR1)+0.15, -0.42, 'Source: Author (2025) | EG7302 MEM Individual Project', ...
    'HorizontalAlignment','right','FontSize',8,'Color',DGRID, ...
    'Interpreter','none');

% ── Export ────────────────────────────────────────────────────────────────
exportgraphics(fig, fullfile(OUT,'F4_11_Strategic_Roadmap.png'),'Resolution',300);
close(fig);
fprintf('F4.11 saved → %s\n', fullfile(OUT,'F4_11_Strategic_Roadmap.png'));

fprintf('\n============================================================\n');
fprintf('STRATEGIC ROADMAP COMPLETE\n');
fprintf('  3 phases | 2026–2035 | 4 swim lanes | 20 milestones\n');
fprintf('  S1/S2/S3/S4 scenario milestones all plotted\n');
fprintf('  S4 Starship decision gate at 2031 marked\n');
fprintf('============================================================\n');
