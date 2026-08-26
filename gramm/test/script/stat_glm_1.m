function stat_glm_1()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x = linspace(0, 10, 50);
y = 2*x + randn(1, 50)*2;

g20 = gramm('x', x, 'y', y);
g20.stat_glm();
g20.geom_jitter('width', 0, 'height', 0);
g20.set_title('Linear Regression (GLM)');
g20.set_names('x', 'X Values', 'y', 'Y Values');
g20.draw();

export_vega(g20, 'file_name', 'test_stat_glm', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_glm.svg');
g20.export('file_name', svg_filename);
close all;



end
