% gramm examples and how-tos

%% Log axes: scatter plots
% set_scale() makes axes logarithmic, here y with set_scale('y','log'), or
% both x and y with set_scale('x','log','y','log'). The axis limits extend
% proportionally beyond the data. Values at or below 0, which can't be
% displayed on log axes, are left out of the limits.
% axe_property('XScale','log') has the same effect as set_scale(). The
% same data is shown with linear axes on the top row

% US population from the census (MATLAB's census.mat), and power outages
% in the US (MATLAB's outages.csv)
load census
outages=readtable('outages.csv');

clear g
for k=1:2
    g(k,1)=gramm('x',cdate,'y',pop);
    g(k,1).geom_line();
    g(k,1).geom_point();
    g(k,1).set_names('x','Year','y','US population (millions)');
    g(k,2)=gramm('x',outages.Customers,'y',outages.Loss,'color',outages.Region);
    g(k,2).geom_point('alpha',0.5);
    g(k,2).set_names('x','Customers affected','y','Power loss (MW)','color','Region');
end
g(1,1).set_title('Linear axes');
g(1,2).set_title('Linear axes');
g(2,1).set_scale('y','log');
g(2,1).set_title('Log y axis');
g(2,2).set_scale('x','log','y','log');
g(2,2).set_title('Log x and y axes');
figure('Position',[100 100 1000 800]);
g.draw();

%% Log axes: histograms
% On a log y axis, bars of stat_bin() (and geom_bar(), stat_summary()
% bars) start from the bottom of the axis. The bins are computed on linear
% values: on a log x axis, bins regularly spaced on the axis are given
% with 'edges' and logspace(). The same data is shown with linear axes
% and bins on the top row

% Duration of power outages in the US (MATLAB's outages.csv)
outages=readtable('outages.csv');
duration=days(outages.RestorationTime-outages.OutageTime);
cause_type=repmat({'Other'},height(outages),1);
cause_type(contains(outages.Cause,{'storm','wind'}))={'Storm or wind'};

clear g
g(1,1)=gramm('x',duration);
g(1,1).stat_bin('geom','bar');
g(1,1).set_title('Linear axes');
g(2,1)=gramm('x',duration);
g(2,1).stat_bin('edges',logspace(-3.5,4.5,33),'geom','bar');
g(2,1).set_scale('x','log');
g(2,1).set_title('Log x axis');
g(1,2)=gramm('x',duration,'color',cause_type);
g(1,2).stat_bin('geom','overlaid_bar','fill','transparent');
g(1,2).set_title('Linear axes');
g(2,2)=gramm('x',duration,'color',cause_type);
g(2,2).stat_bin('edges',logspace(-3.5,4.5,33),'geom','overlaid_bar','fill','transparent');
g(2,2).set_scale('x','log','y','log');
g(2,2).set_title('Log x and y axes');
g.set_names('x','Outage duration (days)','y','Outages','color','Cause');
figure('Position',[100 100 1000 750]);
g.draw();
