function obj=stat_smooth(obj,varargin)
% stat_smooth Display a smoothed estimate of the data with
% optional 95% bootstrapped confidence interval
%
% Arguments given as 'name,value pairs:
% - 'method': Which method to use for the smoothing. Available methods are:
%             - 'eilers' (method from Eilers 2003, default),
%             - 'smoothingspline' (uses fit() from the curve fitting toolbox),
%             - 'moving','lowess','loess','sgolay','rlowess','rloess' (use smooth() from
%               the curve fitting toolbox).
% - 'lambda': generic smoothing parameter, depends on method
%            - Corresponds to lambda in 'eilers' method (possibility to
%            set to 'auto' find optimal smoothing parameter by cross-validation, separately for
%            each for each group)
%            - Corresponds to 'SmoothingParam' in 'smoothingspline' method
%            - Corresponds to span in other methods using smooth(), for
%            'sgolay' it is possible to give a 2-element array,
%            corresponding to [span degree]
% - 'geom': how is the smooth displayed (see stat_summary()
% documentation)
% - 'npoints': number of points over which the smooth is
% evaluated (default is 200).
%
% If used with repeated data (ie when y is given as 2D
% array or cell array), each trajectory will be smoothed and
% displayed individually (without confidence interval computation)
%
% The smoothing algorithm for whittaker is described in:
% Eilers, P. H. C. (2003). A Perfect Smoother. Analytical Chemistry, 75(14), 3631?3636. http://doi.org/10.1021/ac034173t
% http://pubs.acs.org/doi/abs/10.1021/ac034173t

p=inputParser;
my_addParameter(p,'lambda',[]);
my_addParameter(p,'geom','area');
my_addParameter(p,'method','eilers');
my_addParameter(p,'npoints',200);
parse(p,varargin{:});

%Set default lambdas
temp_results=p.Results;
if isempty(temp_results.lambda)
    switch temp_results.method
        case 'perfect'
            temp_results.lambda = 1000;
        case 'smoothingspline'
            temp_results.lambda = [];
        otherwise
            temp_results.lambda = [];
    end
end

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_smooth(dobj,dd,temp_results)});
obj.results.stat_smooth={};
end


function hndl=my_smooth(obj,draw_data,params)

%Define anonymous function for smoothing depending on method
switch params.method
    case 'eilers'
        fun=@(x,y)wrap_eilers(x,y,params.npoints,1000); %Standard value for cell/matrix input
    case 'smoothingspline'
        fun=@(x,y)wrap_fit(x,y,params.npoints,params.lambda);
    otherwise
        fun=@(x,y)wrap_smooth(x,y,params.npoints,params.lambda,params.method);
end


if iscell(draw_data.x) || iscell(draw_data.y) %If input was provided as cell/matrix
    
    %Duplicate the draw data
    %new_draw_data=draw_data;
    if isstr(params.lambda)
        disp('''auto'' parameter in stat_smooth not supported for cell input')
        params.lambda = 1000;
    end
    
    tempx=nan(length(draw_data.y),params.npoints);
    tempy=nan(length(draw_data.y),params.npoints);
    for k=1:length(draw_data.y) %then we smooth each trajectory independently
        if ~isempty(draw_data.y{k})
            
            %[tempy(k,:),tempx(k,:)] = scatsm(draw_data.x{k}, draw_data.y{k}, params.lambda, 2, params.npoints);
            [tempx(k,:),tempy(k,:)] = fun(shiftdim(draw_data.x{k}), shiftdim(draw_data.y{k}));
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
    
    %Values should be ordered by x value for algorithms to work
    combx=comb(draw_data.x);
    [combx,i]=sort(combx);
    comby=comb(draw_data.y);
    comby=comby(i);
    
    %Remove NaNs
    idnan=isnan(combx) | isnan(comby);
    combx(idnan)=[];
    comby(idnan)=[];
    
    if length(combx)>3
        
        %Special case for Eilers method, find best smoothing (done per smooth) using RMS cross-validation error
        if strcmp(params.method,'eilers') && ischar(params.lambda) && strcmp(params.lambda,'auto')
            lambdas = 10 .^ (0:.2:7);
            cvs=zeros(1,length(lambdas));
            for k = 1:length(lambdas)
                [~,~, cvs(k)] =scatsm(combx, comby, lambdas(k), 2, params.npoints);
            end
            [~ , cvi] = min(cvs);
            lambda=lambdas(cvi);
            %We replace the lambda in the function handle
            fun=@(x,y)wrap_eilers(x,y,params.npoints,lambda);
        end
        
        [newx,newy]=fun(combx,comby);
        
    else
        newx=NaN;
        newy=NaN;
    end
    
    if length(combx)>10
        
        booty=zeros(obj.stat_options.nboot,params.npoints);
        bootx=zeros(obj.stat_options.nboot,params.npoints);
        %Bootstap without using bootstrp() in order to get both x and y values
        for k=1:obj.stat_options.nboot
            %We select a random sample of the points with replacement
            sampind=randi(length(combx),length(combx),1);
            sampind=sort(sampind);
            [bootx(k,:),booty(k,:)]=fun(combx(sampind),comby(sampind));
            
            %Problem: the spline smoother chooses the x values for the
            %smooth... so we need to interpolate to get y values at
            %No extrapolation
            booty(k,:)=interp1(bootx(k,:),booty(k,:),newx,'pchip',NaN);
            bootx(k,:)=newx;
        end
        
        % Way of handling missing values at the edge due to
        % bootstrapping inspired by http://content.csbs.utah.edu/~rogers/datanal/R/scatboot.r
        % The confidence interval is an interval that contains 1-alpha
        % proportion of the samples
        yci=nan(2,length(newx));
        %Count number of nans
        n_nan = sum(isnan(booty));
        for k=1:length(newx)
            
            if  n_nan(k) <= obj.stat_options.nboot * obj.stat_options.alpha %if too many nans we can't estimate the CI
                %If not too many nans, we correct the interval depending on number of nans
                conf = (1-obj.stat_options.alpha) * obj.stat_options.nboot/(obj.stat_options.nboot - n_nan(k) );
                pr = 0.5 * (1-conf);
                yci(:,k)= prctile(booty(:,k),100*[pr 1-pr]);
            end
        end
    else
        yci=nan(2,length(newx));
    end
    
    
    
    
    %     if 1
    %         %Super fast spline smoothing !!
    %         if length(combx)>3
    %             if isstr(params.lambda) && strcmp(params.lambda,'auto')
    %                %
    %               cvs = [];
    %             lambdas = 10 .^ (0:.2:7);
    %             for lambda = lambdas
    %                 [newy,newx, cv] =scatsm(combx, comby, lambda, 2, params.npoints);
    %                 cvs = [cvs cv];
    %             end
    %             [cvm cvi] = min(cvs);
    %             lambda=lambdas(cvi);
    %                [newy,newx] = scatsm(combx, comby, lambda, 2, params.npoints);
    %
    %             else
    %                 [newy,newx] = scatsm(combx, comby, params.lambda, 2, params.npoints);
    %                 lambda=params.lambda;
    %             end
    %         else
    %             newx=NaN;
    %             newy=NaN;
    %         end
    %         if length(combx)>10
    %
    %             booty=zeros(obj.stat_options.nboot,params.npoints);
    %             bootx=zeros(obj.stat_options.nboot,params.npoints);
    %             %Bootstap without using bootstrp() in order to get both x and y values
    %             for k=1:obj.stat_options.nboot
    %                 %We select a random sample of the points with replacement
    %                 sampind=randi(length(combx),length(combx),1);
    %                 [booty(k,:),bootx(k,:)]=scatsm(combx(sampind),comby(sampind),lambda,2,params.npoints);
    %
    %                 %Problem: the spline smoother chooses the x values for the
    %                 %smooth... so we need to interpolate to get y values at
    %                 %No extrapolation
    %                 booty(k,:)=interp1(bootx(k,:),booty(k,:),newx,'pchip',NaN);
    %                 bootx(k,:)=newx;
    %             end
    %
    %             % Way of handling missing values at the edge due to
    %             % bootstrapping inspired by http://content.csbs.utah.edu/~rogers/datanal/R/scatboot.r
    %             % The confidence interval is an interval that contains 1-alpha
    %             % proportion of the samples
    %             yci=nan(2,length(newx));
    %             %Count number of nans
    %             n_nan = sum(isnan(booty));
    %             for k=1:length(newx)
    %
    %                 if  n_nan(k) <= obj.stat_options.nboot * obj.stat_options.alpha %if too many nans we can't estimate the CI
    %                     %If not too many nans, we correct the interval depending on number of nans
    %                     conf = (1-obj.stat_options.alpha) * obj.stat_options.nboot/(obj.stat_options.nboot - n_nan(k) );
    %                     pr = 0.5 * (1-conf);
    %                     yci(:,k)= prctile(booty(:,k),100*[pr 1-pr]);
    %                 end
    %             end
    %         else
    %             yci=nan(2,length(newx));
    %         end
    %     else
    %         fops=fitoptions('smoothingspline');
    %         fops.SmoothingParam=params.lambda;
    %         newx=linspace(obj.var_lim.minx,obj.var_lim.maxx,params.npoints);
    %         if length(combx)>3
    %             ft=fit(combx,comby,'smoothingspline',fops);
    %             newy=feval(ft,newx);
    %         else
    %             newx=NaN;
    %             newy=NaN;
    %         end
    %         if length(combx)>10
    %             booty=bootci(obj.stat_options.nboot,@(ax,ay)feval(fit(ax,ay,'smoothingspline',fops),newx),combx,comby);
    %             yci=prctile(booty,100*[obj.stat_options.alpha/2 1-obj.stat_options.alpha/2]);
    %        else
    %             yci=nan(2,length(newx));
    %         end
    %     end
    
    
    obj.results.stat_smooth{obj.result_ind,1}.x=newx;
    obj.results.stat_smooth{obj.result_ind,1}.y=newy;
    obj.results.stat_smooth{obj.result_ind,1}.yci=yci;
    
    
    hndl=plotci(obj,newx,newy,yci,draw_data,params.geom);
    
    %Store plotted handles
    hnames=fieldnames(hndl);
    for k=1:length(hnames)
        obj.results.stat_smooth{obj.result_ind,1}.(hnames{k})=hndl.(hnames{k});
    end
end
end

function [newx,newy,cv] = wrap_fit(x,y,n,lambda)
fops=fitoptions('smoothingspline');
fops.SmoothingParam=lambda;
ft=fit(x,y,'smoothingspline',fops);
newx=linspace(min(x),max(x),n);
newy=feval(ft,newx);
cv = NaN;
end

function [newx,newy,cv] = wrap_smooth(x,y,n,lambda,method)
if strcmp(method,'sgolay') && length(lambda)==2
    yy=smooth(x,y,lambda(1),'sgolay',lambda(2));
else
    if isempty(lambda)
       yy=smooth(x,y,method);
    else
       yy=smooth(x,y,lambda,method);
    end
end
newx=linspace(min(x),max(x),n);
%x values are not unique so we remove them
[xx , ia , ic]=unique(x);
yy=yy(ia);
newy = interp1(xx,yy,newx,'pchip',NaN);
cv=NaN;
end

function [newx,newy,cv] = wrap_eilers(x,y,n,lambda)
if nargout>2
    [newy, newx, cv]=scatsm(x,y,lambda,2,n);
else
    [newy, newx]=scatsm(x,y,lambda,2,n);
end
end

% Algorithm modified from:
% Eilers, P. H. C. (2003). A Perfect Smoother. Analytical Chemistry, 75(14), 3631?3636. http://doi.org/10.1021/ac034173t
% Code downloadable as supporting information on: http://pubs.acs.org/doi/abs/10.1021/ac034173t
function [ygrid, xgrid, cv] = scatsm(x, y, lambda, d, n)
% Smoothing of a scatterplot, based on Whittaker smoother
%
% Input
%   x:      data series x
%   y:      data series y
%   lambda: smoothing parameter
%   d:      order of difference in penalty (usually 2 or 3)
%   n:      number of bins to use (optional, default = 100)
% Output
%   xgrid:  grid on which smooth curve is computed
%   ygrid:  computed smooth curve on grid
%   cv:     RMS crosss-validation error;
%
% Paul Eilers, 2003

if nargin < 5
    n = 100;
end

% Compute bin index
m = length(x);
xmin = min(x);
xmax = max(x);
dx = (xmax - xmin) / (n - 1e-6);
bin = floor(((x - xmin) / dx) + 1);

% Do penalized regression
w = full(sparse(bin, 1, 1));
s = full(sparse(bin, 1, y));
D = diff(eye(n), d);
ygrid = (diag(w) + lambda * D' * D) \ s;
xgrid = ((1:n)' - 0.5) * dx + xmin;

% Cross-validation
if nargout > 2
    H = (diag(w) + lambda * D' * D) \ diag(w);
    u = s ./ (w + 1e-9);
    r = (u - ygrid) ./ (1 - diag(H));
    cv = sqrt(r' * (w .* r) / n);
end
end


