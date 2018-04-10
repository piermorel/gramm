function obj=geom_vline(obj,varargin)
% geom_abline Display vertical reference lines in each facet
%
% Example syntax: gramm_object.geom_abline('xintercept',1,'style','k--')
% See geom_abline for details

p=inputParser;
my_addParameter(p,'xintercept',0);
my_addParameter(p,'style','k--');
my_addParameter(p,'extent',2);
my_addParameter(p,'linewidth',1);
parse(p,varargin{:});

for obj_ind=1:numel(obj)
    obj(obj_ind).abline=fill_abline(obj(obj_ind).abline,NaN,NaN,p.Results.xintercept,NaN,@(x)x,p.Results.style,p.Results.extent,p.Results.linewidth);
end
end