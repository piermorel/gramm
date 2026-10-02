% gramm examples and how-tos

% Shared variable
% We stat by loading the sample data (structure created from the carbig
% dataset)
load example_data;

%% Options for separating groups across subplots with facet_grid()
% To separate groups in different rows and columns of sublots, the grouping
% variable just need to be passed to the
% |facet_grid(goup_rows,group_columns)| function or |facet_wrap(group_columns)|. Both have multiple
% options concerning the scaling of data between subplots.
%
% * By default |'scale','fixed'| all subplots have the same limits
% * |'scale','free_x'|: subplots on the same columns have the same x limits
% * |'scale','free_y'|: subplots on the same rows have the same y limits
% * |'scale','free'|: subplots on the same rows have the same y limits,
% subplots on the same columns have the same x limits
% * |'scale','independent'|: subplots have independent limits
%
% In |facet_grid()|; the |'space'| option allows to set how the subplot axes themselves scale with
% the data. It should be used in conjunction with the corresponding
% |'scale'| option.


% Generating fake data
N=1000;
colval={'A' 'B' 'C'};
rowval={'I' 'II'};
cind=randi(3,N,1);
c=colval(cind);
rind=randi(2,N,1);
r=rowval(rind);

x=randn(N,1);
y=randn(N,1);

x(cind==1 & rind==1)=x(cind==1  & rind==1)*5;
x=x+cind*3;
y(cind==3 & rind==2)=y(cind==3  & rind==2)*3;
y=y-rind*4;

clear g
g(1,1)=gramm('x',x,'y',y,'color',c,'lightness',r);
g(1,2)=copy(g(1));
g(2,1)=copy(g(1));
g(2,2)=copy(g(1));
g(3,1)=copy(g(1));
g(3,2)=copy(g(1));

g(1,1).geom_point();
g(1,1).set_title('No facets');

g(1,2).facet_grid(r,c);
g(1,2).geom_point();
g(1,2).no_legend();
g(1,2).set_title('facet_grid()');


g(2,1).facet_grid(r,c,'scale','free');
g(2,1).geom_point();
g(2,1).no_legend();
g(2,1).set_title('facet_grid(''scale'',''free'')');

g(2,2).facet_grid(r,c,'scale','free','space','free');
g(2,2).geom_point();
g(2,2).no_legend();
g(2,2).set_title('facet_grid(''scale'',''free'',''space'',''free'')');

g(3,1).facet_grid(r,c,'scale','free_x');
g(3,1).geom_point();
g(3,1).no_legend();
g(3,1).set_title('facet_grid(''scale'',''free_x'')');

g(3,2).facet_grid(r,c,'scale','independent');
g(3,2).geom_point();
g(3,2).no_legend();
g(3,2).set_title('facet_grid(''scale'',''independent'')');

g.set_color_options('lightness_range',[40 80],'chroma_range',[80 40]);
g.set_names('column','','row','');
%g.axe_property('color',[0.9 0.9 0.9],'XGrid','on','YGrid','on','GridColor',[1 1 1],'GridAlpha',0.8,'TickLength',[0 0],'XColor',[0.3 0.3 0.3],'YColor',[0.3 0.3 0.3])

gf = copy(g);

figure;
g.set_title('facet_grid() options');
g.draw();

figure;
gf.set_title({'facet_grid() options' 'work together with coord_flip()'});
gf.coord_flip();
gf.draw();
