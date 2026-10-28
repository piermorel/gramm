function obj=redraw(obj,~,~)
% redraw Update the plot after the figure is resized
%
% Syntax: gramm_object.redraw()
% Facet positions are handled by tiledlayout. redraw() wraps long titles
% to the available width, updates the room reserved for the legend and its
% vertical scale, the facet sizes when using the facet_grid() 'space' option
% (e.g. after changing axes limits by hand), and the elements drawn by
% geom_swarm() and stat_cornerhist(). It is called automatically when the
% figure is resized.

%Empty elements of an array of gramm objects, or deleted plots, are skipped
valid=arrayfun(@(o) ~isempty(o.facet_axes_handles) && isgraphics(o.layout),obj);
plots=obj(valid);

%Titles and legend width first, as they change the layout used below
changed=false;
for k=1:numel(plots)
    changed=wrap_titles(plots(k)) || changed;
    changed=reserve_legend_width(plots(k)) || changed;
end
if changed
    drawnow;
end

for k=1:numel(plots)
    apply_facet_space(plots(k));
    scale_legend(plots(k));
    for f=1:length(plots(k).redraw_fun)
        plots(k).redraw_fun{f}();
    end
end

end
