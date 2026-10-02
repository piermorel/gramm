%% Vega export example: stat_bin_1
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
x = randn(200, 1);

g23 = gramm('x', x);
g23.stat_bin();
g23.set_title('Basic Histogram');
g23.set_names('x', 'Values', 'y', 'Count');
g23.draw();

g23.export_vega('file_name', 'test_stat_bin', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_bin.svg');
g23.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
