% setup_gurobi_matlab.m
% Adds the Gurobi MATLAB interface to your path and runs a small LP test.
% Run this ONCE after installing Gurobi.  Re-run if MATLAB ever says
% "Undefined function 'gurobi'".
%
% Expected install path (macOS, Gurobi 13.0.1):
%   /Library/gurobi1301/macos_universal2/matlab
% Edit GRB_DIR below if you installed a different version or path.

clear; clc;

GRB_DIR = '/Library/gurobi1301/macos_universal2/matlab';   % <-- adjust if needed

fprintf('=============================================\n');
fprintf(' Gurobi + MATLAB setup\n');
fprintf('=============================================\n');

if ~exist(GRB_DIR, 'dir')
    error(['Gurobi MATLAB folder not found at:\n  %s\n\n' ...
           'Fix: open Finder, find your Gurobi install, and set GRB_DIR ' ...
           'to the folder that contains gurobi_setup.m.'], GRB_DIR);
end

% Add to path and save permanently
addpath(GRB_DIR);
status = savepath;
if status == 0
    fprintf('Added to MATLAB path (saved permanently): %s\n', GRB_DIR);
else
    warning('Path added for this session but could not be saved. Run MATLAB as admin once, or use pathtool to save.');
end

% Run Gurobi's own setup helper (sets up the library path etc.)
try
    gurobi_setup;
    fprintf('gurobi_setup ran successfully.\n');
catch err
    error('gurobi_setup failed: %s', err.message);
end

% Verify license is picked up from ~/gurobi.lic
licFile = fullfile(getenv('HOME'), 'gurobi.lic');
if ~exist(licFile, 'file')
    warning('No license file at %s — run install_gurobi_license.command first.', licFile);
else
    fprintf('License file found: %s\n', licFile);
end

% ---- Tiny LP sanity test ---------------------------------------------------
% Maximise x + y  s.t. x + 2y <= 4,  3x + y <= 6,  x,y >= 0   (optimum = 2.8)
fprintf('\nRunning LP sanity test (expect obj = 2.8)...\n');

model.A     = sparse([1 2; 3 1]);
model.rhs   = [4; 6];
model.sense = '<<';
model.obj   = [1; 1];
model.modelsense = 'max';
model.vtype = 'CC';
model.lb    = [0; 0];

params.OutputFlag = 0;
res = gurobi(model, params);

fprintf('  Status : %s\n', res.status);
fprintf('  x      = %.4f\n', res.x(1));
fprintf('  y      = %.4f\n', res.x(2));
fprintf('  obj    = %.4f\n', res.objval);

if strcmp(res.status, 'OPTIMAL') && abs(res.objval - 2.8) < 1e-4
    fprintf('\nSUCCESS: Gurobi works from MATLAB.\n');
else
    warning('Solver returned unexpected result — check license / install.');
end
