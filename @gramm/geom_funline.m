function obj=geom_funline(obj,varargin)
% geom_funline Display a custom curve in each facet
%
% Example syntax: gramm_object.geom_funline('fun',@(x)3*sin(x),'style','k--')
% The 'fun' argument allows to pass an anonymous function to
% plot

p=inputParser;
my_addParameter(p,'fun',@(x)x);
my_addParameter(p,'style','k--');
my_addParameter(p,'extent',2);
my_addParameter(p,'linewidth',1);
parse(p,varargin{:});

for obj_ind=1:numel(obj)
    obj(obj_ind).abline=fill_abline(obj(obj_ind).abline,NaN,NaN,NaN,NaN,p.Results.fun,p.Results.style,p.Results.extent,p.Results.linewidth);
end
end