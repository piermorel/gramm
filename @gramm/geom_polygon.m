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
% alpha (0.2) - set fill alpha
% color ([0 0 0]) - fill color of the polygon
% line_color ([0 0 0]) - line color of the polygon
% line_style ({'none'}) - line style
%
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
my_addParameter(p,'alpha',0.2);
my_addParameter(p,'color',[0 0 0]);
my_addParameter(p,'line_color',[0 0 0]);
my_addParameter(p,'line_style',{'none'});
my_addParameter(p,'extent',2);
parse(p,varargin{:});

temp_results=p.Results;


%% Check inputs
if isempty(temp_results.x) && isempty(temp_results.y)
    warning('Both x and y are not provided. Will not draw polygons.')
    return
end

if ~iscell(temp_results.x) || ~iscell(temp_results.y)
    warning('Either x or y is not a cell. Will not draw polygons.')
    return
end

%If one of the xy input is omitted, we fill it with an cell full of empty
%arrays
if isempty(temp_results.x)
    N=length(temp_results.y);
    temp_results.x=repmat({[]},N,1);
elseif isempty(temp_results.y)
    N=length(temp_results.x);
    temp_results.y=repmat({[]},N,1);
else
    N=length(temp_results.x);
end


if length(temp_results.x) ~= length(temp_results.y)
    warning('The number of elements in x does not match y. Will not draw polygons.')
    return
end

%Check number of vertices
nvx=cellfun(@length,temp_results.x);
nvy=cellfun(@length,temp_results.y);

%Which cases are allowed for omitted inputs
to_complete = (nvx==2 & nvy==0) | (nvx==0 & nvy==2);

if ~isequal(nvx(~to_complete),nvy(~to_complete))
    warning('The number of x-coords does not match the number of y-coords for each polygon. Will not draw polygons.')
    return
end




%Expand the inputs for which single entries were given to the number of
%polygons
to_adjust={'alpha','color','line_color','line_style','extent'};
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