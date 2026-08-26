function stat_boxplot_1()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x = repmat({'A', 'B', 'C', 'D'}, 1, 25);
y = [randn(1, 25) + 1, randn(1, 25) + 3, randn(1, 25) + 5, randn(1, 25) + 7];

g28 = gramm('x', x, 'y', y);
g28.stat_boxplot();
g28.set_title('Box Plots');
g28.set_names('x', 'Categories', 'y', 'Values');
g28.draw();

export_vega(g28, 'file_name', 'test_stat_boxplot', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_boxplot.svg');
g28.export('file_name', svg_filename);
close all;



end
