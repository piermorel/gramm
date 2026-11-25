function obj = stat_violin(obj,varargin)
% stat_violin Display violin plots of y for each unique value of x
%
% Example syntax (default arguments): gramm_object.stat_violin('normalization','area','fill','face')
%
% Parameters given as 'name',value pairs:
% - 'normalization': How violins are scaled (default 'area'):
%       - 'area': all violins have the same area
%       - 'count': areas proportional to the number of points
%       - 'width': all violins have the same maximum width
% - 'half': Draw half violins (default 'none'):
%       - 'none' (or false): full violins
%       - 'left' or 'right': half violins on that side, e.g. for raincloud
%            plots with 'nudge' and stat_boxplot() or geom_jitter()
%       - 'color' (or true): left or right depending on the color index,
%            with two colors sharing the same x. Useful to compare
%            distributions between two colors ('dodge' is ignored)
% - 'bandwidth': Same as stat_density() (default -1)
% - 'kernel': Same as stat_density() (default 'normal')
% - 'npoints': Same as stat_density() (default 100)
% - 'extra_y': Same as 'extra_x' in stat_density() (default 0)
% - 'fill': Aspect of the violins, same as stat_bin() (default 'face')
% - 'fill_alpha': Transparency of the faces, same as stat_bin() (default
%            [], set by 'fill')
% - 'width': Width of the violins, see stat_summary() (default 0.6)
% - 'dodge': Spacing between violins of different colors, see
%            stat_summary() (default 0.7)
% - 'nudge': Fixed horizontal shift of the violins, in the same units as
%            'width' (default 0)
% - 'lines': Summary lines drawn across the violins (default 'none'):
%            'median' (solid), 'quartiles' (semi-transparent), 'mean'
%            (dotted), a cell of these, or numeric quantiles between 0 and
%            1 (semi-transparent), e.g. {'median','quartiles'} or
%            [0.1 0.5 0.9]


p=inputParser;
addParameter(p,'bandwidth',-1);
addParameter(p,'kernel','normal')
addParameter(p,'npoints',100)
addParameter(p,'extra_y',0)
addParameter(p,'normalization','area',@(v) valid_choice(v,{'area','count','width'}));
addParameter(p,'fill','face',@(v) valid_choice(v,{'edge','face','all','transparent'}));
addParameter(p,'fill_alpha',[],@(v) valid_range(v,0,1,true));
addParameter(p,'width',0.6,@(v) valid_range(v,0,Inf));
addParameter(p,'dodge',0.7,@(v) valid_range(v,0,Inf));
addParameter(p,'nudge',0,@(v) valid_range(v,-Inf,Inf));
addParameter(p,'lines','none',@(v) (isnumeric(v) && ~isempty(v) && all(v>=0 & v<=1)) || valid_choice(v,{'none','median','quartiles','mean'},true));
addParameter(p,'half','none',@(v) (isscalar(v) && (islogical(v) || isnumeric(v))) || valid_choice(v,{'none','left','right','color'}));
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_violin(dobj,dd,p.Results)});
obj.results.stat_violin={};

end

function hndl=my_violin(obj,draw_data,params)

x=comb(draw_data.x);
y=comb(draw_data.y);

uni_x=unique(x);
uni_x(diff(uni_x)<1e-10)=[];

dens=cell(length(uni_x),1);
dens_pos=cell(length(uni_x),1);

%Side on which violins are drawn (no dodging in 'color' mode)
[side,params.dodge]=half_side(params.half,draw_data.color_index,params.dodge);

if params.dodge>0
    boxw=draw_data.dodge_avl_w*params.width./(draw_data.n_dodge);
else
    boxw=draw_data.dodge_avl_w*params.width;
end
boxmid=dodger(uni_x,draw_data,params.dodge,params.nudge);


[face_color , face_alpha , edge_color , ~] = parse_fill (params.fill,draw_data.color,params.fill_alpha);
temp_line_params={'LineStyle',draw_data.line_style,'Color',edge_color,'lineWidth',draw_data.edge_size};

%Maximum area
max_area=draw_data.dodge_avl_w*(obj.var_lim.maxy-obj.var_lim.miny);

lines=gobjects(1,length(uni_x));
patches=gobjects(1,length(uni_x));

%Summary lines: values and extents accumulated over x, drawn at the end
sum_values=cell(length(uni_x),1);
sum_kinds={};
sum_left=[];
sum_right=[];
sum_y=[];


for ind_x=1:length(uni_x)
    %And here we have a loose selection also because of
    %potential numerical errors
    ysel=y(abs(x-uni_x(ind_x))<1e-10);
    
    if ~isempty(ysel)
        
        extra_y=(max(ysel)-min(ysel))*params.extra_y;
        binranges=linspace(min(ysel)-extra_y,max(ysel)+extra_y,params.npoints);
        
        if params.bandwidth>0
            [dens{ind_x},dens_pos{ind_x}] = ksdensity(ysel,binranges,'function','pdf',...
                'bandwidth',params.bandwidth,'kernel',params.kernel);
        else
            [dens{ind_x},dens_pos{ind_x}] = ksdensity(ysel,binranges,'function','pdf',...
                'kernel',params.kernel);
        end
        
        area=sum(dens{ind_x})*2*(binranges(2)-binranges(1));
        
        
        switch params.normalization
            case 'area'
                %Normalized area is a third of the max available area
                dens{ind_x}=dens{ind_x}*max_area/(3*area);
            case 'count'
                %Normalized count makes area/max available area correspond to
                %n points/n total points
                dens{ind_x}=dens{ind_x}*length(ysel)*max_area/(obj.data_size*area);
            case 'width'
                %Makes maximum widths equal
                dens{ind_x}=0.5*dens{ind_x}/max(dens{ind_x});
        end
        
        
        %Adjust width
        dens{ind_x}=dens{ind_x}*boxw;
        
        
        switch side
            case 'right'
                xpatch=[boxmid(ind_x)+zeros(1,length(dens{ind_x})-1) ; ...
                    boxmid(ind_x)+dens{ind_x}(1:end-1) ; ...
                    boxmid(ind_x)+dens{ind_x}(2:end) ; ...
                    boxmid(ind_x)+zeros(1,length(dens{ind_x})-1)];
            case 'left'
                xpatch=[boxmid(ind_x)-dens{ind_x}(1:end-1) ; ...
                    boxmid(ind_x)+zeros(1,length(dens{ind_x})-1) ; ...
                    boxmid(ind_x)+zeros(1,length(dens{ind_x})-1);  ...
                    boxmid(ind_x)-dens{ind_x}(2:end)];
            otherwise %Full violin
                xpatch=[boxmid(ind_x)-dens{ind_x}(1:end-1) ; ...
                    boxmid(ind_x)+dens{ind_x}(1:end-1) ; ...
                    boxmid(ind_x)+dens{ind_x}(2:end);  ...
                    boxmid(ind_x)-dens{ind_x}(2:end)];
        end
        
        ypatch=[dens_pos{ind_x}(1:end-1) ; ...
            dens_pos{ind_x}(1:end-1) ; ...
            dens_pos{ind_x}(2:end) ; ...
            dens_pos{ind_x}(2:end)];
        
        %Draw patch
        patches(ind_x)=patch(xpatch,ypatch,[1 1 1],'EdgeAlpha',1,'FaceColor',face_color,'EdgeColor','none','FaceAlpha',face_alpha);
        
        %Draw lines
        switch side
            case 'right'
                lines(ind_x)=line(boxmid(ind_x)+[0 dens{ind_x} 0 0] , ...
                    [dens_pos{ind_x}(1) dens_pos{ind_x} dens_pos{ind_x}(end) dens_pos{ind_x}(1)],temp_line_params{:});
            case 'left'
                lines(ind_x)=line(boxmid(ind_x)-[0 dens{ind_x} 0 0] , ...
                    [dens_pos{ind_x}(1) dens_pos{ind_x} dens_pos{ind_x}(end) dens_pos{ind_x}(1)],temp_line_params{:});
            otherwise %Full violin
                lines(ind_x)=line([boxmid(ind_x) dens{ind_x}+boxmid(ind_x) boxmid(ind_x) boxmid(ind_x)-fliplr(dens{ind_x}) boxmid(ind_x)] , ...
                    [dens_pos{ind_x}(1) dens_pos{ind_x} dens_pos{ind_x}(end) fliplr(dens_pos{ind_x}) dens_pos{ind_x}(1)],temp_line_params{:});
        end

        %Summary lines go across the violin, so their half-width is the
        %density at their value
        [sum_values{ind_x},temp_kinds]=summary_lines(ysel,params.lines);
        if ~isempty(sum_values{ind_x})
            temp_w=interp1(dens_pos{ind_x},dens{ind_x},sum_values{ind_x},'linear',0);
            switch side
                case 'right'
                    temp_left=boxmid(ind_x)+zeros(size(temp_w));
                    temp_right=boxmid(ind_x)+temp_w;
                case 'left'
                    temp_left=boxmid(ind_x)-temp_w;
                    temp_right=boxmid(ind_x)+zeros(size(temp_w));
                otherwise
                    temp_left=boxmid(ind_x)-temp_w;
                    temp_right=boxmid(ind_x)+temp_w;
            end
            sum_left=[sum_left temp_left];
            sum_right=[sum_right temp_right];
            sum_y=[sum_y sum_values{ind_x}];
            sum_kinds=[sum_kinds temp_kinds];
        end

        %Nudged violins can go beyond the x range of the data, so we extend
        %the axes limits. Not done without nudge, to keep existing plots
        %unchanged
        if params.nudge~=0
            obj.plot_lim.maxx(obj.current_row,obj.current_column)=max(max(xpatch(:)),obj.plot_lim.maxx(obj.current_row,obj.current_column));
            obj.plot_lim.minx(obj.current_row,obj.current_column)=min(min(xpatch(:)),obj.plot_lim.minx(obj.current_row,obj.current_column));
        end
        
    end
    
end

%Draw summary lines, black when the violin edges have the face color
if strcmp(params.fill,'all')
    sum_color='k';
else
    sum_color=edge_color;
end
sum_hndl=plot_summary_lines(sum_left,sum_right,sum_y,sum_kinds,sum_color,draw_data.summary_size);

obj.results.stat_violin{obj.result_ind,1}.densities=dens;
obj.results.stat_violin{obj.result_ind,1}.densities_y=dens_pos;
obj.results.stat_violin{obj.result_ind,1}.unique_x=uni_x;
obj.results.stat_violin{obj.result_ind,1}.line_handle=lines;
obj.results.stat_violin{obj.result_ind,1}.fill_handle=patches;
obj.results.stat_violin{obj.result_ind,1}.lines_values=sum_values;
fields=fieldnames(sum_hndl);
for k=1:length(fields)
    obj.results.stat_violin{obj.result_ind,1}.(fields{k})=sum_hndl.(fields{k});
end


end

