function stat_violin_1()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x = repmat({'Low', 'Medium', 'High'}, 1, 50);
y = [randn(1, 50) + 2, randn(1, 50) + 4, randn(1, 50) + 6];

g27 = gramm('x', x, 'y', y);
g27.stat_violin();
g27.set_title('Violin Plots');
g27.set_names('x', 'Categories', 'y', 'Values');
g27.draw();

export_vega(g27, 'file_name', 'test_stat_violin', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_violin.svg');
g27.export('file_name', svg_filename);
close all;



end
