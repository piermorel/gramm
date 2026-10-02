%% Vega export example: geom_point_2
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
x2 = randn(60, 1);
y2 = randn(60, 1);
colors = repmat([4, 6, 8], 1, 20);

g2 = gramm('x', x2, 'y', y2, 'color', colors);
g2.geom_point();
g2.set_title('Scatter Plot with Color Groups');
g2.set_names('x', 'X Values', 'y', 'Y Values', 'color', 'Group');
g2.draw();

g2.export_vega('file_name', 'test_geom_point_colors', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_geom_point_colors.svg');
g2.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
