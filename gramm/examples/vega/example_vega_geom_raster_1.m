%% Vega export example: geom_raster_1
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
x_raster = randn(100, 1) * 2;

g8 = gramm('x', x_raster);
g8.geom_raster();
g8.set_title('Strip Plot (Raster)');
g8.set_names('x', 'Values');
g8.draw();

g8.export_vega('file_name', 'test_geom_raster', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_geom_raster.svg');
g8.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
