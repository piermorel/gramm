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
