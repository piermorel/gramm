function draw_polygons(obj)
% draw_polygons
%
% Handles the actual drawing of polygons when the draw() function is
% called.

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

    tmp_x=obj.polygon.x{poly_ind};
    tmp_y=obj.polygon.y{poly_ind};
    
    %Handle cases of omitted x or y values
    if isempty(tmp_x)
        tmp_xl=[obj.var_lim.minx obj.var_lim.maxx];
        tmp_extent=(tmp_xl(2)-tmp_xl(1))*obj.polygon.extent(poly_ind)/2;
        xl=[mean(tmp_xl)-tmp_extent mean(tmp_xl)+tmp_extent];
        tmp_y=[tmp_y(1) tmp_y(2) tmp_y(2) tmp_y(1)];
        tmp_x=[xl(1) xl(1) xl(2) xl(2)];
    end
    if isempty(tmp_y)
        tmp_yl=[obj.var_lim.miny obj.var_lim.maxy];
        tmp_extent=(tmp_yl(2)-tmp_yl(1))*obj.polygon.extent(poly_ind)/2;
        yl=[mean(tmp_yl)-tmp_extent mean(tmp_yl)+tmp_extent];
        tmp_x=[tmp_x(1) tmp_x(2) tmp_x(2) tmp_x(1)];
        tmp_y=[yl(1) yl(1) yl(2) yl(2)];
    end
    
    p = patch(tmp_x,tmp_y,obj.polygon.color(poly_ind,:),...
            'Parent',obj.facet_axes_handles(obj.current_row,obj.current_column),...
            'FaceColor',obj.polygon.color(poly_ind,:),...
            'FaceAlpha',obj.polygon.alpha(poly_ind),...
            'EdgeColor',obj.polygon.line_color(poly_ind,:),...
        	'LineStyle',obj.polygon.line_style{poly_ind});

end

end

