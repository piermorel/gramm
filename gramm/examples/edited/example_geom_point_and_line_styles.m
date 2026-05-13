%% Customizing Point and Line Styles
% This example shows how to control the appearance of points and lines
% in *gramm* using |set_point_options()| and |set_line_options()|.
%
% You can adjust base sizes, step sizes, border colors, transparency,
% line styles, and whether size maps to a continuous input value.

%% Load sample data

load example_data;

%% Generate synthetic data
% We create a simple dataset where both x position and a grouping
% variable vary, producing lines of increasing slope.

clear g

x = repmat(1:10, 1, 5);
y = reshape(bsxfun(@times, 1:5, (1:10)'), 1, 50);
sz = reshape(repmat(1:5, 10, 1), 1, 50);

%% Default point and line appearance
% Without any customization, gramm uses sensible defaults for both
% point size and line width, scaled by the size aesthetic.

g(1,1) = gramm('x',x,'y',y,'size',sz);
g(1,1).geom_point();
g(1,1).geom_line();
g(1,1).set_title('Default');

%% Black point border
% Adding a dark border around points improves visibility when points
% overlap or when using lighter fill colors.

g(1,2) = gramm('x',x,'y',y,'color',sz,'size',sz);
g(1,2).geom_point();
g(1,2).set_point_options('border_color','k','border_width',2);
g(1,2).set_color_options('legend','merge');
g(1,2).set_title('Black point border color');

%% Auto border color with transparency
% Setting |'border_color','auto'| uses the fill color for the border.
% Combined with |alpha=0|, you get outlined-only markers.

g(1,3) = gramm('x',x,'y',y,'color',sz,'size',sz);
g(1,3).geom_point('alpha',0);
g(1,3).set_color_options('legend','merge');
g(1,3).set_point_options('border_color','auto','border_width',1.5);
g(1,3).set_title('Auto border color, 0 alpha fill');

%% Modified base size, step size, and line styles
% |base_size| controls the minimum size, |step_size| controls how much
% each group level increases. Custom line styles can be specified as a
% cell array.

g(2,1) = gramm('x',x,'y',y,'size',sz);
g(2,1).geom_point();
g(2,1).geom_line();
g(2,1).set_line_options('base_size',1,'step_size',0.2,'style',{':' '-' '--' '-.'});
g(2,1).set_point_options('base_size',4,'step_size',1);
g(2,1).set_title('Modified base & step size + line style');

%% Default categorical size mapping
% When a size variable has discrete levels, each level gets a distinct
% point/line size.

g(2,2) = gramm('x',x,'y',y,'size',sz,'subset',sz~=3 & sz~=4);
g(2,2).geom_line();
g(2,2).geom_point();
g(2,2).set_title('Default (size by category)');

%% Continuous size mapping with input_fun
% Use |'use_input',true| with a custom |input_fun| to map the raw size
% value directly to visual properties through a transformation function.

g(2,3) = gramm('x',x,'y',y,'size',sz,'subset',sz~=3 & sz~=4);
g(2,3).geom_line();
g(2,3).geom_point();
g(2,3).set_line_options('use_input',true,'input_fun',@(s)1.5+s);
g(2,3).set_point_options('use_input',true,'input_fun',@(s)5+s*2);
g(2,3).set_title('Size mapped by value (input_fun)');

%% Draw all subplots

g.set_title('Customization of line and point options');
figure;
g.draw();
