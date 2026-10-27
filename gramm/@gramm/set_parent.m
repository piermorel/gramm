function obj=set_parent(obj,parent,varargin)
% set_parent Set where the gramm plot is drawn
%
% Example syntax: gramm_object.set_parent(parent,'tile',1,'span',[1 1])
% parent can be a figure, a panel or a tiledlayout. When it is a
% tiledlayout, the gramm plot is drawn in a tile of the layout, set with
% the following 'name',value pairs (as with nexttile()):
% - 'tile': tile number (counted row by row, default 1), or [row column]
%    of the tile
% - 'span': number of tiles [rows columns] covered by the plot (default
%    [1 1])
% This allows to combine gramm plots of different sizes and regular Matlab
% axes in a single figure:
%   t=tiledlayout(2,3);
%   g.set_parent(t,'tile',1,'span',[2 2]);
% When called on an array of gramm objects, the whole array is drawn in
% the given parent/tile.

is_layout=isa(parent,'matlab.graphics.layout.TiledChartLayout');

p=inputParser;
my_addParameter(p,'tile',1);
my_addParameter(p,'span',[1 1]);
parse(p,varargin{:});
tile=p.Results.tile;
span=p.Results.span;

if ~is_layout
    if ~isempty(varargin)
        error('''tile'' and ''span'' can only be given when the parent is a tiledlayout');
    end
else
    if ~isnumeric(tile) || ~any(numel(tile)==[1 2]) || any(tile<1) || any(tile~=round(tile))
        error('''tile'' must be a tile number or a [row column] pair of positive integers');
    end
    if ~isnumeric(span) || numel(span)~=2 || any(span<1) || any(span~=round(span))
        error('''span'' must be a [rows columns] pair of positive integers');
    end
    if numel(tile)==2
        tile=tilenum(parent,tile(1),tile(2));
    end
    %With a fixed grid, the plot has to fit in it (tiledlayout doesn't
    %complain and places it outside of the figure)
    if strcmp(parent.TileArrangement,'fixed')
        grid=parent.GridSize;
        row=ceil(tile/grid(2));
        column=tile-(row-1)*grid(2);
        if row+span(1)-1>grid(1) || column+span(2)-1>grid(2)
            error('Tile %d spanning [%d %d] does not fit in the %dx%d tiledlayout',tile,span(1),span(2),grid(1),grid(2));
        end
    end
end

for obj_ind=1:numel(obj)
    obj(obj_ind).parent=parent;
    obj(obj_ind).parent_tile=struct('tile',tile,'span',span(:)');
end

end
