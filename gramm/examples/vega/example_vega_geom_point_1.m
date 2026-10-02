%% Vega export example: geom_point_1
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
x1 = randn(50, 1);
y1 = randn(50, 1);

g1 = gramm('x', x1, 'y', y1);
g1.geom_point();
g1.set_title('Basic Scatter Plot');
g1.set_names('x', 'X Values', 'y', 'Y Values');
g1.draw();

g1.export_vega('file_name', 'test_geom_point', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_geom_point.svg');
g1.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
