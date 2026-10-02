%% Vega export example: stat_ellipse_1
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
x = [randn(50, 1); randn(50, 1) + 3];
y = [randn(50, 1); randn(50, 1) + 2];
groups = [repmat({'Cluster A'}, 50, 1); repmat({'Cluster B'}, 50, 1)];

g32 = gramm('x', x, 'y', y, 'color', groups);
g32.stat_ellipse();
g32.geom_jitter('width', 0, 'height', 0);
g32.set_title('Confidence Ellipses');
g32.draw();

g32.export_vega('file_name', 'test_stat_ellipse', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_ellipse.svg');
g32.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
