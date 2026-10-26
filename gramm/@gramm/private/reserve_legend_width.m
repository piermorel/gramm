function reserve_legend_width(obj)
% Make the 'east' tile holding the legend as wide as the legend text.
% tiledlayout sizes outer tiles from the axes decorations (tick labels,
% labels) but ignores text objects drawn inside the axes, so the legend
% axes gets an invisible tick label as wide as the part of the legend that
% overflows the axes.

ax=obj.legend_axe_handle;
txt=findobj(ax,'Type','text','-not','Tag','gramm_legend_probe');
if isempty(txt)
    return; %No legend: the axes stays hidden
end

%Axes has to be visible for its tick labels to count, everything is drawn
%with 'none' colors
set(ax,'Visible','on','Color','none','XColor','none','YColor','none',...
    'XTick',[],'YAxisLocation','right','TickLength',[0 0],...
    'YTick',[],'YTickLabel',{},...
    'FontName',txt(1).FontName,...
    'FontSize',txt(1).FontSize,...
    'HitTest','off');

%Pixel width of the axes itself (tiledlayout gives 'east' tiles a fixed
%width) and right edge of the legend texts, both from the axes left edge.
%Texts are used for the measurements because changing the Units of the
%axes can collapse it inside a tiledlayout
probe=text(ax,ax.XLim(2),ax.YLim(1),'M','Units','data','Visible','off','HandleVisibility','off');
probe.Units='pixels';
axes_width=probe.Position(1);
char_width=probe.Extent(3);
delete(probe);

right_edge=0;
for k=1:numel(txt)
    old_units=txt(k).Units;
    txt(k).Units='pixels';
    right_edge=max(right_edge,sum(txt(k).Extent([1 3])));
    txt(k).Units=old_units;
end

%The tick label only needs to cover what doesn't fit in the axes
overflow=right_edge-axes_width;
if overflow>0
    set(ax,'YTick',mean(ax.YLim),'YTickLabel',{repmat('M',1,ceil(overflow/char_width))});
end

end
