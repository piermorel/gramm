function edges=bin_edges(obj,edges,width,nbins)
%Numeric bin edges over x, from (in order of priority):
% - edges: numeric, datetime or duration bin edges
% - width: bin width, either numeric (in x units), a duration or
%   calendarDuration, or the name of a time unit ('second', 'minute',
%   'hour', 'day', 'week', 'month', 'quarter', 'year'...) for datetime or
%   duration x. Edges then fall on round values (calendar boundaries for
%   datetime x)
% - nbins: number of bins of equal width spanning the x data
T=obj.axis_types.x;
lims=[obj.var_lim.minx obj.var_lim.maxx];
if ~isempty(edges)
    edges=to_num(T,edges);
elseif ~isempty(width)
    if isnumeric(width)
        width=to_num(T,width);
        edges=(floor(lims(1)/width):ceil(lims(2)/width))*width;
        if numel(edges)<2
            edges=[edges edges+width];
        end
    else
        if strcmp(T.type,'numeric')
            error('gramm:binWidth','Time bin widths need datetime or duration x data');
        end
        if ischar(width) || isstring(width)
            [~,edges]=histcounts(from_num(T,lims),'BinMethod',char(width));
        else
            [~,edges]=histcounts(from_num(T,lims),'BinWidth',width);
        end
        edges=to_num(T,edges);
    end
else
    edges=linspace(lims(1),lims(2),nbins+1);
end
end
