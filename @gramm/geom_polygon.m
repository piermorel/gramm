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
%
% modified: 2017-Mar-12, Pierre Morel


%% Parse inputs and set defaults

p=inputParser;

my_addParameter(p,'x',{});
my_addParameter(p,'y',{});
my_addParameter(p,'alpha',0.1);
my_addParameter(p,'color',[0 0 0]);
my_addParameter(p,'line_color',[0 0 0]);
my_addParameter(p,'line_style',{'none'});
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

temp_results=p.Results;

N=length(temp_results.x);

%Expand the inputs for which single entries were given to the number of
%polygons
to_adjust={'alpha','color','line_color','line_style'};
for k=1:length(to_adjust)
    if size(temp_results.(to_adjust{k}),1)==1
        temp_results.(to_adjust{k}) = repmat(temp_results.(to_adjust{k}),N,1);
    end
end
    
%% Add polygon settings to object, used when draw() is called
to_fill=fieldnames(temp_results);
for obj_ind=1:numel(obj)
    
    obj(obj_ind).polygon.on = true;
    for k=1:length(to_fill)
        obj(obj_ind).polygon.(to_fill{k})=vertcat(obj(obj_ind).polygon.(to_fill{k}),temp_results.(to_fill{k})) ;
    end

    
    % Include these options to be compatible with get_colormap
    %   * could be changed to give increased control of polygon coloring
    color_opts=fieldnames(obj(obj_ind).color_options);
    for k=1:length(color_opts)
        obj(obj_ind).polygon.color_options.(color_opts{k})= obj(obj_ind).color_options.(color_opts{k});
    end
end
end