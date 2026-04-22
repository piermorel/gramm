function stat_smooth_1()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x = linspace(0, 4*pi, 100);
y = sin(x) + randn(1, 100)*0.3;

g22 = gramm('x', x, 'y', y);
g22.stat_smooth();
g22.geom_jitter('width', 0, 'height', 0);
g22.set_title('Eilers Smoothing');
g22.set_names('x', 'X Values', 'y', 'Y Values');
g22.draw();

export_vega(g22, 'file_name', 'test_stat_smooth', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_smooth.svg');
g22.export('file_name', svg_filename);
close all;



end
