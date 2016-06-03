function obj=geom_point(obj,varargin)
% geom_point Display data as points
%
% This will add a layer that will display data as points

p=inputParser;
my_addParameter(p,'dodge',0);
parse(p,varargin{:});


obj.geom=vertcat(obj.geom,{@(dd)my_point(obj,dd,p.Results)});
obj.results.geom_point_handle={};
end

function hndl=my_point(obj,draw_data,params)

if obj.continuous_color
    if iscell(draw_data.x)
        [x,y]=to_polar(obj,draw_data.x,draw_data.y);
        if iscell(draw_data.continuous_color)
            hndl=scatter(comb(x),comb(y),draw_data.size*6,comb(draw_data.continuous_color),draw_data.marker,'MarkerFaceColor','flat','MarkerEdgeColor','none');
        else
            for k=1:length(x)
                hndl=scatter(x{k},y{k},draw_data.size*6,repmat(draw_data.continuous_color(k),length(x{k}),1),draw_data.marker,'MarkerFaceColor','flat','MarkerEdgeColor','none');
            end
        end
    else
        [x,y]=to_polar(obj,comb(draw_data.x),comb(draw_data.y));
        hndl=scatter(x,y,draw_data.size*6,draw_data.continuous_color,draw_data.marker,'MarkerFaceColor','flat','MarkerEdgeColor','none');
    end
    obj.plot_lim.maxc(obj.current_row,obj.current_column)=max(obj.plot_lim.maxc(obj.current_row,obj.current_column),max(comb(draw_data.continuous_color)));
    obj.plot_lim.minc(obj.current_row,obj.current_column)=min(obj.plot_lim.maxc(obj.current_row,obj.current_column),min(comb(draw_data.continuous_color)));
    
else
    if isempty(draw_data.z)
        %Normal case !
        x=comb(draw_data.x);
       
        x=dodger(x,draw_data,params.dodge);

        [x,y]=to_polar(obj,x,comb(draw_data.y));
        hndl=line(x,y,'LineStyle','none','Marker',draw_data.marker,'MarkerEdgeColor','none','markerSize',draw_data.size,'MarkerFaceColor',draw_data.color);
    else
        hndl=line(comb(draw_data.x),comb(draw_data.y),comb(draw_data.z),'LineStyle','none','Marker',draw_data.marker,'MarkerEdgeColor','none','markerSize',draw_data.size,'MarkerFaceColor',draw_data.color);
    end
end

obj.results.geom_point_handle{obj.result_ind,1}=hndl;
end