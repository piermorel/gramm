%% Vega export example: geom_line_2
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
n = 15;
x = repmat(1:n, 1, 3);
y = [cumsum(randn(1,n)), cumsum(randn(1,n)) + 2, cumsum(randn(1,n)) - 1];
groups = [repmat(4,1,n), repmat(6,1,n), repmat(8,1,n)];

g = gramm('x', x, 'y', y, 'color', groups);
g.geom_line();
g.set_title('Multi-Series Line Chart');
g.set_names('x', 'Time', 'y', 'Value', 'color', 'Series');
g.draw();

g.export_vega('file_name', 'test_geom_line_multi', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_geom_line_multi.svg');
g.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
