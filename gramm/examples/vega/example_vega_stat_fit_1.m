%% Vega export example: stat_fit_1
% Independent Vega export smoke test.
% <../../../../build/vega/index.html Compare MATLAB SVG and interactive Vega outputs>
original_rng = rng;
cleanup_rng = onCleanup(@() rng(original_rng)); %#ok<NASGU>
rng(0, 'twister');
cleanup_figures = onCleanup(@() close('all')); %#ok<NASGU>
repository_root = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
support_dir = fullfile(repository_root, 'buildutils', 'vega');
original_path = path;
cleanup_path = onCleanup(@() path(original_path)); %#ok<NASGU>
addpath(support_dir, fullfile(repository_root, 'gramm'));
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x = linspace(1, 10, 50);
y = 5./(x+2) + 0.5 + randn(1, 50)*0.05;

g30 = gramm('x', x, 'y', y);
g30.stat_fit('fun', @(a,b,c,x) a./(x+b)+c, 'intopt', 'functional', 'StartPoint', [5 2 0.5]);
g30.geom_jitter('width', 0, 'height', 0);
g30.set_title('Custom Nonlinear Fitting');
g30.draw();

g30.export_vega('file_name', 'test_stat_fit', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_fit.svg');
g30.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
