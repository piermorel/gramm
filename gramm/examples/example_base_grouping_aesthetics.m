%% Gramm examples and how-tos
% This example demonstrates the different ways *grouping variables* can be
% mapped to visual properties and subplots in *gramm*.
%

%% Load sample data
% We start by loading the shared sample dataset.
% The variable |cars| is a structure derived from MATLAB's |carbig| dataset.

load example_data;

%% Grouping options in gramm
% *gramm* offers several ways to represent grouping variables visually.
% Groups can affect:
%
% Aesthetic properties (color, size, marker, line style, etc.)
% Subplot layout (rows or columns)
%
% Grouping variables that control *aesthetics* are provided directly in the
% constructor call |gramm()|.
%
% Grouping variables that control *subplot layout* are provided via:
% |facet_grid()|
% |facet_wrap()|
%
% *Important:* All grouping mappings shown below can be *combined*.
% Different variables may be used simultaneously for different roles.
%
% To display multiple gramm objects in a single figure, we:
% Create an array of gramm objects
% Call |draw()| once at the end on the full array

%% Clear any existing gramm objects
clear g

%% No grouping
% Baseline example with no grouping variables applied.

g(1,1)=gramm('x',cars.Horsepower,'y',cars.MPG, ...
             'subset',cars.Cylinders~=3 & cars.Cylinders~=5);
g(1,1).geom_point();
g(1,1).set_names('x','Horsepower','y','MPG');
g(1,1).set_title('No groups');

%% Group mapped to color
% Map the number of cylinders to point color.

g(1,2)=gramm('x',cars.Horsepower,'y',cars.MPG, ...
             'subset',cars.Cylinders~=3 & cars.Cylinders~=5, ...
             'color',cars.Cylinders);
g(1,2).geom_point();
g(1,2).set_names('x','Horsepower','y','MPG','color','# Cyl');
g(1,2).set_title('Color grouping');

%% Group mapped to lightness
% Similar to color mapping, but using lightness instead.

g(1,3)=gramm('x',cars.Horsepower,'y',cars.MPG, ...
             'subset',cars.Cylinders~=3 & cars.Cylinders~=5, ...
             'lightness',cars.Cylinders);
g(1,3).geom_point();
g(1,3).set_names('x','Horsepower','y','MPG','lightness','# Cyl');
g(1,3).set_title('Lightness grouping');

%% Group mapped to point size
% Use group values to control marker size.

g(2,1)=gramm('x',cars.Horsepower,'y',cars.MPG, ...
             'subset',cars.Cylinders~=3 & cars.Cylinders~=5, ...
             'size',cars.Cylinders);
g(2,1).geom_point();
g(2,1).set_names('x','Horsepower','y','MPG','size','# Cyl');
g(2,1).set_title('Size grouping');

%% Group mapped to marker type
% Different groups are displayed using different marker symbols.

g(2,2)=gramm('x',cars.Horsepower,'y',cars.MPG, ...
             'subset',cars.Cylinders~=3 & cars.Cylinders~=5, ...
             'marker',cars.Cylinders);
g(2,2).geom_point();
g(2,2).set_names('x','Horsepower','y','MPG','marker','# Cyl');
g(2,2).set_title('Marker grouping');

%% Group mapped to line style
% Line plots where group membership controls line style.

g(2,3)=gramm('x',cars.Horsepower,'y',cars.MPG, ...
             'subset',cars.Cylinders~=3 & cars.Cylinders~=5, ...
             'linestyle',cars.Cylinders);
g(2,3).geom_line();
g(2,3).set_names('x','Horsepower','y','MPG','linestyle','# Cyl');
g(2,3).set_title('Line style grouping');

%% Faceting by rows
% Split data into subplot rows using the grouping variable.

g(3,1)=gramm('x',cars.Horsepower,'y',cars.MPG, ...
             'subset',cars.Cylinders~=3 & cars.Cylinders~=5);
g(3,1).facet_grid(cars.Cylinders,[]);
g(3,1).geom_point();
g(3,1).set_names('x','Horsepower','y','MPG','row','# Cyl');
g(3,1).set_title('Subplot rows');

%% Faceting by columns
% Split data into subplot columns using the grouping variable.

g(3,2)=gramm('x',cars.Horsepower,'y',cars.MPG, ...
             'subset',cars.Cylinders~=3 & cars.Cylinders~=5);
g(3,2).facet_grid([],cars.Cylinders);
g(3,2).geom_point();
g(3,2).set_names('x','Horsepower','y','MPG','column','# Cyl');
g(3,2).set_title('Subplot columns');

%% Draw all plots
% Render all gramm objects together in a single figure.

figure;
g.draw();
