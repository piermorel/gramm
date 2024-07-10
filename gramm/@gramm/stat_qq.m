function obj=stat_qq(obj,varargin)
% stat_qq Makes a quantile-quantile plot from the data in x
%
% 'distribution' is used to provide a custom distribution
% constructed with Matlab's makedist(). Default is
% makedist('Normal',0,1). Use 'y' instead of a custom
% distrubution to plot the distribution of y against the
% distribution of x

p=inputParser;
my_addParameter(p,'distribution',makedist('Normal',0,1));
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_qq(dobj,dd,p.Results)});
obj.results.stat_qq={};
end


function hndl=my_qq(obj,draw_data,params)

if strcmp(params.distribution,'y')
    %If we compare the distribution of x and y
    x=comb(draw_data.x);
    y=comb(draw_data.y);
    
    y=sort(y(~isnan(y) & ~isnan(x)));
    xdist=sort(x(~isnan(y) & ~isnan(x)));
    
    if obj.result_ind==1
        obj.aes_names.y=[obj.aes_names.y ' quantiles'];
        obj.aes_names.x=[obj.aes_names.x ' quantiles'];
    end
    
else
    %if we compare x to a theoretical distribution
    x=comb(draw_data.x);
    
    y=sort(x(~isnan(x))); %X values will actually be plotted on the y axis
    
    xeval=((1:length(y))-0.5)/length(y); %We find out the points at which we estimate the theoretical quantiles
    xdist=icdf(params.distribution,xeval); %Compute the theoretical quantiles
    
    
    %Set proper names
    if obj.result_ind==1
        obj.aes_names.y=[obj.aes_names.x ' quantiles'];
        dist_params=num2str(params.distribution.ParameterValues,'%g,');
        obj.aes_names.x=['Theroretical ' params.distribution.DistributionName '(' dist_params(1:end-1) ') quantiles'];
    end
    
end

obj.results.stat_qq{obj.result_ind,1}.x=xdist;
obj.results.stat_qq{obj.result_ind,1}.y=y;

hndl=plot(xdist,y,draw_data.marker,'MarkerEdgeColor','none','markerSize',draw_data.point_size,'MarkerFaceColor',draw_data.color);

obj.results.stat_qq{obj.result_ind,1}.point_handle=hndl;


obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(max(y),obj.plot_lim.maxy(obj.current_row,obj.current_column));
obj.plot_lim.miny(obj.current_row,obj.current_column)=min(min(y),obj.plot_lim.miny(obj.current_row,obj.current_column));

obj.plot_lim.maxx(obj.current_row,obj.current_column)=max(max(xdist),obj.plot_lim.maxx(obj.current_row,obj.current_column));
obj.plot_lim.minx(obj.current_row,obj.current_column)=min(min(xdist),obj.plot_lim.minx(obj.current_row,obj.current_column));

end