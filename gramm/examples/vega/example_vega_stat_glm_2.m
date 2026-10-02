%% Vega export example: stat_glm_2
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
x = repmat(linspace(0, 10, 25), 1, 2);
y = [2*linspace(0, 10, 25) + randn(1, 25)*2, 3*linspace(0, 10, 25) + randn(1, 25)*2];
groups = [repmat({'Group A'}, 1, 25), repmat({'Group B'}, 1, 25)];

g21 = gramm('x', x, 'y', y, 'color', groups);
g21.stat_glm();
g21.geom_jitter('width', 0, 'height', 0);
g21.set_title('Multi-Group GLM');
g21.set_names('x', 'X Values', 'y', 'Y Values', 'color', 'Groups');
g21.draw();

g21.export_vega('file_name', 'test_stat_glm_groups', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_glm_groups.svg');
g21.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
