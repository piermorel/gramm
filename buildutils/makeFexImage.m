function makeFexImage(outFile)
% Draw the picture of gramm on File Exchange: a mosaic of four gramm plots
% (facets with fits, time series, polar histogram, rainclouds), without text as
% File Exchange shows it at about 330x250 pixels. It is uploaded by hand,
% so this isn't a build task. Run from the repository root, e.g.
%   addpath("gramm", "buildutils"); makeFexImage("fex_image.jpeg")
% Saves an 800x600 JPEG (File Exchange doesn't seem to accept PNG): File
% Exchange has no official size, 4:3 is the ratio that isn't cropped, and
% this is about twice the size of the thumbnail. Larger images caused
% problems

% Light theme, whatever the desktop theme
s = settings;
s.matlab.appearance.figure.GraphicsTheme.TemporaryValue = "light";
restoreTheme = onCleanup(@() clearTemporaryValue(s.matlab.appearance.figure.GraphicsTheme));

rng(1);
fig = figure(Visible="off", Position=[100 100 1200 900], Color="w");
t = tiledlayout(fig, 2, 2, TileSpacing="compact", Padding="compact");
g = [facets(t, 1) timeseries(t, 2) polar(t, 3) rainclouds(t, 4)];
for k = 1:numel(g)
    g(k).set_names('x', '', 'y', '', 'color', '', 'column', '', 'row', '');
    g(k).set_layout_options('legend', false);
    g(k).draw();
end
% No facet titles
for ax = reshape(g(1).facet_axes_handles, 1, [])
    title(ax, '');
end
% Wind rose: white gaps between sectors and classes (stat_bin has no edge
% color option)
set(findobj(g(3).facet_axes_handles(1), 'Type', 'patch'), ...
    'EdgeColor', 'w', 'EdgeAlpha', 1, 'LineWidth', 2.5);
% Raincloud violins: outlines as thick as the other lines (stat_violin has
% no line width option)
for k = 1:numel(g(4).results.stat_violin)
    set(g(4).results.stat_violin(k).line_handle, 'LineWidth', 2.5);
end
drawnow % Lets gramm finish laying out the figure
% exportgraphics has no JPEG quality option, so we export a lossless image
% and compress it ourselves with little loss
pngFile = [tempname '.png'];
exportgraphics(fig, pngFile, Resolution=64, Padding="figure");
close(fig);
imwrite(imread(pngFile), outFile, 'jpg', 'Quality', 95);
delete(pngFile);
end

function g = facets(t, tile)
% Three facets x three colors with fits: the grammar of graphics at a glance
nper = 8;
x = []; y = []; c = {}; f = [];
slopes = [0.2 0.5 0.8 ; 0.4 0.6 0.8 ; 0.8 0.6 0.3];
offsets = [1 3 5 ; 4 2 0 ; 0 3 6];
for facet = 1:3
    for col = 1:3
        xx = sort(10*rand(nper, 1));
        x = [x ; xx]; %#ok<AGROW>
        y = [y ; offsets(facet, col) + slopes(facet, col)*xx + 0.6*randn(nper, 1)]; %#ok<AGROW>
        c = [c ; repmat({char('A'+col-1)}, nper, 1)]; %#ok<AGROW>
        f = [f ; repmat(facet, nper, 1)]; %#ok<AGROW>
    end
end
g = gramm('x', x, 'y', y, 'color', c);
g.set_parent(t, 'tile', tile);
g.facet_grid([], f);
g.geom_point();
g.stat_glm();
g.set_point_options('base_size', 7);
g.set_line_options('base_size', 2.5);
g.axe_property('XTick', [], 'YTick', [], 'LineWidth', 3);
end

function g = timeseries(t, tile)
% Individual trajectories with group means and confidence bands
x = 0:23;
n = 20;
grp = repmat({'A' ; 'B'}, n/2, 1);
b = strcmp(grp, 'B');
y = 10 + 3*sin(2*pi*x/12) + b.*linspace(0, 6, 24) + randn(n, 24) + 2*randn(n, 1);
g = gramm('x', x, 'y', y, 'color', grp);
g.set_parent(t, 'tile', tile);
g.geom_line('alpha', 0.3);
g.stat_summary('geom', 'area');
g.set_color_options('map', 'd3_10');
g.set_line_options('base_size', 2);
g.axe_property('XTick', [], 'YTick', [], 'LineWidth', 3);
end

function g = polar(t, tile)
% Wind rose, bottom left: its corner stays empty for the File Exchange
% badge. Few wide sectors and three contrasted classes, readable when small
m = 1000;
direction = mod(250 + 35*randn(m, 1) - 170*(rand(m, 1) > 0.55), 360);
speed = discretize(abs(8 + 5*randn(m, 1)), [0 6 12 Inf]);
g = gramm('x', direction, 'color', speed);
g.set_parent(t, 'tile', tile);
g.set_polar('unit', 'degrees');
g.stat_bin('edges', 0:30:360, 'geom', 'stacked_bar', 'fill', 'all');
g.axe_property('ThetaZeroLocation', 'top', 'ThetaDir', 'clockwise', ...
    'ThetaTick', [], 'RTick', [], 'LineWidth', 3, ...
    'GridColor', [0.15 0.15 0.15], 'GridAlpha', 1, 'ThetaGrid', 'off', 'RGrid', 'off');
map = parula(7);
g.set_color_options('map', map([3 4 6], :), 'n_color', 3, 'n_lightness', 1);
end

function g = rainclouds(t, tile)
% Two rainclouds (half violin and half swarm of big points), in the red and
% blue of the facets
n = 70;
y = [1.3*randn(n, 1) ; 2 + 1.1*randn(n, 1)];
grp = [repmat({'A'}, n, 1) ; repmat({'B'}, n, 1)];
g = gramm('x', grp, 'y', y, 'color', grp);
g.set_parent(t, 'tile', tile);
g.stat_violin('half', 'right', 'dodge', 0, 'width', 1.1, 'nudge', 0.02, ...
    'normalization', 'width', 'fill', 'transparent', 'fill_alpha', 0.5);
g.geom_swarm('half', 'left', 'dodge', 0, 'width', 1.2, 'nudge', -0.02, ...
    'point_size', 4, 'corral', 'gutter', 'type', 'square');
g.set_color_options('map', [0.97 0.35 0.40 ; 0 0.65 0.94], 'n_color', 2, 'n_lightness', 1);
g.set_line_options('base_size', 2.5);
g.axe_property('XTick', [], 'YTick', [], 'LineWidth', 3);
end
