function obj=geom_vline(obj,varargin)
% geom_vline Display vertical reference lines in each facet
%
% Example syntax: gramm_object.geom_vline('xintercept',1,'style','k--')
%
% Parameters given as 'name',value pairs:
% - 'xintercept': x position of the lines, single value or 1D array. Can
%            be datetime or duration values when the data is (default 0)
% - 'style': Line specification or cell of line specifications, same as
%            geom_abline() (default 'k--')
% - 'extent': Length of the lines, same as geom_abline() (default 2)
% - 'line_width': Width of the lines (default [], 'ref_size' of
%            set_line_options())
% - 'linewidth': Former name of 'line_width' (default [])

p=inputParser;
addParameter(p,'xintercept',0);
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
    obj(obj_ind).abline=fill_abline(obj(obj_ind).abline,NaN,NaN,p.Results.xintercept,NaN,@(x)x,p.Results.style,p.Results.extent,line_width);
end
end