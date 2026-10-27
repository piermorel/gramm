% gramm examples and how-tos

% Shared variable
% We stat by loading the sample data (structure created from the carbig
% dataset)
load example_data;


%% Use custom layouts in gramm, marginal histogram example
% Custom layouts are made by drawing gramm plots in tiles of a tiledlayout
% with set_parent(layout,'tile',tile,'span',span), where tile and span work as
% in nexttile(). Here the scatter plot spans 3x3 tiles of a 4x4 layout, with
% the histograms in the top row and in the right column.

load fisheriris.mat

figure('Position',[100 100 600 550]);
t=tiledlayout(4,4,'TileSpacing','compact','Padding','compact');

%Create x data histogram on top (first row, first 3 columns)
g_top=gramm('x',meas(:,2),'color',species);
g_top.set_parent(t,'tile',1,'span',[1 3]);
g_top.set_layout_options('legend',false); % No need to display legend for side histograms
g_top.set_names('x','','y','Count');
g_top.stat_bin('geom','stacked_bar','fill','all','nbins',15); %histogram
g_top.axe_property('XTickLabel',''); % We deactivate the ticks

%Create a scatter plot (rows 2 to 4, columns 1 to 3)
g_main=gramm('x',meas(:,2),'y',meas(:,1),'color',species);
g_main.set_parent(t,'tile',5,'span',[3 3]);
g_main.set_names('x','Sepal Width','y','Sepal Length','color','Species');
g_main.geom_point(); %Scatter plot
g_main.set_point_options('base_size',6);
%The legend is moved to the free top right corner (in normalized figure
%units), so that the scatter plot keeps the width of the top histogram
g_main.set_layout_options('legend_position',[0.8 0.78 0.18 0.2]);
g_main.axe_property('Ygrid','on'); 

%Create y data histogram on the right (rows 2 to 4, last column)
g_right=gramm('x',meas(:,1),'color',species);
g_right.set_parent(t,'tile',8,'span',[3 1]);
g_right.set_layout_options('legend',false);
g_right.set_names('x','','y','Count');
g_right.stat_bin('geom','stacked_bar','fill','all','nbins',15); %histogram
g_right.coord_flip();
g_right.axe_property('XTickLabel','');

%Set global properties and draw the three plots
g=[g_top g_main g_right];
g.axe_property('TickDir','out','XGrid','on','GridColor',[0.5 0.5 0.5]);
g.set_color_options('map','d3_10');
title(t,'Fisher Iris, custom layout','FontWeight','bold');
for k=1:numel(g)
    g(k).draw();
end
