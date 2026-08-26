% gramm examples and how-tos

% Shared variable
% We stat by loading the sample data (structure created from the carbig
% dataset)
load example_data;

%% Visualize x-y difference with inset histogram using stat_cornerhist()


%Generate sample data
N=200;
x=randn(1,N*4);
y=x+randn(1,N*4)/2;
c=repmat([1 2],1,N*2);
b=repmat([1 2 2 2],1,N);
y(c==1 & b==2)=y(c==1 & b==2)+2;


clear g
g=gramm('x',x,'y',y,'color',c);
g.facet_grid([],b);
g.geom_point();
g.stat_cornerhist('edges',-4:0.1:2,'aspect',0.5);
g.geom_abline();

g.set_title('Visualize x-y with stat_cornerhist()');
figure;
g.draw();

%Possibility to use axe handles of the inset axes to add elements or change
%properties
plot(g.results.stat_cornerhist(2).child_axe_handle,[-2 -2],[0 50],'k:','LineWidth',2)
%set([g.results.stat_cornerhist.child_axe_handle],'XTick',[])