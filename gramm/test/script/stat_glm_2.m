function stat_glm_2()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x = repmat(linspace(0, 10, 25), 1, 2);
y = [2*linspace(0, 10, 25) + randn(1, 25)*2, 3*linspace(0, 10, 25) + randn(1, 25)*2];
groups = [repmat({'Group A'}, 1, 25), repmat({'Group B'}, 1, 25)];

g21 = gramm('x', x, 'y', y, 'color', groups);
g21.stat_glm();
g21.geom_jitter('width', 0, 'height', 0);
g21.set_title('Multi-Group GLM');
g21.set_names('x', 'X Values', 'y', 'Y Values', 'color', 'Groups');
g21.draw();

export_vega(g21, 'file_name', 'test_stat_glm_groups', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_glm_groups.svg');
g21.export('file_name', svg_filename);
close all;



end
