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
% - 'alpha' see geom_point()
% - 'width' and 'dodge' see stat_summary()
% - 'cex': changes the size of the plot
%
% See also stat_summary(), stat_bin(), stat_density()

p=inputParser;
my_addParameter(p,'alpha',1)
my_addParameter(p,'width',0.6)
my_addParameter(p,'dodge',0.7)
my_addParameter(p,'cex',1)
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_beeswarm(dobj,dd,p.Results)});
obj.results.stat_beeswarm={};

end

function hndl=my_beeswarm(obj,draw_data,params)

ptsize = draw_data.point_size;

x=comb(draw_data.x);
y=comb(draw_data.y);

uni_x=unique(x);
uni_x(diff(uni_x)<1e-10)=[];

bee_x=cell(length(uni_x),1);
bee_x_pos=cell(length(uni_x),1);


if params.dodge>0
    boxw=draw_data.dodge_avl_w*params.width./(draw_data.n_colors);
else
    boxw=draw_data.dodge_avl_w*params.width;
end
boxmid=dodger(uni_x,draw_data,params.dodge);

%Maximum area
max_area=draw_data.dodge_avl_w*(obj.var_lim.maxy-obj.var_lim.miny);

if obj.handle_graphics
    lines=gobjects(1,length(uni_x));
else
    lines=zeros(1,length(uni_x));
end

obj.redraw_fun=vertcat(obj.redraw_fun,{@()beeswarm_redraw(obj,params.alpha)});

for ind_x=1:length(uni_x)
    %And here we have a loose selection also because of
    %potential numerical errors
    ysel=y(abs(x-uni_x(ind_x))<1e-10);

    [uni_y,~,idx]=unique(ysel);
    uni_y(diff(uni_y)<1e-10)=[];
    
    freq = accumarray(idx(:),1);
    
    bee_x{ind_x} = arrayfun(@(a)-a/2+0.5:1:a/2-0.5,freq,'UniformOutput',false);
    bee_x{ind_x} = horzcat(bee_x{ind_x}{:});
    bee_x{ind_x} = bee_x{ind_x}*params.cex/(4*ptsize);
   
    y_adjust = arrayfun(@(b)y_dodge(b),freq,'UniformOutput',false);
    y_adjust = transpose(horzcat(y_adjust{:}));
    bee_x_pos{ind_x} = sort(ysel) + y_adjust;

    
    if ~isempty(ysel)

        %Draw lines
        lines(ind_x) = line(boxmid(ind_x)+bee_x{ind_x}, ...
                            bee_x_pos{ind_x},...
                            'LineStyle','none',...
                            'Marker',draw_data.marker,...
                            'MarkerEdgeColor','None',...
                            'MarkerSize',ptsize,...
                            'MarkerFaceColor',draw_data.color);

        

        set_alpha(lines(ind_x),1,params.alpha);
    end

    

end

obj.results.stat_beeswarm{obj.result_ind,1}.swarm_x=bee_x;
obj.results.stat_beeswarm{obj.result_ind,1}.swarm_y=bee_x_pos;
obj.results.stat_beeswarm{obj.result_ind,1}.unique_x=uni_x;
obj.results.stat_beeswarm{obj.result_ind,1}.line_handle=lines;


end

function beeswarm_redraw(obj,alpha)
    pos = get(gcf, 'Position');
    factor = max([pos(3);pos(2)])/560;

    for i=1:length(obj.results.stat_beeswarm)
        set(obj.results.stat_beeswarm(i).line_handle,'MarkerSize',factor*3.25);
        for j=1:length(obj.results.stat_beeswarm(i).line_handle)
            set_alpha(obj.results.stat_beeswarm(i).line_handle(j),1,alpha);
        end
    end
end

function yd=y_dodge(fr)
    if mod(fr,2) == 0
        left = fliplr(0:1:fr/2-1);
        right = 0:1:fr/2-1;
    else
        left = fliplr(0:1:fr/2-0.5);
        right = 1:1:fr/2-0.5;
    end
    yd = cat(2,left,right);
    yd = yd*0.1;
end



