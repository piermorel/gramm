%% Vega export example: stat_smooth_1
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
x = linspace(0, 4*pi, 100);
y = sin(x) + randn(1, 100)*0.3;

g22 = gramm('x', x, 'y', y);
g22.stat_smooth();
g22.geom_jitter('width', 0, 'height', 0);
g22.set_title('Eilers Smoothing');
g22.set_names('x', 'X Values', 'y', 'Y Values');
g22.draw();

g22.export_vega('file_name', 'test_stat_smooth', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_smooth.svg');
g22.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
