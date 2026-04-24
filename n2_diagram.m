% =========================================================================
% N² INTERFACE DIAGRAM — Lunar Gateway Supply Chain
% Figure F4.1 — System Interface Mapping
% EG7302 MEM Individual Project | Jagathguru Pazhanaivel (249057008)
%
% Visual design: NASA/Berkeley Earth data visualisation style
%   Grey background · Blue diagonal nodes · Black interface text
%   Dashed grey grid · Bold black title · Clean sans-serif font
% No toolboxes required.
% =========================================================================

clearvars; clc;

OUT = fullfile(fileparts(mfilename('fullpath')), 'figures');
if ~exist(OUT,'dir'), mkdir(OUT); end
fprintf('Output folder: %s\n\n', OUT);

% ── NASA colour palette ───────────────────────────────────────────────────
BG     = [0.941, 0.941, 0.941];   % grey background
DBLUE  = [0.133, 0.133, 0.533];   % diagonal nodes (blue)
BLACK  = [0.000, 0.000, 0.000];   % text, borders
DGRID  = [0.750, 0.750, 0.750];   % empty cells
CISHD  = [0.600, 0.700, 0.900];   % interface cells (blue shading)
WHITE  = [1.000, 1.000, 1.000];
GOLD   = [0.859, 0.686, 0.102];   % diagonal border accent

% ── System definitions ────────────────────────────────────────────────────
systems = {
    'Launch\newlineVehicle\newline(LV)';
    'Cargo\newlineIntegration\newline(CI)';
    'Gateway\newlineStation\newline(GS)';
    'ISRU\newlineModule\newline(ISRU)';
    'Mission\newlineControl\newline(MC)';
    'Supply Chain\newlineMgmt\newline(SCM)';
};
N = length(systems);

% ── Interface flows [from_row, to_col, label] ─────────────────────────────
ifaces = {
    1,2,'Payload\nmass/vol\nenvelope';
    1,3,'Trajectory\n& delta-V\nparams';
    1,5,'Launch\nwindow\ntelemetry';
    2,1,'Cargo\nmass &\nCG data';
    2,3,'Manifest\n& delivery\nschedule';
    2,6,'Logistics\nrequire-\nments';
    3,2,'Docking\nconfirm\n& ICD';
    3,4,'Power &\nthermal\nalloc.';
    3,5,'Station\nhealth\ntelemtry';
    3,6,'Inventory\nstatus &\nconsump.';
    4,3,'Propellant\n& O2\nproduced';
    4,5,'ISRU yield\n& efficiency\ndata';
    5,1,'GO/NO-GO\ncommand';
    5,3,'Ops\ncommands\n& alerts';
    5,4,'ISRU ops\ncommands';
    5,6,'Demand\nforecast\n& priority';
    6,2,'Reorder\ntriggers\n& manifest';
    6,3,'Resupply\nrequest';
    6,5,'KPI reports\n& risk flags';
};

iface_map = false(N,N);
iface_txt = cell(N,N);
for k = 1:size(ifaces,1)
    r=ifaces{k,1}; c=ifaces{k,2};
    iface_map(r,c) = true;
    iface_txt{r,c} = ifaces{k,3};
end

%% Draw figure
fig = figure('Position',[100 100 1050 950],'Color',WHITE);
ax  = axes(fig,'Color',BG); hold on;
axis(ax,'equal'); axis(ax,'off');
ax.XLim = [-0.3, N+0.6];
ax.YLim = [-0.6, N+0.8];

pad = 0.04;

for row = 1:N
    for col = 1:N
        x = col-1;
        y = N-row;

        if row == col
            % Diagonal — dark blue node
            rectangle(ax,'Position',[x+pad,y+pad,1-2*pad,1-2*pad], ...
                'Curvature',0.08,'FaceColor',DBLUE,'EdgeColor',GOLD,'LineWidth',2.5);
            text(ax,x+0.5,y+0.5,systems{row}, ...
                'HorizontalAlignment','center','VerticalAlignment','middle', ...
                'FontSize',7.5,'FontWeight','bold','Color',WHITE);

        elseif iface_map(row,col)
            % Interface cell — blue shading
            rectangle(ax,'Position',[x+pad,y+pad,1-2*pad,1-2*pad], ...
                'Curvature',0.05,'FaceColor',CISHD,'EdgeColor',DBLUE,'LineWidth',0.9);
            text(ax,x+0.5,y+0.5,iface_txt{row,col}, ...
                'HorizontalAlignment','center','VerticalAlignment','middle', ...
                'FontSize',5.0,'Color',BLACK);
        else
            % Empty cell — grey
            rectangle(ax,'Position',[x+pad,y+pad,1-2*pad,1-2*pad], ...
                'Curvature',0.05,'FaceColor',BG,'EdgeColor',DGRID,'LineWidth',0.5);
        end
    end
end

% Diagonal flow arrows
for k = 1:N-1
    x1 = (k-1)+1-pad*0.5;  y1 = N-(k-1)-pad*0.5;
    x2 = k+pad*0.5;         y2 = N-k+1-pad*0.5;
    annotation(fig,'arrow', ...
        [ax.Position(1)+x1/range(ax.XLim)*ax.Position(3), ...
         ax.Position(1)+x2/range(ax.XLim)*ax.Position(3)], ...
        [ax.Position(2)+y1/range(ax.YLim)*ax.Position(4), ...
         ax.Position(2)+y2/range(ax.YLim)*ax.Position(4)], ...
        'Color',GOLD,'LineWidth',1.5,'HeadLength',6,'HeadWidth',5);
end

% Row & column labels
for k = 1:N
    text(ax,-0.10,N-k+0.5,sprintf('R%d',k), ...
        'HorizontalAlignment','right','FontSize',9,'Color',BLACK,'FontWeight','bold');
    text(ax,k-0.5,N+0.13,sprintf('C%d',k), ...
        'HorizontalAlignment','center','FontSize',9,'Color',BLACK,'FontWeight','bold');
end

% Title (NASA large bold black title)
text(ax,N/2,N+0.62, ...
    'N^2 Interface Diagram: Lunar Gateway Supply Chain Subsystems', ...
    'HorizontalAlignment','center','FontSize',13,'FontWeight','bold','Color',BLACK);

% Subtitle caption
text(ax,N/2,-0.30, ...
    'Diagonal: subsystem nodes (blue)     Off-diagonal: interface data flows     Read rows → outputs, columns → inputs', ...
    'HorizontalAlignment','center','FontSize',8,'Color',BLACK,'FontAngle','italic');

% Legend
leg_fc = {DBLUE, CISHD, BG};
leg_ec = {GOLD,  DBLUE, DGRID};
leg_lbl= {'Subsystem Node','Interface Flow','No Interface'};
for k=1:3
    lx = 0.05 + (k-1)*1.85;
    rectangle(ax,'Position',[lx,-0.52,0.35,0.22], ...
        'FaceColor',leg_fc{k},'EdgeColor',leg_ec{k},'LineWidth',1.0);
    text(ax,lx+0.42,-0.41,leg_lbl{k},'FontSize',8,'Color',BLACK,'VerticalAlignment','middle');
end

% Credit
text(ax,N+0.55,-0.50,'19 interface flows  |  NASA SEBoK methodology', ...
    'HorizontalAlignment','right','FontSize',8,'Color',BLACK,'FontAngle','italic');

exportgraphics(fig, fullfile(OUT,'F4_1_N2_Diagram.png'),'Resolution',300);
close(fig);
fprintf('F4.1 N2 Diagram saved\n\nN2 DIAGRAM COMPLETE (NASA style)\n');
