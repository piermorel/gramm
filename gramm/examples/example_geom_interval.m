% gramm examples and how-tos

% Shared variable
% We stat by loading the sample data (structure created from the carbig
% dataset)
load example_data;

%% Methods for visualizing custom confidence intervals
% With |geom_interval()| it is possible to plot custom confidence intervals
% by provinding |'ymin'| and |'ymax'| values to |gramm()|. All options to
% display confidence intervals in |stat_summary()| are available, including
% dodging. |'ymin'| and |'ymax'| are absolute, and not given relative to
% |'y'|

cars_summary=rowfun(@(hp)deal(mean(hp,'omitnan'),bootci(200,@(x)mean(x,'omitnan'),hp)'),cars(cars.Cylinders~=3 & cars.Cylinders~=5,:),...
    'InputVariables',{'Horsepower'},...
    'GroupingVariables',{'Origin_Region' 'Cylinders'},...
    'OutputVariableNames',{'hp_mean' 'hp_ci'});

clear g
%Bars and error bars
g(1,1)=gramm('x',cars_summary.Origin_Region,'y',cars_summary.hp_mean,...
    'ymin',cars_summary.hp_ci(:,1),'ymax',cars_summary.hp_ci(:,2),'color',cars_summary.Cylinders);
g(1,1).set_names('x','Origin','y','Horsepower','color','# Cylinders');
g(1,1).geom_bar('dodge',0.8,'width',0.6);
g(1,1).geom_interval('geom','black_errorbar','dodge',0.8,'width',1);

%points and error bars
g(1,2)=gramm('x',categorical(cars_summary.Cylinders),'y',cars_summary.hp_mean,...
    'ymin',cars_summary.hp_ci(:,1),'ymax',cars_summary.hp_ci(:,2),'color',cars_summary.Origin_Region);
g(1,2).set_names('color','Origin','y','Horsepower','x','# Cylinders');
g(1,3)=copy(g(1,2));
g(1,2).set_color_options('map','matlab');

g(1,2).geom_point('dodge',0.2);
g(1,2).geom_interval('geom','errorbar','dodge',0.2,'width',0.8);

%Shaded area
g(1,3).geom_interval('geom','area');

figure;
g.axe_property('YLim',[-10 190]);
g.draw();

