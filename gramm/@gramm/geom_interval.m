function obj = geom_interval( obj,varargin )
% geom_interval Display intervals given by the ymin and ymax data (error bars, areas)
%
% Example syntax: gramm_object.geom_interval('geom','area')
% The data must contain ymin and ymax values (see gramm()) defining the
% interval boundaries. Error bars are drawn with MATLAB's errorbar(): their
% handles in results are ErrorBar objects.
%
% Parameters given as 'name',value pairs:
% - 'geom': How the intervals are displayed, one or a cell of several of
%            the following (default 'area'):
%       - 'area': y connected by a line, interval as a shaded transparent
%            area
%       - 'lines': y connected by a line, interval as thin lines
%       - 'line': y connected by a line
%       - 'area_only': interval as a shaded transparent area, no line
%       - 'solid_area': y connected by a line, interval as a solid area
%       - 'errorbar': interval as colored error bars
%       - 'black_errorbar': interval as black error bars
%       - 'bar': y as colored bars
%       - 'edge_bar': y as colored bars with black edges
%       - 'point': y as points
%       - 'black_point': y as black points
% - 'dodge': Spacing between intervals of different colors within an
%            unique x value (default [], 0.6 for 'bar' with several
%            colors, 0 otherwise)
% - 'width': Width of the bars (default [], 0.8 times 'dodge' if dodging,
%            0.5 otherwise). The size of errorbar caps is set with
%            set_line_options('cap_size',...)
% - 'fill_alpha': Transparency of the 'area' geom, from 0 (transparent)
%            to 1 (opaque) (default 0.2)

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
