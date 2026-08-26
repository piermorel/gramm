function geom_point_3()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x_int = randn(80, 1);
y_int = randn(80, 1);
colors_int = repmat({'Red Group', 'Blue Group', 'Green Group', 'Orange Group'}, 1, 20);

g13 = gramm('x', x_int, 'y', y_int, 'color', colors_int);
g13.geom_jitter('width', 0, 'height', 0);
g13.set_title('Interactive Scatter Plot - Click Legend to Filter');
g13.set_names('x', 'X Values', 'y', 'Y Values', 'color', 'Groups');
g13.draw();

export_vega(g13, 'file_name', 'test_interactive_scatter', 'export_path', vega_dir, ...
    'interactive', 'true', 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_interactive_scatter.svg');
g13.export('file_name', svg_filename);
close all;



end
