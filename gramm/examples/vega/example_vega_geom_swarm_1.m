%% Vega export example: geom_swarm_1
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
groups_swarm = repmat({'Group A', 'Group B', 'Group C'}, 1, 15);
values_swarm = [randn(1, 15) + 2, randn(1, 15) + 4, randn(1, 15) + 6];

g12 = gramm('x', groups_swarm, 'y', values_swarm);
g12.geom_swarm();
g12.set_title('Beeswarm Plot');
g12.set_names('x', 'Group', 'y', 'Value');
g12.draw();

g12.export_vega('file_name', 'test_geom_swarm', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_geom_swarm.svg');
g12.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
