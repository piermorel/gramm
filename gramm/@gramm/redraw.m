function obj=redraw(obj,~,~)
% redraw Update the plot after the figure is resized
%
% Syntax: gramm_object.redraw()
% Facet positions and legend width are handled by tiledlayout. redraw()
% updates the vertical scale of the legend, the facet sizes when using the
% facet_grid() 'space' option (e.g. after changing axes limits by hand),
% and the elements drawn by geom_swarm() and stat_cornerhist(). It is
% called automatically when the figure is resized.

for k=1:numel(obj)
    if isempty(obj(k).facet_axes_handles) || ~isgraphics(obj(k).layout)
        continue %Empty element of an array of gramm objects, or deleted plot
    end
    apply_facet_space(obj(k));
    scale_legend(obj(k));
    for f=1:length(obj(k).redraw_fun)
        obj(k).redraw_fun{f}();
    end
end

end
