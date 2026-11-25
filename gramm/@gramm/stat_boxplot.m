
function obj=stat_boxplot(obj,varargin)
% stat_boxplot Display box and whisker plots of y for each unique value of x
%
% Example syntax (default arguments): gramm_object.stat_boxplot('width',0.6,'dodge',0.7)
% The box is drawn between the 25 and 75 percentiles, with a line at the
% median. The whiskers extend to the most extreme data points within 1.5
% times the interquartile range from the box (Tukey boxplot). Points
% outside the whiskers are plotted as outliers.
%
% Parameters given as 'name',value pairs:
% - 'width': Width of the boxes, see stat_summary() (default 0.6)
% - 'dodge': Spacing between boxes of different colors within an unique
%            x value, see stat_summary() (default 0.7)
% - 'nudge': Fixed horizontal shift of the boxes, in the same units as
%            'width', e.g. to place them next to a half violin, see
%            stat_violin() (default 0)
% - 'notch': Display notches at median +/- 1.58*IQR/sqrt(N) (default
%            false)
% - 'lines': Summary lines drawn across the boxes (default 'median'):
%            'median' (solid), 'mean' (dotted), 'quartiles'
%            (semi-transparent, on the box edges), a cell of these, numeric
%            quantiles between 0 and 1 (semi-transparent), or 'none', e.g.
%            {'median','mean'}
% - 'outliers': Display the outliers. If not set, outliers are hidden when
%            geom_point(), geom_jitter() or geom_swarm() are used (default
%            true)

p=inputParser;
addParameter(p,'width',0.6,@(v) valid_range(v,0,Inf));
addParameter(p,'dodge',0.7,@(v) valid_range(v,0,Inf));
addParameter(p,'nudge',0,@(v) valid_range(v,-Inf,Inf));
addParameter(p,'notch',false);
addParameter(p,'lines','median',@(v) (isnumeric(v) && ~isempty(v) && all(v>=0 & v<=1)) || valid_choice(v,{'none','median','quartiles','mean'},true));
addParameter(p,'outliers',true);

parse(p,varargin{:});

params = p.Results;
%Did the user specify the outliers settings
if any(strcmp(p.UsingDefaults,'outliers'))
    params.default_outliers = true;
else
    params.default_outliers = false;
end

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_boxplot(dobj,dd,params)});
obj.results.stat_boxplot={};

end




function hndl=my_boxplot(obj,draw_data,params)

%Make sure we have column vectors (data given as matrix/cells is combined as rows)
x=shiftdim(comb(draw_data.x));
y=shiftdim(comb(draw_data.y));

%NEW: compute unique Xs at the facet level (to avoid problems
%with bar dodging width computation)
%facet_x=comb(draw_data.facet_x);
%uni_x=unique(facet_x);

%NEW DODGING
uni_x=unique(x);


%Here we need to implement a loose 'unique' because of
%potential numerical errors
uni_x(diff(uni_x)<1e-10)=[];

%Initialize arrays
if params.notch
    p=zeros(length(uni_x),7);
else
    p=zeros(length(uni_x),5);
end
outliersx=[];
outliersy=[];


%Loop over unique X values
for ind_x=1:length(uni_x)
    %And here we have a loose selection also because of
    %potential numerical errors
    ysel=y(abs(x-uni_x(ind_x))<1e-10);
    
    %Quartiles
    temp=prctile(ysel,[25 50 75]);
    
    IQR=temp(3)-temp(1);
    
    if params.notch
        p(ind_x,:)=[temp(1)-1.5*IQR , temp(1), temp(2)-1.58*IQR/sqrt(length(ysel)) , temp(2) , temp(2)+1.58*IQR/sqrt(length(ysel)) , temp(3) , temp(3)+1.5*IQR];
    else
        %Outlier limits at 1.5 Inter Quartile Range
        p(ind_x,:)=[temp(1)-1.5*IQR , temp , temp(3)+1.5*IQR];
    end
    
    %Outliers
    sel_outlier=ysel<p(ind_x,1) | ysel>p(ind_x,end);
    if sum(sel_outlier)>0
        outliersy=[outliersy ysel(sel_outlier)'];
        outliersx=[outliersx repmat(ind_x,1,sum(sel_outlier))];
    end
    
    %Whiskers are at the lowest and highest data points that
    %are not outliers (within the +/- 1.5 IQR range)
    sel_non_outlier=~sel_outlier;
    if sum(sel_non_outlier)>0
        p(ind_x,1)=min(ysel(sel_non_outlier));
        p(ind_x,end)=max(ysel(sel_non_outlier));
    end
    
end

obj.results.stat_boxplot{obj.result_ind,1}.boxplot_data=p;


if params.dodge>0
    boxw=draw_data.dodge_avl_w*params.width./(draw_data.n_colors);
else
    boxw=draw_data.dodge_avl_w*params.width;
end
boxmid=dodger(uni_x,draw_data,params.dodge,params.nudge);


boxleft=boxmid-0.5*boxw;
boxright=boxmid+0.5*boxw;

notchleft=boxmid-0.25*boxw;
notchright=boxmid+0.25*boxw;

if params.notch
    xpatch=[boxleft' ; boxright' ; boxright' ; notchright'; boxright' ; boxright' ; boxleft' ; boxleft' ; notchleft' ; boxleft'];
    ypatch=[p(:,2)'  ; p(:,2)'   ; p(:,3)'   ; p(:,4)'    ; p(:,5)'   ; p(:,6)'   ; p(:,6)'  ; p(:,5)' ; p(:,4)'     ; p(:,3)'];
else
    xpatch=[boxleft' ; boxright' ; boxright' ; boxleft'];
    ypatch=[p(:,2)' ; p(:,2)' ; p(:,4)' ; p(:,4)'];

end

%Draw boxes
hndl=patch(xpatch,...
    ypatch,...
    [1 1 1],'FaceColor',draw_data.color,'EdgeColor','k','FaceAlpha',1,'EdgeAlpha',1);

obj.results.stat_boxplot{obj.result_ind,1}.box_handle=hndl;

%Draw summary lines (median by default). The median spans the notch when
%there is one, the other lines span the box
sum_values=cell(length(uni_x),1);
sum_kinds={};
sum_left=[];
sum_right=[];
sum_y=[];
for ind_x=1:length(uni_x)
    ysel=y(abs(x-uni_x(ind_x))<1e-10);
    [sum_values{ind_x},temp_kinds]=summary_lines(ysel,params.lines);
    temp_left=boxleft(ind_x)+zeros(size(sum_values{ind_x}));
    temp_right=boxright(ind_x)+zeros(size(sum_values{ind_x}));
    if params.notch
        sel_median=strcmp(temp_kinds,'median');
        temp_left(sel_median)=notchleft(ind_x);
        temp_right(sel_median)=notchright(ind_x);
    end
    sum_left=[sum_left temp_left];
    sum_right=[sum_right temp_right];
    sum_y=[sum_y sum_values{ind_x}];
    sum_kinds=[sum_kinds temp_kinds];
end
sum_hndl=plot_summary_lines(sum_left,sum_right,sum_y,sum_kinds,'k',0.5);
obj.results.stat_boxplot{obj.result_ind,1}.lines_values=sum_values;
fields=fieldnames(sum_hndl);
for k=1:length(fields)
    obj.results.stat_boxplot{obj.result_ind,1}.(fields{k})=sum_hndl.(fields{k});
end

%Draw whiskers
obj.results.stat_boxplot{obj.result_ind,1}.lower_whisker_handle=line([boxmid' ; boxmid'],[p(:,1)' ; p(:,2)'],'Color','k');
obj.results.stat_boxplot{obj.result_ind,1}.upper_whisker_handle=line([boxmid' ; boxmid'],[p(:,end-1)' ; p(:,end)'],'Color','k');

%Auto detect geom_point and geom_jitter to deactivate outlier plotting if
%not explicitly set
if any(cellfun(@(f)string(func2str(f)).contains(["jitter" "point" "swarm"]),obj.geom))
    if params.default_outliers
        params.outliers = false;
        if any(obj.firstrun,"all")
            disp("geom_jitter(), geom_point() or geom_swarm() are present, stat_boxplot() outliers ignored ");
        end
    else
        if params.outliers && any(obj.firstrun,"all")
            disp("geom_jitter(), geom_point() or geom_swarm() are present and stat_boxplot() outliers are plotted");
        end
    end
end

%Draw outliers
if params.outliers
    obj.results.stat_boxplot{obj.result_ind,1}.outliers_handle=plot(boxmid(outliersx),outliersy,'o','MarkerEdgeColor','none','MarkerFaceColor',draw_data.color);
end

%Adjust limits
obj.plot_lim.maxx(obj.current_row,obj.current_column)=max(max(boxright),obj.plot_lim.maxx(obj.current_row,obj.current_column));
obj.plot_lim.minx(obj.current_row,obj.current_column)=min(min(boxleft),obj.plot_lim.minx(obj.current_row,obj.current_column));

obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(max(p(:,end)),obj.plot_lim.maxy(obj.current_row,obj.current_column));
obj.plot_lim.miny(obj.current_row,obj.current_column)=min(min(p(:,1)),obj.plot_lim.miny(obj.current_row,obj.current_column));


end