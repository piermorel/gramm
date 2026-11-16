function obj=geom_count(obj,varargin)
% geom_count Display data as points which size varies with the number of overlapping points
%
% Example syntax: gramm_object.geom_count('scale',20)
%
% Parameters given as 'name',value pairs:
% - 'scale': Scaling factor between count and point area (default 20)
% - 'point_color': How the points are colored (default 'all'):
%       - 'all': colored faces, no edges
%       - 'face': colored faces with black edges
%       - 'edge': colored edges, no faces

p=inputParser;
addParameter(p,'scale',20);
addParameter(p,'point_color','all',@(v) valid_choice(v,{'all','face','edge'})); %edge,face,all
parse(p,varargin{:});
obj.geom=vertcat(obj.geom,{@(dobj,dd)my_count(dobj,dd,p.Results)});
obj.results.geom_count_handle={};
end

function hndl=my_count(obj,draw_data,params)

if obj.continuous_color_options.active
    disp('geom_count() unsupported with continuous color')
    hndl=[];
else
    x=comb(draw_data.x);
    y=comb(draw_data.y);
    
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