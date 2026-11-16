function obj=geom_funline(obj,varargin)
% geom_funline Display a custom curve in each facet
%
% Example syntax: gramm_object.geom_funline('fun',@(x)3*sin(x),'style','k--')
%
% Parameters given as 'name',value pairs:
% - 'fun': Anonymous function of x, or cell of anonymous functions
%            (default @(x)x)
% - 'style': Line specification or cell of line specifications, same as
%            geom_abline() (default 'k--')
% - 'extent': Length of the curves, same as geom_abline() (default 2)
% - 'line_width': Width of the lines (default 1)
% - 'linewidth': Former name of 'line_width' (default [])

p=inputParser;
addParameter(p,'fun',@(x)x);
addParameter(p,'style','k--');
addParameter(p,'extent',2);
addParameter(p,'line_width',1,@(v) valid_range(v,0,Inf));
addParameter(p,'linewidth',[],@(v) valid_range(v,0,Inf,true)); %Former name of 'line_width'
parse(p,varargin{:});

line_width=p.Results.line_width;
if ~isempty(p.Results.linewidth)
    line_width=p.Results.linewidth;
end

for obj_ind=1:numel(obj)
    obj(obj_ind).abline=fill_abline(obj(obj_ind).abline,NaN,NaN,NaN,NaN,p.Results.fun,p.Results.style,p.Results.extent,line_width);
end
end