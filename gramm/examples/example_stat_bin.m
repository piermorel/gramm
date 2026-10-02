% gramm examples and how-tos

% Shared variable
% We stat by loading the sample data (structure created from the carbig
% dataset)
load example_data;

%Create variables used throughout this example
x=randn(1200,1)-1;
cat=repmat([1 1 1 2],300,1);
x(cat==2)=x(cat==2)+2;

%% Options for creating histograms with stat_bin()
% Example of different |'geom'| options:
%
% * |'bar'| (default), where color groups are side-by-side (dodged)
% * |'stacked_bar'|
% * |'line'|
% * |'overlaid_bar'|
% * |'point'|
% * |'stairs'|

clear g
g(1,1)=gramm('x',x,'color',cat);
g(1,2)=copy(g(1));
g(1,3)=copy(g(1));
g(2,1)=copy(g(1));
g(2,2)=copy(g(1));
g(2,3)=copy(g(1));

g(1,1).stat_bin(); %by default, 'geom' is 'bar', where color groups are side-by-side (dodged)
g(1,1).set_title('''bar'' (default)');

g(1,2).stat_bin('geom','stacked_bar'); %Stacked bars option
g(1,2).set_title('''stacked_bar''');

g(2,1).stat_bin('geom','line'); %Draw lines instead of bars, easier to visualize when lots of categories, default fill to edges !
g(2,1).set_title('''line''');

g(2,2).stat_bin('geom','overlaid_bar'); %Overlaid bar automatically changes bar coloring to transparent
g(2,2).set_title('''overlaid_bar''');

g(1,3).stat_bin('geom','point');
g(1,3).set_title('''point''');

g(2,3).stat_bin('geom','stairs'); %Default fill is edges
g(2,3).set_title('''stairs''');

g.set_title('''geom'' options for stat_bin()');

figure;
g.draw();


%% Normalization options for stat_bin()
%
% * Default binning
% * |'normalization','probability'|
% * |'normalization','cumcount'|
% * |'normalization','cdf'|
% * |'edges',-1:0.5:10|
% * |'normalization','countdensity'| and custom edges

clear g
g(1,1)=gramm('x',x,'color',cat);
g(1,2)=copy(g(1));
g(1,3)=copy(g(1));
g(2,1)=copy(g(1));
g(2,2)=copy(g(1));
g(2,3)=copy(g(1));

g(1,1).stat_bin('geom','overlaid_bar'); %Default binning (30 bins)

%Normalization to 'probability'
g(2,1).stat_bin('normalization','probability','geom','overlaid_bar');
g(2,1).set_title('''normalization'',''probability''','FontSize',10);

%Normalization to cumulative count
g(1,2).stat_bin('normalization','cumcount','geom','stairs');
g(1,2).set_title('''normalization'',''cumcount''','FontSize',10);

%Normalization to cumulative density
g(2,2).stat_bin('normalization','cdf','geom','stairs');
g(2,2).set_title('''normalization'',''cdf''','FontSize',10);

%Custom edges for the bins
g(1,3).stat_bin('edges',-1:0.5:10,'geom','overlaid_bar');
g(1,3).set_title('''edges'',-1:0.5:10','FontSize',10);

%Custom edges with non-constand width (normalization 'countdensity'
%recommended)
g(2,3).stat_bin('geom','overlaid_bar','normalization','countdensity','edges',[-5 -4 -2 -1 -0.5 -0.25 0 0.25 0.5  1 2 4 5]);
g(2,3).set_title({'''normalization'',''countdensity'',' '''edges'',' '[-5 -4 -2 -1 -0.5 -0.25 0 0.25 0.5  1 2 4 5]'},'FontSize',10);

g.set_title('Normalization options for stat_bin()');

figure;
g.draw();


%% Fill options for stat_bin()
%
% * |'face'|
% * |'all'|
% * |'edge'|
% * |'transparent'|

clear g
g(1,1)=gramm('x',x,'color',cat);
g(1,2)=copy(g(1));
g(1,3)=copy(g(1));
g(2,1)=copy(g(1));
g(2,2)=copy(g(1));
g(2,3)=copy(g(1));

g(1,1).stat_bin('fill','face');
g(1,1).set_title('''face''');

g(1,2).stat_bin('fill','transparent');
g(1,2).set_title('''transparent''');

g(1,3).stat_bin('fill','all');
g(1,3).set_title('''all''');

g(2,1).stat_bin('fill','edge');
g(2,1).set_title('''edge''');

g(2,2).stat_bin('geom','stairs','fill','transparent');
g(2,2).set_title('''transparent''');

g(2,3).stat_bin('geom','line','fill','all');
g(2,3).set_title('''all''');

g.set_title('''fill'' options for stat_bin()');

figure;
g.draw();
