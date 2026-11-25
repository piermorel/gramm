function obj=stat_qq(obj,varargin)
% stat_qq Make a quantile-quantile plot from the data in x
%
% Example syntax (default arguments): gramm_object.stat_qq('distribution',makedist('Normal',0,1))
%
% Parameters given as 'name',value pairs:
% - 'distribution': Theoretical distribution against which x is plotted,
%            created with makedist(), or 'y' to plot the distribution of x
%            against the distribution of y (default makedist('Normal',0,1))

p=inputParser;
addParameter(p,'distribution',makedist('Normal',0,1));
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
        obj.aes_names.x=['Theoretical ' params.distribution.DistributionName '(' dist_params(1:end-1) ') quantiles'];
    end
    
end

obj.results.stat_qq{obj.result_ind,1}.x=xdist;
obj.results.stat_qq{obj.result_ind,1}.y=y;

point_props=marker_props(obj,draw_data);
hndl=plot(xdist,y,point_props{:});

obj.results.stat_qq{obj.result_ind,1}.point_handle=hndl;


obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(max(y),obj.plot_lim.maxy(obj.current_row,obj.current_column));
obj.plot_lim.miny(obj.current_row,obj.current_column)=min(min(y),obj.plot_lim.miny(obj.current_row,obj.current_column));

obj.plot_lim.maxx(obj.current_row,obj.current_column)=max(max(xdist),obj.plot_lim.maxx(obj.current_row,obj.current_column));
obj.plot_lim.minx(obj.current_row,obj.current_column)=min(min(xdist),obj.plot_lim.minx(obj.current_row,obj.current_column));

end