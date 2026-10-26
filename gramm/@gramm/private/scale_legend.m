function scale_legend(obj)
% Scale the legend vertically so that entries are 25 pixels apart, or
% compress it to the legend axes height when it doesn't fit.

ax=obj.legend_axe_handle;
if isempty(ax) || ~isvalid(ax) || isempty(obj.legend_transform) || ~isvalid(obj.legend_transform) || obj.legend_y>=0
    return;
end

legend_y_step=1;
legend_y_additional_step=0.5;

%Height in pixels, whatever the figure units. Measured with a hidden text
%placed at the top of the axes: changing the Units of the axes itself
%while tiledlayout resizes it can leave it collapsed to zero height, and
%getpixelposition() is wrong for axes in nested tiledlayouts
probe=findall(ax,'Tag','gramm_legend_probe');
if isempty(probe)
    probe=text(ax,0,0,'','Visible','off','HandleVisibility','off','Tag','gramm_legend_probe');
end
probe.Units='data';
probe.Position=[ax.XLim(1) ax.YLim(2) 0];
probe.Units='pixels';
height_px=probe.Position(2);
probe.Units='data';
if height_px<=0
    return;
end

%YLim spans abs(legend_y) legend units, so scale=1 fills the axes height
legend_scale=min(25*abs(obj.legend_y)/height_px,1);
obj.legend_transform.Matrix=makehgtform("scale",[1 legend_scale 1],"translate",[0 -(obj.legend_y+legend_y_additional_step+legend_y_step)/2 0]);

end
