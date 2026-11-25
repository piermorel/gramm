%% Raincloud plots
% <matlab:edit('example_advanced_raincloud_plots.m') Open this example in the editor> - <index.html All gramm examples> - <../gramm_cheat_sheet.html#stat_violin stat_violin() in the cheat sheet>
%
% Raincloud plots show a distribution three ways side by side: a half
% violin (the cloud), a narrow boxplot, and the raw data points (the rain).
% In gramm they are made of three layers placed next to each other with the
% 'nudge' option of stat_violin(), stat_boxplot(), geom_jitter(),
% geom_swarm() and stat_summary().
%
% We start by loading the sample data (structure created from the carbig
% dataset)
%%
load example_data;

%% Nudging layers next to each other
% 'nudge' shifts a layer horizontally by a fixed amount, in the same units
% as 'width' (a fraction of the space available for each x value). Here
% the half violin starts at the x value, the box is just left of it and
% the jittered points further left.

clear g
g=gramm('x',cars.Origin_Region,'y',cars.Horsepower);
g.stat_violin('half','right','width',0.7,'fill','transparent');
g.stat_boxplot('width',0.06,'nudge',-0.05);
g.geom_jitter('width',0.15,'nudge',-0.2,'alpha',0.5);
g.set_names('x','Origin','y','Horsepower');
g.set_title('Raincloud plot');
figure('Position',[100 100 700 450]);
g.draw();

%% Rainclouds with several colors
% When dodging, all layers must use the same 'dodge'. Widths and nudges are
% then divided by the number of colors, so the same values keep the
% layers of each color together. Here geom_swarm() replaces geom_jitter()
% to avoid overlapping points: with 'half', the swarm grows on one side of
% its x position, like a half violin, so it sits against the flat side of
% the violin without any nudge ('corral' can keep it within half of its
% 'width'). The 'square' type stacks the points in rows, as a dot
% histogram. With 'normalization','count', the areas of the violins are
% proportional to the number of points.

clear g
g=gramm('x',cars.Origin_Region,'y',cars.Horsepower,'color',cars.Cylinders,...
    'subset',cars.Cylinders==4 | cars.Cylinders==6);
g.stat_violin('half','right','width',0.7,'dodge',0.8,'fill','transparent','normalization','count');
g.geom_swarm('half','left','point_size',2,'width',0.5,'dodge',0.8,'type','square');
g.set_names('x','Origin','y','Horsepower','color','# Cyl');
g.set_title('Rainclouds with several colors');
figure('Position',[100 100 1000 450]);
g.draw();

%% Variants
% The violin can be on either side, the box replaced by a mean and
% confidence interval from stat_summary() or by summary lines across the
% violin ('lines' option of stat_violin(): median solid, quartiles
% semi-transparent, mean dotted), and the plot turned horizontal with
% coord_flip().

clear g
g(1,1)=gramm('x',cars.Origin_Region,'y',cars.Horsepower);
g(1,2)=copy(g(1,1));
g(1,3)=copy(g(1,1));
g(1,4)=copy(g(1,1));

%Violin on the left, points on the right
g(1,1).stat_violin('half','left','width',0.7,'fill','transparent');
g(1,1).stat_boxplot('width',0.06,'nudge',0.05);
g(1,1).geom_jitter('width',0.15,'nudge',0.2,'alpha',0.5);
g(1,1).set_title('''half'',''left''');

%Mean and 95% CI instead of the box
g(1,2).stat_violin('half','right','width',0.7,'fill','transparent');
g(1,2).stat_summary('geom',{'black_point','black_errorbar'},'nudge',-0.05);
g(1,2).geom_jitter('width',0.15,'nudge',-0.2,'alpha',0.5);
g(1,2).set_title('with stat_summary()');

%Median, quartiles and mean as lines across the violin instead of the box
g(1,3).stat_violin('half','right','width',0.7,'fill','transparent',...
    'lines',{'median','quartiles','mean'});
g(1,3).geom_jitter('width',0.15,'nudge',-0.1,'alpha',0.5);
g(1,3).set_title('''lines'' in stat_violin()');

%Horizontal raincloud
g(1,4).stat_violin('half','right','width',0.7,'fill','transparent');
g(1,4).stat_boxplot('width',0.06,'nudge',-0.05);
g(1,4).geom_jitter('width',0.15,'nudge',-0.2,'alpha',0.5);
g(1,4).coord_flip();
g(1,4).set_title('with coord_flip()');

g.set_names('x','Origin','y','Horsepower');
g.set_title('Raincloud variants');
figure('Position',[100 100 1400 450]);
g.draw();
