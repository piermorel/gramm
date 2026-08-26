function geom_bar_3()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
quarters = repmat({'Q1', 'Q2', 'Q3', 'Q4'}, 1, 3);
revenues = [120, 150, 180, 200, 80, 95, 110, 125, 60, 70, 85, 90];
divisions = repmat({'North', 'South', 'West'}, 1, 4);

g15 = gramm('x', quarters, 'y', revenues, 'color', divisions);
g15.geom_bar('dodge', 0.6);
g15.set_title('Interactive Grouped Bars - Legend Controls Visibility');
g15.set_names('x', 'Quarter', 'y', 'Revenue (K)', 'color', 'Division');
g15.draw();

export_vega(g15, 'file_name', 'test_interactive_bars', 'export_path', vega_dir, ...
    'interactive', 'true', 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_interactive_bars.svg');
g15.export('file_name', svg_filename);
close all;



end
