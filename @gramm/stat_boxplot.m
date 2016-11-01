function obj=stat_boxplot(obj,varargin)
%stat_boxplot() Create box and whiskers plots
%
% stat_boxplot() will create box and whisker plots of Y values for
%unique values of X. The box is drawn between the 25 and 75
%percentiles, with a line indicating the median. The wiskers
%extend above and below the box to the most extreme data points that are within
% a distance to the box equal to 1.5 times the interquartile
% range (Tukey boxplot).
% Points outside the whiskers ranges are plotted.
% - 'notch', set to true to display notches at median ± 1.58*IQR/sqrt(N)
% - 'dodge' allows to set the spacing between boxes of
%   different colors within an unique value of x.
% - 'width' allows to set the width of the individual boxes.
% See the documentation of stat_summary() for the behavior of
% 'dodge' and 'width'

p=inputParser;
my_addParameter(p,'width',0.6);
my_addParameter(p,'dodge',0.7);
my_addParameter(p,'notch',false);
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_boxplot(dobj,dd,p.Results)});
obj.results.stat_boxplot={};

end




function hndl=my_boxplot(obj,draw_data,params)

x=comb(draw_data.x);
y=comb(draw_data.y);

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
boxmid=dodger(uni_x,draw_data,params.dodge);


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

%Draw medians
if params.notch
    obj.results.stat_boxplot{obj.result_ind,1}.median_handle=line([notchleft' ; notchright'],[p(:,4)' ; p(:,4)'],'Color','k');
else
    obj.results.stat_boxplot{obj.result_ind,1}.median_handle=line([boxleft' ; boxright'],[p(:,3)' ; p(:,3)'],'Color','k');
end

%Draw whiskers
obj.results.stat_boxplot{obj.result_ind,1}.lower_whisker_handle=line([boxmid' ; boxmid'],[p(:,1)' ; p(:,2)'],'Color','k');
obj.results.stat_boxplot{obj.result_ind,1}.upper_whisker_handle=line([boxmid' ; boxmid'],[p(:,end-1)' ; p(:,end)'],'Color','k');

%Draw outliers
obj.results.stat_boxplot{obj.result_ind,1}.outliers_handle=plot(boxmid(outliersx),outliersy,'o','MarkerEdgeColor','none','MarkerFaceColor',draw_data.color);

%Adjust limits
obj.plot_lim.maxx(obj.current_row,obj.current_column)=max(max(boxright),obj.plot_lim.maxx(obj.current_row,obj.current_column));
obj.plot_lim.minx(obj.current_row,obj.current_column)=min(min(boxleft),obj.plot_lim.minx(obj.current_row,obj.current_column));

obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(max(p(:,end)),obj.plot_lim.maxy(obj.current_row,obj.current_column));
obj.plot_lim.miny(obj.current_row,obj.current_column)=min(min(p(:,1)),obj.plot_lim.miny(obj.current_row,obj.current_column));


end