function geom_line_3()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x_custom = linspace(0, 4*pi, 100);
y_custom = sin(x_custom) .* exp(-x_custom/10);

g11 = gramm('x', x_custom, 'y', y_custom);
g11.geom_line();
g11.set_title('Damped Sine Wave');
g11.set_names('x', 'Time (s)', 'y', 'Amplitude');
g11.draw();

export_vega(g11, 'file_name', 'test_custom_params', 'export_path', vega_dir, ...
    'title', 'Damped Sine Wave', 'x', 'Time (s)', 'y', 'Amplitude', ...
    'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_custom_params.svg');
g11.export('file_name', svg_filename);
close all;



end
