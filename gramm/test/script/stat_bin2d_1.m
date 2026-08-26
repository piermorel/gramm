function stat_bin2d_1()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x = randn(200, 1);
y = x + randn(200, 1);

g31 = gramm('x', x, 'y', y);
g31.stat_bin2d();
g31.set_title('2D Histograms');
g31.draw();

export_vega(g31, 'file_name', 'test_stat_bin2d', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_bin2d.svg');
g31.export('file_name', svg_filename);
close all;



end
