function obj=geom_polygon(obj,varargin)
% geom_polygon Display reference polygons in the background of each facet
%
% Example syntax: gramm_object.geom_polygon('x',{[0 1 1]},'y',{[0 0 1]},'color',[1 0 0])
% The P polygons are given in one of two ways.
%
% With both 'x' and 'y', the i-th cell of each holds the x (or y)
% coordinates of the vertices of the i-th polygon, as vectors of the same
% length. 'x',{[0 1 1]},'y',{[0 0 1]} draws a triangle.
%
% With only 'x' (or only 'y'), vertical (or horizontal) bands spanning the
% whole plot are drawn, each cell holding the [start end] of one band.
% 'x',{[1 2] [5 6]} draws two vertical bands.
%
% The other options are given either once for all polygons, or once per
% polygon (P values, P rows or P cells).
%
% Parameters given as 'name',value pairs:
% - 'x': Cell of P vectors with the x coordinates of the vertices, or the
%            [start end] of vertical bands if 'y' is not given (default {})
% - 'y': Cell of P vectors with the y coordinates of the vertices, or the
%            [start end] of horizontal bands if 'x' is not given (default
%            {})
% - 'fill_alpha': Fill transparency, from 0 (transparent) to 1 (opaque),
%            single value or array of length P (default [], uses 'alpha')
% - 'alpha': Former name of 'fill_alpha' (default 0.2)
% - 'color': Fill color, RGB as a 1x3 or Px3 matrix, or indices of colors
%            of the gramm colormap (default [0 0 0])
% - 'line_color': Edge color, same format as 'color' (default [0 0 0])
% - 'line_style': Edge style, cell of length 1 or P (default {'none'})
% - 'extent': Length of the bands, as a ratio of the axis range (default
%            2: bands cross the whole axis)


% created: 2017-Mar-03
% author: Nicholas J. Schaub, Ph.D.
% email: nicholas.j.schaub@gmail.com
%
% modified: 2017-Mar-12, 2017-Apr-18, Pierre Morel


% Parse inputs and set defaults

p=inputParser;

addParameter(p,'x',{});
addParameter(p,'y',{});
addParameter(p,'alpha',0.2,@(v) valid_range(v,0,1));
addParameter(p,'fill_alpha',[],@(v) valid_range(v,0,1,true));
addParameter(p,'color',[0 0 0]);
addParameter(p,'line_color',[0 0 0]);
addParameter(p,'line_style',{'none'});
addParameter(p,'extent',2);
parse(p,varargin{:});

temp_results=p.Results;
%'fill_alpha' is the name used by the other geoms
if ~isempty(temp_results.fill_alpha)
    temp_results.alpha=temp_results.fill_alpha;
end
temp_results=rmfield(temp_results,'fill_alpha');


% Check inputs
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
    
% Add polygon settings to object, used when draw() is called
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