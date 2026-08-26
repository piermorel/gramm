function stat_bin_2()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x = [randn(100, 1); randn(100, 1) + 2];
groups = [repmat({'Group A'}, 100, 1); repmat({'Group B'}, 100, 1)];

g24 = gramm('x', x, 'color', groups);
g24.stat_bin();
g24.set_title('Grouped Histogram');
g24.set_names('x', 'Values', 'y', 'Count', 'color', 'Groups');
g24.draw();

export_vega(g24, 'file_name', 'test_stat_bin_groups', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_bin_groups.svg');
g24.export('file_name', svg_filename);
close all;



end
