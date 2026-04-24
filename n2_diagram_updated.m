% =========================================================================
% N² Interface Diagram — Lunar Gateway Supply Chain
% EG7302 MEM Individual Project | Jagathguru Pazhanaivel (249057008)
%
% HOW TO RUN:
%   1. Open MATLAB
%   2. Paste this entire script into a new .m file or the Command Window
%   3. Press Run (F5) — figure opens automatically
%   4. To save as PNG:  exportgraphics(gcf, 'N2_Diagram.png', 'Resolution', 300)
%   5. To save as PDF:  exportgraphics(gcf, 'N2_Diagram.pdf', 'ContentType', 'vector')
%
% Tested on MATLAB R2021b and above. No toolboxes required.
% =========================================================================

clear; clc; close all;

NAVY  = [0  58  112] / 255;
GOLD  = [196 154  42] / 255;
LGRAY = [232 237 242] / 255;
WHITE = [1 1 1];
DGRAY = [74  74  74] / 255;

systems = {
    {'Launch','Vehicle','(LV)'};
    {'Cargo','Integration','(CI)'};
    {'Gateway','Station','(GS)'};
    {'ISRU','Module','(ISRU)'};
    {'Mission','Control','(MC)'};
    {'Supply Chain','Mgmt','(SCM)'};
};
N = numel(systems);

interfaces = cell(N, N);
interfaces{1,2} = {'Payload mass/vol','envelope'};
interfaces{1,3} = {'Trajectory &','delta-V params'};
interfaces{1,5} = {'Launch window','telemetry'};
interfaces{2,1} = {'Cargo mass &','CG data'};
interfaces{2,3} = {'Manifest &','delivery sched.'};
interfaces{2,6} = {'Logistics','requirements'};
interfaces{3,2} = {'Docking confirm','& ICD status'};
interfaces{3,4} = {'Power & thermal','allocation'};
interfaces{3,5} = {'Station health','telemetry'};
interfaces{3,6} = {'Inventory status','& consump.'};
interfaces{4,3} = {'Propellant & O_2','produced'};
interfaces{4,5} = {'ISRU yield &','efficiency data'};
interfaces{5,1} = {'GO/NO-GO','command'};
interfaces{5,3} = {'Ops commands','& alerts'};
interfaces{5,4} = {'ISRU ops','commands'};
interfaces{5,6} = {'Demand forecast','& priority'};
interfaces{6,2} = {'Reorder triggers','& manifest'};
interfaces{6,3} = {'Resupply','request'};
interfaces{6,5} = {'KPI reports &','risk flags'};

fig = figure('Color', 'white', 'Units', 'inches', 'Position', [1 1 13 11]);
ax  = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.08 0.07 0.88 0.84]);
hold(ax, 'on');
axis(ax, 'off');
axis(ax, [0 N 0 N]);
axis(ax, 'equal');
set(ax, 'YDir', 'reverse');

pad = 0.04;
for row = 1:N
    for col = 1:N
        x0 = (col-1) + pad;
        y0 = (row-1) + pad;
        w  = 1 - 2*pad;
        h  = 1 - 2*pad;

        if row == col
            fill(ax, [x0 x0+w x0+w x0], [y0 y0 y0+h y0+h], NAVY, ...
                 'EdgeColor', GOLD, 'LineWidth', 2.5);
            lbl = strjoin(systems{row}, newline);
            text(ax, x0+w/2, y0+h/2, lbl, ...
                 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment',   'middle', ...
                 'FontName',  'Arial', 'FontSize', 7.5, ...
                 'FontWeight', 'bold', 'Color', WHITE, ...
                 'Interpreter', 'none');

        elseif ~isempty(interfaces{row, col})
            fill(ax, [x0 x0+w x0+w x0], [y0 y0 y0+h y0+h], LGRAY, ...
                 'EdgeColor', [0.7 0.8 0.85], 'LineWidth', 0.8);
            lbl = strjoin(interfaces{row, col}, newline);
            text(ax, x0+w/2, y0+h/2, lbl, ...
                 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment',   'middle', ...
                 'FontName', 'Arial', 'FontSize', 5.5, ...
                 'Color', DGRAY, 'Interpreter', 'tex');
        else
            fill(ax, [x0 x0+w x0+w x0], [y0 y0 y0+h y0+h], WHITE, ...
                 'EdgeColor', [0.8 0.8 0.8], 'LineWidth', 0.5);
        end
    end
end

for k = 1:N-1
    x_start = k  - pad;
    y_start = k  - pad;
    x_end   = k  + pad;
    y_end   = k  + pad;
    annotation(fig, 'arrow', ...
        [ax.Position(1) + (x_start/N)*ax.Position(3), ...
         ax.Position(1) + (x_end/N)  *ax.Position(3)], ...
        [ax.Position(2) + (1 - y_start/N)*ax.Position(4), ...
         ax.Position(2) + (1 - y_end/N)  *ax.Position(4)], ...
        'Color', GOLD, 'LineWidth', 1.5, 'HeadStyle', 'vback2', 'HeadSize', 6);
end

for k = 1:N
    text(ax, -0.08, k-0.5, sprintf('R%d', k), ...
         'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle', ...
         'FontName', 'Arial', 'FontSize', 7, 'FontWeight', 'bold', 'Color', NAVY);
    text(ax, k-0.5, -0.08, sprintf('C%d', k), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
         'FontName', 'Arial', 'FontSize', 7, 'FontWeight', 'bold', 'Color', NAVY);
end

title(ax, {'N² Interface Diagram: Lunar Gateway Supply Chain Subsystems'}, ...
      'FontName', 'Arial', 'FontSize', 11, 'FontWeight', 'bold', 'Color', NAVY);

annotation(fig, 'textbox', [0.08 0.01 0.88 0.04], ...
    'String', ['Diagonal: subsystem nodes (Leicester Navy)  |  ' ...
               'Off-diagonal: interface data flows  |  ' ...
               'Read rows as outputs → columns as inputs  |  ' ...
               'Source: Author (2025), EG7302 MEM'], ...
    'FitBoxToText', 'off', 'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center', 'FontName', 'Arial', ...
    'FontSize', 7, 'FontAngle', 'italic', 'Color', [0.4 0.4 0.4]);

fprintf('N2 diagram rendered.\n');
fprintf('To save: exportgraphics(gcf, ''N2_Diagram.png'', ''Resolution'', 300)\n');
