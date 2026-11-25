function props=marker_props(obj,draw_data,face_color)
%Name-value pairs for data points drawn with plot() or line(): marker and
%size of the group, border from set_point_options(). face_color is the
%group color by default, or black for the 'black_' geoms. A border_color
%of 'auto' takes the face color
if nargin<3
    face_color=draw_data.color;
end

border_color=obj.point_options.border_color;
if strcmp(border_color,'auto')
    border_color=face_color;
end

props={'LineStyle','none',...
    'Marker',draw_data.marker,...
    'MarkerSize',draw_data.point_size,...
    'MarkerFaceColor',face_color,...
    'MarkerEdgeColor',border_color,...
    'LineWidth',draw_data.border_width};

end
