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

%% Dodging groups of several aesthetics
% Elements are dodged for each combination of the color, lightness,
% marker, linestyle and size groups, colors being the outer level. Here a
% 'linestyle' variable independent of color gives two boxes per color
% (first panel).
% Groups given as 'group' are not dodged: they usually are units drawn as
% separate lines, such as subjects, which stay in the slot of their color
% (second panel).
% |set_dodge_options('by',...)| chooses the aesthetics that are dodged.
% Summaries such as boxes need all their groups dodged, but points can
% also share the slot of their color, with markers showing a secondary
% attribute (last two panels).

%Second grouping variable, independent of x and of the colors
period=[repmat({'Before'},1,500) repmat({'After'},1,500)];
y2=y+strcmp(period,'After')*3;
sel=c<3 & ismember(catx,{'A','B','C','D'});

%Synthetic repeated measures: 20 subjects in two treatment groups,
%measured in three sessions
n_subj=20;
[session,subject]=ndgrid(1:3,1:n_subj);
treatment=repmat({'Drug'},size(subject));
treatment(subject>n_subj/2)={'Placebo'};
sex=repmat({'F'},size(subject));
sex(mod(subject,2)==0)={'M'};
score=10+session.*strcmp(treatment,'Drug')+1.5*strcmp(sex,'M')+...
    repmat(randn(1,n_subj),3,1)+0.5*randn(size(subject));
session_names={'S1','S2','S3'};
session_names=session_names(session(:));

clear g
g(1,1)=gramm('x',catx,'y',y2,'color',c,'linestyle',period,'subset',sel);
g(1,1).stat_boxplot('fill','transparent');
g(1,1).set_names('linestyle','Period');
g(1,1).set_title('Color and linestyle groups dodged');

g(1,2)=gramm('x',session_names,'y',score(:),'color',treatment(:),'group',subject(:));
g(1,2).geom_line('dodge',0.4);
g(1,2).geom_point('dodge',0.4);
g(1,2).set_names('x','Session','y','Score','color','Treatment');
g(1,2).set_title('Subjects (''group'') not dodged');

g(2,1)=gramm('x',session_names,'y',score(:),'color',treatment(:),'marker',sex(:));
g(2,1).geom_point('dodge',0.6);
g(2,1).set_names('x','Session','y','Score','color','Treatment','marker','Sex');
g(2,1).set_title('Color and marker groups dodged');

g(2,2)=copy(g(2,1));
g(2,2).geom_point('dodge',0.6);
g(2,2).set_dodge_options('by',{'color'});
g(2,2).set_title('set_dodge_options(''by'',{''color''})');

g(2,:).set_point_options('base_size',7,'markers',{'o','^'});
g.set_title('Dodging of groups of several aesthetics');

figure('Position',[100 100 1100 760]);
g.draw();
