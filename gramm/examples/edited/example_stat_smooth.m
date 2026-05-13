%% Smoothing Methods with stat_smooth()
% This example compares the different smoothing algorithms available in
% *gramm*'s |stat_smooth()| method.
%
% We use a noisy signal with varying noise levels to show how each
% method handles heterogeneous data. A vertical line marks the
% transition from high to low noise, and the true function is overlaid
% for reference.

%% Generate test signal
% The underlying function is |sin(exp((x-5)/12))|. Noise is large for
% |x < 2| and small for |x >= 2|, simulating a scenario where
% signal-to-noise ratio changes along the x-axis.

x = 0:0.02:9.8;
y = sin(exp(x-5)/12);
y(x < 2) = y(x < 2) + randn(1, sum(x < 2)) / 2;
y(x >= 2) = y(x >= 2) + randn(1, sum(x >= 2)) / 8;

%% Set up base gramm objects
% All subplots share the true function (green line) and a vertical
% reference line at the noise transition point.

figure;
clear g

g = gramm('x',x,'y',y);
g.geom_funline('fun',@(x)sin(exp(x-5)/12));
g.geom_vline('xintercept',2);
g.axe_property('XLim',[0 9.8]);

g(1,2) = copy(g(1));
g(1,3) = copy(g(1));
g(2,1) = copy(g(1));
g(2,2) = copy(g(1));
g(2,3) = copy(g(1));

%% Raw data
% Shows the noisy input points for reference.

g(1,1).geom_point();
g(1,1).set_title('Raw input');

%% Default penalized spline
% The default |stat_smooth()| uses a penalized B-spline with
% cross-validated smoothing parameter.

g(1,2).stat_smooth();
g(1,2).set_title('stat_smooth() default');

%% Automatic lambda selection
% Setting |'lambda','auto'| uses generalized cross-validation to pick
% the optimal smoothing penalty. More evaluation points (|npoints=500|)
% give a finer output curve.

g(1,3).stat_smooth('lambda','auto','npoints',500);
g(1,3).set_title('default with ''lambda'',''auto''');

%% Savitzky-Golay filter
% A polynomial fit within a sliding window. The |lambda| parameter
% specifies |[window_size, polynomial_order]|. Good for preserving
% peaks and local features.

g(2,1).stat_smooth('method','sgolay','lambda',[31 3]);
g(2,1).set_title('''method'',''sgolay''');

%% Moving average
% The simplest smoother: average within a sliding window of size 31.
% Very fast but over-smooths sharp transitions.

g(2,2).stat_smooth('method','moving','lambda',31);
g(2,2).set_title('''method'',''moving''');

%% LOESS (local regression)
% Locally weighted scatter-plot smoothing. The |lambda| parameter
% controls the fraction of data used for each local fit. Smaller
% values track the data more closely.

g(2,3).stat_smooth('method','loess','lambda',0.1,'setylim',true);
g(2,3).set_title('''method'',''loess''');

%% Draw all subplots

g.set_title('Options for stat_smooth()');
g.draw();
