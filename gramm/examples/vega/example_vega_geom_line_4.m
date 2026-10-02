%% Vega export example: geom_line_4
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
x_lines = repmat(1:20, 1, 4);
y_lines = [];
line_groups = [];
group_names = {'Sales', 'Marketing', 'Engineering', 'Support'};

for i = 1:4
    y_lines = [y_lines, cumsum(randn(1, 20)) + i*5];
    line_groups = [line_groups, repmat(group_names(i), 1, 20)];
end

g14 = gramm('x', x_lines, 'y', y_lines, 'color', line_groups);
g14.geom_line();
g14.set_title('Interactive Multi-Series Lines - Click Legend to Highlight');
g14.set_names('x', 'Time Period', 'y', 'Performance Score', 'color', 'Department');
g14.draw();

g14.export_vega('file_name', 'test_interactive_lines', 'export_path', vega_dir, ...
    'interactive', 'true', 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_interactive_lines.svg');
g14.export('file_name', svg_filename);
validate_test_outputs(vega_dir, svg_filename);
close all;
