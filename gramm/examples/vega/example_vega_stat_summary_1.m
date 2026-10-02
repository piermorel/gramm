%% Vega export example: stat_summary_1
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
x = repmat({'A', 'B', 'C'}, 1, 30);
y = [randn(1, 30) + 2, randn(1, 30) + 4, randn(1, 30) + 6];

g25 = gramm('x', x, 'y', y);
g25.stat_summary('type', 'sem');
g25.set_title('Statistical Summary');
g25.set_names('x', 'Categories', 'y', 'Values');
g25.draw();

g25.export_vega('file_name', 'test_stat_summary', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_summary.svg');
g25.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
