%% Vega export example: geom_point_line_2
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
x_nan = 1:15;
y_nan = [1, 2, NaN, 4, 5, NaN, 7, 8, 9, NaN, 11, 12, 13, 14, 15];

g10 = gramm('x', x_nan, 'y', y_nan);
g10.geom_point();
g10.geom_line();
g10.set_title('Data with NaN Values');
g10.set_names('x', 'Index', 'y', 'Value');
g10.draw();

g10.export_vega('file_name', 'test_nan_handling', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_nan_handling.svg');
g10.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
