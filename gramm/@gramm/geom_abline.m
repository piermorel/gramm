function obj=geom_abline(obj,varargin)
% geom_abline Display y=ax+b reference lines in each facet
%
% Example syntax: gramm_object.geom_abline('slope',1,'intercept',0,'style','k--')
% 'slope' and 'intercept' can be 1D arrays of the same size in
% order to draw multiple lines. In that case, 'style' can
% either be a single style string (all lines will have the same
% style), or a cell array of strings to define one style per
% line.
%
% Other parameters, also used by geom_hline(), geom_vline() and
% geom_funline():
% - 'style': MATLAB line specification giving the line style and color
%   (default 'k--')
% - 'line_width': width of the lines (default 1). 'linewidth' is accepted
%   as well
% - 'extent': length of the lines, as a ratio of the axis range (default
%   2: lines cross the whole axis)

p=inputParser;
my_addParameter(p,'slope',1);
my_addParameter(p,'intercept',0);
my_addParameter(p,'style','k--');
my_addParameter(p,'extent',2);
my_addParameter(p,'line_width',1);
my_addParameter(p,'linewidth',[]); %Former name of 'line_width'
parse(p,varargin{:});

line_width=p.Results.line_width;
if ~isempty(p.Results.linewidth)
    line_width=p.Results.linewidth;
end

for obj_ind=1:numel(obj)
    obj(obj_ind).abline=fill_abline(obj(obj_ind).abline,p.Results.slope,p.Results.intercept,NaN,NaN,@(x)x,p.Results.style,p.Results.extent,line_width);
end
end