% gramm examples and how-tos

% Shared variable
% We stat by loading the sample data (structure created from the carbig
% dataset)
load example_data;

%% Customizing color maps with set_color_options()
% With the method set_color_options(), automatic color generation for
% color and lightness groups can be tweaked

%Default: LCH-based colormap with hue variation
clear g
g(1,1)=gramm('x',cars.Origin,'y',cars.Horsepower,'color',cars.Origin);
g(1,1).stat_summary('geom',{'bar'},'dodge',0);
g(1,2)=copy(g(1));
g(1,3)=gramm('x',cars.Origin,'y',cars.Horsepower,'lightness',cars.Origin);
g(2,1)=copy(g(1));
g(2,2)=copy(g(1));
g(2,3)=copy(g(1));

g(1,1).set_title('Default LCH (''color'' groups)','FontSize',12);

%Possibility to change the hue range as well as lightness and chroma of
%the LCH-based colormap
g(1,2).set_color_options('hue_range',[-60 60],'chroma',40,'lightness',90);
g(1,2).set_title('Modified LCH (''color'' groups)','FontSize',12);

%Possibility to change the lightness and chroma range of the LCH-based
%colormap when a 'lightness' variable is given
g(1,3).stat_summary('geom',{'bar'},'dodge',0);
g(1,3).set_color_options('lightness_range',[0 95],'chroma_range',[0 0]);
g(1,3).set_title('Modified LCH (''lightness'' groups)','FontSize',12);

%Go back to Matlab's defauls colormap
g(2,1).set_color_options('map','matlab');
g(2,1).set_title('Matlab 2014B+ ','FontSize',12);

%Brewer colormap 1
g(2,2).set_color_options('map','brewer1');
g(2,2).set_title('Color Brewer 1','FontSize',12);

%Brewer colormap 2
g(2,3).set_color_options('map','brewer2');
g(2,3).set_title('Color Brewer 2','FontSize',12);

%Some methods can be called on all objects at the same time !
g.axe_property('YLim',[0 140]);
g.axe_property('XTickLabelRotation',60); %Should work for recent Matlab versions
g.set_names('x','Origin','y','Horsepower','color','Origin','lightness','Origin');
g.set_title('Colormap customizations examples');

figure
g.draw();


%% Customizing color/lightness maps and legends with set_color_options()
% When both a |'color'| and a |'lightness'| grouping variable are used,
% set_color_options() also controls how the legend is displayed

clear g

g(1,1)=gramm('x',cars.Origin_Region,'y',cars.Horsepower,'color',cars.Origin_Region,'lightness',cars.Cylinders,...
    'subset',cars.Cylinders==4 | cars.Cylinders==6);
g(1,1).stat_summary('geom',{'bar'},'dodge',1.3,'width',1.2);
g(1,2) = copy( g(1,1) );
g(1,3) = copy( g(1,1) );
g(2,1) = copy( g(1,1) );
g(2,2) = copy( g(1,1) );

% Default lightness/chroma is beter suited for more lightness categories
g(1,1).set_title('Default LCH, default legend','FontSize',12);

% It is possible to restrict the lightness/chroma changes across the
% lightness categories. Forcing the legend to 'separate' here makes the
% lightness legends use the first color instead of gray levels
g(1,2).set_color_options('lightness_range',[70 40],'chroma_range',[60 70],'legend','separate');
g(1,2).set_title('Modified LCH, lightness legend with color','FontSize',12);

% Pre-defined color/lightness maps can yeild better results than default
% parametric LCH colormaps
g(1,3).set_color_options('map','brewer_paired');
g(1,3).set_title('Brewer colormap','FontSize',12);

% Witht the 'expand' legend option, all ligthness/color combinations are
% presented in the legend
g(2,1).set_color_options('map','d3_20','legend','expand');
g(2,1).set_title('D3.js colormap, ''expand'' legend option','FontSize',12);


g(2,2)=gramm('x',cars.Origin,'y',cars.Horsepower,'color',cars.Origin,...
    'marker',cars.Origin,'subset',cars.Cylinders==4 | cars.Cylinders==6);
g(2,2).stat_summary('geom',{'bar'},'dodge',0,'width',0.15);
g(2,2).stat_summary('geom',{'point'},'dodge',0,'width',1);
g(2,2).set_point_options('base_size',10);
g(2,3)=copy(g(2,2));

g(2,2).set_title('D3.js colormap','FontSize',12);
g(2,2).set_color_options('map','d3_10');

% With the 'merge' legend option, plots that use the same categories for
% color and marker/linestyle/size will be combined
g(2,3).set_color_options('map','d3_10','legend','merge');
g(2,3).set_title('D3.js colormap, ''merge'' legend option','FontSize',12);

g.axe_property('YLim',[0 160]);
g.axe_property('XTickLabelRotation',60); %Should work for recent Matlab versions
g.set_names('x','Origin','y','Horsepower','color','Origin','marker','Origin','lightness','# Cyl');
g.set_title('Color/Lightness maps and legend customizations examples');

figure;
g.draw();
