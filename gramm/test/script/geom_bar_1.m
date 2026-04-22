function geom_bar_1()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
categories = {'A', 'B', 'C', 'D', 'E'};
values = [23, 45, 56, 78, 32];

g5 = gramm('x', categories, 'y', values);
g5.geom_bar();
g5.set_title('Categorical Bar Chart');
g5.set_names('x', 'Category', 'y', 'Count');
g5.draw();

export_vega(g5, 'file_name', 'test_geom_bar_categorical', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_geom_bar_categorical.svg');
g5.export('file_name', svg_filename);
close all;



end
