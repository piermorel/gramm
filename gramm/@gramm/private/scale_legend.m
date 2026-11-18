function scale_legend(obj)
% Scale the legend vertically so that entries are 18.75 points apart (25
% pixels on a 96 pixels per inch screen), or compress it to the legend axes
% height when it doesn't fit. Horizontally, legend units are 6 points wide
% whatever the width of the legend axes, so that symbols and line samples
% have the same size in all figures.

ax=obj.legend_axe_handle;
if isempty(ax) || ~isvalid(ax) || isempty(obj.legend_transform) || ~isvalid(obj.legend_transform) || obj.legend_y>=0
    return;
end

legend_y_step=1;
legend_y_additional_step=0.5;

%Height in pixels, from the layout (pixel positions inside the axes are
%slow to read in busy figures, and getpixelposition() is wrong for axes in
%nested tiledlayouts)
box=getfield(GetLayoutInformation(ax),'PlotBox'); %#ok<GFLD>
height_px=box(4);
if height_px<=0
    return;
end

%YLim spans abs(legend_y) legend units, so scale=1 fills the axes height
%Sizes are in points so that they follow the font size, whatever the
%screen resolution (pixels are 1/72 inch on some Linux systems)
px_per_pt=get(groot,'ScreenPixelsPerInch')/72;
legend_scale=min(18.75*px_per_pt*abs(obj.legend_y)/height_px,1);
%Horizontal scaling around x=1, where the legend symbols start
x_scale=6*px_per_pt*diff(ax.XLim)/box(3);
obj.legend_transform.Matrix=makehgtform("translate",[1-x_scale 0 0])*...
    makehgtform("scale",[x_scale legend_scale 1],"translate",[0 -(obj.legend_y+legend_y_additional_step+legend_y_step)/2 0]);

end
