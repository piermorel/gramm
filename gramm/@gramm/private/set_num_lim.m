function set_num_lim(ax,axis_name,lim)
%Set axes limits given as numbers, also on datetime/duration rulers
ruler=ax.([axis_name 'Axis']);
if isa(ruler,'matlab.graphics.axis.decorator.NumericRuler')
    ax.([axis_name 'Lim'])=lim;
else
    ax.([axis_name 'Lim'])=num2ruler(lim,ruler);
end
end
