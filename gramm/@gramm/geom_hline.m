function obj=geom_hline(obj,varargin)
% geom_hline Display horizontal reference lines in each facet
%
% Example syntax: gramm_object.geom_hline('yintercept',1,'style','k--')
%
% Parameters given as 'name',value pairs:
% - 'yintercept': y position of the lines, single value or 1D array. Can
%            be datetime or duration values when the data is (default 0)
% - 'style': Line specification or cell of line specifications, same as
%            geom_abline() (default 'k--')
% - 'extent': Length of the lines, same as geom_abline() (default 2)
% - 'line_width': Width of the lines (default 1)
% - 'linewidth': Former name of 'line_width' (default [])

p=inputParser;
addParameter(p,'yintercept',0);
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
    obj(obj_ind).abline=fill_abline(obj(obj_ind).abline,NaN,NaN,NaN,p.Results.yintercept,@(x)x,p.Results.style,p.Results.extent,line_width);
end
end