% gramm examples and how-tos

% Shared variable
% We stat by loading the sample data (structure created from the carbig
% dataset)
load example_data;

%% Smooth continuous data with stat_smooth()

x=0:0.02:9.8;
y=sin(exp(x-5)/12);
y(x<2)=y(x<2)+randn(1,sum(x<2))/2;
y(x>=2)=y(x>=2)+randn(1,sum(x>=2))/8;

figure;
clear g
g=gramm('x',x,'y',y);
g.geom_funline('fun',@(x)sin(exp(x-5)/12));
g.geom_vline('xintercept',2)
g.axe_property('XLim',[0 9.8]);
g(1,2)=copy(g(1));
g(1,3)=copy(g(1));
g(2,1)=copy(g(1));
g(2,2)=copy(g(1));
g(2,3)=copy(g(1));
g(1,1).geom_point();
g(1,1).set_title('Raw input');

g(1,2).stat_smooth();
g(1,2).set_title('stat_smooth() default');

g(1,3).stat_smooth('lambda','auto','npoints',500);
g(1,3).set_title('default with ''lambda'',''auto''');

g(2,1).stat_smooth('method','sgolay','lambda',[31 3]);
g(2,1).set_title('''method'',''sgolay''');

g(2,2).stat_smooth('method','moving','lambda',31);
g(2,2).set_title('''method'',''moving''');


g(2,3).stat_smooth('method','loess','lambda',0.1,'setylim',true);
g(2,3).set_title('''method'',''loess'',''setylim'',''true''');

g.set_title('Options for stat_smooth()');
g.draw();


