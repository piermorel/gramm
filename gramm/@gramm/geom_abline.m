function obj=geom_abline(obj,varargin)
% geom_abline Display y=ax+b reference lines in each facet
%
% Example syntax: gramm_object.geom_abline('slope',1,'intercept',0,'style','k--')
% 'slope' and 'intercept' can be 1D arrays of the same size in order to
% draw multiple lines. In that case, 'style' can either be a single style
% (all lines have the same style), or a cell of styles, one per line.
%
% Parameters given as 'name',value pairs:
% - 'slope': Slope of the lines, single value or 1D array (default 1)
% - 'intercept': Intercept of the lines, single value or 1D array
%            (default 0)
% - 'style': MATLAB line specification giving the line style and color,
%            or cell of line specifications (default 'k--')
% - 'extent': Length of the lines, as a ratio of the axis range (default
%            2: lines cross the whole axis)
% - 'line_width': Width of the lines (default [], 'ref_size' of
%            set_line_options())
% - 'linewidth': Former name of 'line_width' (default [])

p=inputParser;
addParameter(p,'slope',1);
addParameter(p,'intercept',0);
addParameter(p,'style','k--');
addParameter(p,'extent',2);
addParameter(p,'line_width',[],@(v) valid_range(v,0,Inf,true));
addParameter(p,'linewidth',[],@(v) valid_range(v,0,Inf,true)); %Former name of 'line_width'
parse(p,varargin{:});

%Advanced defaults: NaN width means the 'ref_size' of set_line_options(),
%resolved in draw() since set_line_options() may be called afterwards
line_width=p.Results.line_width;
if ~isempty(p.Results.linewidth)
    line_width=p.Results.linewidth;
end
if isempty(line_width)
    line_width=NaN;
end

for obj_ind=1:numel(obj)
    obj(obj_ind).abline=fill_abline(obj(obj_ind).abline,p.Results.slope,p.Results.intercept,NaN,NaN,@(x)x,p.Results.style,p.Results.extent,line_width);
end
end