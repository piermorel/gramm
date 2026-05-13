%% Custom Layout: Marginal Histograms
% This example demonstrates how to build a scatter plot with marginal
% histograms using *gramm*'s |set_layout_options()| method.
%
% The layout consists of three gramm objects arranged manually:
%
% * A top histogram showing the x-variable distribution
% * A central scatter plot with a detached legend
% * A right histogram (flipped) showing the y-variable distribution
%
% This pattern is useful for exploring bivariate distributions while
% retaining the marginal structure.

%% Load the Fisher Iris dataset
% This classic dataset contains measurements of sepal and petal
% dimensions for three iris species.

load fisheriris.mat

%% Create the top marginal histogram
% Positioned above the scatter plot. We disable the legend here since
% it will appear on the main scatter plot instead.

clear g
figure;

g(1,1) = gramm('x',meas(:,2),'color',species);
g(1,1).set_layout_options( ...
    'Position',[0 0.8 0.8 0.2], ...
    'legend',false, ...
    'margin_height',[0.02 0.05], ...
    'margin_width',[0.1 0.02], ...
    'redraw',false);
g(1,1).set_names('x','');
g(1,1).stat_bin('geom','stacked_bar','fill','all','nbins',15);
g(1,1).axe_property('XTickLabel','');

%% Create the central scatter plot
% This is the main visualization. The legend is detached and placed
% in the top-right corner using |legend_pos|.

g(2,1) = gramm('x',meas(:,2),'y',meas(:,1),'color',species);
g(2,1).set_names('x','Sepal Width','y','Sepal Length','color','Species');
g(2,1).geom_point();
g(2,1).set_point_options('base_size',6);
g(2,1).set_layout_options( ...
    'Position',[0 0 0.8 0.8], ...
    'legend_pos',[0.83 0.75 0.2 0.2], ...
    'margin_height',[0.1 0.02], ...
    'margin_width',[0.1 0.02], ...
    'redraw',false);
g(2,1).axe_property('Ygrid','on');

%% Create the right marginal histogram
% Positioned to the right of the scatter plot. Uses |coord_flip()| to
% display the y-variable histogram vertically.

g(3,1) = gramm('x',meas(:,1),'color',species);
g(3,1).set_layout_options( ...
    'Position',[0.8 0 0.2 0.8], ...
    'legend',false, ...
    'margin_height',[0.1 0.02], ...
    'margin_width',[0.02 0.05], ...
    'redraw',false);
g(3,1).set_names('x','');
g(3,1).stat_bin('geom','stacked_bar','fill','all','nbins',15);
g(3,1).coord_flip();
g(3,1).axe_property('XTickLabel','');

%% Apply global styling and draw
% Shared properties ensure consistent tick direction and grid lines
% across all three components.

g.axe_property('TickDir','out','XGrid','on','GridColor',[0.5 0.5 0.5]);
g.set_title('Fisher Iris, custom layout');
g.set_color_options('map','d3_10');
g.draw();
