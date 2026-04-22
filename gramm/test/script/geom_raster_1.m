function geom_raster_1()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
x_raster = randn(100, 1) * 2;

g8 = gramm('x', x_raster);
g8.geom_raster();
g8.set_title('Strip Plot (Raster)');
g8.set_names('x', 'Values');
g8.draw();

export_vega(g8, 'file_name', 'test_geom_raster', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_geom_raster.svg');
g8.export('file_name', svg_filename);
close all;



end
