%% Vega export example: geom_jitter_2
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
treatments = repmat({'Control', 'Treatment A', 'Treatment B'}, 1, 25);
responses = [randn(1, 25) + 2, randn(1, 25) + 4, randn(1, 25) + 3.5];

g16 = gramm('x', treatments, 'y', responses, 'color', treatments);
g16.geom_jitter('width', 0.4);
g16.set_title('Interactive Jitter Plot - Filter by Treatment');
g16.set_names('x', 'Treatment', 'y', 'Response', 'color', 'Treatment');
g16.draw();

g16.export_vega('file_name', 'test_interactive_jitter', 'export_path', vega_dir, ...
    'interactive', 'true', 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_interactive_jitter.svg');
g16.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
