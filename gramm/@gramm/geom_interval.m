function obj = geom_interval( obj,varargin )
% geom_interval Display confidence intervals or error regions
%
% Example syntax: gramm_object.geom_interval('geom','area')
% This will add a layer that displays confidence intervals using the
% ymin and ymax aesthetics. The data must contain ymin and ymax values
% that define the interval boundaries.
%
% Parameters given as 'name',value pairs:
% - 'geom': How the intervals are displayed. Options include 'area',
%           'errorbar', 'line', 'bar' (default 'area')
% - 'dodge': Spacing between intervals of different colors within an 
%            unique x value. If empty, automatic dodging is applied
%            for bar geoms when multiple colors are present (default [])
% - 'width': Width of the intervals when using bar geoms (the size of
%            errorbar caps is set with set_line_options('cap_size',...)).
%            If empty, automatically determined based on dodge setting (default [])
% - 'fill_alpha': Transparency of the area of the 'area' geom, from 0
%            (transparent) to 1 (opaque) (default 0.2)

p=inputParser;
addParameter(p,'geom','area',@(v) valid_choice(v,{'line','lines','area','area_only','solid_area','errorbar','black_errorbar','bar','edge_bar','point','black_point'},true));
addParameter(p,'dodge',[],@(v) valid_range(v,0,Inf,true));
addParameter(p,'width',[],@(v) valid_range(v,0,Inf,true));
addParameter(p,'fill_alpha',0.2,@(v) valid_range(v,0,1));
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_ci(dobj,dd,p.Results)});
obj.results.geom_interval={};

end

function hndl=my_ci(obj,draw_data,params)

params.geom=cellstr(params.geom); %char, string, cell or string array

if isempty(draw_data.ymin) || isempty(draw_data.ymax)
    error('No ymin or ymax data for geom_ci');
end

%Advanced defaults
if isempty(params.dodge)
    if sum(strcmp(params.geom,'bar'))>0 && draw_data.n_colors>1 %If we have a bar as geom, we dodge
        params.dodge=0.6;
    else
        params.dodge=0;
    end
end

if isempty(params.width) %If no width given
    if params.dodge>0 %Equal to dodge if dodge given
        params.width=params.dodge*0.8;
    else
        params.width=0.5;
    end
end

if iscell(draw_data.x)
    for k=1:length(draw_data.x)
        hndl = plotci(obj,draw_data.x{k},draw_data.y{k},[draw_data.ymin{k} draw_data.ymax{k}],draw_data,params.geom,params.dodge,params.width,params.fill_alpha);
    end
else
    hndl=plotci(obj,draw_data.x,draw_data.y,[draw_data.ymin draw_data.ymax],draw_data,params.geom,params.dodge,params.width,params.fill_alpha);
end

obj.results.geom_interval{obj.result_ind,1}=hndl;

end
