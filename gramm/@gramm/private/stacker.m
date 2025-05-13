function [x_out,old,new] = stacker(obj,x,y,facet_x,baseline,type)

    % selnan = ~isnan(x) & ~isnan(y);
    % x=x(selnan);
    % y=y(selnan);


    %Problem with stacked bar when different x values are used

    if obj.firstrun(obj.current_row,obj.current_column)
        obj.extra.uni_x = unique(facet_x);
        obj.extra.uni_x = reshape(obj.extra.uni_x,1,[]);

        %Store heights at the level of dodge x
        obj.extra.(['stacked_' type '_height'])=zeros(1,length(obj.extra.uni_x));
        if ~isempty(baseline)
            obj.extra.(['stacked_' type '_height']) = obj.extra.(['stacked_' type '_height']) + baseline;
        end

        % %We take all x values so that lines look good even if some groups
        % %don't have all x values
        % [obj.extra.tmp_x, obj.extra.sortind ]= sort(unique(draw_data.facet_x));
        % 
        % %Make sure we have row vector
        % obj.extra.tmp_x = reshape(obj.extra.tmp_x,1,[]);
    end

    % Find which x values will be stacked in this group
    x_stack_ind=arrayfun(@(xin)find(abs(obj.extra.uni_x-xin)<1e-10,1),x);

    prev_stacked_bar_height = obj.extra.(['stacked_' type '_height']);
    
    for k = 1:length(x_stack_ind)
        obj.extra.(['stacked_' type '_height'])(x_stack_ind(k)) = obj.extra.(['stacked_' type '_height'])(x_stack_ind(k))+y(k);
    end
    %obj.extra.(['stacked_' type '_height'])(x_stack_ind) = obj.extra.(['stacked_' type '_height'])(x_stack_ind)+y(:)';

    if (strcmp(type,'line'))
        %We return the full stacked height
        old = prev_stacked_bar_height;
        new = obj.extra.(['stacked_' type '_height']);
        x_out = obj.extra.uni_x;
    else
         %We return only changed stacked height
        old = prev_stacked_bar_height(x_stack_ind);
        new = obj.extra.(['stacked_' type '_height'])(x_stack_ind);
        x_out = obj.extra.uni_x(x_stack_ind);
    end

end