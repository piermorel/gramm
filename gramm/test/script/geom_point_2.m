function geom_point_2()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x2 = randn(60, 1);
y2 = randn(60, 1);
colors = repmat([4, 6, 8], 1, 20);

g2 = gramm('x', x2, 'y', y2, 'color', colors);
g2.geom_jitter('width', 0, 'height', 0);
g2.set_title('Scatter Plot with Color Groups');
g2.set_names('x', 'X Values', 'y', 'Y Values', 'color', 'Group');
g2.draw();

export_vega(g2, 'file_name', 'test_geom_point_colors', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_geom_point_colors.svg');
g2.export('file_name', svg_filename);
close all;



end
