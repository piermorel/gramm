%% Vega export example: geom_jitter_1
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
categories_jitter = repmat({'Low', 'Medium', 'High'}, 1, 20);
values_jitter = [randn(1, 20) + 1, randn(1, 20) + 3, randn(1, 20) + 5];

g7 = gramm('x', categories_jitter, 'y', values_jitter);
g7.geom_jitter('width', 0.3);
g7.set_title('Jittered Points');
g7.set_names('x', 'Category', 'y', 'Value');
g7.draw();

g7.export_vega('file_name', 'test_geom_jitter', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_geom_jitter.svg');
g7.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
