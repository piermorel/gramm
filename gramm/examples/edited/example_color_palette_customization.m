%% Color Palette Customization
% This example demonstrates how to customize color generation in *gramm*
% using |set_color_options()|.
%
% *gramm* generates colors automatically from a perceptually uniform LCH
% color space. You can tweak the hue range, lightness, and chroma, or
% switch to predefined palettes (MATLAB default, Color Brewer, D3.js).

%% Load sample data

load example_data;

%% Single-variable color maps
% These examples show how |'color'| and |'lightness'| grouping
% variables interact with different color map settings.

clear g

g(1,1) = gramm('x',cars.Origin,'y',cars.Horsepower,'color',cars.Origin);
g(1,1).stat_summary('geom',{'bar'},'dodge',0);
g(1,2) = copy(g(1));
g(1,3) = gramm('x',cars.Origin,'y',cars.Horsepower,'lightness',cars.Origin);
g(2,1) = copy(g(1));
g(2,2) = copy(g(1));
g(2,3) = copy(g(1));

%% Default LCH colormap
% The default generates evenly-spaced hues in LCH space for color
% groups.

g(1,1).set_title('Default LCH (''color'' groups)','FontSize',12);

%% Modified LCH parameters
% Restrict hue range and adjust lightness/chroma to create warm,
% pastel-toned bars.

g(1,2).set_color_options('hue_range',[-60 60],'chroma',40,'lightness',90);
g(1,2).set_title('Modified LCH (''color'' groups)','FontSize',12);

%% Lightness-based differentiation
% When using a |'lightness'| variable instead of |'color'|, you can
% control the grayscale range.

g(1,3).stat_summary('geom',{'bar'},'dodge',0);
g(1,3).set_color_options('lightness_range',[0 95],'chroma_range',[0 0]);
g(1,3).set_title('Modified LCH (''lightness'' groups)','FontSize',12);

%% MATLAB default colormap
% Switch to MATLAB's built-in colormap (parula-derived discrete colors).

g(2,1).set_color_options('map','matlab');
g(2,1).set_title('Matlab 2014B+','FontSize',12);

%% Color Brewer palette 1

g(2,2).set_color_options('map','brewer1');
g(2,2).set_title('Color Brewer 1','FontSize',12);

%% Color Brewer palette 2

g(2,3).set_color_options('map','brewer2');
g(2,3).set_title('Color Brewer 2','FontSize',12);

%% Apply shared formatting and draw

g.axe_property('YLim',[0 140]);
g.axe_property('XTickLabelRotation',60);
g.set_names('x','Origin','y','Horsepower','color','Origin','lightness','Origin');
g.set_title('Colormap customizations examples');

figure;
g.draw();

%% Combined color and lightness maps
% When both |'color'| and |'lightness'| grouping variables are used,
% |set_color_options()| also controls how the legend is displayed.

clear g

g(1,1) = gramm('x',cars.Origin_Region,'y',cars.Horsepower, ...
    'color',cars.Origin_Region,'lightness',cars.Cylinders, ...
    'subset',cars.Cylinders==4 | cars.Cylinders==6);
g(1,1).stat_summary('geom',{'bar'},'dodge',1.3,'width',1.2);
g(1,2) = copy(g(1,1));
g(1,3) = copy(g(1,1));
g(2,1) = copy(g(1,1));
g(2,2) = copy(g(1,1));

%% Default combined legend
% Default lightness/chroma settings with separate color and lightness
% legends.

g(1,1).set_title('Default LCH, default legend','FontSize',12);

%% Separate legend with color
% Force the lightness legend to display in color (first group color)
% instead of gray.

g(1,2).set_color_options('lightness_range',[70 40],'chroma_range',[60 70],'legend','separate');
g(1,2).set_title('Lightness legend with color','FontSize',12);

%% Brewer paired palette
% Pre-defined paired colormaps interleave light/dark pairs, producing
% better results than parametric LCH for paired data.

g(1,3).set_color_options('map','brewer_paired');
g(1,3).set_title('Brewer paired colormap','FontSize',12);

%% Expanded legend
% The |'expand'| option shows every color-lightness combination as a
% separate legend entry.

g(2,1).set_color_options('map','d3_20','legend','expand');
g(2,1).set_title('D3.js 20-color, ''expand'' legend','FontSize',12);

%% Merged legend
% The |'merge'| option combines legends when the same variable is used
% for multiple aesthetics (color + marker, etc.).

g(2,2) = gramm('x',cars.Origin,'y',cars.Horsepower,'color',cars.Origin, ...
    'marker',cars.Origin,'subset',cars.Cylinders==4 | cars.Cylinders==6);
g(2,2).stat_summary('geom',{'bar'},'dodge',0,'width',0.15);
g(2,2).stat_summary('geom',{'point'},'dodge',0,'width',1);
g(2,2).set_point_options('base_size',10);
g(2,3) = copy(g(2,2));

g(2,2).set_color_options('map','d3_10');
g(2,2).set_title('D3.js 10-color','FontSize',12);

g(2,3).set_color_options('map','d3_10','legend','merge');
g(2,3).set_title('D3.js 10-color, ''merge'' legend','FontSize',12);

%% Apply shared formatting and draw

g.axe_property('YLim',[0 160]);
g.axe_property('XTickLabelRotation',60);
g.set_names('x','Origin','y','Horsepower','color','Origin','marker','Origin','lightness','# Cyl');
g.set_title('Color/Lightness maps and legend customizations');

figure;
g.draw();
