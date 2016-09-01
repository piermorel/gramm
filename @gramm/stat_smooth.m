function obj=stat_smooth(obj,varargin)
% stat_smooth Display a smoothed estimate of the data with
% optional 95% bootstrapped confidence interval
%
% Arguments given as 'name,value pairs:
% - 'lambda': smoothing parameter (default is 1000)
% - 'geom': how is the smooth displayed (see stat_summary()
% documentation)
% - 'npoints': number of points over which the smooth is
% evaluated (default is 100).
%
% If used with repeated data (ie when y is given as 2D
% array or cell array), each trajectory will be smoothed and
% displayed individually (without confidence interval computation)

p=inputParser;
my_addParameter(p,'lambda',1000);
my_addParameter(p,'geom','area');
my_addParameter(p,'npoints',100);
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dd)my_smooth(obj,dd,p.Results)});
obj.results.stat_smooth={};
end


function hndl=my_smooth(obj,draw_data,params)

if iscell(draw_data.x) || iscell(draw_data.y) %If input was provided as cell/matrix
    
    %Duplicate the draw data
    %new_draw_data=draw_data;
    
    tempx=nan(length(draw_data.y),params.npoints);
    tempy=nan(length(draw_data.y),params.npoints);
    for k=1:length(draw_data.y) %then we smooth each trajectory independently
        if ~isempty(draw_data.y{k})
            %[new_draw_data.y{k},new_draw_data.x{k}, ~] = turbotrend(draw_data.x{k}, draw_data.y{k}, params.lambda, 100);
            [tempy(k,:),tempx(k,:), ~] = turbotrend(draw_data.x{k}, draw_data.y{k}, params.lambda, params.npoints);
        end
    end
    hndl=plot(tempx',tempy','LineStyle',draw_data.line_style,'lineWidth',draw_data.line_size,'Color',draw_data.color);
    
    %                 %Create fake params for call to stat_summary
    %                 summ_params.type='ci';
    %                 summ_params.geom=params.geom;
    %                 summ_params.dodge=false;
    %                 summ_params.setylim=false;
    %                 summ_params.interp='none';
    %                 summ_params.interp_in=100;
    %                 summ_params.bin_in=-1;
    %
    %                 %Call summary to do the actual plotting
    %                 obj.my_summary(new_draw_data,summ_params);
    
    obj.results.stat_smooth{obj.result_ind,1}.x=tempx;
    obj.results.stat_smooth{obj.result_ind,1}.y=tempy;
    obj.results.stat_smooth{obj.result_ind,1}.line_handle=hndl;
    
else
    
    combx=comb(draw_data.x);
    [combx,i]=sort(combx);
    comby=comb(draw_data.y);
    comby=comby(i);
    
    %Remove NaN
    idnan=isnan(combx) | isnan(comby);
    combx(idnan)=[];
    comby(idnan)=[];
    
    %Slow
    %newy=smooth(combx,comby,0.2,'loess');
    %plot(combx,newy,'Color',c,'LineWidth',2)
    
    %Super fast spline smoothing !!
    if length(combx)>3
        [newy,newx, yfit] = turbotrend(combx, comby, params.lambda, params.npoints);
    else
        newx=NaN;
        newy=NaN;
    end
    
    if length(combx)>10
        booty=bootstrp(obj.stat_options.nboot,@(ax,ay)turbotrend(ax,ay,params.lambda,params.npoints),combx,comby);
        yci=prctile(booty,100*[obj.stat_options.alpha/2 1-obj.stat_options.alpha/2]);
    else
        yci=nan(2,length(newx));
    end
    
    
    obj.results.stat_smooth{obj.result_ind,1}.x=newx;
    obj.results.stat_smooth{obj.result_ind,1}.y=newy;
    obj.results.stat_smooth{obj.result_ind,1}.yci=yci;
    
    %For some reason bootci is super slow there ! %zci=bootci(50,@(ax,ay)turbotrend(ax,ay,10,100),combx,comby);
    
    %Spline smoothing
    %             newx=linspace(min(combx),max(combx),100);
    %             curve = fit(combx,comby,'smoothingspline','SmoothingParam',smoothparam); %'smoothingspline','SmoothingParam',0.1
    %             newy=feval(curve,newx);
    %             yci=bootci(200,@(ax,ay)feval(fit(ax,ay,'smoothingspline','SmoothingParam',smoothparam),newx),combx,comby);
    
    
    %hndl=plotci(newx,newy,yci,c,lt,sz,geom);
    hndl=plotci(obj,newx,newy,yci,draw_data,params.geom);
    
    %Store plotted handles
    hnames=fieldnames(hndl);
    for k=1:length(hnames)
        obj.results.stat_smooth{obj.result_ind,1}.(hnames{k})=hndl.(hnames{k});
    end
    
    %cfit=fit(combx,comb(y)','smoothingspline');
    %newx=linspace(min(combx),max(combx),100);
    %hndl=plot(newx,cfit(newx),'Color',c);
end
end




function [z,xs, yfit] = turbotrend(x, y, lambda, n)
% Very fast spline smoothing (Discretize x & compute bin midpoints) found
% at: http://stat.ethz.ch/events/archive/Ascona_04/Slides/eilers.pdf
xmin = min(x);
xmax = max(x);
dx = 1.0001 * (xmax - xmin) / n;
xb = floor(1 + (x - xmin) / dx);
xs = xmin + ((1:n) - 0.5)' * dx;
% Construct equations & solve
s = sparse(xb, 1, y);       % Right-hand side
t = sparse(xb, 1, 1);       % Diagonal W = B?B
D = diff(eye(n), 2);
W = spdiags(t, 0, n, n);
C = chol(W + lambda * D' * D);
z = C \ (C' \ s);           % Solve with Cholesky
yfit = z(xb);
end