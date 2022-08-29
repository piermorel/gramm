function obj = stat_beeswarm(obj,varargin)
% stat_beeswarm display beeswarm plots of y data for unique x
%
% Options can be given as 'name',value pairs:
% With 'width', the maximum widths of all violins
% are matched
% - 'half': If set to true, only half violins are drawn, and the color
% index determines if the left half or right hald is drawn. Useful for
% comparing distributions across two colors.
% - 'fill' see stat_bin()
% - 'width' and 'dodge' see stat_summary()
%
% See also stat_summary(), stat_bin(), stat_density()

p=inputParser;
my_addParameter(p,'fill','face')
my_addParameter(p,'width',0.6)
my_addParameter(p,'dodge',0.7)
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_beeswarm(dobj,dd,p.Results)});
obj.results.stat_beeswarm={};

end

function hndl=my_beeswarm(obj,draw_data,params)

x=comb(draw_data.x);
y=comb(draw_data.y);

uni_x=unique(x);
uni_x(diff(uni_x)<1e-10)=[];

dens=cell(length(uni_x),1);
dens_pos=cell(length(uni_x),1);


if params.dodge>0
    boxw=draw_data.dodge_avl_w*params.width./(draw_data.n_colors);
else
    boxw=draw_data.dodge_avl_w*params.width;
end
boxmid=dodger(uni_x,draw_data,params.dodge);



[face_color , face_alpha , edge_color , ~] = parse_fill (params.fill,draw_data.color);
temp_line_params={'LineStyle',draw_data.line_style,'Color',edge_color,'lineWidth',1};

%Maximum area
max_area=draw_data.dodge_avl_w*(obj.var_lim.maxy-obj.var_lim.miny);

if obj.handle_graphics
    lines=gobjects(1,length(uni_x));
    patches=gobjects(1,length(uni_x));
else
    lines=zeros(1,length(uni_x));
    patches=zeros(1,length(uni_x));
end


for ind_x=1:length(uni_x)
    %And here we have a loose selection also because of
    %potential numerical errors
    ysel=y(abs(x-uni_x(ind_x))<1e-10);

    [uni_y,~,idx]=unique(ysel);
    uni_y(diff(uni_y)<1e-10)=[];
    
    freq = accumarray(idx(:),1);
    bee_x = arrayfun(@(a)-a/2+0.5:1:a/2-0.5,freq,'UniformOutput',false);
    bee_x = horzcat(bee_x{:});
    bee_x = bee_x/30;

    
    if ~isempty(ysel)
        
        binranges=linspace(min(ysel),max(ysel),100);
        
        [dens{ind_x},dens_pos{ind_x}] = ksdensity(ysel,binranges,'function','pdf',...
            'kernel','normal');
        
        area=sum(dens{ind_x})*2*(binranges(2)-binranges(1));
        
        % normalization - area
        dens{ind_x}=dens{ind_x}*max_area/(3*area);
        
        
        %Adjust width
        dens{ind_x}=dens{ind_x}*boxw;

        
        %Draw lines
        %lines(ind_x)=line([boxmid(ind_x) dens{ind_x}+boxmid(ind_x) boxmid(ind_x) boxmid(ind_x)-fliplr(dens{ind_x}) boxmid(ind_x)] , ...
        % [dens_pos{ind_x}(1) dens_pos{ind_x} dens_pos{ind_x}(end) fliplr(dens_pos{ind_x}) dens_pos{ind_x}(1)],temp_line_params{:});
        lines(ind_x) = line(boxmid(ind_x)+bee_x, ...
                            repelem(uni_y,freq),...
                            'LineStyle','none',...
                            'Marker',draw_data.marker,...
                            'MarkerEdgeColor','none',...
                            'MarkerSize',draw_data.point_size,...
                            'MarkerFaceColor',draw_data.color);
        
    end
    
end

obj.results.stat_beeswarm{obj.result_ind,1}.densities=dens;
obj.results.stat_beeswarm{obj.result_ind,1}.densities_y=dens_pos;
obj.results.stat_beeswarm{obj.result_ind,1}.unique_x=uni_x;
obj.results.stat_beeswarm{obj.result_ind,1}.line_handle=lines;
obj.results.stat_beeswarm{obj.result_ind,1}.fill_handle=patches;


end



