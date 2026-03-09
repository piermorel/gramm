%% Complete Gramm Test Suite - SVG and Vega Export
% Generates all SVG files and Vega-Lite outputs for gramm tests

clear; clc; close all;

vega_dir = './gramm_vega';
svg_dir = './gramm_svg';

if ~exist(vega_dir, 'dir')
    mkdir(vega_dir);
end
if ~exist(svg_dir, 'dir')
    mkdir(svg_dir);
end

svg_files = {};
test_titles = {};

%% Test 1: geom_point - Basic Scatter Plot
figure('Visible', 'off');
x1 = randn(50, 1);
y1 = randn(50, 1);

g1 = gramm('x', x1, 'y', y1);
g1.geom_point();
g1.set_title('Basic Scatter Plot');
g1.set_names('x', 'X Values', 'y', 'Y Values');
g1.draw();

export_vega(g1, 'file_name', 'test_geom_point', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_geom_point.svg');
g1.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_geom_point.svg';
test_titles{end+1} = 'Basic Scatter Plot';

%% Test 2: geom_point with Color Groups
figure('Visible', 'off');
x2 = randn(60, 1);
y2 = randn(60, 1);
colors = repmat([4, 6, 8], 1, 20);

g2 = gramm('x', x2, 'y', y2, 'color', colors);
g2.geom_point();
g2.set_title('Scatter Plot with Color Groups');
g2.set_names('x', 'X Values', 'y', 'Y Values', 'color', 'Group');
g2.draw();

export_vega(g2, 'file_name', 'test_geom_point_colors', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_geom_point_colors.svg');
g2.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_geom_point_colors.svg';
test_titles{end+1} = 'Scatter Plot with Color Groups';

%% Test 3: geom_line - Line Chart
figure('Visible', 'off');
x3 = 1:20;
y3 = cumsum(randn(1, 20));

g3 = gramm('x', x3, 'y', y3);
g3.geom_line();
g3.set_title('Basic Line Chart');
g3.set_names('x', 'Time', 'y', 'Value');
g3.draw();

export_vega(g3, 'file_name', 'test_geom_line', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_geom_line.svg');
g3.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_geom_line.svg';
test_titles{end+1} = 'Basic Line Chart';

%% Test 4: geom_line with Multiple Series
figure('Visible', 'off');
n = 15;
x = repmat(1:n, 1, 3);
y = [cumsum(randn(1,n)), cumsum(randn(1,n)) + 2, cumsum(randn(1,n)) - 1];
groups = [repmat(4,1,n), repmat(6,1,n), repmat(8,1,n)];

g = gramm('x', x, 'y', y, 'color', groups);
g.geom_line();
g.set_title('Multi-Series Line Chart');
g.set_names('x', 'Time', 'y', 'Value', 'color', 'Series');
g.draw();

export_vega(g, 'file_name', 'test_geom_line_multi', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_geom_line_multi.svg');
g.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_geom_line_multi.svg';
test_titles{end+1} = 'Multi-Series Line Chart';

%% Test 5: geom_bar - Bar Chart with Categorical Data
figure('Visible', 'off');
categories = {'A', 'B', 'C', 'D', 'E'};
values = [23, 45, 56, 78, 32];

g5 = gramm('x', categories, 'y', values);
g5.geom_bar();
g5.set_title('Categorical Bar Chart');
g5.set_names('x', 'Category', 'y', 'Count');
g5.draw();

export_vega(g5, 'file_name', 'test_geom_bar_categorical', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_geom_bar_categorical.svg');
g5.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_geom_bar_categorical.svg';
test_titles{end+1} = 'Categorical Bar Chart';

%% Test 6: geom_bar with Numeric Data and Groups
figure('Visible', 'off');
x_bars = repmat([1, 2, 3, 4], 1, 3);
y_bars = [10, 15, 12, 18, 8, 20, 14, 22, 16, 25, 11, 19];
bar_groups = [repmat(4,1,4), repmat(6,1,4), repmat(8,1,4)];

g6 = gramm('x', x_bars, 'y', y_bars, 'color', bar_groups);
g6.geom_bar('dodge', 0.6);
g6.set_title('Grouped Bar Chart');
g6.set_names('x', 'Position', 'y', 'Value', 'color', 'Group');
g6.draw();

export_vega(g6, 'file_name', 'test_geom_bar_groups', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_geom_bar_groups.svg');
g6.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_geom_bar_groups.svg';
test_titles{end+1} = 'Grouped Bar Chart';

%% Test 7: geom_jitter - Jittered Points
figure('Visible', 'off');
categories_jitter = repmat({'Low', 'Medium', 'High'}, 1, 20);
values_jitter = [randn(1, 20) + 1, randn(1, 20) + 3, randn(1, 20) + 5];

g7 = gramm('x', categories_jitter, 'y', values_jitter);
g7.geom_jitter('width', 0.3);
g7.set_title('Jittered Points');
g7.set_names('x', 'Category', 'y', 'Value');
g7.draw();

export_vega(g7, 'file_name', 'test_geom_jitter', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_geom_jitter.svg');
g7.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_geom_jitter.svg';
test_titles{end+1} = 'Jittered Points';

%% Test 8: geom_raster - Strip Plot
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

svg_files{end+1} = 'test_geom_raster.svg';
test_titles{end+1} = 'Strip Plot (Raster)';

%% Test 9: Combined geom_point and geom_line
figure('Visible', 'off');
x9 = 1:10;
y9 = x9 + randn(1, 10);

g9 = gramm('x', x9, 'y', y9);
g9.geom_point();
g9.geom_line();
g9.set_title('Combined Point and Line');
g9.set_names('x', 'X Values', 'y', 'Y Values');
g9.draw();

export_vega(g9, 'file_name', 'test_combined_point_line', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_combined_point_line.svg');
g9.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_combined_point_line.svg';
test_titles{end+1} = 'Combined Point and Line';

%% Test 10: Data with NaN Values
figure('Visible', 'off');
x_nan = 1:15;
y_nan = [1, 2, NaN, 4, 5, NaN, 7, 8, 9, NaN, 11, 12, 13, 14, 15];

g10 = gramm('x', x_nan, 'y', y_nan);
g10.geom_point();
g10.geom_line();
g10.set_title('Data with NaN Values');
g10.set_names('x', 'Index', 'y', 'Value');
g10.draw();

export_vega(g10, 'file_name', 'test_nan_handling', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_nan_handling.svg');
g10.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_nan_handling.svg';
test_titles{end+1} = 'Data with NaN Values';

%% Test 11: Custom Parameters
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

svg_files{end+1} = 'test_custom_params.svg';
test_titles{end+1} = 'Custom Export Parameters';

%% Test 12: geom_swarm (Beeswarm approximation)
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

svg_files{end+1} = 'test_geom_swarm.svg';
test_titles{end+1} = 'Beeswarm Plot';

%% Test 13: Interactive Legend - Scatter Plot
figure('Visible', 'off');
x_int = randn(80, 1);
y_int = randn(80, 1);
colors_int = repmat({'Red Group', 'Blue Group', 'Green Group', 'Orange Group'}, 1, 20);

g13 = gramm('x', x_int, 'y', y_int, 'color', colors_int);
g13.geom_point();
g13.set_title('Interactive Scatter Plot - Click Legend to Filter');
g13.set_names('x', 'X Values', 'y', 'Y Values', 'color', 'Groups');
g13.draw();

export_vega(g13, 'file_name', 'test_interactive_scatter', 'export_path', vega_dir, ...
    'interactive', 'true', 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_interactive_scatter.svg');
g13.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_interactive_scatter.svg';
test_titles{end+1} = 'Interactive Scatter Plot';

%% Test 14: Interactive Legend - Line Chart
figure('Visible', 'off');
x_lines = repmat(1:20, 1, 4);
y_lines = [];
line_groups = [];
group_names = {'Sales', 'Marketing', 'Engineering', 'Support'};

for i = 1:4
    y_lines = [y_lines, cumsum(randn(1, 20)) + i*5];
    line_groups = [line_groups, repmat(group_names(i), 1, 20)];
end

g14 = gramm('x', x_lines, 'y', y_lines, 'color', line_groups);
g14.geom_line();
g14.set_title('Interactive Multi-Series Lines - Click Legend to Highlight');
g14.set_names('x', 'Time Period', 'y', 'Performance Score', 'color', 'Department');
g14.draw();

export_vega(g14, 'file_name', 'test_interactive_lines', 'export_path', vega_dir, ...
    'interactive', 'true', 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_interactive_lines.svg');
g14.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_interactive_lines.svg';
test_titles{end+1} = 'Interactive Multi-Series Lines';

%% Test 15: Interactive Legend - Grouped Bar Chart
figure('Visible', 'off');
quarters = repmat({'Q1', 'Q2', 'Q3', 'Q4'}, 1, 3);
revenues = [120, 150, 180, 200, 80, 95, 110, 125, 60, 70, 85, 90];
divisions = repmat({'North', 'South', 'West'}, 1, 4);

g15 = gramm('x', quarters, 'y', revenues, 'color', divisions);
g15.geom_bar();
g15.set_title('Interactive Grouped Bars - Legend Controls Visibility');
g15.set_names('x', 'Quarter', 'y', 'Revenue (K)', 'color', 'Division');
g15.draw();

export_vega(g15, 'file_name', 'test_interactive_bars', 'export_path', vega_dir, ...
    'interactive', 'true', 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_interactive_bars.svg');
g15.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_interactive_bars.svg';
test_titles{end+1} = 'Interactive Grouped Bars';

%% Test 16: Interactive Jitter Plot
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

svg_files{end+1} = 'test_interactive_jitter.svg';
test_titles{end+1} = 'Interactive Jitter Plot';

%% Test 17: Standard Legend (Non-Interactive)
figure('Visible', 'off');
x_std = randn(75, 1);
y_std = randn(75, 1);
groups_std = repmat({'Alpha', 'Beta', 'Gamma'}, 1, 25);

g17 = gramm('x', x_std, 'y', y_std, 'color', groups_std);
g17.geom_point();
g17.set_title('Standard Legend (Non-Interactive)');
g17.set_names('x', 'X Values', 'y', 'Y Values', 'color', 'Groups');
g17.draw();

export_vega(g17, 'file_name', 'test_standard_legend', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_standard_legend.svg');
g17.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_standard_legend.svg';
test_titles{end+1} = 'Standard Legend (Non-Interactive)';

%% Test 18: Interactive Legend Demo
figure('Visible', 'off');
x_demo = randn(100, 1);
y_demo = randn(100, 1);
demo_groups = repmat({'Click Me', 'Shift+Click', 'Multi-Select', 'Reset'}, 1, 25);

g18 = gramm('x', x_demo, 'y', y_demo, 'color', demo_groups);
g18.geom_point();
g18.set_title('Interactive Legend Demo - Click & Shift+Click');
g18.set_names('x', 'X Values', 'y', 'Y Values', 'color', 'Interactive Groups');
g18.draw();

export_vega(g18, 'file_name', 'test_interactive_legend', 'export_path', vega_dir, ...
    'interactive', 'true', 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_interactive_legend.svg');
g18.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_interactive_legend.svg';
test_titles{end+1} = 'Interactive Legend Demo';

%% Test 19: Large Dataset Interactive Test
figure('Visible', 'off');
x_large = randn(500, 1);
y_large = randn(500, 1);
large_groups = repmat({'Dataset A', 'Dataset B', 'Dataset C', 'Dataset D', 'Dataset E'}, 1, 100);

g19 = gramm('x', x_large, 'y', y_large, 'color', large_groups);
g19.geom_point();
g19.set_title('Large Dataset Interactive Test - 500 Points');
g19.set_names('x', 'X Values', 'y', 'Y Values', 'color', 'Datasets');
g19.draw();

export_vega(g19, 'file_name', 'test_large_interactive', 'export_path', vega_dir, ...
    'interactive', 'true', 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_large_interactive.svg');
g19.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_large_interactive.svg';
test_titles{end+1} = 'Large Dataset Interactive Test';

%% Test 20: Linear Regression (GLM)
figure('Visible', 'off');
x = linspace(0, 10, 50);
y = 2*x + randn(1, 50)*2;

g20 = gramm('x', x, 'y', y);
g20.stat_glm();
g20.geom_point();
g20.set_title('Linear Regression (GLM)');
g20.set_names('x', 'X Values', 'y', 'Y Values');
g20.draw();

export_vega(g20, 'file_name', 'test_stat_glm', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_glm.svg');
g20.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_stat_glm.svg';
test_titles{end+1} = 'Linear Regression (GLM)';

%% Test 21: Multi-Group GLM
figure('Visible', 'off');
x = repmat(linspace(0, 10, 25), 1, 2);
y = [2*linspace(0, 10, 25) + randn(1, 25)*2, 3*linspace(0, 10, 25) + randn(1, 25)*2];
groups = [repmat({'Group A'}, 1, 25), repmat({'Group B'}, 1, 25)];

g21 = gramm('x', x, 'y', y, 'color', groups);
g21.stat_glm();
g21.geom_point();
g21.set_title('Multi-Group GLM');
g21.set_names('x', 'X Values', 'y', 'Y Values', 'color', 'Groups');
g21.draw();

export_vega(g21, 'file_name', 'test_stat_glm_groups', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_glm_groups.svg');
g21.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_stat_glm_groups.svg';
test_titles{end+1} = 'Multi-Group GLM';

%% Test 22: Eilers Smoothing
figure('Visible', 'off');
x = linspace(0, 4*pi, 100);
y = sin(x) + randn(1, 100)*0.3;

g22 = gramm('x', x, 'y', y);
g22.stat_smooth();
g22.geom_point();
g22.set_title('Eilers Smoothing');
g22.set_names('x', 'X Values', 'y', 'Y Values');
g22.draw();

export_vega(g22, 'file_name', 'test_stat_smooth', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_smooth.svg');
g22.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_stat_smooth.svg';
test_titles{end+1} = 'Eilers Smoothing';

%% Test 23: Basic Histogram
figure('Visible', 'off');
x = randn(200, 1);

g23 = gramm('x', x);
g23.stat_bin();
g23.set_title('Basic Histogram');
g23.set_names('x', 'Values', 'y', 'Count');
g23.draw();

export_vega(g23, 'file_name', 'test_stat_bin', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_bin.svg');
g23.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_stat_bin.svg';
test_titles{end+1} = 'Basic Histogram';

%% Test 24: Grouped Histogram
figure('Visible', 'off');
x = [randn(100, 1); randn(100, 1) + 2];
groups = [repmat({'Group A'}, 100, 1); repmat({'Group B'}, 100, 1)];

g24 = gramm('x', x, 'color', groups);
g24.stat_bin();
g24.set_title('Grouped Histogram');
g24.set_names('x', 'Values', 'y', 'Count', 'color', 'Groups');
g24.draw();

export_vega(g24, 'file_name', 'test_stat_bin_groups', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_bin_groups.svg');
g24.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_stat_bin_groups.svg';
test_titles{end+1} = 'Grouped Histogram';

%% Test 25: Statistical Summary
figure('Visible', 'off');
x = repmat({'A', 'B', 'C'}, 1, 30);
y = [randn(1, 30) + 2, randn(1, 30) + 4, randn(1, 30) + 6];

g25 = gramm('x', x, 'y', y);
g25.stat_summary('type', 'sem');
g25.set_title('Statistical Summary');
g25.set_names('x', 'Categories', 'y', 'Values');
g25.draw();

export_vega(g25, 'file_name', 'test_stat_summary', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_summary.svg');
g25.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_stat_summary.svg';
test_titles{end+1} = 'Statistical Summary';

%% Test 26: Kernel Density
figure('Visible', 'off');
x = [randn(100, 1); randn(100, 1) + 3];
groups = [repmat({'Group A'}, 100, 1); repmat({'Group B'}, 100, 1)];

g26 = gramm('x', x, 'color', groups);
g26.stat_density();
g26.set_title('Kernel Density');
g26.set_names('x', 'Values', 'y', 'Density', 'color', 'Groups');
g26.draw();

export_vega(g26, 'file_name', 'test_stat_density', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_density.svg');
g26.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_stat_density.svg';
test_titles{end+1} = 'Kernel Density';

%% Test 27: Violin Plots
figure('Visible', 'off');
x = repmat({'Low', 'Medium', 'High'}, 1, 50);
y = [randn(1, 50) + 2, randn(1, 50) + 4, randn(1, 50) + 6];

g27 = gramm('x', x, 'y', y);
g27.stat_violin();
g27.set_title('Violin Plots');
g27.set_names('x', 'Categories', 'y', 'Values');
g27.draw();

export_vega(g27, 'file_name', 'test_stat_violin', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_violin.svg');
g27.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_stat_violin.svg';
test_titles{end+1} = 'Violin Plots';

%% Test 28: Box Plots
figure('Visible', 'off');
x = repmat({'A', 'B', 'C', 'D'}, 1, 25);
y = [randn(1, 25) + 1, randn(1, 25) + 3, randn(1, 25) + 5, randn(1, 25) + 7];

g28 = gramm('x', x, 'y', y);
g28.stat_boxplot();
g28.set_title('Box Plots');
g28.set_names('x', 'Categories', 'y', 'Values');
g28.draw();

export_vega(g28, 'file_name', 'test_stat_boxplot', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_boxplot.svg');
g28.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_stat_boxplot.svg';
test_titles{end+1} = 'Box Plots';

%% Test 29: Q-Q Plots
figure('Visible', 'off');
x = [randn(50, 1); randn(50, 1) * 2 + 1];
groups = [repmat({'Normal'}, 50, 1); repmat({'Skewed'}, 50, 1)];

g29 = gramm('x', x, 'color', groups);
g29.stat_qq();
g29.set_title('Q-Q Plots');
g29.set_names('x', 'Sample Quantiles', 'y', 'Theoretical Quantiles', 'color', 'Distribution');
g29.draw();

export_vega(g29, 'file_name', 'test_stat_qq', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_qq.svg');
g29.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_stat_qq.svg';
test_titles{end+1} = 'Q-Q Plots';

% %% Test 30: Polynomial Fitting (stat_fit)
% figure('Visible', 'off');
% x = linspace(0, 10, 50);
% y = 0.1*x.^2 + randn(1, 50)*2;

% g30 = gramm('x', x, 'y', y);
% g30.stat_fit('fun', @(a,b,c,x) a*x.^2 + b*x + c);
% g30.geom_point();
% g30.set_title('Polynomial Fitting');
% g30.draw();

% export_vega(g30, 'file_name', 'test_stat_fit', 'export_path', vega_dir, 'width', '400', 'height', '300');

% svg_filename = fullfile(svg_dir, 'test_stat_fit.svg');
% g30.export('file_name', svg_filename);
% close all;

svg_files{end+1} = 'test_stat_fit.svg';
test_titles{end+1} = 'Polynomial Fitting';

%% Test 31: 2D Histograms
figure('Visible', 'off');
x = randn(200, 1);
y = x + randn(200, 1);

g31 = gramm('x', x, 'y', y);
g31.stat_bin2d();
g31.set_title('2D Histograms');
g31.draw();

export_vega(g31, 'file_name', 'test_stat_bin2d', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_bin2d.svg');
g31.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_stat_bin2d.svg';
test_titles{end+1} = '2D Histograms';

%% Test 32: Confidence Ellipses
figure('Visible', 'off');
x = [randn(50, 1); randn(50, 1) + 3];
y = [randn(50, 1); randn(50, 1) + 2];
groups = [repmat({'Cluster A'}, 50, 1); repmat({'Cluster B'}, 50, 1)];

g32 = gramm('x', x, 'y', y, 'color', groups);
g32.stat_ellipse();
g32.geom_point();
g32.set_title('Confidence Ellipses');
g32.draw();

export_vega(g32, 'file_name', 'test_stat_ellipse', 'export_path', vega_dir, 'width', '400', 'height', '300');

svg_filename = fullfile(svg_dir, 'test_stat_ellipse.svg');
g32.export('file_name', svg_filename);
close all;

svg_files{end+1} = 'test_stat_ellipse.svg';
test_titles{end+1} = 'Confidence Ellipses';