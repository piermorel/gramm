function stat_bin_1()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x = randn(200, 1);

g23 = gramm('x', x);
g23.stat_bin();
g23.set_title('Basic Histogram');
g23.set_names('x', 'Values', 'y', 'Count');
g23.draw();

export_vega(g23, 'file_name', 'test_stat_bin', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_bin.svg');
g23.export('file_name', svg_filename);
close all;



end
