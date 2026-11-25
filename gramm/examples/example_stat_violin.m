% Violin plots
% <matlab:edit('example_stat_violin.m') Open this example in the editor> - <index.html All gramm examples> - <../gramm_cheat_sheet.html#stat_violin stat_violin() in the cheat sheet>
%
% We start by loading the sample data (structure created from the carbig
% dataset)
%%
load example_data;

%% Graphic and normalization options in stat_violin()

clear g
g(1,1)=gramm('x',cars.Origin_Region,'y',cars.Horsepower,'color',cars.Cylinders,'subset',cars.Cylinders~=3 & cars.Cylinders~=5);
g(1,1).set_names('x','Origin','y','Horsepower','color','# Cyl');
g(1,2)=copy(g(1,1));
g(1,3)=copy(g(1,1));
g(2,1)=copy(g(1,1));
g(2,2)=copy(g(1,1));

%Jittered scatter plot
g(1,1).geom_jitter('width',0.6,'height',0,'dodge',0.7);
g(1,1).set_title('jittered data');


g(1,2).stat_violin('normalization','area');
g(1,2).set_title('''normalization'',''area'' (Default)');

g(1,3).stat_violin('normalization','width');
g(1,3).set_title('''normalization'',''width''');

g(2,1).stat_violin('normalization','count','fill','all');
g(2,1).set_title('''normalization'',''count'' , ''fill'',''all''');

g(2,2).stat_violin('half',true,'normalization','count','width',1,'fill','transparent');
g(2,2).set_title('''half'',true , ''fill'',''transparent''');

g(2,3)=gramm('x',cars.Origin_Region,'y',cars.Horsepower,'color',cars.Origin_Region,'subset',cars.Cylinders~=3 & cars.Cylinders~=5);
g(2,3).set_names('x','Origin','y','Horsepower','color','Origin');
g(2,3).stat_violin('normalization','area','dodge',0,'fill','edge');
g(2,3).stat_boxplot('width',0.15);
g(2,3).set_title('with stat_boxplot()');
g(2,3).set_color_options('map','brewer_dark');

g.set_title('Options for stat_violin()');
figure('Position',[100 100 1100 660]);
g.draw();

%% Summary lines in violins and boxplots
% The 'lines' option of stat_violin() and stat_boxplot() draws lines across
% the violins or boxes: 'median' (solid), 'quartiles' (semi-transparent),
% 'mean' (dotted), or numeric quantiles (semi-transparent). The quantiles
% are computed from the data, so they are the same in both. In boxplots the
% default is 'median', and adding 'mean' shows the skewness of the
% distribution. The lines are stored in the results (median_handle,
% quantile_handle, mean_handle) to change their appearance after drawing
% (quantile_handle is a patch, with 'EdgeColor' and 'EdgeAlpha').

clear g
g(1,1)=gramm('x',cars.Origin_Region,'y',cars.Horsepower,'color',cars.Origin_Region,'subset',cars.Cylinders~=3 & cars.Cylinders~=5);
g(1,1).set_names('x','Origin','y','Horsepower','color','Origin');
g(1,1).set_color_options('map','brewer_dark');
g(1,2)=copy(g(1,1));
g(1,3)=copy(g(1,1));

g(1,1).stat_violin('dodge',0,'fill','transparent','lines',{'median','quartiles'});
g(1,1).set_title('''lines'',{''median'',''quartiles''}'); 

g(1,2).stat_violin('dodge',0,'fill','transparent','lines',[0.1 0.5 0.9]);
g(1,2).set_title('''lines'',[0.1 0.5 0.9]');

g(1,3).stat_boxplot('dodge',0,'lines',{'median','mean'});
g(1,3).set_title('stat_boxplot(''lines'',{''median'',''mean''})');

g.set_layout_options('legend',false);
g.set_title('Summary lines');
figure('Position',[100 100 1100 450]);
g.draw();
