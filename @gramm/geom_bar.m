function obj=geom_bar(obj,varargin)
% geom_point Display data as bars
%
% Example syntax (default arguments): gramm_object.geom_bar(0.8)
% This will add a layer that will display data as bars. When
% data in several colors has to be displayed, the bars of
% different colors are dodged. The function can receive an
% optional argument specifying the width of the bar

p=inputParser;
my_addParameter(p,'width',0.80);
my_addParameter(p,'stacked',false);
my_addParameter(p,'dodge',0);
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_bar(dobj,dd,p.Results)});
obj.results.geom_bar_handle={};
end



function hndl=my_bar(obj,draw_data,params)
width=params.width;
x=comb(draw_data.x);
y=comb(draw_data.y);

if min(y)>0
    obj.plot_lim.miny(obj.current_row,obj.current_column)=0;
end
if max(y)<0
    obj.plot_lim.maxy(obj.current_row,obj.current_column)=0;
end
    

if params.stacked
    
    x=shiftdim(x)';
    y=shiftdim(y)';
    
    %Problem with stacked bar when different x values are used
    if obj.firstrun(obj.current_row,obj.current_column)
        %Store heights at the level of dodge x
        obj.extra.stacked_bar_height=zeros(1,length(draw_data.dodge_x));
        obj.plot_lim.minx(obj.current_row,obj.current_column)=min(x)-width;
        obj.plot_lim.maxx(obj.current_row,obj.current_column)=max(x)+width;
        %obj.firstrun(obj.current_row,obj.current_column)=0;
    end
    
    x_stack_ind=arrayfun(@(xin)find(abs(draw_data.dodge_x-xin)<1e-10,1),x);
    
    hndl=patch([x-width/2 ; x+width/2 ; x+width/2 ; x-width/2],...
        [obj.extra.stacked_bar_height(x_stack_ind) ; obj.extra.stacked_bar_height(x_stack_ind) ; obj.extra.stacked_bar_height(x_stack_ind)+y ; obj.extra.stacked_bar_height(x_stack_ind)+y],...
        draw_data.color,...
        'EdgeColor','k',...
        'LineWidth',draw_data.line_size);
    
    obj.results.geom_bar_handle{obj.result_ind,1}=hndl;
    
    obj.extra.stacked_bar_height(x_stack_ind)=obj.extra.stacked_bar_height(x_stack_ind)+y;
    if obj.plot_lim.maxy(obj.current_row,obj.current_column)<max(obj.extra.stacked_bar_height)
        obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(obj.extra.stacked_bar_height);
    end
    
else
    

    hndl=plotci(obj,shiftdim(x),shiftdim(y),[shiftdim(y) shiftdim(y)],draw_data,'edge_bar',params.dodge,params.width);
    obj.results.geom_bar_handle{obj.result_ind,1}=hndl.bar_handle;
    
end


end