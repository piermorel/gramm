function draw_polygons(obj)
% draw_polygons
%
% Handles the actual drawing of polygons when the draw() function is
% called.
%
% created: 2017-Mar-03
% author: Nicholas J. Schaub, Ph.D.
% email: nicholas.j.schaub@gmail.com
%
% modified: 2017-Mar-12, Pierre Morel

%If we get indices for color or line_color, use get_line_colormap to get actual line_colors
if size(obj.polygon.color,2)==1
    cmap=get_colormap(max(obj.polygon.color),1,obj.polygon.color_options);
    obj.polygon.color=cmap(obj.polygon.color,:);
end

if size(obj.polygon.line_color,2)==1
    cmap=get_colormap(max(obj.polygon.line_color),1,obj.polygon.color_options);
    obj.polygon.line_color=cmap(obj.polygon.line_color,:);
end

for poly_ind = 1:length(obj.polygon.x)

    p = patch(obj.polygon.x{poly_ind},obj.polygon.y{poly_ind},obj.polygon.color(poly_ind,:),...
            'Parent',obj.facet_axes_handles(obj.current_row,obj.current_column),...
            'FaceColor',obj.polygon.color(poly_ind,:),...
            'FaceAlpha',obj.polygon.alpha(poly_ind),...
            'EdgeColor',obj.polygon.line_color(poly_ind,:),...
        	'LineStyle',obj.polygon.line_style{poly_ind});

end

end

