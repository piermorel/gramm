%% Lines, points and fills
% <matlab:edit('example_geom_lines_points_fills.m') Open this example in the editor> - <index.html All gramm examples> - <../gramm_cheat_sheet.html#set_line_options set_line_options() in the cheat sheet>
%
% How the widths of lines, the sizes and borders of points, and the faces
% and edges of bars, boxes, violins and ellipses are set, and how they
% follow the 'size', 'linestyle' and 'marker' groups. Dodging of groups of
% several aesthetics is shown in <example_base_group_spacing.html Group spacing>.
%
% We start by loading the sample data (structure created from the carbig
% dataset)
%%
load example_data;

%% Widths of the different kinds of lines
% |set_line_options()| sets one width per kind of line: |'base_size'| for
% data lines (|geom_line()|, |stat_summary()|, |stat_glm()|...),
% |'edge_size'| for the edges of bars, boxes, violins and ellipses (and
% the boxplot whiskers), |'interval_size'| for errorbars, |'summary_size'|
% for the median and other summary lines of boxplots and violins, and
% |'ref_size'| for the reference lines of |geom_hline()| and the like.
% Here the same bars and errorbars (mean and standard deviation) with one
% width changed in each panel.

clear g
g(1,1)=gramm('x',cars.Origin_Region,'y',cars.Horsepower,'color',cars.Cylinders,...
    'subset',cars.Cylinders==4 | cars.Cylinders==8);
g(1,2)=copy(g(1,1));
g(2,1)=copy(g(1,1));
g(2,2)=copy(g(1,1));

for k=1:numel(g)
    g(k).stat_summary('type','std','geom',{'bar','black_errorbar'},'fill','face');
end

g(1,1).set_title('Default');

g(1,2).set_line_options('edge_size',2.5);
g(1,2).set_title('''edge_size'',2.5');

g(2,1).set_line_options('interval_size',2.5);
g(2,1).set_title('''interval_size'',2.5');

g(2,2).set_line_options('cap_size',14);
g(2,2).set_title('''cap_size'',14');

g.set_names('x','Origin','y','Horsepower','color','# Cyl');
g.set_title('set_line_options()');

figure('Position',[100 100 900 660]);
g.draw();

%% Lines and points following the 'size' groups
% With a 'size' grouping variable, lines (here the edges and summary lines
% of the boxes) get wider and points bigger from one group to the next.
% The size groups are also dodged side by side, as color groups are.
% |'size_aes',false| in |set_line_options()| or |set_point_options()|
% keeps the lines or the points at their base size, so that the groups are
% shown by the other ones only. Here the cars of the first and last model
% years.

clear g
g(1,1)=gramm('x',cars.Origin_Region,'y',cars.Horsepower,'size',1900+cars.Model_Year,...
    'subset',cars.Model_Year==70 | cars.Model_Year==82);
g(1,2)=copy(g(1,1));
g(1,3)=copy(g(1,1));

for k=1:numel(g)
    %Boxes on the left and points on the right of each group
    g(k).stat_boxplot('fill','transparent','dodge',0.9,'width',0.3,'nudge',-0.2);
    g(k).geom_jitter('dodge',0.9,'width',0.2,'nudge',0.2,'alpha',0.6);
end

g(1,1).set_title('Default');

g(1,2).set_line_options('size_aes',false);
g(1,2).set_title('set_line_options(''size_aes'',false)');

g(1,3).set_point_options('size_aes',false);
g(1,3).set_title('set_point_options(''size_aes'',false)');

g.set_names('x','Origin','y','Horsepower','size','Model year');

figure('Position',[100 100 1500 450]);
g.draw();

%% Point borders and markers in all layers
% The border options of |set_point_options()| and the 'marker' groups
% apply to every layer drawing data points: points, jittered points,
% summary points, quantiles of |stat_qq()|, boxplot outliers... Black
% borders follow the figure theme, like other black elements.

clear g
g(1,1)=gramm('x',cars.Origin_Region,'y',cars.Horsepower,'color',cars.Cylinders,'marker',cars.Cylinders,...
    'subset',(cars.Cylinders==4 | cars.Cylinders==6) & cars.Model_Year>=79);
g(1,2)=copy(g(1,1));
g(1,3)=copy(g(1,1));

g(1,1).geom_jitter('width',0.5,'dodge',0.7);
g(1,1).set_title('geom_jitter()');

g(1,2).stat_summary('type','std','geom',{'point','errorbar'},'dodge',0.5);
g(1,2).set_title('stat_summary() points');

g(1,3).stat_boxplot('fill','transparent');
g(1,3).set_title('stat_boxplot() outliers');

g.set_point_options('base_size',8,'border_color','k','border_width',1.5);
g.set_names('x','Origin','y','Horsepower','color','# Cyl','marker','# Cyl');
g.set_color_options('legend','merge');
g.set_title('set_point_options(''border_color'',''k'',''border_width'',1.5)');

figure('Position',[100 100 1200 400]);
g.draw();

%% Line styles of lines and edges
% The 'linestyle' groups apply to data lines and to the edges of bars,
% boxes, violins and ellipses (not to errorbars, whiskers and summary
% lines, where dashes would be hard to read).

clear g
g(1,1)=gramm('x',cars.Horsepower,'color',cars.Cylinders,'linestyle',cars.Cylinders,...
    'subset',cars.Cylinders==4 | cars.Cylinders==8);
g(1,1).stat_bin('geom','overlaid_bar','fill','edge');
g(1,1).set_title('stat_bin()');

g(1,2)=gramm('x',cars.Origin_Region,'y',cars.Horsepower,'color',cars.Cylinders,'linestyle',cars.Cylinders,...
    'subset',cars.Cylinders==4 | cars.Cylinders==8);
g(1,2).stat_boxplot('fill','transparent');
g(1,2).set_title('stat_boxplot()');

g(1,3)=gramm('x',cars.Horsepower,'y',cars.Acceleration,'color',cars.Cylinders,'linestyle',cars.Cylinders,...
    'subset',cars.Cylinders==4 | cars.Cylinders==8);
g(1,3).geom_point('alpha',0.3);
g(1,3).stat_ellipse('fill','edge');
g(1,3).set_title('stat_ellipse()');

g.set_names('x','Horsepower','y','','color','# Cyl','linestyle','# Cyl');
g.set_color_options('legend','merge');
g.set_line_options('edge_size',1.5);

figure('Position',[100 100 1200 380]);
g.draw();

%% Fill styles
% Elements with a face (bars of |stat_summary()|, |stat_bin()| and
% |geom_bar()|, boxes, violins, ellipses) all take the same |'fill'|
% styles: |'face'| (colored face, black edge), |'edge'| (colored edge, no
% face), |'all'| (colored face, no edge) and |'transparent'| (colored edge,
% transparent face). |'fill_alpha'| sets the transparency of the faces.

fills={'face','edge','all','transparent'};

clear g
for k=1:length(fills)
    g(1,k)=gramm('x',cars.Origin_Region,'y',cars.Horsepower,'color',cars.Cylinders,...
        'subset',cars.Cylinders==4 | cars.Cylinders==8);
    g(1,k).stat_boxplot('fill',fills{k});
    g(1,k).set_title(['stat_boxplot(''fill'',''' fills{k} ''')']);

    g(2,k)=gramm('x',cars.Origin_Region,'y',cars.Horsepower,'color',cars.Cylinders,...
        'subset',cars.Cylinders==4 | cars.Cylinders==8);
    g(2,k).stat_summary('geom',{'bar','black_errorbar'},'fill',fills{k});
    g(2,k).set_title(['stat_summary(''fill'',''' fills{k} ''')']);

    g(3,k)=gramm('x',cars.Horsepower,'y',cars.Acceleration,'color',cars.Cylinders,...
        'subset',cars.Cylinders==4 | cars.Cylinders==8);
    g(3,k).geom_point('alpha',0.3);
    g(3,k).stat_ellipse('fill',fills{k});
    g(3,k).set_title(['stat_ellipse(''fill'',''' fills{k} ''')']);
end

g.set_names('x','','y','','color','# Cyl');
g.set_layout_options('legend',false);
g.set_title('The same ''fill'' styles for all elements with a face');

figure('Position',[100 100 1200 800]);
g.draw();

%% Getting the look of earlier versions
% The widths and line styles of earlier versions of gramm can be set back:
% thinner edges, whiskers and summary lines (0.5), thicker errorbars
% (1.5), and dashed lines for the second linestyle group. Bars of
% |geom_bar()| had edges of |'LineWidth',1.5|.
% Groups of other aesthetics than color (marker, linestyle...) used to be
% drawn on top of each other instead of side by side;
% |set_dodge_options('by',{'color','lightness'})| brings that back.

clear g
g(1,1)=gramm('x',cars.Origin_Region,'y',cars.Horsepower,'color',cars.Cylinders,...
    'subset',cars.Cylinders==4 | cars.Cylinders==8);
g(1,1).stat_boxplot();
g(2,1)=gramm('x',cars.Origin_Region,'y',cars.Horsepower,'color',cars.Cylinders,...
    'subset',cars.Cylinders==4 | cars.Cylinders==8);
g(2,1).stat_summary('type','std','geom',{'bar','black_errorbar'},'fill','face');
g(3,1)=gramm('x',cars.Model_Year,'y',cars.MPG,'linestyle',cars.Cylinders,...
    'subset',cars.Cylinders==4 | cars.Cylinders==6 | cars.Cylinders==8);
g(3,1).stat_summary('geom','line');
for k=1:3
    g(k,2)=copy(g(k,1));
end

g(1,1).set_title('Current defaults');
g(1,2).set_title('Defaults of earlier versions');
g(:,2).set_line_options('edge_size',0.5,'interval_size',1.5,'styles',{'-' '--' ':' '-.'});

g.set_names('x','','y','','color','# Cyl','linestyle','# Cyl');

figure('Position',[100 100 900 900]);
g.draw();
