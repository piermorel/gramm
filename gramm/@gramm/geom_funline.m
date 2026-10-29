function obj=geom_funline(obj,varargin)
% geom_funline Display a custom curve in each facet
%
% Example syntax: gramm_object.geom_funline('fun',@(x)3*sin(x),'style','k--')
% The 'fun' argument allows to pass an anonymous function to
% plot. 'style', 'line_width' and 'extent': see geom_abline

p=inputParser;
my_addParameter(p,'fun',@(x)x);
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
    obj(obj_ind).abline=fill_abline(obj(obj_ind).abline,NaN,NaN,NaN,NaN,p.Results.fun,p.Results.style,p.Results.extent,line_width);
end
end