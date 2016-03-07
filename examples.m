%% Generate fake data

N=400

%Create a x and y data
x=linspace(0,100,N);
y=sin(x/10)+randn(1,N)*0.5; 

%Create groups
twoalt=repmat([1 2],1,N/2);
twoaltb=repmat([1 1 2 2],1,N/4);
twoaltc=repmat({'A' 'B'},1,N/2);
twoaltcb=repmat({'one' 'one' 'two' 'two'},1,N/4);
twoaltcc=repmat({'1' '1' '2' '1'},1,N/4);
fouraltc=repmat({'alpha' 'beta' 'gamma' 'epsilon'},1,N/4);
eightaltc=repmat({'I' 'II' 'III' 'IV' 'V' 'VI' 'VII' 'VIII'},1,N/8)

%Change data between groups
y(twoalt==1)=y(twoalt==1)+8;
x(twoalt==1)=x(twoalt==1)+30;
y(twoaltb==1)=y(twoaltb==1)+2;
x(twoaltb==1)=x(twoaltb==1)-90;


%% Example use

figure
g1=gramm('x',x,'y',y,'color',fouraltc,'linestyle',twoaltcb)
g1.facet_grid(twoaltc,twoaltcb,'scale','fixed')
g1.geom_point()
g1.stat_smooth('lambda',1000,'geom','area')
%It's possible to set native axis properties
g1.axe_property('XGrid','on','YGrid','on')
g1.draw()

%% Plot multiple gramm objects in single window

%Just create an array of gramm objects, each graph being a different
%element (they stay independent), rows will be rows, columns will be
%columns, starting from top left

clear g2

g2(1,1)=gramm('x',x,'y',y,'color',fouraltc)
g2(1,1).facet_grid(twoaltc,twoaltcb) %,'scales','independent'
g2(1,1).stat_smooth('lambda',1000,'geom','area')
g2(1,1).geom_point()

g2(1,2)=gramm('x',y,'y',x,'color',twoaltc)
g2(1,2).geom_point()
 
% X data can be a cellstr, data will be treated as being categorical
g2(2,1)=gramm('x',fouraltc,'y',y,'color',twoaltcb,'size',4)
g2(2,1).facet_grid(twoaltc,[],'scale','fixed')
g2(2,1).geom_jitter('width',0.2,'height',0) %We can jitter the points in the scatter plot to make the density more apparent

g2(2,2)=gramm('x',y,'color',twoaltc)
g2(2,2).no_legend() %It's possible to drop the side legends (useful when the grouping is the same across multiple objects)
g2(2,2).stat_bin('geom','bar') %Using stat_bin we can create histograms
g2(2,2).set_limit_extra(0.1,0)

%And call the draw function on the whole array !
figure
g2.draw()



%% Example of different scaling options for faceting with facet_grid

clear g3

%Example with everything in the same plot
g3(1,1)=gramm('x',x,'y',y,'color',fouraltc)
g3(1,1).geom_point()

% 'fixed': same x and y scale for all subplots
g3(1,2)=gramm('x',x,'y',y,'color',fouraltc)
g3(1,2).facet_grid(twoaltc,twoaltcb,'scale','fixed') 
g3(1,2).geom_point()

% 'free_x': subplots on the same columns have the same x scale
g3(2,1)=gramm('x',x,'y',y,'color',fouraltc)
g3(2,1).facet_grid(twoaltc,twoaltcb,'scale','free_x') 
g3(2,1).geom_point()

% 'free_y': subplots on the same rows have the same y scale
g3(2,2)=gramm('x',x,'y',y,'color',fouraltc)
g3(2,2).facet_grid(twoaltc,twoaltcb,'scale','free_y') 
g3(2,2).geom_point()

% 'free': subplots on the same rows  have the same y scale and facets on the same columns have the same x scale
g3(3,1)=gramm('x',x,'y',y,'color',fouraltc)
g3(3,1).facet_grid(twoaltc,twoaltcb,'scale','free') 
g3(3,1).geom_point()

% 'independent': subplots are independent on each facet
g3(3,2)=gramm('x',x,'y',y,'color',fouraltc)
g3(3,2).facet_grid(twoaltc,twoaltcb,'scale','independent') 
g3(3,2).geom_point()

figure('Position',[100 100 700 800])
g3.draw()


%% Example of different scaling options for wrap faceting

clear g4

%Example with everything in the same plot
g4(1,1)=gramm('x',x,'y',y,'color',fouraltc)
g4(1,1).geom_point()

% 'fixed': same x and y scale for all subplots
g4(1,2)=gramm('x',x,'y',y,'color',fouraltc)
g4(1,2).facet_wrap(fouraltc,'scale','fixed','ncols',3) 
g4(1,2).geom_point()

% 'free_x': subplots on the same columns have the same x scale -> for wrap, each plot
%has its own x scale
g4(2,1)=gramm('x',x,'y',y,'color',fouraltc)
g4(2,1).facet_wrap(fouraltc,'scale','free_x','ncols',3) 
g4(2,1).geom_point()

% 'free_y': subplots on the same rows have the same y scale -> for wrap, each plot has
%its own y scale
g4(2,2)=gramm('x',x,'y',y,'color',fouraltc)
g4(2,2).facet_wrap(fouraltc,'scale','free_y','ncols',3) 
g4(2,2).geom_point()

% 'free': behaves like 'independent' option when using facet_wrap
g4(3,1)=gramm('x',x,'y',y,'color',fouraltc)
g4(3,1).facet_wrap(fouraltc,'scale','free','ncols',3) 
g4(3,1).geom_point()

% 'independent': scales are independent on each subplot
g4(3,2)=gramm('x',x,'y',y,'color',fouraltc)
g4(3,2).facet_wrap(fouraltc,'scale','independent','ncols',3) 
g4(3,2).geom_point()

figure('Position',[100 100 700 800])
g4.draw()

%% Examples for different types of histograms

%Create variables
x=randn(1200,1)-1;
cat=repmat([1 1 1 2],300,1);
x(cat==2)=x(cat==2)+2;

%Example of different geoms
clear g5
g5(1,1)=gramm('x',x,'color',cat)
g5(1,1).stat_bin() %by default, 'geom' is 'bar', where color groups are side-by-side (dodged)

g5(1,2)=gramm('x',x,'color',cat)
g5(1,2).stat_bin('geom','stacked_bar') %Stacked bars option

g5(2,1)=gramm('x',x,'color',cat)
g5(2,1).stat_bin('geom','line') %Draw lines instead of bars, easier to visualize when lots of categories, default fill to edges !

g5(2,2)=gramm('x',x,'color',cat)
g5(2,2).stat_bin('geom','overlaid_bar') %Overlaid bar automatically changes bar coloring to transparent

g5(1,3)=gramm('x',x,'color',cat)
g5(1,3).stat_bin('geom','point') 


g5(2,3)=gramm('x',x,'color',cat)
g5(2,3).stat_bin('geom','stairs') %Default fill is edges

figure
g5.draw()

%Example of alternative fill options
figure
clear g6
g6(1,1)=gramm('x',x,'color',cat)
g6(1,1).stat_bin('fill','face')

g6(1,2)=gramm('x',x,'color',cat)
g6(1,2).stat_bin('fill','all')

g6(2,1)=gramm('x',x,'color',cat)
g6(2,1).stat_bin('fill','edge')

g6(2,2)=gramm('x',x,'color',cat)
g6(2,2).stat_bin('fill','transparent')

g6.draw()

%Example of other histogram-generation examples
figure
clear g7
g7(1,1)=gramm('x',x,'color',cat)
g7(1,1).stat_bin('geom','overlaid_bar') %Default binning (30 bins)

%Normalization to 'probability'
g7(2,1)=gramm('x',x,'color',cat)
g7(2,1).stat_bin('normalization','probability','geom','overlaid_bar')

%Normalization to cumulative count
g7(1,2)=gramm('x',x,'color',cat)
g7(1,2).stat_bin('normalization','cumcount','geom','stairs')

%Normalization to cumulative density
g7(2,2)=gramm('x',x,'color',cat)
g7(2,2).stat_bin('normalization','cdf','geom','stairs')

%Custom edges for the bins
g7(1,3)=gramm('x',x,'color',cat)
g7(1,3).stat_bin('edges',-1:0.5:10,'geom','overlaid_bar')

%Custom edges with non-constand width (normalization 'countdensity'
%recommended)
g7(2,3)=gramm('x',x,'color',cat)
g7(2,3).stat_bin('geom','overlaid_bar','normalization','countdensity','edges',[-5 -4 -2 -1 -0.5 -0.25 0 0.25 0.5  1 2 4 5])



g7.draw()



%% Example from the readme

clear g8
figure

load carbig.mat %Load example dataset about cars
origin_region=num2cell(org,2); %Convert origin data to a cellstr
%Create a gramm object, provide x (year) and y (mpg) data
%color data (region of origin) and select a subset of the data
g8=gramm('x',Model_Year,'y',MPG,'color',origin_region,'subset',Cylinders~=3 & Cylinders~=5,'size',5)
%Set appropriate names for legends
g8.set_names('color','Origin','x','Year of production','y','MPG','column','# Cylinders')
%Subdivide the data in subplots horizontally by number of cylinders
g8.facet_grid([],Cylinders)
%Plot raw data points
g8.geom_point()
%Plot summarized data: 5 bins over x are created and for each
%bin the mean and confidence interval is displayed as a shaded area
g8.stat_summary('geom','area','type','bootci','bin_in',5)
g8.draw() %Draw method

%% Example for summary and boxplot dodging (with tricky data)


x=repmat(1:10,1,100);
catx=repmat({'A' 'B' 'C' 'F' 'E' 'D' 'G' 'H' 'I' 'J'},1,100);
y=randn(1,1000);
c=repmat([1 1 1 1 1 1 1 1 1 1    1 1 2 2 2 2 2 2 3 2     2 1 1 2 2 2 2 2 3 3     2 1 1 2 2 2 2 2 3 2],1,25);
y=y+x+c*0.5;


figure
g=gramm('x',x,'y',y,'color',c);
g.geom_jitter('width',0.5);
g.draw();



figure
clear g
g(1,1)=gramm('x',catx,'y',y,'color',c);
g(1,1).stat_boxplot('spacing',0.5,'dodge',-1);
g(1,1).geom_vline('xintercept',0.5:1:10.5,'style','k-');
g(2,1)=gramm('x',catx,'y',y,'color',c);
g(2,1).stat_boxplot('spacing',0.2,'dodge',0);
g(2,1).geom_vline('xintercept',0.5:1:10.5,'style','k-');
g(3,1)=gramm('x',catx,'y',y,'color',c);
g(3,1).stat_boxplot('spacing',0.2,'dodge',0.1);
g(3,1).geom_vline('xintercept',0.5:1:10.5,'style','k-');
g(4,1)=gramm('x',catx,'y',y,'color',c);
g(4,1).facet_grid([],c);
g(4,1).stat_boxplot('spacing',0.4,'dodge',-1);
g.draw();


figure
clear g
g(1,1)=gramm('x',catx,'y',y,'color',c);
g(1,1).stat_summary('geom',{'bar' 'black_errorbar'},'dodge',0);
g(1,1).geom_vline('xintercept',0.5:1:10.5,'style','k-');
g(2,1)=gramm('x',catx,'y',y,'color',c);
g(2,1).stat_summary('geom',{'bar' 'black_errorbar'},'dodge',0.2);
g(2,1).geom_vline('xintercept',0.5:1:10.5,'style','k-');
g(3,1)=gramm('x',catx,'y',y,'color',c);
g(3,1).stat_summary('geom',{'area'});
g(4,1)=gramm('x',catx,'y',y,'color',c);
g(4,1).stat_summary('geom',{'point' 'errorbar'},'dodge',0);
g(4,1).geom_vline('xintercept',0.5:1:10.5,'style','k-');
g.draw();

%% Quantile-quantile plots example

figure
grp=repmat([1 2],1,500)';
g=gramm('x',randn(1000,1).*grp,'color',grp)
g.stat_qq('Distribution',makedist('Normal',0,2))
g.geom_abline()
g.draw()

figure
g=gramm('x',randn(1000,1).*grp,'y',randn(1000,1),'color',grp)
g.stat_qq('Distribution','y')
g.geom_abline()
g.draw()


%% Example for date ticks

t=now;

figure
g9=gramm('x',t+[0 0.1 1 5 6],'y',t+[1 2 3 4 5])
g9.geom_line()
g9.set_datetick('x',2)
g9.set_datetick('y',1)
g9.draw()

%% Example of glm fit

load carbig.mat %Load example dataset about cars

figure
g10=gramm('x',Horsepower,'y',Acceleration,'color',Cylinders,'subset',Cylinders~=3 & Cylinders~=5)
g10.set_names('color','# Cylinders','x','Horsepower','y','Acceleration')
g10.stat_glm('geom','area','disp_fit',true) %Linear fit (default for stat_glm
g10.geom_point()
g10.draw()


%% Example of all the different input formats for x and y


%Standard ggplot-like input (arrays for everything)
Y=[1 2 3 4 5 2 3 4 5 6 3 4 5 6 7];
X=[1 2 3 4 5 0 1 2 3 4 -1 0 1 2 3];
C=[1 1 1 1 1 2 2 2 2 2 2 2 2 2 2];

%Note the continuous line connecting all blue data points, gramm can't know
%when to start a new line in this case
figure
g11=gramm('x',X,'y',Y,'color',C)
g11.geom_line()
g11.draw()

%Adding a group variable solves the problem in a ggplot-like way
G=[1 1 1 1 1 2 2 2 2 2 3 3 3 3 3];
figure
g12=gramm('x',X,'y',Y,'color',C,'group',G)
g12.geom_line()
g12.draw()

%For a more matlab-like solution, Y and X can be matrices, rows will automatically be considered as groups.
% as a consequence grouping data (color, etc...) are provided for the rows !
Y=[1 2 3 4 5;2 3 4 5 6; 3 4 5 6 7];
X=[1 2 3 4 5; 0 1 2 3 4; -1 0 1 2 3];
C=[1 2 2];
figure
g13=gramm('x',X,'y',Y,'color',C)
g13.geom_line()
g13.draw()

% If all X values are the same, it's possible to provide X as a single row
X=[1 2 3 4 5];
figure
g14=gramm('x',X,'y',Y,'color',C)
g14.geom_line()
g14.draw()

%Similar results can be obtained with cells of arrays
Y={[1 2 3 4 5] [2 3 4 5 6] [3 4 5 6 7]}
X={[1 2 3 4 5] [0 1 2 3 4] [-1 0 1 2 3]}
figure
g15=gramm('x',X,'y',Y,'color',C)
g15.geom_line()
g15.draw()

Y={[1 2 3 4 5] [2 3 4 5 6] [3 4 5 6 7]}
X=[1 2 3 4 5];
figure
g16=gramm('x',X,'y',Y,'color',C)
g16.geom_line()
g16.draw()

%With cells of arrays, there is the opportinity to have different lengths
%for different groups
Y={[1 2 3 4 5] [3 4 5] [3 4 5 6 7]}
X={[1 2 3 4 5] [1 2 3] [-1 0 1 2 3]}
figure
g17=gramm('x',X,'y',Y,'color',C)
g17.geom_line()
g17.draw()



%% When there are too many colors, we switch to a continuous scale

load spectra.mat

figure
%Here we create x as a 1xN array (see example above), and use a MxN matrix
%for y. Color applies to the M rows of y.
g18=gramm('x',900:2:1700,'y',NIR,'color',octane);
g18.set_names('x','Wavelength (nm)','y','NIR','color','octane')
g18.set_continuous_color('colormap','hot')
g18.geom_line;
g18.draw;

%% Examples for representations of 2D data

%Create point cloud with two categories
N=10^4;
x=randn(1,N);
y=x+randn(1,N);
test=repmat([0 1 0 0],1,N/4);
y(test==0)=y(test==0)+3;

clear g
figure

% Display points and 95% percentile confidence ellipse
g(1,1)=gramm('x',x,'y',y,'color',test,'size',2)
g(1,1).set_names('color','grp')
g(1,1).geom_point()
%'patch_opts' can be used to provide more options to the patch() internal
%call
g(1,1).stat_ellipse('type','95percentile','geom','area','patch_opts',{'FaceAlpha',0.1,'LineWidth',2})

%Plot point density as contour plot
g(1,2)=gramm('x',x,'y',y,'color',test)
g(1,2).stat_bin2d('nbins',[10 10],'geom','contour')
g(1,2).set_names('color','grp')

%Plot density as point size (looks good only when axes have the same
%scale, hence the 'DataAspectRatio' option, equivalent to axis equal)
g(2,1)=gramm('x',x,'y',y,'color',test)
g(2,1).stat_bin2d('nbins',{-10:0.4:10 ; -10:0.4:10},'geom','point')
g(2,1).axe_property('DataAspectRatio',[1 1 1])
g(2,1).set_names('color','grp')

%Plot density as heatmaps (Heatmaps don't work with multiple colors, so we separate
%the categories with facets). With the heatmap we see better the
%distribution in high-density areas
g(2,2)=gramm('x',x,'y',y)
g(2,2).facet_grid([],test)
g(2,2).stat_bin2d('nbins',[20 20],'geom','image')
g(2,2).set_continuous_color('LCH_colormap',[0 100 ; 100 20 ;30 20]) %Let's try a custom LCH colormap !
g(2,2).set_names('column','grp','color','count')


g.draw()

%% stat_glm examples (statistics toolbox required)

%Create repeated x values
x=repmat(1:10,1,20)

%Create measurement (y=x+noise)
y=x+randn(1,length(x))*3;


figure
g=gramm('x',x,'y',y)
g.geom_point()
%By default, stat_glm assumes a normal distribution and an identity link
%function (i.e. it performs a linear model fit). The fit is represented as
%a thick line and 95% CI as a shaded area
g.stat_glm()
g.draw()


%The measurements are now binomial (follows a logit curve centered on 5)
y=random('binomial',1,1./(1+exp(5-x)))

figure
g=gramm('x',x,'y',y)
%We plot jittered points to get a better idea of the distribution
%g.geom_jitter('width',0.2,'height',0.1)
g.geom_count()
%By specifying that the distribution is binomial, a logit link function is
%used (see help for glm_fit).
g.stat_glm('distribution','binomial','geom','lines')
g.draw()


%% stat_fit() example (requires the curve fitting toolbox).

%Function used to generate the data
fun=@(alpha,beta,gamma,x)alpha*exp(cos(x-beta)*gamma);

%Create X and categories
x=repmat(linspace(0,3*pi,100),1,20);
cat=repmat([1 2],1,1000);

%Create Y from function and categories, add noise
y=zeros(size(x));
y(cat==1)=fun(1,1,3,x(cat==1));
y(cat==2)=fun(3,2,1,x(cat==2));
y=y+randn(size(y))*1;

%Gramm plot with fit !
figure
g=gramm('x',x,'y',y,'color',cat)
g.geom_point()
g.stat_fit('fun',fun,'disp_fit',true) %We provide the function for the fit
g.draw()


