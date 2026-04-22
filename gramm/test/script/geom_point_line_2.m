function geom_point_line_2()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x_nan = 1:15;
y_nan = [1, 2, NaN, 4, 5, NaN, 7, 8, 9, NaN, 11, 12, 13, 14, 15];

g10 = gramm('x', x_nan, 'y', y_nan);
g10.geom_jitter('width', 0, 'height', 0);
g10.geom_line();
g10.set_title('Data with NaN Values');
g10.set_names('x', 'Index', 'y', 'Value');
g10.draw();

export_vega(g10, 'file_name', 'test_nan_handling', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_nan_handling.svg');
g10.export('file_name', svg_filename);
close all;



end
