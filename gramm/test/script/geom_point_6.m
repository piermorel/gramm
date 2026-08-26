function geom_point_6()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x_large = randn(500, 1);
y_large = randn(500, 1);
large_groups = repmat({'Dataset A', 'Dataset B', 'Dataset C', 'Dataset D', 'Dataset E'}, 1, 100);

g19 = gramm('x', x_large, 'y', y_large, 'color', large_groups);
g19.geom_jitter('width', 0, 'height', 0);
g19.set_title('Large Dataset Interactive Test - 500 Points');
g19.set_names('x', 'X Values', 'y', 'Y Values', 'color', 'Datasets');
g19.draw();

export_vega(g19, 'file_name', 'test_large_interactive', 'export_path', vega_dir, ...
    'interactive', 'true', 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_large_interactive.svg');
g19.export('file_name', svg_filename);
close all;



end
