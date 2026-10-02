%% Vega export example: geom_bar_1
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
categories = {'A', 'B', 'C', 'D', 'E'};
values = [23, 45, 56, 78, 32];

g5 = gramm('x', categories, 'y', values);
g5.geom_bar();
g5.set_title('Categorical Bar Chart');
g5.set_names('x', 'Category', 'y', 'Count');
g5.draw();

g5.export_vega('file_name', 'test_geom_bar_categorical', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_geom_bar_categorical.svg');
g5.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
