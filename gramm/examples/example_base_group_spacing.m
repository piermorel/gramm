%% Group spacing
% <matlab:edit('example_base_group_spacing.m') Open this example in the editor> - <index.html All gramm examples> - <../gramm_cheat_sheet.html#stat_boxplot stat_boxplot() in the cheat sheet>
%
% We start by loading the sample data (structure created from the carbig
% dataset)
%%
load example_data;

%% Group spacing: dodge and width options for grouped elements
% When a color grouping variable is used with categorical X data, graphical
% elements (boxes, bars, points...) of different groups can be placed
% side-by-side using the |'dodge'| option, and their size controlled with
% |'width'|. Here demonstrated with |stat_boxplot()|, but the same options
% apply to |stat_summary()| (last panel) and |stat_bin()|.

%Create data
x=repmat(1:10,1,100);
catx=repmat({'A' 'B' 'C' 'F' 'E' 'D' 'G' 'H' 'I' 'J'},1,100);
y=randn(1,1000)*3;
c=repmat([1 1 1 1 1 1 1 1 1 1    1 1 2 2 2 2 2 3 2 2     2 1 1 2 2 2 2 3 2 3     2 1 1 2 2 2 2 2 2 2],1,25);
y=2+y+x+c*0.5;


clear g
g(1,1)=gramm('x',catx,'y',y,'color',c);
g(1,2)=copy(g(1));
g(2,1)=copy(g(1));
g(2,2)=copy(g(1));
g(3,1)=copy(g(1));
g(3,2)=copy(g(1));


g(1,1).stat_boxplot();
g(1,1).geom_vline('xintercept',0.5:1:10.5,'style','k-');
g(1,1).set_title('''width'',0.6,''dodge'',0.7 (Default)');

g(1,2).stat_boxplot('width',0.5,'dodge',0);
g(1,2).geom_vline('xintercept',0.5:1:10.5,'style','k-');
g(1,2).set_title('''width'',0.5,''dodge'',0');

g(2,1).stat_boxplot('width',1,'dodge',1);
g(2,1).geom_vline('xintercept',0.5:1:10.5,'style','k-');
g(2,1).set_title('''width'',1,''dodge'',1');

g(2,2).stat_boxplot('width',0.6,'dodge',0.4);
g(2,2).geom_vline('xintercept',0.5:1:10.5,'style','k-');
g(2,2).set_title('''width'',0.6,''dodge'',0.4');

g(3,1).facet_grid([],c);
g(3,1).stat_boxplot('width',0.5,'dodge',0,'notch',true);
g(3,1).set_title('''width'',0.5,''dodge'',0,''notch'',true');

g(3,2).stat_summary('geom',{'bar','black_errorbar'},'width',0.6,'dodge',0.7);
g(3,2).geom_vline('xintercept',0.5:1:10.5,'style','k-');
g(3,2).set_title('stat_summary(), ''width'',0.6,''dodge'',0.7');

g.set_title('Dodge and spacing options for stat_boxplot()');

figure('Position',[100 100 1100 660]);
g.draw();
