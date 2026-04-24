% mission_cost_comparison.m
% Replicates the Mission Cost vs Launch Cost comparison plot
% ISRU vs Earth-Based supply, with baseline at $5000/kg
%
% Just run this file in MATLAB (or Octave) to generate the figure.

clear; clc; close all;

%% ---------- Data ----------
launch_cost = 1000:1000:10000;                 % $/kg

% Linear cost models (fit to the reference chart)
isru_cost       = 0.31 + 0.00009  * launch_cost;   % $B
earth_cost      = 0.75 + 0.000347 * launch_cost;   % $B

baseline_x = 5000;                              % $/kg baseline

%% ---------- Figure ----------
fig = figure('Color','w','Position',[100 100 900 500]);
hold on; box on; grid on;

% Shaded cost-difference region (Earth-Based > ISRU)
x_fill = [launch_cost, fliplr(launch_cost)];
y_fill = [earth_cost,  fliplr(isru_cost)];
hFill  = fill(x_fill, y_fill, [1.0 0.85 0.88], ...
              'EdgeColor','none', 'FaceAlpha',0.55);

% ISRU line
hISRU = plot(launch_cost, isru_cost, '-o', ...
             'Color',[0.10 0.25 0.85], ...
             'MarkerFaceColor',[0.10 0.25 0.85], ...
             'MarkerSize',5, 'LineWidth',1.6);

% Earth-Based line
hEarth = plot(launch_cost, earth_cost, '-s', ...
              'Color',[0.10 0.55 0.20], ...
              'MarkerFaceColor',[0.10 0.55 0.20], ...
              'MarkerSize',5, 'LineWidth',1.6);

% Baseline vertical dashed line
yl = [0 4.5];
plot([baseline_x baseline_x], yl, '--k', 'LineWidth',1.2);
text(baseline_x + 80, 4.25, 'Baseline', ...
     'FontSize',10, 'FontWeight','normal');

%% ---------- Axes / Labels ----------
xlabel('Launch Cost, $/kg');
ylabel('Mission Cost, $B');
xlim([1000 10000]);
ylim(yl);
xticks(1000:1000:10000);
yticks(0:0.5:4.5);
set(gca,'FontSize',11,'GridAlpha',0.25,'Layer','top');

%% ---------- Legend ----------
legend([hISRU, hEarth, hFill], ...
       {'ISRU','Earth-Based','Cost Difference (Earth-Based > ISRU)'}, ...
       'Location','northwest','FontSize',10,'Box','on');

hold off;

%% ---------- Save to PNG next to the script ----------
outFile = fullfile(fileparts(mfilename('fullpath')), 'mission_cost_comparison.png');
try
    exportgraphics(fig, outFile, 'Resolution', 200);
    fprintf('Saved figure to: %s\n', outFile);
catch
    % Fallback for older MATLAB / Octave
    print(fig, outFile, '-dpng', '-r200');
    fprintf('Saved figure to: %s\n', outFile);
end
