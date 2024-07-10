function obj=stat_density(obj,varargin)
% geom_point Displays an smooth density estimate of the data in x
%
% Example syntax (default arguments): gramm_object.stat_density('function','pdf','kernel','normal','npoints',100)
% the 'function','kernel', and 'bandwidth' arguments are the
% ones used by the underlying matlab function ksdensity
% 'npoints' is used to set how many x values are used to
% display the density estimates.
% 'extra_x' is used to increase the range of x values over
% which the estimated density function is displayed. Values
% will be extended to the right and to the left by extra_x
% times the range of x data.

p=inputParser;
my_addParameter(p,'bandwidth',-1);
my_addParameter(p,'function','pdf')
my_addParameter(p,'kernel','normal')
my_addParameter(p,'npoints',100)
my_addParameter(p,'extra_x',0.1)
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_density(dobj,dd,p.Results)});
obj.results.stat_density={};
end

function hndl=my_density(obj,draw_data,params)


if obj.polar.is_polar
    %Make x data modulo 2 pi
    draw_data.x=mod(comb(draw_data.x),2*pi);
    warning('Polar density estimate is probably not proper for circular data, use custom bandwidth');
    %Let's try to make boundaries a bit more proper by
    %repeating values below 0 and above 2 pi
    draw_data.x=[draw_data.x-2*pi;draw_data.x;draw_data.x+2*pi];
    extra_x=0;
    binranges=linspace(0,2*pi,params.npoints);
else
    extra_x=(obj.var_lim.maxx-obj.var_lim.minx)*params.extra_x;
    binranges=linspace(obj.var_lim.minx-extra_x,obj.var_lim.maxx+extra_x,params.npoints);
end

if params.bandwidth>0
    [f,xi] = ksdensity(comb(draw_data.x),binranges,'function',params.function,'bandwidth',params.bandwidth,'kernel',params.kernel);
else
    [f,xi] = ksdensity(comb(draw_data.x),binranges,'function',params.function,'kernel',params.kernel);
end

obj.plot_lim.minx(obj.current_row,obj.current_column)=obj.var_lim.minx-extra_x;
obj.plot_lim.maxx(obj.current_row,obj.current_column)=obj.var_lim.maxx+extra_x;
obj.plot_lim.miny(obj.current_row,obj.current_column)=0;
if obj.firstrun(obj.current_row,obj.current_column)
    obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(f);
    %obj.firstrun(obj.current_row,obj.current_column)=0;
    obj.aes_names.y=[obj.aes_names.x ' ' params.function];
else
    if max(f)>obj.plot_lim.maxy(obj.current_row,obj.current_column)
        obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(f);
    end
end

obj.results.stat_density{obj.result_ind,1}.x=xi;
obj.results.stat_density{obj.result_ind,1}.y=f;

[xi,f]=to_polar(obj,xi,f);
hndl=plot(xi,f,'LineStyle',draw_data.line_style,'Color',draw_data.color,'lineWidth',draw_data.line_size);

obj.results.stat_density{obj.result_ind,1}.handle=hndl;
end