function obj=geom_jitter(obj,varargin)
% geom_jitter Display data as randomly jittered points
%
% Example syntax (default arguments): gramm_object.geom_jitter('width',0.2,'height',0)
% Useful when points overlap a lot, e.g. with discrete x or y values.
% Supports color, lightness, marker and size groups.
%
% Parameters given as 'name',value pairs:
% - 'width': Horizontal extent of the jitter, relative to the space
%            available for each x value (default 0.2)
% - 'height': Vertical extent of the jitter, in y units (default 0)
% - 'dodge': Spacing between points of different colors within an
%            unique x value (default 0)
% - 'nudge': Fixed horizontal shift of the points, in the same units as
%            'width', e.g. to place them next to a boxplot or a half violin
%            (default 0)
% - 'alpha': Transparency of points, from 0 (transparent) to 1 (opaque)
%            (default 1)
% - 'raw_width': Set to true to give 'width' and 'nudge' in x units
%            (default false)

p=inputParser;
addParameter(p,'width',0.2,@(v) valid_range(v,0,Inf));
addParameter(p,'height',0,@(v) valid_range(v,0,Inf));
addParameter(p,'dodge',0,@(v) valid_range(v,0,Inf));
addParameter(p,'nudge',0,@(v) valid_range(v,-Inf,Inf));
addParameter(p,'alpha',1,@(v) valid_range(v,0,1));
addParameter(p,'raw_width',false);
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_jitter(dobj,dd,p.Results)});
obj.results.geom_jitter_handle={};
end


function  hndl=my_jitter(obj,draw_data,params)

draw_data.x=comb(draw_data.x);
draw_data.y=comb(draw_data.y);

if params.raw_width
    %With raw_width the nudge is also in x units
    draw_data.x=dodger(draw_data.x,draw_data,params.dodge)+params.nudge;
else
    draw_data.x=dodger(draw_data.x,draw_data,params.dodge,params.nudge);
end

if params.dodge>0
    params.avl_width=draw_data.dodge_avl_w*params.width./(draw_data.n_colors);
else
    params.avl_width=draw_data.dodge_avl_w*params.width;
end

if params.raw_width
    draw_data.x=draw_data.x+rand(size(draw_data.x))*params.width-params.width/2;
else
    draw_data.x=draw_data.x+rand(size(draw_data.x))*params.avl_width-params.avl_width/2;
end

draw_data.y=draw_data.y+rand(size(draw_data.y))*params.height-params.height/2;

%We adjust axes limits to accomodate for the jittering
if max(draw_data.x)>obj.plot_lim.maxx(obj.current_row,obj.current_column);
    obj.plot_lim.maxx(obj.current_row,obj.current_column)=max(draw_data.x);
end
if min(draw_data.x)<obj.plot_lim.minx(obj.current_row,obj.current_column);
    obj.plot_lim.minx(obj.current_row,obj.current_column)=min(draw_data.x);
end
if max(draw_data.y)>obj.plot_lim.maxy(obj.current_row,obj.current_column);
    obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(draw_data.y);
end
if min(draw_data.y)<obj.plot_lim.miny(obj.current_row,obj.current_column);
    obj.plot_lim.miny(obj.current_row,obj.current_column)=min(draw_data.y);
end

%hndl=my_point(obj,draw_data);
hndl=scatter(draw_data.x,draw_data.y,draw_data.point_size^2,...
    'Marker',draw_data.marker,...
    'MarkerEdgeColor','none','MarkerFaceColor',draw_data.color);

if ~isempty(hndl)
    hndl.MarkerFaceAlpha=params.alpha;
end

obj.results.geom_jitter_handle{obj.result_ind,1}=hndl;
end