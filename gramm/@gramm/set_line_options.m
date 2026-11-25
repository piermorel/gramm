function obj = set_line_options( obj , varargin )
% set_line_options Set line width and style options
%
% Example syntax (default arguments): gramm_object.set_line_options('base_size',1.5,'step_size',1,'edge_size',1)
% Without a 'size' grouping variable, all lines have the width
% 'base_size'. With one, the first size group has 'base_size' and each
% next group is 'step_size' wider. With 'use_input', numeric size data is
% used directly as line widths instead of as groups.
% The other kinds of lines (edges, errorbars, summary lines) have their own
% width, and follow the size groups the same way: each next group is
% 'step_size' wider. With 'use_input', they are as much wider (or thinner)
% than their own width as the data lines are wider than 'base_size'.
%
% Parameters given as 'name',value pairs:
% - 'base_size': Width of the data lines (geom_line(), stat_summary(),
%            stat_smooth()...), or of the first size group (default 1.5)
% - 'step_size': Width difference between successive size groups
%            (default 1)
% - 'edge_size': Width of the edges and outlines of bars, boxes and
%            their whiskers, violins, ellipses and polygons (default 1)
% - 'interval_size': Width of the errorbars (default 1)
% - 'summary_size': Width of the summary lines (median...) of
%            stat_boxplot() and stat_violin() (default [], same as
%            'edge_size')
% - 'ref_size': Width of the reference lines of geom_abline(),
%            geom_hline(), geom_vline() and geom_funline(), when not given
%            to them as 'line_width' (default 1)
% - 'size_aes': Lines follow the 'size' groups (default true). With false,
%            all lines keep their own width and only the points follow
%            the 'size' groups (see set_point_options())
% - 'use_input': Use the numeric values of the 'size' data as line
%            widths, instead of size groups (default false)
% - 'input_fun': Function converting the 'size' data into line widths
%            when 'use_input' is true, e.g. @(v)v/2 (default @(v)v)
% - 'styles': Line styles of the linestyle groups, in order (default
%            {'-' ':' '--' '-.'}). They apply to the data lines and to
%            the edges of bars, boxes, violins and ellipses, not to
%            errorbars, whiskers and summary lines
% - 'cap_size': Size of the error bar caps, in points (default 6)


p=inputParser;
addParameter(p, 'base_size', 1.5 );
addParameter(p, 'step_size', 1 );
addParameter(p, 'edge_size', 1 ,@(v) valid_range(v,0,Inf));
addParameter(p, 'interval_size', 1 ,@(v) valid_range(v,0,Inf));
addParameter(p, 'summary_size', [] ,@(v) valid_range(v,0,Inf,true));
addParameter(p, 'ref_size', 1 ,@(v) valid_range(v,0,Inf));
addParameter(p, 'size_aes', true );
addParameter(p, 'use_input', false );
addParameter(p, 'input_fun', @(v)v );
addParameter(p, 'styles', {'-' ':' '--' '-.'} );
addParameter(p, 'cap_size', 6 ,@(v) valid_range(v,0,Inf));
parse(p,varargin{:});

params=p.Results;

%Advanced defaults: summary lines have the width of the edges
if isempty(params.summary_size)
    params.summary_size=params.edge_size;
end

for obj_ind=1:numel(obj)
    obj(obj_ind).line_options=params;
end

end
