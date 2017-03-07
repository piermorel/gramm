function obj=geom_polygon(obj,varargin)
% geom_rect Create a polygon or polygons
%
% This function allows arbitrary polygons to be drawn. Polygons are drawn
% before any points are plotted so that data is not covered up.
%
% Required inputs:
% x - Cell array of vectors containing x values for each point in a
%     polygon. Each cell should contain a vector of x-coordinates for each
%     point in a polygon.
% y - Cell array of vectors containing x values for each point in a
%     polygon. Each cell should contain a vector of x-coordinates for each
%     point in a polygon.
% 
% Optional inputs (defaults):
% map (obj.color_options.map) - Use this to override main color mapping
% alpha (0.2) - set fill alpha
% color ([]) - line color indexing, empty is black
% fill ([]) - fill color indexing, empty is gray
% style ([]) - line type, empty is no line. Options are identical to
%              set_line_type('styles')
%
% Example Usage:
% figure;
% g=gramm('x',Model_Year,'y',MPG,'color',Cylinders,'subset',Cylinders~=3 & Cylinders~=5);
% g.facet_grid([],origin_region);
% g.geom_point();
% g.stat_glm();
% cmap = [1   0.5 0.5; % red (bad gas mileage)
%         1   1   0.5; % yellow (reasonable gas mileage)
%         0.5 1   0.5]; % green (good gas mileage)
% g.geom_polygon('x',{[50;90;90;50] [50;90;90;50] [50;90;90;50]},'y',{[5;5;20;20] [20;20;30;30] [30;30;50;50]},'alpha',.2,'fill',[1 2 3],'map',cmap);
% g.set_names('column','Origin','x','Year of production','y','Fuel economy (MPG)','color','# Cylinders');
% g.set_title('Fuel economy of new cars between 1970 and 1982');
% g.draw();
%
% created: 2017-Mar-03
% author: Nicholas J. Schaub, Ph.D.
% email: nicholas.j.schaub@gmail.com

%% Parse inputs and set defaults

p=inputParser;

my_addParameter(p,'x',{});
my_addParameter(p,'y',{});
my_addParameter(p,'map',obj.color_options.map);
my_addParameter(p,'alpha',0.2);
my_addParameter(p,'color',[]);
my_addParameter(p,'fill',[]);
my_addParameter(p,'style',[]);
parse(p,varargin{:});

%% Check inputs
if isempty(p.Results.x) || isempty(p.Results.y)
    warning('Either x or y is not provided. Will not draw polygons.')
    return
end

if ~iscell(p.Results.x) || ~iscell(p.Results.y)
    warning('Either x or y is not a cell. Will not draw polygons.')
    return
end

if length(p.Results.x) ~= length(p.Results.y)
    warning('The number of elements in x does not match y. Will not draw polygons.')
    return
end

if ~isequal(cellfun(@length,p.Results.x),cellfun(@length,p.Results.y))
    warning('The number of x-coords does not match the number of y-coords for each polygon. Will not draw polygons.')
    return
end

%% Add polygon settings to object, used when draw() is called
for obj_ind=1:numel(obj)
    obj(obj_ind).polygon.on = true;
    obj(obj_ind).polygon.x{end+1}=p.Results.x;
    obj(obj_ind).polygon.y{end+1}=p.Results.y;
    obj(obj_ind).polygon.color_options{end+1}.map=p.Results.map;
    obj(obj_ind).polygon.alpha(end+1)=p.Results.alpha(1);
    obj(obj_ind).polygon.color{end+1}=p.Results.color;
    obj(obj_ind).polygon.fill{end+1}=p.Results.fill;
    obj(obj_ind).polygon.style{end+1}=p.Results.style;
    
    % Include these options to be compatible with get_colormap
    %   * could be changed to give increased control of polygon coloring
    obj(obj_ind).polygon.color_options{end}.lightness_range=obj.color_options.lightness_range;
    obj(obj_ind).polygon.color_options{end}.chroma_range=obj.color_options.chroma_range;
    obj(obj_ind).polygon.color_options{end}.hue_range=obj.color_options.hue_range;
    obj(obj_ind).polygon.color_options{end}.lightness=obj.color_options.lightness;
    obj(obj_ind).polygon.color_options{end}.chroma=obj.color_options.chroma;
end
end