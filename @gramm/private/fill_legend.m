function []= fill_legend(obj,title_text,legend_text,legend_type,legend_color,legend_marker,legend_linestyle,legend_line_size,legend_point_size)

legend_y_step=1;
legend_y_additional_step=0.5;

obj.legend_text_handles=[obj.legend_text_handles...
    text(1,obj.legend_y,title_text,...
    'FontWeight','bold',...
    'Interpreter',obj.text_options.interpreter,...
    'FontName',obj.text_options.font,...
    'FontSize',obj.text_options.base_size*obj.text_options.legend_title_scaling,...
    'Parent',obj.legend_axe_handle)];

obj.legend_y=obj.legend_y-legend_y_step;

for ind_legend=1:length(legend_text)
    
    if size(legend_color,1)>1
        temp_color = legend_color(ind_legend,:);
    else
        temp_color = legend_color;
    end
    
    if length(legend_marker)>1
        temp_marker = legend_marker{ind_legend};
    else
        temp_marker = legend_marker;
    end
    
    if length(legend_linestyle)>1
        temp_linestyle = legend_linestyle{ind_legend};
    else
        temp_linestyle = legend_linestyle;
    end
    
   if length(legend_line_size)>1
        temp_line_size = legend_line_size(ind_legend);
    else
        temp_line_size = legend_line_size;
   end
    
       
   if length(legend_point_size)>1
        temp_point_size = legend_point_size(ind_legend);
    else
        temp_point_size = legend_point_size;
    end
    
    if strcmp(legend_type,'point')
        plot(1.5,obj.legend_y,temp_marker,...
            'MarkerEdgeColor','none',...
            'MarkerFaceColor', temp_color,...
            'Parent',obj.legend_axe_handle,...
            'MarkerSize',temp_point_size);
    end
    if strcmp(legend_type,'line') || strcmp(legend_type,'both')
        plot([1 2],[obj.legend_y obj.legend_y],temp_linestyle,...
            'Color',temp_color,...
            'lineWidth',temp_line_size,...
            'Parent',obj.legend_axe_handle)
    end
    if strcmp(legend_type,'both')
        plot(1,obj.legend_y,temp_marker,...
            'MarkerEdgeColor','none',...
            'MarkerFaceColor', temp_color,...
            'Parent',obj.legend_axe_handle,...
            'MarkerSize',temp_point_size);
    end
    
    obj.legend_text_handles=[obj.legend_text_handles...
        text(2.5,obj.legend_y,legend_text{ind_legend},...
        'Interpreter',obj.text_options.interpreter,...
        'FontName',obj.text_options.font,...
        'FontSize',obj.text_options.base_size*obj.text_options.legend_scaling,...
        'Parent',obj.legend_axe_handle)];
    
    obj.legend_y=obj.legend_y-legend_y_step;
end

obj.legend_y=obj.legend_y-legend_y_additional_step;

end


