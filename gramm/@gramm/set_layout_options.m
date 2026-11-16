function obj = set_layout_options( obj , varargin )
% set_layout_options Change figure layout options
%
% Example syntax (default arguments): gramm_object.set_layout_options('legend',true,'spacing','compact')
%
% Parameters given as 'name',value pairs:
% - 'legend': Display the side legend (colors, markers...) (default true).
%            set_layout_options('legend',false) replaces no_legend()
% - 'legend_position': Separates the legend from the gramm plot and puts it
%            at a custom [left bottom width height] position in the figure
%            (normalized coordinates) (default 'auto')
% - 'redraw': Update the figure automatically on resize, see redraw()
%            (default true). Must be set on the first element when using an
%            array of gramm objects
% - 'spacing': 'TileSpacing' option of tiledlayout() within a gramm plot
%            (default 'compact')
% - 'padding': 'Padding' option of tiledlayout() within a gramm plot
%            (default 'compact')
% - 'multi_spacing': 'TileSpacing' option of tiledlayout() between
%            multiple gramm plots (default 'compact')
% - 'multi_padding': 'Padding' option of tiledlayout() between multiple
%            gramm plots (default 'compact')
%
% The position and size of gramm plots are set by tiledlayout. In order to
% create custom layouts (plots of different sizes, combination with
% regular Matlab axes), draw gramm plots in tiles of a tiledlayout using
% set_parent(layout,'tile',tile,'span',span).

%Options of the former manual layout, which have no equivalent with
%tiledlayout
removed={'position','legend_width','title_centering','redraw_gap','margin_height','margin_width','gap'};
names=varargin(1:2:end);
is_removed=cellfun(@(n)(ischar(n) || isstring(n)) && any(strcmpi(n,removed)),names);
if any(is_removed)
    error('gramm:removedOption',['set_layout_options(''%s'') is not supported anymore since gramm uses tiledlayout. ' ...
        'For custom layouts, draw the gramm plot in a tile of a tiledlayout with set_parent(layout,''tile'',tile,''span'',span).'],...
        char(names{find(is_removed,1)}));
end

p=inputParser;
addParameter(p,'legend', true );
addParameter(p,'legend_position', 'auto' );
addParameter(p,'redraw',true);
addParameter(p,'multi_padding','compact'); 
addParameter(p,'multi_spacing','compact'); 
addParameter(p,'padding','compact'); 
addParameter(p,'spacing','compact'); 
parse(p,varargin{:});

for obj_ind=1:numel(obj)
    obj(obj_ind).layout_options=p.Results;
end

end
