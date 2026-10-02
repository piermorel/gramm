%% Vega export example: stat_density_1
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
x = [randn(100, 1); randn(100, 1) + 3];
groups = [repmat({'Group A'}, 100, 1); repmat({'Group B'}, 100, 1)];

g26 = gramm('x', x, 'color', groups);
g26.stat_density();
g26.set_title('Kernel Density');
g26.set_names('x', 'Values', 'y', 'Density', 'color', 'Groups');
g26.draw();

g26.export_vega('file_name', 'test_stat_density', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_density.svg');
g26.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
