function obj=geom_count(obj,varargin)
%geom_count Display data as points which size vary with with
%count
%
% Parameters:
% 'scale': set the scaling factor between count and area
% 'point_color': set how the points are colored 'edge', 'face',
% 'all'

p=inputParser;
my_addParameter(p,'scale',20);
my_addParameter(p,'point_color','all'); %edge,face,all
parse(p,varargin{:});
obj.geom=vertcat(obj.geom,{@(dobj,dd)my_count(dobj,dd,p.Results)});
obj.results.geom_count_handle={};
end

function hndl=my_count(obj,draw_data,params)

if obj.continuous_color
    disp('geom_count() unsupported with continuous color')
    hndl=[];
else
    [x,y]=to_polar(obj,comb(draw_data.x),comb(draw_data.y));
    
    [C,ia,ic]=unique([shiftdim(x) shiftdim(y)],'rows');
    counts=accumarray(ic,1);
    
    switch params.point_color
        case 'face'
            edge='k';
            face=draw_data.color;
        case 'edge'
            edge=draw_data.color;
            face='none';
        otherwise
            edge='none';
            face=draw_data.color;
    end
    
    hndl=scatter(C(:,1),C(:,2),counts*params.scale,draw_data.marker,'MarkerEdgeColor',edge,'MarkerFaceColor',face);
    
    %hndl=my_point(obj,draw_data);
end

obj.results.geom_count_handle{obj.result_ind,1}=hndl;
end