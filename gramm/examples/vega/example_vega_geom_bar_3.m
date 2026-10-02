%% Vega export example: geom_bar_3
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
quarters = repmat({'Q1', 'Q2', 'Q3', 'Q4'}, 1, 3);
revenues = [120, 150, 180, 200, 80, 95, 110, 125, 60, 70, 85, 90];
divisions = repmat({'North', 'South', 'West'}, 1, 4);

g15 = gramm('x', quarters, 'y', revenues, 'color', divisions);
g15.geom_bar('dodge', 0.6);
g15.set_title('Interactive Grouped Bars - Legend Controls Visibility');
g15.set_names('x', 'Quarter', 'y', 'Revenue (K)', 'color', 'Division');
g15.draw();

g15.export_vega('file_name', 'test_interactive_bars', 'export_path', vega_dir, ...
    'interactive', 'true', 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_interactive_bars.svg');
g15.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
