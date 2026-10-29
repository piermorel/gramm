function obj=geom_vline(obj,varargin)
% geom_vline Display vertical reference lines in each facet
%
% Example syntax: gramm_object.geom_vline('xintercept',1,'style','k--')
% 'xintercept' can also be datetime or duration values when the data is.
% See geom_abline for details

p=inputParser;
my_addParameter(p,'xintercept',0);
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
    obj(obj_ind).abline=fill_abline(obj(obj_ind).abline,NaN,NaN,p.Results.xintercept,NaN,@(x)x,p.Results.style,p.Results.extent,line_width);
end
end