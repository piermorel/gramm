function geom_point_4()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x_std = randn(75, 1);
y_std = randn(75, 1);
groups_std = repmat({'Alpha', 'Beta', 'Gamma'}, 1, 25);

g17 = gramm('x', x_std, 'y', y_std, 'color', groups_std);
g17.geom_jitter('width', 0, 'height', 0);
g17.set_title('Standard Legend (Non-Interactive)');
g17.set_names('x', 'X Values', 'y', 'Y Values', 'color', 'Groups');
g17.draw();

export_vega(g17, 'file_name', 'test_standard_legend', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_standard_legend.svg');
g17.export('file_name', svg_filename);
close all;



end
