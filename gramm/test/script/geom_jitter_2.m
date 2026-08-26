function geom_jitter_2()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
treatments = repmat({'Control', 'Treatment A', 'Treatment B'}, 1, 25);
responses = [randn(1, 25) + 2, randn(1, 25) + 4, randn(1, 25) + 3.5];

g16 = gramm('x', treatments, 'y', responses, 'color', treatments);
g16.geom_jitter('width', 0.4);
g16.set_title('Interactive Jitter Plot - Filter by Treatment');
g16.set_names('x', 'Treatment', 'y', 'Response', 'color', 'Treatment');
g16.draw();

export_vega(g16, 'file_name', 'test_interactive_jitter', 'export_path', vega_dir, ...
    'interactive', 'true', 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_interactive_jitter.svg');
g16.export('file_name', svg_filename);
close all;



end
