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
% - 'width': Width of the intervals when using bar or errorbar geoms.
%            If empty, automatically determined based on dodge setting (default [])

p=inputParser;
my_addParameter(p,'geom','area');
my_addParameter(p,'dodge',[]);
my_addParameter(p,'width',[]);
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_ci(dobj,dd,p.Results)});
obj.results.geom_interval={};

end

function hndl=my_ci(obj,draw_data,params)

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
        hndl = plotci(obj,draw_data.x{k},draw_data.y{k},[draw_data.ymin{k} draw_data.ymax{k}],draw_data,params.geom,params.dodge,params.width);
    end
else
    hndl=plotci(obj,draw_data.x,draw_data.y,[draw_data.ymin draw_data.ymax],draw_data,params.geom,params.dodge,params.width);
end

obj.results.geom_interval{obj.result_ind,1}=hndl;

end
