% gramm examples and how-tos

%% Polar plots: tuning curves
% set_polar() draws on polar axes: x is the angle and y the radius. Angles
% are in radians by default, or in degrees with set_polar('unit','degrees')
% (the angle axis then shows degrees too). With 'closed', lines connect
% the last and first angles. stat_summary() with 'interp','polar' smoothly
% interpolates around the circle with interpft(), which needs angles
% regularly spaced around the full circle. When x takes only a few
% different angles, the angle ticks are placed at these angles. Polar
% plots need MATLAB R2025a or newer.

% Synthetic firing rates of three neurons recorded over repeated trials of
% movements in 8 directions (every 45 degrees), before and after learning
rng(1);
directions=0:45:315;
n_trials=15;
[dir_ind,trial,neuron_ind,cond_ind]=ndgrid(1:8,1:n_trials,1:3,1:2);
movement_direction=directions(dir_ind(:))';
preferred=[45 160 270];
gain=[12 18 10 ; 25 18 16];
mean_rate=4+gain(sub2ind(size(gain),cond_ind(:),neuron_ind(:))).*exp(2*(cosd(movement_direction-preferred(neuron_ind(:))')-1));
% Spike counts in 1-s trials follow a Poisson distribution (spikes are
% drawn independently in 1-ms bins)
rate=sum(rand(numel(mean_rate),1000)<mean_rate/1000,2);
neuron_names={'Neuron 1','Neuron 2','Neuron 3'};
neuron=neuron_names(neuron_ind(:))';
cond_names={'Before','After'};
condition=cond_names(cond_ind(:))';

clear g
g=gramm('x',movement_direction,'y',rate,'color',condition);
g.facet_wrap(neuron,'ncols',3);
g.set_polar('unit','degrees','closed',true);
g.geom_point('alpha',0.2);
g.stat_summary('geom',{'area','line'},'interp','polar');
g.geom_hline('yintercept',4,'style','k:');
g.set_order_options('color',{'Before','After'});
g.set_names('x','Movement direction','y','Firing rate (Hz)','color','','column','');
g.set_title('Tuning curves');
figure('Position',[100 100 900 400]);
g.draw();

%% Polar histograms: wind rose
% stat_bin() makes wedges in polar plots. Bin edges are given in the angle
% unit. The orientation of the angle axis (here, compass orientation) is
% set with axe_property()

% Synthetic wind directions (in degrees) and speeds for two seasons
n=1500;
season=repmat({'Winter';'Summer'},n/2,1);
wind_direction=mod(250+40*randn(n,1)-150*strcmp(season,'Summer').*(rand(n,1)>0.6),360);
speed=categorical(discretize(abs(8+5*randn(n,1)),[0 5 10 15 Inf],...
    'categorical',{'0-5','5-10','10-15','>15'}),{'0-5','5-10','10-15','>15'});

clear g
g=gramm('x',wind_direction,'color',speed);
g.facet_grid([],season);
g.set_polar('unit','degrees');
g.stat_bin('edges',0:22.5:360,'geom','stacked_bar','fill','face');
g.axe_property('ThetaZeroLocation','top','ThetaDir','clockwise');
g.set_color_options('map','d3_10');
g.set_names('x','Wind direction','y','Count','color','Wind speed (m/s)','column','');
g.set_title('Wind rose');
figure('Position',[100 100 900 450]);
g.draw();

%% Radar charts
% Categorical x data is evenly spread around the circle, with the
% categories as angle ticks. Here, attributes of cars (each rescaled
% between 0 and 1 over all cars) are averaged by region of origin

load example_data;
attributes={'MPG','Acceleration','Horsepower','Weight','Displacement'};
value=[];
attribute={};
region={};
for k=1:numel(attributes)
    v=cars.(attributes{k});
    value=[value ; (v-min(v))/(max(v)-min(v))];
    attribute=[attribute ; repmat(attributes(k),numel(v),1)];
    region=[region ; cars.Origin_Region];
end

clear g
g=gramm('x',categorical(attribute,attributes),'y',value,'color',region);
g.set_polar('closed',true,'maxy',1);
g.stat_summary('geom',{'area','line','point'});
g.axe_property('ThetaZeroLocation','top','ThetaDir','clockwise');
g.set_names('x','','y','Rescaled value','color','Origin');
g.set_title('Car attributes by region of origin');
figure('Position',[100 100 600 500]);
g.draw();
