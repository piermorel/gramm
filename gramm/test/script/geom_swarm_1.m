function geom_swarm_1()
% Auto-generated test case from doc/generate_all_outputs.m
[vega_dir, svg_dir] = test_output_dirs();

figure('Visible', 'off');
groups_swarm = repmat({'Group A', 'Group B', 'Group C'}, 1, 15);
values_swarm = [randn(1, 15) + 2, randn(1, 15) + 4, randn(1, 15) + 6];

g12 = gramm('x', groups_swarm, 'y', values_swarm);
g12.geom_swarm();
g12.set_title('Beeswarm Plot');
g12.set_names('x', 'Group', 'y', 'Value');
g12.draw();

export_vega(g12, 'file_name', 'test_geom_swarm', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_geom_swarm.svg');
g12.export('file_name', svg_filename);
close all;



end
