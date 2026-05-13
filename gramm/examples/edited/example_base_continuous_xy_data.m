%% Visualizing Continuous X-Y Relationships
% This example demonstrates the different methods *gramm* provides for
% visualizing the relationship between two continuous variables.
%
% Each subplot shows a different approach: raw scatter, linear model,
% custom fit, smoothing, binned summary, and corner histograms.

%% Load sample data
% The |cars| structure is derived from MATLAB's |carbig| dataset.

load example_data;

%% Create gramm objects for each visualization method
% We build a 2x3 array of gramm objects, all sharing the same base data:
% Horsepower vs Acceleration, colored by number of cylinders.

clear g

g(1,1) = gramm('x',cars.Horsepower,'y',cars.Acceleration, ...
    'color',cars.Cylinders, ...
    'subset',cars.Cylinders~=3 & cars.Cylinders~=5);
g(1,2) = copy(g(1));
g(1,3) = copy(g(1));
g(2,1) = copy(g(1));
g(2,2) = copy(g(1));

%% Raw scatter plot with geom_point()
% The simplest visualization: each observation as a colored point.

g(1,1).geom_point();
g(1,1).set_title('geom_point()');

%% Generalized linear model with stat_glm()
% Fits a linear model to each color group and displays the fit line
% with a confidence interval.

g(1,2).stat_glm();
g(1,2).set_title('stat_glm()');

%% Custom parametric fit with stat_fit()
% You can supply any function handle. Here we fit a reciprocal model
% of the form: |a/(x+b) + c|

g(1,3).stat_fit('fun',@(a,b,c,x)a./(x+b)+c,'intopt','functional');
g(1,3).set_title('stat_fit(''fun'',@(a,b,c,x)a./(x+b)+c)');

%% Spline smoothing with stat_smooth()
% Non-parametric smoothing using penalized splines. Adapts to local
% curvature without assuming a functional form.

g(2,1).stat_smooth();
g(2,1).set_title('stat_smooth()');

%% Binned summary with stat_summary()
% Divides the x-axis into bins and computes summary statistics (mean
% and confidence interval) within each bin.

g(2,2).stat_summary('bin_in',10);
g(2,2).set_title('stat_summary(''bin_in'',10)');

%% Set shared axis labels

g.set_names('x','Horsepower','y','Acceleration','color','# Cylinders');

%% Corner histogram with stat_cornerhist()
% A scatter plot with marginal histograms projected along both axes.
% Data is z-scored to show standardized relationships.

g(2,3) = gramm('x',(cars.Horsepower-mean(cars.Horsepower,'omitnan'))/std(cars.Horsepower,'omitnan'), ...
    'y',-(cars.Acceleration-mean(cars.Acceleration,'omitnan'))/std(cars.Acceleration,'omitnan'), ...
    'color',cars.Cylinders, ...
    'subset',cars.Cylinders~=3 & cars.Cylinders~=5);
g(2,3).geom_point();
g(2,3).stat_cornerhist('edges',-4:0.2:4,'aspect',0.6);
g(2,3).geom_abline();
g(2,3).set_title('stat_cornerhist()');
g(2,3).set_names('x','z(Horsepower)','y','-z(Acceleration)');

%% Draw all subplots

g.set_title('Visualization of Y~X relationship with both X and Y as continuous variables');
figure;
g.draw();
