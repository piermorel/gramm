function apply_theme(obj)
%Gives the figure (or uipanel/uitab) gramm draws in the same background as
%the axes, for gramm's clean look, and makes pure black elements drawn by
%gramm (reference lines, error bars, bar edges, legend symbols...) use
%MATLAB's automatic neutral color, which follows the figure theme. Figure
%themes exist from R2025a: a ThemeChangedFcn keeps the backgrounds matched
%when the theme changes after drawing

container=ancestor(obj.parent,{'figure','uipanel','uitab'});
setappdata(container,'gramm_axes',obj.facet_axes_handles(1));
match_background(container);

fig=ancestor(container,'figure');
if ~isprop(fig,'Theme') || isempty(fig.Theme)
    return
end
%The callback is figure-wide and handles all gramm containers. A
%ThemeChangedFcn already set by the user is left alone
if isempty(fig.ThemeChangedFcn)
    fig.ThemeChangedFcn=@(f,~) theme_changed(f);
end

parents=[obj.layout ; obj.legend_axe_handle(:)];
if isfield(obj.extra,'cornerhist_child_axe')
    parents=[parents ; obj.extra.cornerhist_child_axe(:)];
end
h=findall(parents(isgraphics(parents)));

set(findobj(h,'flat','Type','line','Color',[0 0 0]),'ColorMode','auto','SeriesIndex','none');
%Filled markers of lines have no automatic color mode: black ones get the
%(automatic) line color, and are updated when the theme changes
black_markers=findobj(h,'flat','Type','line','MarkerFaceColor',[0 0 0]);
for k=1:numel(black_markers)
    setappdata(black_markers(k),'gramm_black_marker',true);
end
match_markers(black_markers);
%Black marker edges (point borders) have no automatic color mode either:
%they get the neutral color of the axes, and are updated when the theme
%changes
black_edges=[findobj(h,'flat','Type','line','MarkerEdgeColor',[0 0 0]) ; ...
    findobj(h,'flat','Type','scatter','MarkerEdgeColor',[0 0 0])];
for k=1:numel(black_edges)
    setappdata(black_edges(k),'gramm_black_edge',true);
end
match_edges(black_edges);
set(findobj(h,'flat','Type','errorbar','Color',[0 0 0]),'ColorMode','auto','SeriesIndex','none');
set(findobj(h,'flat','Type','scatter','CData',[0 0 0]),'CDataMode','auto','SeriesIndex','none');
%Patch color modes are not documented, but behave like the others
set(findobj(h,'flat','Type','patch','EdgeColor',[0 0 0]),'EdgeColorMode','auto','SeriesIndex','none');
set(findobj(h,'flat','Type','patch','FaceColor',[0 0 0]),'FaceColorMode','auto','SeriesIndex','none');

end


function theme_changed(fig)
%Axes colors are already updated to the new theme when this is called
containers=findall(fig,'-function',@(c) isappdata(c,'gramm_axes'));
for k=1:numel(containers)
    match_background(containers(k));
end
match_markers(findall(fig,'Type','line','-function',@(l) isappdata(l,'gramm_black_marker')));
match_edges(findall(fig,'-function',@(l) isappdata(l,'gramm_black_edge')));
end


function match_markers(lines)
for k=1:numel(lines)
    lines(k).MarkerFaceColor=lines(k).Color;
end
end


function match_edges(objs)
%The neutral color of lines in automatic color mode is the axes XColor
for k=1:numel(objs)
    ax=ancestor(objs(k),'axes');
    if ~isempty(ax)
        objs(k).MarkerEdgeColor=ax.XColor;
    end
end
end


function match_background(container)
ax=getappdata(container,'gramm_axes');
if ~isgraphics(ax) || ~isnumeric(ax.Color) %Deleted, or 'none' set by the user
    return
end
if isprop(container,'BackgroundColor') %uipanel, uitab
    container.BackgroundColor=ax.Color;
else
    container.Color=ax.Color;
end
end
