function changed=wrap_titles(obj)
%Wraps long titles on several lines so that they fit the space available
%to them: the title (and the title of an array of gramm plots) over the
%width of the plots, column titles over the width of their facet, and row
%titles along the height of their facet. The layout takes the extra lines
%into account. Titles given with explicit line breaks (cell arrays) and
%LaTeX titles are left as they are. When wrapping is turned off with
%set_text_options(), wrapped titles get their original string back. Returns
%true if a title changed

changed=false;
%Wrapping over an infinite width restores the original strings
if obj.text_options.wrap
    scale=1;
else
    scale=Inf;
end
%Invisible text used to measure the width of candidate lines
probe=text(obj.facet_axes_handles(1),0,0,'','Units','pixels','Visible','off','HandleVisibility','off');
cleanup=onCleanup(@() delete(probe));

if ~isempty(obj.title_text_handle)
    changed=wrap(obj.title_text_handle,scale*layout_width(obj.layout,obj.legend_axe_handle),probe) || changed;
end
if obj.multi.active && isequal(obj.parent_tile.tile,[1 1]) %Title of the whole array
    changed=wrap(obj.parent.Title,scale*layout_width(obj.parent,[]),probe) || changed;
end
for k=1:numel(obj.facet_axes_handles)
    ax=obj.facet_axes_handles(k);
    if ~isgraphics(ax)
        continue
    end
    box=getfield(GetLayoutInformation(ax),'PlotBox'); %#ok<GFLD>
    changed=wrap(ax.Title,scale*box(3),probe) || changed;
end
for r=1:numel(obj.facet_row_axes)
    if isgraphics(obj.facet_row_axes(r))
        box=getfield(GetLayoutInformation(obj.facet_axes_handles(r,end)),'PlotBox'); %#ok<GFLD>
        changed=wrap(obj.facet_row_axes(r).YLabel,scale*box(4),probe) || changed;
    end
end

end


function changed=wrap(h,width,probe)
changed=false;
if ~isgraphics(h) || strcmp(h.Interpreter,'latex')
    return
end
%The original string is kept to wrap it again when the figure is resized,
%unless the title was changed by hand in the meantime
str=h.String;
state=getappdata(h,'gramm_wrap');
if ~isempty(state) && isequal(str,state.wrapped)
    str=state.original;
end
if ~(ischar(str) && size(str,1)==1) && ~(isstring(str) && isscalar(str))
    return %Empty, or explicit line breaks
end
str=char(str);

%Greedy wrapping: words are added to the current line as long as it fits
set(probe,'FontName',h.FontName,'FontSize',h.FontSize,'FontWeight',h.FontWeight,...
    'FontAngle',h.FontAngle,'Interpreter',h.Interpreter);
words=strsplit(str,' ');
if isinf(width)
    words={str};
end
lines={};
current=words{1};
for k=2:numel(words)
    probe.String=[current ' ' words{k}];
    if probe.Extent(3)>0.95*width %Small margin between neighboring titles
        lines{end+1}=current; %#ok<AGROW>
        current=words{k};
    else
        current=probe.String;
    end
end
lines{end+1}=current;

if isscalar(lines)
    wrapped=str;
else
    wrapped=lines;
end
if ~isequal(h.String,wrapped)
    h.String=wrapped;
    changed=true;
end
%Stored as returned by the text object (cell arrays come back as columns)
setappdata(h,'gramm_wrap',struct('original',str,'wrapped',{h.String}));
end


function width=layout_width(layout,legend_axe)
%Width spanned by the plots of a layout, in pixels. The legend of the plot
%is excluded, as layout titles are centered over the tiles without it
ax=findobj(layout,'Type','axes');
ax(ismember(ax,legend_axe))=[];
boxes=zeros(numel(ax),4);
for k=1:numel(ax)
    boxes(k,:)=getfield(GetLayoutInformation(ax(k)),'OuterPosition'); %#ok<GFLD>
end
width=max(boxes(:,1)+boxes(:,3))-min(boxes(:,1));
end
