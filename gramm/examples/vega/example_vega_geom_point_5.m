%% Vega export example: geom_point_5
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
x_demo = randn(100, 1);
y_demo = randn(100, 1);
demo_groups = repmat({'Click Me', 'Shift+Click', 'Multi-Select', 'Reset'}, 1, 25);

g18 = gramm('x', x_demo, 'y', y_demo, 'color', demo_groups);
g18.geom_point();
g18.set_title('Interactive Legend Demo - Click & Shift+Click');
g18.set_names('x', 'X Values', 'y', 'Y Values', 'color', 'Interactive Groups');
g18.draw();

g18.export_vega('file_name', 'test_interactive_legend', 'export_path', vega_dir, ...
    'interactive', 'true', 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_interactive_legend.svg');
g18.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
