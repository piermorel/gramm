% gramm examples and how-tos

% Shared variable
% We stat by loading the sample data (structure created from the carbig
% dataset)
load example_data;


%% Plots of different sizes
% gramm plots can be drawn in tiles of a tiledlayout with
% set_parent(layout,'tile',tile,'span',span). tile and span work as in
% nexttile(): tile is the number of the first tile (counted row by row, or
% given as [row column]) and span is the number of [rows columns] covered
% by the plot.

figure('Position',[100 100 1000 600]);
t=tiledlayout(2,3);

%Large plot on the left, spanning 2 rows and 2 columns
g_large=gramm('x',cars.Horsepower,'y',cars.MPG,'color',cars.Cylinders,'subset',cars.Cylinders~=3 & cars.Cylinders~=5);
g_large.set_parent(t,'tile',1,'span',[2 2]);
g_large.geom_point();
g_large.stat_glm();
g_large.set_names('x','Horsepower','y','MPG','color','# Cyl');
g_large.set_title('Fuel economy vs. horsepower');
g_large.draw();

%Two smaller plots on the right
g_top=gramm('x',cars.Origin_Region,'y',cars.MPG,'color',cars.Origin_Region);
g_top.set_parent(t,'tile',3);
g_top.stat_boxplot();
g_top.set_names('x','','y','MPG');
g_top.set_layout_options('legend',false);
g_top.set_title('Per region');
g_top.draw();

g_bottom=gramm('x',cars.Model_Year,'y',cars.MPG);
g_bottom.set_parent(t,'tile',6);
g_bottom.stat_summary('geom','area');
g_bottom.set_names('x','Year','y','MPG');
g_bottom.set_title('Over the years');
g_bottom.draw();


%% Combine gramm with regular Matlab axes
% The other tiles of the tiledlayout can hold any Matlab plot, created with
% nexttile() as usual

figure('Position',[100 100 900 400]);
t=tiledlayout(1,2);

g=gramm('x',cars.Weight,'y',cars.Acceleration,'color',cars.Origin_Region);
g.set_parent(t,'tile',1);
g.geom_point();
g.set_names('x','Weight','y','Acceleration','color','Origin');
g.set_title('gramm plot');
g.draw();

ax=nexttile(t,2);
imagesc(ax,corr([cars.Horsepower cars.Weight cars.Acceleration cars.MPG],'rows','complete'));
axis(ax,'image');
colorbar(ax);
ax.XTick=1:4; ax.YTick=1:4;
ax.XTickLabel={'Horsepower','Weight','Acceleration','MPG'};
ax.YTickLabel=ax.XTickLabel;
title(ax,'Regular Matlab axes (correlations)');


%% Array of gramm plots in a tile
% An array of gramm plots can itself be drawn in a tile: give the tile to
% the whole array with set_parent()

figure('Position',[100 100 1000 600]);
t=tiledlayout(1,3);

clear g
g(1,1)=gramm('x',cars.Horsepower,'y',cars.MPG,'color',cars.Origin_Region);
g(1,1).geom_point();
g(1,1).set_title('Points');
g(2,1)=gramm('x',cars.Horsepower,'y',cars.MPG,'color',cars.Origin_Region);
g(2,1).stat_glm();
g(2,1).set_title('Fits');
g.set_names('x','Horsepower','y','MPG','color','Origin');
g.set_title('Array of gramm plots spanning two tiles');
g.set_parent(t,'tile',1,'span',[1 2]);
g.draw();

g2=gramm('x',cars.MPG,'color',cars.Origin_Region);
g2.set_parent(t,'tile',3);
g2.stat_density();
g2.set_names('x','MPG','color','Origin');
g2.set_title('Single plot');
g2.draw();
