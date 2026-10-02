%% Vega export example: geom_point_line_1
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
x9 = 1:10;
y9 = x9 + randn(1, 10);

g9 = gramm('x', x9, 'y', y9);
g9.geom_point();
g9.geom_line();
g9.set_title('Combined Point and Line');
g9.set_names('x', 'X Values', 'y', 'Y Values');
g9.draw();

g9.export_vega('file_name', 'test_combined_point_line', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_combined_point_line.svg');
g9.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
