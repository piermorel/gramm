function order_layers(ax,n_old)
%Draws the layers of a facet in the order of their calls, so that a layer
%covers all the groups of the previous ones (otherwise they are stacked
%group by group, as draw() loops over groups then over geoms). Only the
%children added since the facet had n_old children are sorted, by their
%'gramm_layer' appdata: older content (from before an update()) stays
%below. Objects without layer go on top. The sort is stable, so groups
%keep their order within each layer

children=ax.Children;
n_new=numel(children)-n_old;
if n_new<2
    return
end
layer=inf(n_new,1);
for k=1:n_new
    if isappdata(children(k),'gramm_layer')
        layer(k)=getappdata(children(k),'gramm_layer');
    end
end
%Children are stored from top to bottom
[~,order]=sort(layer,'descend');
ax.Children=[children(order) ; children(n_new+1:end)];

end
