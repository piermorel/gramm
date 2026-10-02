% gramm examples and how-tos

% Shared variable
% We stat by loading the sample data (structure created from the carbig
% dataset)
load example_data;

%% Advanced customization of gramm figures
% The options for the geom_ and stat_ methods, as well as the
% |axe_property()| method allow for high-level customization of gramm figures. Since
% the gramm object allows access to all handles for graphical objects, it's
% also possible to do more precise customizations and modifications of a
% gramm figure once it's drawn. In this figure:
%
% * Text sizes and fonts are changed with |set_text_options()|
% * Y grid is turned on on all facets with |axe_property('YGrid','on')|
% * A vertical line and text is added to only one of the facets by using
% the |facet_axes_handles| public property of gramm objects
% * All points are made smaller by using their handles 
% |results.grom_point_handle| in the |set()| function
% * Similarly, all confidence areas are made grey |g.results.stat_glm.area_handle|
% * A subset of the glm lines are made thicker by calling |set()| on a
% subset teir handles |g.results.stat_glm(g.results.color==4).line_handle]
% 
% It is also possible to set where the gramm
% axes are drawn by using the |set_parent(parent_handle)| function, which receives the
% handle of a figure/uipanel/uitab object to use as parent as argument.

f=figure;
%Create fake button
c=uicontrol('Style','pushbutton','String','Dummy','Units','normalized','Position',[0.8 0.45 0.15 0.1]);
%Create uipanel to put our gramm plots
p=uipanel('Position',[0.05 0.1 0.7 0.8],'Parent',f,'BackgroundColor',[1 1 1]);

% Starting with the example figure
load example_data;
g=gramm('x',cars.Model_Year,'y',cars.MPG,'color',cars.Cylinders,'subset',cars.Cylinders~=3 & cars.Cylinders~=5);
g.facet_grid([],cars.Origin_Region);
g.stat_glm();
g.geom_point();
g.set_names('column','Origin','x','Year of production','y','Fuel economy (MPG)','color','# Cylinders');
g.set_title('Fuel economy of new cars between 1970 and 1982');
g.axe_property('YGrid','on');
g.set_parent(p);

g.set_text_options('font','Courier',...
    'base_size',12,...
    'label_scaling',0.8,...
    'legend_scaling',1.5,...
    'legend_title_scaling',1.5,...
    'facet_scaling',1,...
    'title_scaling',1.5);

g.draw();

%It's possible to use the axes handles to add elements to single axes
line([75 75],[0 50],'Color','k','LineStyle','--','Parent',g.facet_axes_handles(1));
text(75.3,47,{'Important' 'event'},'Parent',g.facet_axes_handles(1),'FontName','Courier');

%It's also possible to change properties of graphical elements
%Either all at once
set([g.results.geom_point_handle],'SizeData',25);
set([g.results.stat_glm.area_handle],'FaceColor',[0.4 0.4 0.4]);
%Or on a subset of them (here only for the lines of glms of 4-cylinder cars)
set([g.results.stat_glm(g.results.color==4).line_handle],'LineWidth',3);

