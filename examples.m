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
y(twoalt==1)=y(twoalt==1)+3
x(twoaltb==1)=x(twoaltb==1)+50;

%% Example use

figure
g=gramm('x',x,'y',y,'color',fouraltc,'linestyle',twoaltcb)
g.facet_grid(twoaltcb,twoaltc,'scales','fixed')
g.geom_point()
g.stat_smooth('lambda',1000,'geom','area')
%It's possible to set native axis properties
g.axe_property('XGrid','on')
g.axe_property('YGrid','on')
g.draw()

%% Plot multiple gramm objects in single window

%Just create an array of gramm objects, each graph being a different
%element (they stay independent), rows will be rows, columns will be
%columns, starting from top left

clear g

g(1,1)=gramm('x',x,'y',y,'color',fouraltc)
g(1,1).facet_grid(twoaltc,twoaltcb) %,'scales','independent'
g(1,1).stat_smooth('lambda',1000,'geom','area')
g(1,1).geom_point()

g(1,2)=gramm('x',y,'y',x,'color',twoaltc)
g(1,2).geom_point()
 
% X data can be a cellstr, data will be treated as being categorical
g(2,1)=gramm('x',fouraltc,'y',y,'color',twoaltcb,'size',4)
g(2,1).facet_grid(twoaltc,[],'scales','fixed')
g(2,1).geom_jitter('width',0.2,'height',0) %We can jitter the points in the scatter plot to make the density more apparent

g(2,2)=gramm('x',y,'color',twoaltc)
g(2,2).stat_bin('geom','bar') %Using stat_bin we can create histograms

%And call the draw function on the whole array !
g.draw()


%% Example of different scaling options for faceting

clear g

g(1,1)=gramm('x',x,'y',y,'color',twoaltcb)
g(1,1).facet_grid(twoaltc,twoaltcb,'scales','fixed') %Same x and y scale for all facets
g(1,1).stat_smooth('lambda',1000,'geom','area')
g(1,1).geom_point()

g(1,2)=gramm('x',x,'y',y,'color',twoaltcb)
g(1,2).facet_grid(twoaltc,twoaltcb,'scales','free_x') %Facets on the same columns have the same x scale
g(1,2).stat_smooth('lambda',1000,'geom','area')
g(1,2).geom_point()

g(2,1)=gramm('x',x,'y',y,'color',twoaltcb)
g(2,1).facet_grid(twoaltc,twoaltcb,'scales','free_y') %Facets on the same rows have the same y scale
g(2,1).stat_smooth('lambda',1000,'geom','area')
g(2,1).geom_point()

g(2,2)=gramm('x',x,'y',y,'color',twoaltcb)
g(2,2).facet_grid(twoaltc,twoaltcb,'scales','independent') %Scales are independent on each facet
g(2,2).stat_smooth('lambda',1000,'geom','area')
g(2,2).geom_point()

g.draw()

%% Example from the readme

clear g
load carbig.mat %Load example dataset about cars
origin_region=num2cell(org,2); %Convert origin data to a cellstr
%Create a gramm object, provide x (year) and y (mpg) data
%color data (region of origin) and select a subset of the data
g=gramm('x',Model_Year,'y',MPG,'color',origin_region,'subset',Cylinders~=3 & Cylinders~=5,'size',5)
%Set appropriate names for legends
g.set_names('color','Origin','x','Year of production','y','MPG','column','# Cylinders')
%Subdivide the data in subplots horizontally by number of cylinders
g.facet_grid([],Cylinders)
%Plot raw data points
g.geom_point()
%Plot summarized data: 5 bins over x are created and for each
%bin the mean and confidence interval is displayed as a shaded area
g.stat_summary('geom','area','type','bootci','bin_in',5)
g.draw() %Draw method

%% Example for date ticks

t=now;

g=gramm('x',t+[0 0.1 1 5 6],'y',t+[1 2 3 4 5])
g.geom_line()
g.set_datetick('x',2)
g.set_datetick('y',1)
g.draw()

%% Example of glm fit

load carbig.mat %Load example dataset about cars

g=gramm('x',Horsepower,'y',Acceleration,'color',Cylinders,'subset',Cylinders~=3 & Cylinders~=5)
g.set_names('color','# Cylinders','x','Horsepower','y','Acceleration')
g.stat_glm('geom','area') %Linear fit (default for stat_glm
g.geom_point()
g.draw()


%% Example of all the different input formats for x and y


%Standard ggplot-like input (arrays for everything)
Y=[1 2 3 4 5 2 3 4 5 6 3 4 5 6 7];
X=[1 2 3 4 5 0 1 2 3 4 -1 0 1 2 3];
C=[1 1 1 1 1 2 2 2 2 2 2 2 2 2 2];

%Note the continuous line connecting all blue data points
figure
g=gramm('x',X,'y',Y,'color',C)
g.geom_line()
g.draw()

%Adding a group variable solves the problem in a ggplot-like way
G=[1 1 1 1 1 2 2 2 2 2 3 3 3 3 3];
figure
g=gramm('x',X,'y',Y,'color',C,'group',G)
g.geom_line()
g.draw()

%For a more matlab-like solution, Y and X can be matrices, rows will automatically be considered as groups.
% as a consequence grouping data (color, etc...) are provided for the rows !
Y=[1 2 3 4 5;2 3 4 5 6; 3 4 5 6 7];
X=[1 2 3 4 5; 0 1 2 3 4; -1 0 1 2 3];
C=[1 2 2];
figure
g=gramm('x',X,'y',Y,'color',C)
g.geom_line()
g.draw()

% If all X values are the same, it's possible to provide X as a single row
X=[1 2 3 4 5];
figure
g=gramm('x',X,'y',Y,'color',C)
g.geom_line()
g.draw()

%Similar results can be obtained with cells of arrays
Y={[1 2 3 4 5] [2 3 4 5 6] [3 4 5 6 7]}
X={[1 2 3 4 5] [0 1 2 3 4] [-1 0 1 2 3]}
figure
g=gramm('x',X,'y',Y,'color',C)
g.geom_line()
g.draw()

Y={[1 2 3 4 5] [2 3 4 5 6] [3 4 5 6 7]}
X=[1 2 3 4 5];
figure
g=gramm('x',X,'y',Y,'color',C)
g.geom_line()
g.draw()

%With cells of arrays, there is the opportinity to have different lengths
%for different groups
Y={[1 2 3 4 5] [3 4 5] [3 4 5 6 7]}
X={[1 2 3 4 5] [1 2 3] [-1 0 1 2 3]}
figure
g=gramm('x',X,'y',Y,'color',C)
g.geom_line()
g.draw()

%% When there are too many colors, we switch to a continuous scale

load spectra.mat

%Here we create x as a 1xN array (see example above), and use a MxN matrix
%for y. Color applies to the M rows of y.
g=gramm('x',900:2:1700,'y',NIR,'color',octane);
g.set_names('x','Wavelength (nm)','y','NIR','color','octane')
g.geom_line;
g.draw;


%% stat_fit examples (statistics toolbox required)

%Create repeated x values
x=repmat(1:10,1,20)

%Create measurement (y=x+noise)
y=x+randn(1,length(x))*3;


figure
g=gramm('x',x,'y',y)
g.geom_point()
%By default, stat_glm assumes a normal distribution and an identity link
%function (i.e. it performs a linear model fit). The fit is represented as
%a thick line and 95% CI as thin lighter lines
g.stat_glm()
g.draw()


%The measurements are now binomial (follows a logit curve centered on 5)
y=random('binomial',1,1./(1+exp(5-x)))

figure
g=gramm('x',x,'y',y)
%We plot jittered points to get a better idea of the distribution
g.geom_jitter('width',0.2,'height',0.1)
%By specifying that the distribution is binomial, a logit link function is
%used (see help for glm_fit). By using the option 'geom','area', the 95% CI
%is represented as a shaded area.
g.stat_glm('distribution','binomial','geom','area')
g.draw()

