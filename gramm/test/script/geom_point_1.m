function geom_point_1()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x1 = randn(50, 1);
y1 = randn(50, 1);

g1 = gramm('x', x1, 'y', y1);
g1.geom_jitter('width', 0, 'height', 0);
g1.set_title('Basic Scatter Plot');
g1.set_names('x', 'X Values', 'y', 'Y Values');
g1.draw();

export_vega(g1, 'file_name', 'test_geom_point', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_geom_point.svg');
g1.export('file_name', svg_filename);
close all;



end
