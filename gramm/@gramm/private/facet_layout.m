function [grid,tile,row_span,col_span]=facet_layout(obj,nr,nc,row_w,col_w)
% Tile grid and tile placement of the facets of a facet_grid() plot.
% Facets are spanning tiles of the layout grid. When the size of the facets
% depends on the axes limits (facet_grid() 'space' option), the free
% dimension of the grid is divided in 100 tiles and each row/column of
% facets spans a number of tiles proportional to its weight (row_w,col_w).
% Without weights all facets have the same size.

if nargin<4
    row_w=ones(1,nr);
    col_w=ones(1,nc);
end

[free_rows,free_cols]=free_space_dims(obj);
grid=[nr nc];
grid([free_rows free_cols] & grid>1)=100;

row_span=weights_to_spans(row_w,grid(1));
col_span=weights_to_spans(col_w,grid(2));

%Tiles are numbered row-wise, starting tile of each facet is the first tile
%after the spans of the preceding rows/columns
row_start=cumsum([0 row_span(1:end-1)]);
col_start=cumsum([0 col_span(1:end-1)]);
tile=row_start'*grid(2)+col_start+1;

end


function [free_rows,free_cols]=free_space_dims(obj)
% Which dimensions of the facet grid have sizes depending on axes limits
free_x=any(strcmp(obj.facet_space,{'free','free_x'}));
free_y=any(strcmp(obj.facet_space,{'free','free_y'}));
if obj.wrap_ncols>0 || strcmp(obj.facet_scale,'independent')
    free_x=false;
    free_y=false;
end
if obj.is_flipped %x axes are vertical
    free_rows=free_x;
    free_cols=free_y;
else
    free_rows=free_y;
    free_cols=free_x;
end
end


function spans=weights_to_spans(w,n)
% Integer spans proportional to the weights w, summing to n, at least 1
w=w(:)';
if numel(w)==n
    spans=ones(1,n);
    return
end
w(~(w>0))=mean(w(w>0)); %NaN, zero or negative weights get the mean weight
if all(isnan(w))
    w=ones(size(w));
end
spans=max(1,floor(w/sum(w)*n));
%Distribute the remaining tiles to the largest remainders (or remove
%extra tiles from the largest spans when the minimum of 1 overshoots)
remainder=w/sum(w)*n-spans;
while sum(spans)<n
    [~,k]=max(remainder);
    spans(k)=spans(k)+1;
    remainder(k)=remainder(k)-1;
end
while sum(spans)>n
    [~,k]=max(spans);
    spans(k)=spans(k)-1;
end
end
