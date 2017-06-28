function obj = geom_interval( obj,varargin )

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
