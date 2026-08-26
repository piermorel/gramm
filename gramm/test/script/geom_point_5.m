function geom_point_5()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x_demo = randn(100, 1);
y_demo = randn(100, 1);
demo_groups = repmat({'Click Me', 'Shift+Click', 'Multi-Select', 'Reset'}, 1, 25);

g18 = gramm('x', x_demo, 'y', y_demo, 'color', demo_groups);
g18.geom_jitter('width', 0, 'height', 0);
g18.set_title('Interactive Legend Demo - Click & Shift+Click');
g18.set_names('x', 'X Values', 'y', 'Y Values', 'color', 'Interactive Groups');
g18.draw();

export_vega(g18, 'file_name', 'test_interactive_legend', 'export_path', vega_dir, ...
    'interactive', 'true', 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_interactive_legend.svg');
g18.export('file_name', svg_filename);
close all;



end
