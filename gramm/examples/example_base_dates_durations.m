% gramm examples and how-tos

%% Dates and durations
% x and y data can be given as datetime or duration arrays. Axes then
% display dates and durations natively (ticks, zoom, pan). Dates and
% durations can also be used as grouping data (color, facets...), in which
% case they are ordered chronologically.

% Synthetic data: daily measurements over a year at two sites
rng(1);
t=datetime(2024,1,1)+days(0:365)';
site=repmat({'North';'South'},ceil(numel(t)/2),1);
site=site(1:numel(t));
temperature=12-10*cos(2*pi*days(t-t(1))/365)+3*strcmp(site,'South')+2*randn(numel(t),1);

clear g
g=gramm('x',t,'y',temperature,'color',site);
g.geom_point('alpha',0.4);
g.stat_smooth();
g.set_names('x','Date','y','Temperature (°C)','color','Site');
g.set_title('Datetime x data');
figure('Position',[100 100 800 450]);
g.draw();

%% Calendar binning
% stat_bin() and stat_summary() accept a 'bin_width' option, given as the
% name of a time unit ('day','week','month','quarter','year'...), as a
% duration or as a calendarDuration (or as a number for numeric x). Bins
% then follow calendar boundaries. Bin edges ('edges' in stat_bin(),
% 'bin_in' in stat_summary()) can also be given as datetime or duration
% arrays.

% Event times spread over a year, more frequent in summer
event_time=datetime(2024,1,1)+days(mod(182+70*randn(800,1),365));

clear g
g(1,1)=gramm('x',event_time);
g(1,1).stat_bin('bin_width','month');
g(1,1).set_names('x','Date','y','Events per month');
g(1,1).set_title('stat_bin(''bin_width'',''month'')');

g(1,2)=gramm('x',t,'y',temperature,'color',site);
g(1,2).stat_summary('bin_width',calweeks(2),'geom','area');
g(1,2).set_names('x','Date','y','Temperature (°C)','color','Site');
g(1,2).set_title('stat_summary(''bin_width'',calweeks(2))');

figure('Position',[100 100 900 400]);
g.draw();

%% Durations
% Reaction times given as durations, with a reference line given as a
% duration as well

n=400;
condition=repmat({'Easy';'Hard'},n/2,1);
rt=milliseconds(350+120*strcmp(condition,'Hard')+exp(4+0.6*randn(n,1)));

clear g
g=gramm('x',condition,'y',rt,'color',condition);
g.stat_boxplot();
g.geom_hline('yintercept',milliseconds(500));
g.set_names('x','Condition','y','Reaction time','color','Condition');
g.set_title('Duration y data');
figure('Position',[100 100 500 400]);
g.draw();

%% Dates as grouping data and tick formats
% Here facets are made from the quarter of each date. After draw(), the
% format of date ticks can be changed with xtickformat() (or
% ytickformat()) on the facet axes.

quarter=dateshift(t,'start','quarter');
quarter.Format='QQQ yyyy';

clear g
g=gramm('x',t,'y',temperature,'color',site);
g.facet_wrap(quarter,'ncols',4,'scale','free_x');
g.geom_line();
g.set_names('x','','y','Temperature (°C)','color','Site','column','');
g.set_title('Facets by quarter');
figure('Position',[100 100 1000 350]);
g.draw();
for ax=g.facet_axes_handles(:)'
    xtickformat(ax,'MMM d');
end
