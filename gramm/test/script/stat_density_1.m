function stat_density_1()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x = [randn(100, 1); randn(100, 1) + 3];
groups = [repmat({'Group A'}, 100, 1); repmat({'Group B'}, 100, 1)];

g26 = gramm('x', x, 'color', groups);
g26.stat_density();
g26.set_title('Kernel Density');
g26.set_names('x', 'Values', 'y', 'Density', 'color', 'Groups');
g26.draw();

export_vega(g26, 'file_name', 'test_stat_density', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_density.svg');
g26.export('file_name', svg_filename);
close all;



end
