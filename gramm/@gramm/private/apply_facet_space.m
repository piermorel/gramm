function apply_facet_space(obj)
% Size the facets of a facet_grid() plot proportionally to their axes
% limits (facet_grid() 'space' option), by changing the number of tiles
% each facet spans

if isempty(obj.facet_axes_handles) || obj.wrap_ncols>0 || strcmp(obj.facet_space,'fixed') ...
        || strcmp(obj.facet_scale,'independent')
    return
end

[nr,nc]=size(obj.facet_axes_handles);
row_w=ones(1,nr);
col_w=ones(1,nc);

if any(strcmp(obj.facet_space,{'free','free_x'}))
    if obj.is_flipped %x axes are along rows
        row_w=arrayfun(@(ax)diff(ruler2num(ax.XLim,ax.XAxis)),obj.facet_axes_handles(:,1))';
    else
        col_w=arrayfun(@(ax)diff(ruler2num(ax.XLim,ax.XAxis)),obj.facet_axes_handles(1,:));
    end
end
if any(strcmp(obj.facet_space,{'free','free_y'}))
    if obj.is_flipped %y axes are along columns
        col_w=arrayfun(@(ax)diff(ruler2num(ax.YLim,ax.YAxis)),obj.facet_axes_handles(1,:));
    else
        row_w=arrayfun(@(ax)diff(ruler2num(ax.YLim,ax.YAxis)),obj.facet_axes_handles(:,1))';
    end
end

[~,tile,row_span,col_span]=facet_layout(obj,nr,nc,row_w,col_w);
for r=1:nr
    for c=1:nc
        set_tile(obj.facet_axes_handles(r,c),tile(r,c),[row_span(r) col_span(c)]);
    end
    if numel(obj.facet_row_axes)>=r && isgraphics(obj.facet_row_axes(r))
        set_tile(obj.facet_row_axes(r),tile(r,nc),[row_span(r) col_span(nc)]);
    end
end

end


function set_tile(ax,tile,span)
if ax.Layout.Tile~=tile || any(ax.Layout.TileSpan~=span)
    %Span reset first so that the axes always fits in the grid
    ax.Layout.TileSpan=[1 1];
    ax.Layout.Tile=tile;
    ax.Layout.TileSpan=span;
end
end
