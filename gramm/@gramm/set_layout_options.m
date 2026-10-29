function obj = set_layout_options( obj , varargin )
% set_layout_options Change figure layout options
%
% 'name',value pairs:
% 'legend':         specify (true/false) whether the side legend will be
%                   displayed. set_layout_options('legend',false)
%                   replaces no_legend()
% 'legend_position':Separates the legend from the gramm plot and puts in a 
%                   custom position in the figure (normalized coordinates).
% 'redraw'          true (default) / false. Specify whether the figure gets
%                   automatically updated on resize (see redraw()). Must be
%                   set on the first element when using an array of gramm
%                   objects
% 'spacing'         Corresponds to 'TileSpacing' option in tiledlayout()
%                   within a gramm plot
% 'padding'         Corresponds to 'Padding' option in tiledlayout()
%                   within a gramm plot
% 'multi_spacing'   Corrseponds to 'TileSpacing' option in tiledlayout()
%                   between multiple gramm plots 
% 'multi_padding'   Corresponds to 'Padding' option in tiledlayout()
%                   between multiple gramm plots 
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
