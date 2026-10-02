% gramm examples and how-tos

% Shared variable
% We stat by loading the sample data (structure created from the carbig
% dataset)
load example_data;
%% Plot one variable against many others
%Inspired by: https://drsimonj.svbtle.com/plot-some-variables-against-many-others


%Use stack to transform the wide table to a long format
T=stack(cars,{'Displacement'  'Weight' 'Acceleration'});

%Use the variable resutling from the stacking as x
g=gramm('x',T.Displacement_Weight_Acceleration,'y',T.MPG,'color',T.Horsepower,'marker',T.Cylinders,'subset',T.Cylinders~=3 & T.Cylinders~=5 & T.Model_Year<75);
%Use the stacking indicator as facet variable
g.facet_wrap(T.Displacement_Weight_Acceleration_Indicator,'scale','independent');
g.set_point_options('base_size',7);
g.set_continuous_color('LCH_colormap',[20 80 ; 40 30 ; 260 260 ]);
g.set_names('y','MPG','x','Value','column','','color','HP','marker','# Cylinders');
g.geom_point();

g.axe_property('TickDir','out','XGrid','on','Ygrid','on','GridColor',[0.5 0.5 0.5]);
figure;
g.draw();
