function geom_jitter_1()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
categories_jitter = repmat({'Low', 'Medium', 'High'}, 1, 20);
values_jitter = [randn(1, 20) + 1, randn(1, 20) + 3, randn(1, 20) + 5];

g7 = gramm('x', categories_jitter, 'y', values_jitter);
g7.geom_jitter('width', 0.3);
g7.set_title('Jittered Points');
g7.set_names('x', 'Category', 'y', 'Value');
g7.draw();

export_vega(g7, 'file_name', 'test_geom_jitter', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_geom_jitter.svg');
g7.export('file_name', svg_filename);
close all;



end
