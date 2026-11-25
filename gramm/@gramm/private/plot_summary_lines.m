function hndl=plot_summary_lines(left,right,values,kinds,color,line_width)
%Draws the summary lines of stat_violin() and stat_boxplot(), horizontal
%segments from left to right at the given values, all with the same width.
%One NaN-separated object per kind: median solid, mean dotted (MATLAB's
%dashes are too long for such short segments), quantiles semi-transparent.
%Quantiles are drawn as a patch, as transparent lines in geom_line(),
%because lines have no documented transparency. Returns a struct with
%median_handle, quantile_handle and mean_handle (empty when not drawn)

uni_kinds={'median','quantile','mean'};

for ind_kind=1:length(uni_kinds)
    sel_kind=strcmp(kinds,uni_kinds{ind_kind});
    if any(sel_kind)
        n_lines=sum(sel_kind);
        temp_x=[left(sel_kind) ; right(sel_kind) ; NaN(1,n_lines)];
        temp_y=[values(sel_kind) ; values(sel_kind) ; NaN(1,n_lines)];
        switch uni_kinds{ind_kind}
            case 'quantile'
                hndl.quantile_handle=patch('XData',temp_x(:),'YData',temp_y(:),...
                    'FaceColor','none',...
                    'EdgeColor',color,...
                    'EdgeAlpha',0.4,...
                    'LineWidth',line_width);
            case 'mean'
                hndl.mean_handle=line(temp_x(:),temp_y(:),...
                    'Color',color,...
                    'LineStyle',':',...
                    'LineWidth',line_width);
            otherwise
                hndl.median_handle=line(temp_x(:),temp_y(:),...
                    'Color',color,...
                    'LineWidth',line_width);
        end
    else
        hndl.([uni_kinds{ind_kind} '_handle'])=gobjects(0);
    end
end

end
