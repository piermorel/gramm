function obj=geom_abline(obj,varargin)
% geom_abline Display y=ax+b reference lines in each facet
%
% Example syntax: gramm_object.geom_abline('slope',1,'intercept',0,'style','k--')
% 'slope' and 'intercept' can be 1D arrays of the same size in
% order to draw multiple lines. In that case, 'style' can
% either be a single style string (all lines will have the same
% style), or a cell array of strings to define one style per
% line.

p=inputParser;
my_addParameter(p,'slope',1);
my_addParameter(p,'intercept',0);
my_addParameter(p,'style','k--');
my_addParameter(p,'extent',2);
my_addParameter(p,'linewidth',1);
parse(p,varargin{:});

for obj_ind=1:numel(obj)
    obj(obj_ind).abline=fill_abline(obj(obj_ind).abline,p.Results.slope,p.Results.intercept,NaN,NaN,@(x)x,p.Results.style,p.Results.extent,p.Results.linewidth);
end
end