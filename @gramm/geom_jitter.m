function obj=geom_jitter(obj,varargin)
% geom_jitter Display data as jittered points
%
% Example syntax (default arguments): gramm_object.geom_jitter('width',0.2,'height',0.2)
% In case datapoints are grouped together and are hard to see,
% it's possible to randomly jitter them in an area of width
% 'width' and height 'height' using this function.

p=inputParser;
my_addParameter(p,'width',0.2);
my_addParameter(p,'height',0);
my_addParameter(p,'dodge',0);
my_addParameter(p,'alpha',1);
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_jitter(dobj,dd,p.Results)});
obj.results.geom_jitter_handle={};
end


function  hndl=my_jitter(obj,draw_data,params)

draw_data.x=comb(draw_data.x);
draw_data.y=comb(draw_data.y);

draw_data.x=dodger(draw_data.x,draw_data,params.dodge);

draw_data.x=draw_data.x+rand(size(draw_data.x))*params.width-params.width/2;
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
hndl=line(draw_data.x,draw_data.y,'LineStyle','none','Marker',draw_data.marker,'MarkerEdgeColor','none','markerSize',draw_data.point_size,'MarkerFaceColor',draw_data.color);

set_alpha(hndl,1,params.alpha);

obj.results.geom_jitter_handle{obj.result_ind,1}=hndl;
end