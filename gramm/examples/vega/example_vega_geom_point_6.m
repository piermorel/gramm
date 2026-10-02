%% Vega export example: geom_point_6
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
x_large = randn(500, 1);
y_large = randn(500, 1);
large_groups = repmat({'Dataset A', 'Dataset B', 'Dataset C', 'Dataset D', 'Dataset E'}, 1, 100);

g19 = gramm('x', x_large, 'y', y_large, 'color', large_groups);
g19.geom_point();
g19.set_title('Large Dataset Interactive Test - 500 Points');
g19.set_names('x', 'X Values', 'y', 'Y Values', 'color', 'Datasets');
g19.draw();

g19.export_vega('file_name', 'test_large_interactive', 'export_path', vega_dir, ...
    'interactive', 'true', 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_large_interactive.svg');
g19.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
