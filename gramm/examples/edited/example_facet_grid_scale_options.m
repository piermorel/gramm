%% Facet Grid Scale Options
% This example demonstrates how |facet_grid()| splits data into subplot
% grids and how the |'scale'| and |'space'| options control axis limits
% and subplot sizing.
%
% Available scale options:
%
% * |'fixed'| (default) - all subplots share the same axis limits
% * |'free_x'| - columns share x limits independently
% * |'free_y'| - rows share y limits independently
% * |'free'| - rows share y, columns share x independently
% * |'independent'| - each subplot has fully independent limits
%
% The |'space'| option (used with |'free'|) additionally scales the
% physical size of each subplot proportionally to its data range.

%% Load sample data

load example_data;

%% Generate synthetic grouped data
% We create data with different spreads across groups to highlight how
% scale options behave.

N = 1000;
colval = {'A' 'B' 'C'};
rowval = {'I' 'II'};
cind = randi(3, N, 1);
c = colval(cind);
rind = randi(2, N, 1);
r = rowval(rind);

x = randn(N, 1);
y = randn(N, 1);

x(cind==1 & rind==1) = x(cind==1 & rind==1) * 5;
x = x + cind*3;
y(cind==3 & rind==2) = y(cind==3 & rind==2) * 3;
y = y - rind*4;

%% Create gramm array for comparison

clear g

g(1,1) = gramm('x',x,'y',y,'color',c,'lightness',r);
g(1,2) = copy(g(1));
g(2,1) = copy(g(1));
g(2,2) = copy(g(1));
g(3,1) = copy(g(1));
g(3,2) = copy(g(1));

%% No facets (baseline)
% All data in a single plot for reference.

g(1,1).geom_point();
g(1,1).set_title('No facets');

%% Default facet_grid (fixed scale)
% Groups are split across rows and columns. All subplots share
% identical axis limits.

g(1,2).facet_grid(r, c);
g(1,2).geom_point();
g(1,2).no_legend();
g(1,2).set_title('facet_grid()');

%% Free scale
% Each row gets independent y limits, each column gets independent x
% limits. Reveals the true spread within each group.

g(2,1).facet_grid(r, c, 'scale','free');
g(2,1).geom_point();
g(2,1).no_legend();
g(2,1).set_title('facet_grid(''scale'',''free'')');

%% Free scale with proportional space
% Combined with |'space','free'|, subplot physical dimensions scale
% proportionally to the data range. Wider data gets wider panels.

g(2,2).facet_grid(r, c, 'scale','free', 'space','free');
g(2,2).geom_point();
g(2,2).no_legend();
g(2,2).set_title('facet_grid(''scale'',''free'',''space'',''free'')');

%% Free x only
% Columns get independent x limits but all rows share y limits.

g(3,1).facet_grid(r, c, 'scale','free_x');
g(3,1).geom_point();
g(3,1).no_legend();
g(3,1).set_title('facet_grid(''scale'',''free_x'')');

%% Fully independent scales
% Each subplot determines its own limits with no sharing. Useful for
% exploratory analysis when group distributions differ drastically.

g(3,2).facet_grid(r, c, 'scale','independent');
g(3,2).geom_point();
g(3,2).no_legend();
g(3,2).set_title('facet_grid(''scale'',''independent'')');

%% Apply shared styling and draw

g.set_color_options('lightness_range',[40 80],'chroma_range',[80 40]);
g.set_names('column','','row','');

gf = copy(g);

figure;
g.set_title('facet_grid() options');
g.draw();

%% Bonus: coord_flip() works with all facet options
% All scale and space options compose naturally with |coord_flip()|.

figure;
gf.set_title({'facet_grid() options' 'combined with coord_flip()'});
gf.coord_flip();
gf.draw();
