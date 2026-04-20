% gramm examples and how-tos

% Shared variable
% We stat by loading the sample data (structure created from the carbig
% dataset)
load example_data;

%% Methods for visualizing Y~X relationship with both X and Y as continuous variables
% The following methods can be used when
% both X and Y data are continuous

clear g
%Raw data as scatter plot
g(1,1)=gramm('x',cars.Horsepower,'y',cars.Acceleration,'color',cars.Cylinders,'subset',cars.Cylinders~=3 & cars.Cylinders~=5);
g(1,2)=copy(g(1));
g(1,3)=copy(g(1));
g(2,1)=copy(g(1));
g(2,2)=copy(g(1));

g(1,1).geom_point();
g(1,1).set_title('geom_point()');

%Generalized linear model fit
g(1,2).stat_glm();
g(1,2).set_title('stat_glm()');

%Custom fit with provided function
g(1,3).stat_fit('fun',@(a,b,c,x)a./(x+b)+c,'intopt','functional');
g(1,3).set_title('stat_fit(''fun'',@(a,b,c,x)a./(x+b)+c)');

%Spline smoothing
g(2,1).stat_smooth();
g(2,1).set_title('stat_smooth()');

%Moving average
g(2,2).stat_summary('bin_in',10);
g(2,2).set_title('stat_summary(''bin_in'',10)');

g.set_names('x','Horsepower','y','Acceleration','color','# Cylinders');

%Corner histogram
g(2,3)=gramm('x',(cars.Horsepower-mean(cars.Horsepower,'omitnan'))/std(cars.Horsepower,'omitnan'),'y',-(cars.Acceleration-mean(cars.Acceleration,'omitnan'))/std(cars.Acceleration,'omitnan'),'color',cars.Cylinders,'subset',cars.Cylinders~=3 & cars.Cylinders~=5);
g(2,3).geom_point();
g(2,3).stat_cornerhist('edges',-4:0.2:4,'aspect',0.6);
g(2,3).geom_abline();
g(2,3).set_title('stat_cornerhist()');
g(2,3).set_names('x','z(Horsepower)','y','-z(Acceleration)');

g.set_title('Visualization of Y~X relationship with both X and Y as continuous variables');
figure;
g.draw();
