%% Vega export example: geom_point_4
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
x_std = randn(75, 1);
y_std = randn(75, 1);
groups_std = repmat({'Alpha', 'Beta', 'Gamma'}, 1, 25);

g17 = gramm('x', x_std, 'y', y_std, 'color', groups_std);
g17.geom_point();
g17.set_title('Standard Legend (Non-Interactive)');
g17.set_names('x', 'X Values', 'y', 'Y Values', 'color', 'Groups');
g17.draw();

g17.export_vega('file_name', 'test_standard_legend', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_standard_legend.svg');
g17.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
