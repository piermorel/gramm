% gramm examples and how-tos

% Shared variable
% We stat by loading the sample data (structure created from the carbig
% dataset)
load example_data;

%% Methods for visualizing X densities
% The following methods can be used in order to represent the density of a continuous variable. Note that here
% we represent the same data as in the previous figure, this time with Horsepower as X
% (over which the densities are represented), and separating the region of
% origin with subplots.

clear g

g(1,1)=gramm('x',cars.Horsepower,'color',cars.Cylinders,'subset',cars.Cylinders~=3 & cars.Cylinders~=5);
g(1,2)=copy(g(1));
g(2,1)=copy(g(1));
g(2,2)=copy(g(1));

%Raw data as raster plot
g(1,1).facet_grid(cars.Origin_Region,[]);
g(1,1).geom_raster();
g(1,1).set_title('geom_raster()');

%Histogram
g(1,2).facet_grid(cars.Origin_Region,[]);
g(1,2).stat_bin('nbins',8);
g(1,2).set_title('stat_bin()');

%Kernel smoothing density estimate
g(2,1).facet_grid(cars.Origin_Region,[]);
g(2,1).stat_density();
g(2,1).set_title('stat_density()');

% Q-Q plot for normality
g(2,2).facet_grid(cars.Origin_Region,[]);
g(2,2).stat_qq();
g(2,2).axe_property('XLim',[-5 5]);
g(2,2).set_title('stat_qq()');

g.set_names('x','Horsepower','color','# Cyl','row','','y','');
g.set_title('Visualization of X densities');
figure;
g.draw();

