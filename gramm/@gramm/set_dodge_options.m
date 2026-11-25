function obj = set_dodge_options( obj , varargin )
% set_dodge_options Set which groups are dodged
%
% Example syntax (default arguments): gramm_object.set_dodge_options('by',{'color','lightness','marker','linestyle','size'})
% With a 'dodge' option above 0, geoms and stats (stat_boxplot(),
% stat_violin(), stat_summary() bars, geom_point()...) place the elements
% of different groups side by side at each x value. Groups are the
% combinations of the aesthetics listed in 'by', colors being the outer
% level. When the other aesthetics are the same as color (e.g. 'marker' and
% 'color' given the same variable), only colors are dodged.
%
% Parameters given as 'name',value pairs:
% - 'by': Aesthetics whose groups are dodged, among 'color', 'lightness',
%            'marker', 'linestyle', 'size' and 'group' (default all but
%            'group', which usually gives the units drawn as separate
%            lines, e.g. subjects, that stay in the slot of their color).
%            For instance {'color','lightness'} dodges colors only: points
%            of different markers then share the slot of their color, as
%            in earlier versions of gramm


p=inputParser;
addParameter(p, 'by', {'color','lightness','marker','linestyle','size'} ,...
    @(v) valid_choice(v,{'color','lightness','marker','linestyle','size','group'},true));
parse(p,varargin{:});

params=p.Results;
params.by=cellstr(params.by);

for obj_ind=1:numel(obj)
    obj(obj_ind).dodge_options=params;
end

end
