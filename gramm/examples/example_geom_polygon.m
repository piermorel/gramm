% gramm examples and how-tos

% Shared variable
% We stat by loading the sample data (structure created from the carbig
% dataset)
load example_data;

%% Decorate plot backgrounds with geom_polygon()

clear g
g=gramm('x',cars.Model_Year,'y',cars.MPG,'color',cars.Cylinders,'subset',cars.Cylinders~=3 & cars.Cylinders~=5);
g.facet_grid([],cars.Origin_Region);
g.geom_point();
g.stat_glm('geom','line');
g.set_names('column','','x','Year of production','y','Fuel economy (MPG)','color','# Cylinders');

g(1,2)=copy(g(1));
g(2,1)=copy(g(1));
g(2,2)=copy(g(1));

% Color mapping for the polygons
cmap = [1   0.5 0.5; % red (bad gas mileage)
        1   1   0.5; % yellow (reasonable gas mileage)
        0.5 1   0.5]; % green (good gas mileage)

% Standard geom_polygon call, 'x' and 'y' are used to provide polygons vertex coordinates, Possibility to manually set fill, color, style and alpha.
g(1,1).geom_polygon('x',{[50 90 90 50] ; [50 90 90 50] ; [50 90 90 50]},'y',{[5 5 20 20];  [20 20 30 30];  [30 30 50 50]},'color',cmap,'alpha',0.3);

% Simplified geom_polygon call, 'x' was omitted and only pairs of 'y' values are provided,
% specifying lower and upper limits of horizontal areas.
g(1,2).geom_polygon('y',{[5 20];  [20 30];  [30 50]},'color',cmap);

%Possibility to set color and fill by indices (using a column vector of
%integers. Colormap generated between 1 and max(vector))
g(2,1).geom_polygon('y',{[5 20];  [20 30];  [30 50]},'color',[1 ; 3;  2]);

% Single fill, alpha, color and styles are automatically extended to all polygons in the call
g(2,2).geom_polygon('y',{[5 20];  [30 50]},'color',[1 0 0],'line_style',{'--'},'line_color',[0 0 0.5]);
% Possibility to do multiple calls
g(2,2).geom_polygon('x',{[72 80 76]},'y',{[22 22 28]}); %Default is grey

g.set_title('Decorate plot backgrounds with geom_polygon()');

figure;
g.draw();

