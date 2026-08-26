function stat_summary_1()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x = repmat({'A', 'B', 'C'}, 1, 30);
y = [randn(1, 30) + 2, randn(1, 30) + 4, randn(1, 30) + 6];

g25 = gramm('x', x, 'y', y);
g25.stat_summary('type', 'sem');
g25.set_title('Statistical Summary');
g25.set_names('x', 'Categories', 'y', 'Values');
g25.draw();

export_vega(g25, 'file_name', 'test_stat_summary', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_summary.svg');
g25.export('file_name', svg_filename);
close all;



end
