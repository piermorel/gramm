%% Vega export example: geom_line_3
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
x_custom = linspace(0, 4*pi, 100);
y_custom = sin(x_custom) .* exp(-x_custom/10);

g11 = gramm('x', x_custom, 'y', y_custom);
g11.geom_line();
g11.set_title('Damped Sine Wave');
g11.set_names('x', 'Time (s)', 'y', 'Amplitude');
g11.draw();

g11.export_vega('file_name', 'test_custom_params', 'export_path', vega_dir, ...
    'title', 'Damped Sine Wave', 'x', 'Time (s)', 'y', 'Amplitude', ...
    'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_custom_params.svg');
g11.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
