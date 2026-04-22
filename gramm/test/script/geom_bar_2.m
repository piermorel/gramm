function geom_bar_2()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x_bars = repmat([1, 2, 3, 4], 1, 3);
y_bars = [10, 15, 12, 18, 8, 20, 14, 22, 16, 25, 11, 19];
bar_groups = [repmat(4,1,4), repmat(6,1,4), repmat(8,1,4)];

g6 = gramm('x', x_bars, 'y', y_bars, 'color', bar_groups);
g6.geom_bar('dodge', 0.6);
g6.set_title('Grouped Bar Chart');
g6.set_names('x', 'Position', 'y', 'Value', 'color', 'Group');
g6.draw();

export_vega(g6, 'file_name', 'test_geom_bar_groups', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_geom_bar_groups.svg');
g6.export('file_name', svg_filename);
close all;



end
