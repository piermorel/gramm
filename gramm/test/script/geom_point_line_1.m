function geom_point_line_1()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x9 = 1:10;
y9 = x9 + randn(1, 10);

g9 = gramm('x', x9, 'y', y9);
g9.geom_jitter('width', 0, 'height', 0);
g9.geom_line();
g9.set_title('Combined Point and Line');
g9.set_names('x', 'X Values', 'y', 'Y Values');
g9.draw();

export_vega(g9, 'file_name', 'test_combined_point_line', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_combined_point_line.svg');
g9.export('file_name', svg_filename);
close all;



end
