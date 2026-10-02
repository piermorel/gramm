% gramm examples and how-tos

% Shared variable
% We stat by loading the sample data (structure created from the carbig
% dataset)
load example_data;

%% Create a broken axis

x=[randn(1,50)*2 randn(1,50)*8+70];
y=-x;
g(1,1)=gramm('x',x,'y',y);
g(1,1).geom_point();
g(1,1).set_title('Without broken axis');


g(2,1)=gramm('x',x,'y',y);
g(2,1).facet_grid([],x>20,"scale","free_x","space","free_x","column_labels",false);
g(2,1).geom_point();
g(2,1).set_title('With broken axis');
figure;
g.draw();
g(2,1).facet_axes_handles(2).YAxis.Visible='off';
g(2,1).facet_axes_handles(1).XLim=[-5 6];
g(2,1).facet_axes_handles(1).XTick=-5:5:5;
g(2,1).facet_axes_handles(2).XLim=[50 90];
g(2,1).facet_axes_handles(2).XTick=50:5:90;