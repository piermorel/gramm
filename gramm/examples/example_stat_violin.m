% gramm examples and how-tos

% Shared variable
% We stat by loading the sample data (structure created from the carbig
% dataset)
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
figure;
g.draw();

