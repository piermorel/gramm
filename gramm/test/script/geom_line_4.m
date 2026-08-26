function geom_line_4()
% Auto-generated test case from doc/generate_all_outputs.m
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

export_vega(g14, 'file_name', 'test_interactive_lines', 'export_path', vega_dir, ...
    'interactive', 'true', 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_interactive_lines.svg');
g14.export('file_name', svg_filename);
close all;



end
