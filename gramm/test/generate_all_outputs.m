%% Complete Gramm Test Suite - SVG and Vega Export
% Runs all tests in doc/test and generates SVG and Vega outputs.

clear; clc; close all;

doc_dir = fileparts(mfilename('fullpath'));
test_dir = fullfile(doc_dir, 'script');

if ~exist(test_dir, 'dir')
    error('Test directory not found: %s', test_dir);
end

addpath(test_dir);
cleanup_path = onCleanup(@() rmpath(test_dir)); %#ok<NASGU>

tests = {
    'geom_point_1',      'test_geom_point.svg',            'Basic Scatter Plot';
    'geom_point_2',      'test_geom_point_colors.svg',     'Scatter Plot with Color Groups';
    'geom_line_1',       'test_geom_line.svg',             'Basic Line Chart';
    'geom_line_2',       'test_geom_line_multi.svg',       'Multi-Series Line Chart';
    'geom_bar_1',        'test_geom_bar_categorical.svg',  'Categorical Bar Chart';
    'geom_bar_2',        'test_geom_bar_groups.svg',       'Grouped Bar Chart';
    'geom_jitter_1',     'test_geom_jitter.svg',           'Jittered Points';
    'geom_raster_1',     'test_geom_raster.svg',           'Strip Plot (Raster)';
    'geom_point_line_1', 'test_combined_point_line.svg',   'Combined Point and Line';
    'geom_point_line_2', 'test_nan_handling.svg',          'Data with NaN Values';
    'geom_line_3',       'test_custom_params.svg',         'Custom Export Parameters';
    'geom_swarm_1',      'test_geom_swarm.svg',            'Beeswarm Plot';
    'geom_point_3',      'test_interactive_scatter.svg',   'Interactive Scatter Plot';
    'geom_line_4',       'test_interactive_lines.svg',     'Interactive Multi-Series Lines';
    'geom_bar_3',        'test_interactive_bars.svg',      'Interactive Grouped Bars';
    'geom_jitter_2',     'test_interactive_jitter.svg',    'Interactive Jitter Plot';
    'geom_point_4',      'test_standard_legend.svg',       'Standard Legend (Non-Interactive)';
    'geom_point_5',      'test_interactive_legend.svg',    'Interactive Legend Demo';
    'geom_point_6',      'test_large_interactive.svg',     'Large Dataset Interactive Test';
    'stat_glm_1',        'test_stat_glm.svg',              'Linear Regression (GLM)';
    'stat_glm_2',        'test_stat_glm_groups.svg',       'Multi-Group GLM';
    'stat_smooth_1',     'test_stat_smooth.svg',           'Eilers Smoothing';
    'stat_bin_1',        'test_stat_bin.svg',              'Basic Histogram';
    'stat_bin_2',        'test_stat_bin_groups.svg',       'Grouped Histogram';
    'stat_bin_3',        'test_stat_bin_groups_bar.svg',   'Grouped Histogram Geom Options';
    'stat_summary_1',    'test_stat_summary.svg',          'Statistical Summary';
    'stat_density_1',    'test_stat_density.svg',          'Kernel Density';
    'stat_violin_1',     'test_stat_violin.svg',           'Violin Plots';
    'stat_boxplot_1',    'test_stat_boxplot.svg',          'Box Plots';
    'stat_qq_1',         'test_stat_qq.svg',               'Q-Q Plots';
    'stat_fit_1',        'test_stat_fit.svg',              'Polynomial Fitting';
    'stat_bin2d_1',      'test_stat_bin2d.svg',            '2D Histograms';
    'stat_ellipse_1',    'test_stat_ellipse.svg',          'Confidence Ellipses'
};

svg_files = {};
test_titles = {};
num_tests = size(tests, 1);

for i = 1:num_tests
    test_fn = tests{i, 1};
    fprintf('Running test %d/%d: %s\n', i, num_tests, test_fn);

    try
        feval(test_fn);
    catch ME
        fprintf(2, 'Test failed: %s\n', test_fn);
        rethrow(ME);
    end

    svg_files{end+1} = tests{i, 2}; %#ok<SAGROW>
    test_titles{end+1} = tests{i, 3}; %#ok<SAGROW>
end

fprintf('\n=== SVG Export Summary ===\n');
fprintf('Generated %d SVG files for all tests:\n', length(svg_files));
for i = 1:length(svg_files)
    fprintf('Test %d - %s: %s\n', i, svg_files{i}, test_titles{i});
end

fprintf('\n=== All Tests Completed Successfully ===\n');

close all;
