function stat_qq_1()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x = [randn(50, 1); randn(50, 1) * 2 + 1];
groups = [repmat({'Normal'}, 50, 1); repmat({'Skewed'}, 50, 1)];

g29 = gramm('x', x, 'color', groups);
g29.stat_qq();
g29.set_title('Q-Q Plots');
g29.set_names('x', 'Sample Quantiles', 'y', 'Theoretical Quantiles', 'color', 'Distribution');
g29.draw();

export_vega(g29, 'file_name', 'test_stat_qq', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_qq.svg');
g29.export('file_name', svg_filename);
close all;



end
