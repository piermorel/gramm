function geom_line_1()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x3 = 1:20;
y3 = cumsum(randn(1, 20));

g3 = gramm('x', x3, 'y', y3);
g3.geom_line();
g3.set_title('Basic Line Chart');
g3.set_names('x', 'Time', 'y', 'Value');
g3.draw();

export_vega(g3, 'file_name', 'test_geom_line', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_geom_line.svg');
g3.export('file_name', svg_filename);
close all;



end
