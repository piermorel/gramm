%% Vega export example: stat_bin_3
% Independent Vega export smoke test.
% <../../../../build/vega/index.html Compare MATLAB SVG and interactive Vega outputs>
original_rng = rng;
cleanup_rng = onCleanup(@() rng(original_rng)); %#ok<NASGU>
rng(0, 'twister');
cleanup_figures = onCleanup(@() close('all')); %#ok<NASGU>
repository_root = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
support_dir = fullfile(repository_root, 'buildutils', 'vega');
original_path = path;
cleanup_path = onCleanup(@() path(original_path)); %#ok<NASGU>
addpath(support_dir, fullfile(repository_root, 'gramm'));
[vega_dir, svg_dir] = test_output_dirs();

x = randn(1200, 1) - 1;
cat = repmat([1 1 1 2], 300, 1);
cat = cat(:);
x(cat == 2) = x(cat == 2) + 2;

geom_options = {'bar', 'stacked_bar', 'line', 'overlaid_bar', 'point', 'stairs'};
file_suffix = {'bar', 'stacked_bar', 'line', 'overlaid_bar', 'point', 'stairs'};

for i = 1:numel(geom_options)
    figure('Visible', 'off');
    geom_option = geom_options{i};
    
    g = gramm('x', x, 'color', cat);
    if strcmp(geom_option, 'bar')
        g.stat_bin();
    else
        g.stat_bin('geom', geom_option);
    end
    
    g.set_title(sprintf('Grouped Histogram (''%s'')', geom_option));
    g.set_names('x', 'x', 'y', 'count', 'color', 'Color');
    g.draw();
    
    file_stem = sprintf('test_stat_bin_groups_%s', file_suffix{i});
    g.export_vega('file_name', file_stem, 'export_path', vega_dir, 'width', '400', 'height', '300');
    
    svg_filename = fullfile(svg_dir, [file_stem '.svg']);
    g.export('file_name', svg_filename);
    validate_test_outputs(vega_dir, svg_filename);
    close all;
end
