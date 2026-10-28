function changed=reserve_legend_width(obj)
% Make the 'east' tile holding the legend as wide as the legend text.
% tiledlayout sizes outer tiles from the axes decorations (tick labels,
% labels) but ignores text objects drawn inside the axes, so the legend
% axes gets an invisible tick label as wide as the part of the legend that
% overflows the axes. The width of the axes itself follows the figure
% size, so this is redone by redraw() on resize. Returns whether the
% tick label changed (the layout then changes at the next drawnow).

changed=false;
if ~strcmp(obj.layout_options.legend_position,'auto') || ~isgraphics(obj.legend_axe_handle)
    return
end

ax=obj.legend_axe_handle;
txt=findobj(ax,'Type','text');
if isempty(txt)
    return; %No legend: the axes stays hidden
end

%Axes has to be visible for its tick labels to count, everything is drawn
%with 'none' colors
set(ax,'Visible','on','Color','none','XColor','none','YColor','none',...
    'XTick',[],'YAxisLocation','right','TickLength',[0 0],...
    'FontName',txt(1).FontName,...
    'FontSize',txt(1).FontSize,...
    'HitTest','off');

%Pixel width of the axes itself (tiledlayout sizes 'east' tiles from the
%figure size) and right edge of the legend texts, both from the axes left
%edge. Pixel positions inside the axes are slow to read in busy figures
%and wrong during resizes: the axes width comes from the layout, text
%positions from their data coordinates, and text widths in pixels (which
%don't depend on the figure size) are measured once and kept
box=getfield(GetLayoutInformation(ax),'PlotBox'); %#ok<GFLD>
axes_width=box(3);
char_width=text_width(ax,'M',txt(1));

right_edge=0;
for k=1:numel(txt)
    w=text_width(ax,txt(k).String,txt(k));
    left=(txt(k).Position(1)-ax.XLim(1))/diff(ax.XLim)*axes_width;
    switch txt(k).HorizontalAlignment
        case 'center'
            left=left-w/2;
        case 'right'
            left=left-w;
    end
    right_edge=max(right_edge,left+w);
end

%The tick label only needs to cover what doesn't fit in the axes
overflow=right_edge-axes_width;
label=repmat('M',1,max(0,ceil(overflow/char_width)));
if ~strcmp(strjoin(cellstr(ax.YTickLabel),''),label)
    changed=true;
    if isempty(label)
        set(ax,'YTick',[],'YTickLabel',{});
    else
        set(ax,'YTick',mean(ax.YLim),'YTickLabel',{label});
    end
end

end


function w=text_width(ax,str,ref)
%Pixel width of str in the font of the text object ref, kept in the
%appdata of ref (of the axes when str is not the string of ref)
key={str,ref.FontName,ref.FontSize,ref.FontWeight,ref.FontAngle,ref.Interpreter};
if isequal(str,ref.String)
    holder=ref;
else
    holder=ax;
end
cached=getappdata(holder,'gramm_width');
if ~isempty(cached) && isequal(cached.key,key)
    w=cached.width;
    return
end
probe=text(ax,0,0,str,'Units','pixels','Visible','off','HandleVisibility','off',...
    'FontName',ref.FontName,'FontSize',ref.FontSize,'FontWeight',ref.FontWeight,...
    'FontAngle',ref.FontAngle,'Interpreter',ref.Interpreter);
w=probe.Extent(3);
delete(probe);
setappdata(holder,'gramm_width',struct('key',{key},'width',w));
end
