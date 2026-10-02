%% Vega export example: stat_violin_1
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
x = repmat({'Low', 'Medium', 'High'}, 1, 50);
y = [randn(1, 50) + 2, randn(1, 50) + 4, randn(1, 50) + 6];

g27 = gramm('x', x, 'y', y);
g27.stat_violin();
g27.set_title('Violin Plots');
g27.set_names('x', 'Categories', 'y', 'Values');
g27.draw();

g27.export_vega('file_name', 'test_stat_violin', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_violin.svg');
g27.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
