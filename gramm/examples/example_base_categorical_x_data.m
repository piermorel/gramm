% gramm examples and how-tos

% Shared variable
% We stat by loading the sample data (structure created from the carbig
% dataset)
load example_data;

%% Methods for visualizing Y~X relationships with X as categorical variable
% The following methods can be used when Y data is continuous and X data discrete/categorical.
%
% Here we also use an array of gramm objects in order to have multiple gramm plots
% on the same figure. The gramm objects use the same data, so  we copy them after construction using the
% |copy()| method. We also duplicate the whole array of gramm objects
% before drawing in order to demonstrate the use of coord_flip() to
% exchange X and Y axes

clear g

g(1,1)=gramm('x',cars.Origin_Region,'y',cars.Horsepower,'color',cars.Cylinders,'subset',cars.Cylinders~=3 & cars.Cylinders~=5);
g(1,2)=copy(g(1));
g(1,3)=copy(g(1));
g(2,1)=copy(g(1));
g(2,2)=copy(g(1));
g(2,3)=copy(g(1));

%Raw data as scatter plot
g(1,1).geom_point();
g(1,1).set_title('geom_point()');

%Jittered scatter plot
g(1,2).geom_jitter('width',0.4,'height',0);
g(1,2).set_title('geom_jitter()');

%Averages with confidence interval
g(1,3).stat_summary('geom',{'bar','black_errorbar'});
g(1,3).set_title('stat_summary()');

%Boxplots
g(2,1).stat_boxplot();
g(2,1).set_title('stat_boxplot()');

%Violin plots
g(2,2).stat_violin('fill','transparent');
g(2,2).set_title('stat_violin()');

%beeswarm / swarm plots
g(2,3).geom_swarm('point_size',2);
g(2,3).set_title('geom_swarm()');

%These functions can be called on arrays of gramm objects
g.set_names('x','Origin','y','Horsepower','color','# Cyl');
g.set_title('Visualization of Y~X relationships with X as categorical variable');

gf = copy(g);

figure;
g.draw();

gf.set_title('Visualization of Y~X relationships with X as categorical variable and flipped coordinates');
figure;
gf.coord_flip();
gf.draw();
