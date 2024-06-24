function obj=stat_ellipse(obj,varargin)
%stat_ellipse() Create confidence ellipses around 2D groups of
% points
%
% Parameters:
% 'type': The default '95percentile' displays an ellipse that
% contains 95% of the points (assuming a bivariate normal
% distribution). The option 'ci' will first compute boostrapped
% 2D means and plot the 95% ellipse around these means
% 'geom': Sets how to display the result 'area' for a shaded
% area or 'line' for a simple contour line.
% 'patch_opts': Provide additional patch properties as name-value
% pairs in a cell array (as if those were options for Matlab's
% built in patch() function)

p=inputParser;
my_addParameter(p,'type','95percentile'); %ci
my_addParameter(p,'geom','area'); %line
my_addParameter(p,'patch_opts',{});
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_ellipse(dobj,dd,p.Results)});
obj.results.stat_ellipse={};
end


function hndl=my_ellipse(obj,draw_data,params)


persistent elpoints;
persistent sphpoints;

%Cache unity ellipse points
if isempty(elpoints)
    res=30;
    ang=0:pi/(0.5*res):2*pi;
    elpoints=[cos(ang); sin(ang)];
    [x,y,z]=sphere(10);
    sphpoints=surf2patch(x,y,z);
end

combx=shiftdim(comb(draw_data.x));
comby=shiftdim(comb(draw_data.y));
combz=shiftdim(comb(draw_data.z));

%If we have "enough" points
if sum(~isnan(combx))>2 && sum(~isnan(comby))>2
    
    if isempty(draw_data.z)
        
        
        r=[combx comby];
        %Using a chi square with 2 degrees of freedom is proper
        %here (tested: generated ellipse do contain 1-alpha of the
        %points)
        k=@(alpha) sqrt(chi2inv(1-alpha,2));
        
        
        %If a CI on the mean is requested, we replace the original points
        %with bootstrapped mean samples
        if strcmp(params.type,'ci')
            r=bootstrp(obj.stat_options.nboot,@nanmean,r);
        end
        
        %Extract mean and covariance
        m=nanmean(r);
        cv=nancov(r);
        
        
        %Compute ellipse points
        conf_elpoints=sqrtm(cv)*elpoints*k(obj.stat_options.alpha);
        
        %Compute ellipse axes
        [evec,eval]=eig(cv);
        if eval(2,2)>eval(1,1) %Reorder
            evec=fliplr(evec);
            eval=fliplr(flipud(eval));
        end
        elaxes=sqrtm(cv)*evec*k(obj.stat_options.alpha);
        
        
        
        obj.results.stat_ellipse{obj.result_ind,1}.mean=m;
        obj.results.stat_ellipse{obj.result_ind,1}.cv=cv;
        obj.results.stat_ellipse{obj.result_ind,1}.major_axis=elaxes(:,1)';
        obj.results.stat_ellipse{obj.result_ind,1}.minor_axis=elaxes(:,2)';
        
        %plot([0 elaxes(1,1)]+m(1),[0 elaxes(2,1)]+m(2),'k')
        %plot([0 elaxes(1,2)]+m(1),[0 elaxes(2,2)]+m(2),'k')
        
        switch params.geom
            case 'area'
                hndl=patch(conf_elpoints(1,:)+m(1),conf_elpoints(2,:)+m(2),draw_data.color,'FaceColor',draw_data.color,'EdgeColor',draw_data.color,'LineWidth',2,'FaceAlpha',0.2);
                
            case 'line'
                hndl=patch(conf_elpoints(1,:)+m(1),conf_elpoints(2,:)+m(2),draw_data.color,'FaceColor','none','EdgeColor',draw_data.color,'LineWidth',2);    
        end
        set(hndl,params.patch_opts{:});
        %One matlab version displayed stuff if no output value was set (but
        %crashes 2014a and earlier versions)
        %tmp = set(hndl,params.patch_opts{:}); 
        
        
        
        center_hndl=plot(m(1),m(2),'+','MarkerFaceColor',draw_data.color,'MarkerEdgeColor',draw_data.color,'MarkerSize',10);
    else
        
        r=[combx comby combz];
        k=@(alpha) sqrt(chi2inv(1-alpha,3));
        
        %If a CI on the mean is requested, we replace the original points
        %with bootstrapped mean samples
        if strcmp(params.type,'ci')
            r=bootstrp(obj.stat_options.nboot,@nanmean,r);
        end
        
        %Extract mean and covariance
        m=nanmean(r);
        cv=nancov(r);
        
        obj.results.stat_ellipse{obj.result_ind,1}.mean=m;
        obj.results.stat_ellipse{obj.result_ind,1}.cv=cv;
        obj.results.stat_ellipse{obj.result_ind,1}.major_axis=[];
        obj.results.stat_ellipse{obj.result_ind,1}.minor_axis=[];
        
        conf_sphpoints=sphpoints;
        conf_sphpoints.vertices=bsxfun(@plus,sqrtm(cv)*conf_sphpoints.vertices'*k(obj.stat_options.alpha),m')';
        hndl=patch(conf_sphpoints,'FaceColor',draw_data.color,'EdgeColor','none','LineWidth',2,'FaceAlpha',0.2);
        
        center_hndl=plot3(m(1),m(2),m(3),'+','MarkerFaceColor',draw_data.color,'MarkerEdgeColor',draw_data.color,'MarkerSize',10);
    end
    obj.results.stat_ellipse{obj.result_ind,1}.ellipse_handle=hndl;
    obj.results.stat_ellipse{obj.result_ind,1}.center_handle=center_hndl;
else
    warning('Not enough points for ellipse')
    
    obj.results.stat_ellipse{obj.result_ind,1}.mean=NaN;
    obj.results.stat_ellipse{obj.result_ind,1}.cv=NaN;
    obj.results.stat_ellipse{obj.result_ind,1}.major_axis=[];
    obj.results.stat_ellipse{obj.result_ind,1}.minor_axis=[];
    obj.results.stat_ellipse{obj.result_ind,1}.ellipse_handle=[];
    obj.results.stat_ellipse{obj.result_ind,1}.center_handle=[];
end
end