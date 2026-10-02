%% Vega export example: stat_glm_1
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
x = linspace(0, 10, 50);
y = 2*x + randn(1, 50)*2;

g20 = gramm('x', x, 'y', y);
g20.stat_glm();
g20.geom_jitter('width', 0, 'height', 0);
g20.set_title('Linear Regression (GLM)');
g20.set_names('x', 'X Values', 'y', 'Y Values');
g20.draw();

g20.export_vega('file_name', 'test_stat_glm', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_glm.svg');
g20.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
