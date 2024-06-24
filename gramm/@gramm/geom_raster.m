function obj=geom_raster(obj,varargin)
% geom_raster Plot X data as a raster plot
%
% Option 'geom': 'line' or 'point'

p=inputParser;
my_addParameter(p,'geom','line');
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_raster(dobj,dd,p.Results)});
obj.results.geom_raster_handle={};
end


function hndl=my_raster(obj,draw_data,params)

%Reset raster position for new subplot
if obj.firstrun(obj.current_row,obj.current_column)
    obj.extra.raster_position=0;
end

if iscell(draw_data.x)
    
    temp_x=padded_cell2mat(draw_data.x);
    temp_y=ones(size(temp_x));
    temp_y=bsxfun(@times,temp_y,shiftdim(obj.extra.raster_position:obj.extra.raster_position+length(draw_data.x)-1));
    
    obj.extra.raster_position=obj.extra.raster_position+length(draw_data.x);
    
    if strcmp(params.geom,'line')
        %Slow version
        %line([temp_x(:) temp_x(:)]',[temp_y(:) temp_y(:)+1]','color',draw_data.color,'lineWidth',draw_data.size/4);
        
        %Fast version
        allx=[temp_x(:) temp_x(:) temp_x(:)]';
        ally=[temp_y(:) temp_y(:)+0.9 NaN(numel(temp_x),1)]';
        hndl=line(allx(:),ally(:),'color',draw_data.color,'lineWidth',draw_data.line_size);
    else
        hndl=line(temp_x(:),temp_y(:),'LineStyle','none','Marker','o','MarkerEdgeColor','none','markerSize',draw_data.point_size,'MarkerFaceColor',draw_data.color);
    end
    
else
    
    if strcmp(params.geom,'line')
        allx=[shiftdim(draw_data.x) shiftdim(draw_data.x) nan(length(draw_data.x),1)]';
        ally=repmat([obj.extra.raster_position obj.extra.raster_position+0.9 NaN ],length(draw_data.x),1)';
        hndl=line(allx(:),ally(:),'color',draw_data.color,'lineWidth',draw_data.line_size);
    else
        hndl=line(shiftdim(draw_data.x),repmat(obj.extra.raster_position,1,length(draw_data.x)),...
            'LineStyle','none','Marker','o','MarkerEdgeColor','none','markerSize',draw_data.point_size,'MarkerFaceColor',draw_data.color);
    end
    obj.extra.raster_position=obj.extra.raster_position+1;
    
end
obj.plot_lim.miny(obj.current_row,obj.current_column)=0;
obj.plot_lim.maxy(obj.current_row,obj.current_column)=obj.extra.raster_position;

obj.results.geom_raster_handle{obj.result_ind,1}=hndl;
end