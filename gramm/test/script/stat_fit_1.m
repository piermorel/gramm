function stat_fit_1()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x = linspace(1, 10, 50);
y = 5./(x+2) + 0.5 + randn(1, 50)*0.05;

g30 = gramm('x', x, 'y', y);
g30.stat_fit('fun', @(a,b,c,x) a./(x+b)+c, 'intopt', 'functional', 'StartPoint', [5 2 0.5]);
g30.geom_jitter('width', 0, 'height', 0);
g30.set_title('Custom Nonlinear Fitting');
g30.draw();

export_vega(g30, 'file_name', 'test_stat_fit', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_fit.svg');
g30.export('file_name', svg_filename);
close all;



end
