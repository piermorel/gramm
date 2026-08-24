% gramm examples and how-tos

% Shared variable
% We stat by loading the sample data (structure created from the carbig
% dataset)
load example_data;

%% Methods for visualizing repeated trajectories
% gramm supports 2D inputs for X and Y data (as 2D array or cell of
% arrays), which is particularly useful for representing repeated
% trajectories. Here for example we generate 50 trajectories, each of
% length 40. The grouping data is then given per trajectory and not per
% data point. Here the color grouping variable is thus given as a 1x50
% cellstr.

%We generate 50 trajectories of length 40, with 3 groups
N=50;
nx=40;
cval={'A' 'B' 'C'};
cind=randi(3,N,1);
c=cval(cind);
x=linspace(0,3,nx);
y=arrayfun(@(c)sin(x*c)+randn(1,nx)/10+x*randn/5,cind,'UniformOutput',false);

clear g
g(1,1)=gramm('x',x,'y',y,'color',c);
g(1,2)=copy(g(1));
g(2,1)=copy(g(1));
g(2,2)=copy(g(1));

g(1,1).geom_point();
g(1,1).set_title('geom_point()');

g(1,2).geom_line();
g(1,2).set_title('geom_line()');

g(2,1).stat_smooth();
g(2,1).set_point_options('base_size',3);
g(2,1).set_title('stat_smooth()');

g(2,2).stat_summary();
g(2,2).set_title('stat_summary()');

g.set_title('Visualization of repeated trajectories ');

figure;
g.draw();


%% Methods for visualizing repeated event densities (e.g. spike trains)
% With the support of 2D inputs for X and gramm's functionality for
% representing the density of data, useful neuroscientific plots can be
% generated when the provided X corresponds to spike trains: raster plots
% and peristimulus time histograms (PSTHs).

%We generate 50 spike trains, with 3 groups
N=50;
cval={'A' 'B' 'C'};
cind=randi(3,N,1);
c=cval(cind);
train_template=[zeros(1,300)  ones(1,200)];
%Pseudo-poisson spike trains
spike_train=cell(N,1);
for k=1:N
    temp_train=rand*0.05+train_template/(cind(k)*8);
    U=rand(size(temp_train));
    spike_train{k}=find(U<temp_train);
end

clear g
g(1,1)=gramm('x',spike_train,'color',c);
g(1,1).geom_raster();
g(1,1).set_title('geom_raster()');

g(1,2)=gramm('x',spike_train,'color',c);
g(1,2).stat_bin('nbins',25,'geom','line');
g(1,2).set_title('stat_bin()');

g.set_names('x','Time','y','');
g.set_title('Visualization of spike densities');

figure;
g.draw();
