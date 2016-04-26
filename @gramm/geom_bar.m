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
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dd)my_bar(obj,dd,p.Results)});
obj.results.geom_bar_handle={};
end



function hndl=my_bar(obj,draw_data,params)
width=params.width;
x=comb(draw_data.x);
y=comb(draw_data.y);
obj.plot_lim.miny(obj.current_row,obj.current_column)=0;

if params.stacked
    
    x=shiftdim(x)';
    y=shiftdim(y)';
    
    %Problem with stacked bar when different x values are used
    if obj.firstrun(obj.current_row,obj.current_column)
        obj.extra.stacked_bar_height=zeros(1,length(x));
        obj.plot_lim.minx(obj.current_row,obj.current_column)=min(x)-width;
        obj.plot_lim.maxx(obj.current_row,obj.current_column)=max(x)+width;
        %obj.firstrun(obj.current_row,obj.current_column)=0;
    end
    
    hndl=patch([x-width/2 ; x+width/2 ; x+width/2 ; x-width/2],...
        [obj.extra.stacked_bar_height ; obj.extra.stacked_bar_height ; obj.extra.stacked_bar_height+y ; obj.extra.stacked_bar_height+y],...
        draw_data.color,'EdgeColor','k');
    
    obj.extra.stacked_bar_height=obj.extra.stacked_bar_height+y;
    
    if obj.plot_lim.maxy(obj.current_row,obj.current_column)<max(obj.extra.stacked_bar_height)
        obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(obj.extra.stacked_bar_height);
    end
    
else
    
    if min(x+(draw_data.color_index/(draw_data.n_colors+1)-0.5)*width-width/(draw_data.n_colors+1))<obj.plot_lim.minx(obj.current_row,obj.current_column)
        obj.plot_lim.minx(obj.current_row,obj.current_column)=min((draw_data.color_index/(draw_data.n_colors+1)-0.5)*width-width/(draw_data.n_colors+1));
    end
    if max(x+(draw_data.color_index/(draw_data.n_colors+1)-0.5)*width+width/(draw_data.n_colors+1))>obj.plot_lim.maxx(obj.current_row,obj.current_column)
        obj.plot_lim.maxx(obj.current_row,obj.current_column)=max(x+(draw_data.color_index/(draw_data.n_colors+1)-0.5)*width+width/(draw_data.n_colors+1));
    end
    
    hndl=bar(x+(draw_data.color_index/(draw_data.n_colors+1)-0.5)*width,y,width/(draw_data.n_colors+1),'faceColor',draw_data.color,'EdgeColor','none');
end

obj.results.geom_bar_handle{obj.result_ind,1}=hndl;
end