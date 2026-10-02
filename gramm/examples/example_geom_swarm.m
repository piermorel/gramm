% gramm examples and how-tos

% Shared variable
% We stat by loading the sample data (structure created from the carbig
% dataset)
load example_data;

%% Options for geom_swarm()

N=700;
x = floor(rand(N,1)*2);
y = randn(N,1);
y(x==1)=y(x==1)+1;
c = round(rand(N,1)*2);
c=categorical(c);
x=categorical(x);
c(x=="0" & c=="0") = "2";

figure;
clear g
g(1,1)=gramm('x',x,'y',y,'color',c);
g(1,2) = copy(g(1,1));
g(1,3) = copy(g(1,1));
g(2,1) = copy(g(1,1));
g(2,2) = copy(g(1,1));
g(2,3) = copy(g(1,1));

g(1,1).geom_swarm('point_size',2);
g(1,1).stat_summary('geom','point','dodge',0.7,'width',0.9);
g(1,1).set_title('default method ''up''');

g(1,2).geom_swarm('point_size',2,'type','fan');
g(1,2).set_title('method ''fan''');

g(1,3).geom_swarm('point_size',2,'type','hex');
g(1,3).set_title('method ''hex''');

g(2,1).geom_swarm('point_size',2,'type','square');
g(2,1).set_title('method ''square''');

g(2,2).geom_swarm('point_size',2,'corral','gutter','alpha',0.5,'dodge',0.8,'width',0.7);
g(2,2).set_title('corral ''gutter'' and alpha 0.3');

g(2,3).geom_swarm('point_size',2,'corral','omit','alpha',0.5,'dodge',0.8,'width',0.7);
g(2,3).set_title('corral ''omit'' and alpha 0.3');

g.set_title('Options for geom_swarm()');
g.draw();

%Make the points marking the group averages more visible
set([g(1,1).results.stat_summary.point_handle],'MarkerFaceColor',[0 0 0])
set([g(1,1).results.stat_summary.point_handle],'Marker','s')
set([g(1,1).results.stat_summary.point_handle],'MarkerSize',8)

