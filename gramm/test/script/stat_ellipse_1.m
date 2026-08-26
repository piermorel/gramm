function stat_ellipse_1()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x = [randn(50, 1); randn(50, 1) + 3];
y = [randn(50, 1); randn(50, 1) + 2];
groups = [repmat({'Cluster A'}, 50, 1); repmat({'Cluster B'}, 50, 1)];

g32 = gramm('x', x, 'y', y, 'color', groups);
g32.stat_ellipse();
g32.geom_jitter('width', 0, 'height', 0);
g32.set_title('Confidence Ellipses');
g32.draw();

export_vega(g32, 'file_name', 'test_stat_ellipse', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_ellipse.svg');
g32.export('file_name', svg_filename);
close all;



end
