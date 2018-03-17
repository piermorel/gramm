function obj=geom_hline(obj,varargin)
% geom_abline Display an horizontal reference lines in each facet
%
% Example syntax: gramm_object.geom_abline('yintercept',1,'style','k--')
% See geom_abline for details

p=inputParser;
my_addParameter(p,'yintercept',0);
my_addParameter(p,'style','k--');
my_addParameter(p,'extent',2);
my_addParameter(p,'linewidth',1);
parse(p,varargin{:});

for obj_ind=1:numel(obj)
    obj(obj_ind).abline=fill_abline(obj(obj_ind).abline,NaN,NaN,NaN,p.Results.yintercept,@(x)x,p.Results.style,p.Results.extent,p.Results.linewidth);
end
end