function set_layer(ax,n_before,layer)
%Marks the children added to ax since it had n_before children (new
%children are added on top, i.e. first) with their layer (see order_layers)

children=ax.Children;
for k=1:numel(children)-n_before
    setappdata(children(k),'gramm_layer',layer);
end

end
