function draw_polygons(obj,ca)
% draw_polygons
%
% Handles the actual drawing of polygons when the draw() function is
% called.
%
% created: 2017-Mar-03
% author: Nicholas J. Schaub, Ph.D.
% email: nicholas.j.schaub@gmail.com

for poly_ind = 1:length(obj.polygon.alpha)

    p_X = obj.polygon.x{poly_ind};
    p_Y = obj.polygon.y{poly_ind};
    p_fill = obj.polygon.fill{poly_ind};
    p_color = obj.polygon.color{poly_ind};
    p_alpha = obj.polygon.alpha(poly_ind);

    % Get color map for polygon borders
    if ~isempty(obj.polygon.color{poly_ind}) && ~isempty(obj.polygon.style{poly_ind})
        line_style = obj.polygon.style(poly_ind);
        color_cat = unique(obj.polygon.color);
        cmap = get_colormap(length(color_cat),1,obj.polygon.color_options{poly_ind});
    elseif ~isempty(obj.polygon.color{poly_ind})
        line_style = obj.polygon.style(poly_ind);
        color_cat = 1;
        p_color = ones(length(p_X),1);
        cmap = [0 0 0];
    elseif ~isempty(obj.polygon.style{poly_ind})
        line_style = '-';
        color_cat = unique(obj.polygon.color{poly_ind});
        cmap = get_colormap(length(color_cat),1,obj.polygon.color_options{poly_ind});
    else
        line_style ='none';
        color_cat = 1;
        p_color = ones(length(p_X),1);
        cmap = [0 0 0];
    end

    if ~isempty(obj.polygon.fill{poly_ind})
        fill_cat = unique(obj.polygon.fill{poly_ind});
        fmap = get_colormap(length(fill_cat),1,obj.polygon.color_options{poly_ind});
    else
        fill_cat = 1;
        p_fill = ones(length(p_X),1);
        fmap = [0 0 0];
    end

    for shape_ind = 1:length(p_X)
        p = patch(p_X{shape_ind}',p_Y{shape_ind}',fmap(1,:));
        p.Parent = ca;
        p.FaceColor = fmap(fill_cat==p_fill(shape_ind),:);
        p.FaceAlpha = p_alpha;
        p.EdgeColor = cmap(color_cat==p_color(shape_ind),:);
        p.LineStyle = line_style;
    end

end

end

