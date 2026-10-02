%% Vega export example: geom_point_3
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
x_int = randn(80, 1);
y_int = randn(80, 1);
colors_int = repmat({'Red Group', 'Blue Group', 'Green Group', 'Orange Group'}, 1, 20);

g13 = gramm('x', x_int, 'y', y_int, 'color', colors_int);
g13.geom_point();
g13.set_title('Interactive Scatter Plot - Click Legend to Filter');
g13.set_names('x', 'X Values', 'y', 'Y Values', 'color', 'Groups');
g13.draw();

g13.export_vega('file_name', 'test_interactive_scatter', 'export_path', vega_dir, ...
    'interactive', 'true', 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_interactive_scatter.svg');
g13.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
