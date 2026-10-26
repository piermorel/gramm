function reserve_legend_width(obj)
% Make the 'east' tile holding the legend as wide as the legend text.
% tiledlayout sizes outer tiles from the axes decorations (tick labels,
% labels) but ignores text objects drawn inside the axes, so the legend
% axes gets an invisible tick label as wide as its widest text.

ax=obj.legend_axe_handle;
txt=findobj(ax,'Type','text');
if isempty(txt)
    return; %No legend: the axes stays hidden
end

%Widest text (all texts are in the same axes so data-unit widths compare)
[~,ind]=max(arrayfun(@(t)t.Extent(3),txt));
widest=txt(ind).String;
if iscell(widest) %Multi-line text: keep the longest line
    [~,l]=max(cellfun(@numel,widest));
    widest=widest{l};
end

%Axes has to be visible for its tick labels to count, everything is drawn
%with 'none' colors
set(ax,'Visible','on','Color','none','XColor','none','YColor','none',...
    'XTick',[],'YAxisLocation','right','TickLength',[0 0],...
    'YTick',mean(ax.YLim),'YTickLabel',{[widest '  ']},...
    'TickLabelInterpreter',txt(ind).Interpreter,...
    'FontName',txt(ind).FontName,...
    'FontSize',txt(ind).FontSize,...
    'FontWeight',txt(ind).FontWeight,...
    'HitTest','off');

end
