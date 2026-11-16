function obj=stat_ellipse(obj,varargin)
% stat_ellipse Display confidence ellipses around 2D groups of points
%
% Example syntax (default arguments): gramm_object.stat_ellipse('type','95percentile','geom','area')
%
% Parameters given as 'name',value pairs:
% - 'type': What the ellipse contains (default '95percentile'):
%       - '95percentile': 95% of the points (assuming a bivariate normal
%            distribution)
%       - 'ci': 95% of the bootstrapped 2D means
% - 'geom': How the ellipse is displayed (default 'area'):
%       - 'area': shaded area with outline
%       - 'line': outline only
% - 'fill_alpha': Transparency of the 'area' geom, from 0 (transparent)
%            to 1 (opaque) (default 0.2)
% - 'patch_opts': Additional patch() properties, as a cell of 'name',value
%            pairs (default {})

p=inputParser;
addParameter(p,'type','95percentile',@(v) valid_choice(v,{'95percentile','ci'})); %ci
addParameter(p,'geom','area',@(v) valid_choice(v,{'area','line'})); %line
addParameter(p,'fill_alpha',0.2,@(v) valid_range(v,0,1));
addParameter(p,'patch_opts',{});
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
            r=bootstrp(obj.stat_options.nboot,@(v) mean(v,'omitnan'),r);
        end
        
        %Extract mean and covariance
        m=mean(r,'omitnan');
        cv=cov(r,'omitrows');
        
        
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
                hndl=patch(conf_elpoints(1,:)+m(1),conf_elpoints(2,:)+m(2),draw_data.color,'FaceColor',draw_data.color,'EdgeColor',draw_data.color,'LineWidth',2,'FaceAlpha',params.fill_alpha);
                
            case 'line'
                hndl=patch(conf_elpoints(1,:)+m(1),conf_elpoints(2,:)+m(2),draw_data.color,'FaceColor','none','EdgeColor',draw_data.color,'LineWidth',2);    
        end
        %set() without property names would list all settable values
        if ~isempty(params.patch_opts)
            set(hndl,params.patch_opts{:});
        end
        
        
        
        center_hndl=plot(m(1),m(2),'+','MarkerFaceColor',draw_data.color,'MarkerEdgeColor',draw_data.color,'MarkerSize',10);
    else
        
        r=[combx comby combz];
        k=@(alpha) sqrt(chi2inv(1-alpha,3));
        
        %If a CI on the mean is requested, we replace the original points
        %with bootstrapped mean samples
        if strcmp(params.type,'ci')
            r=bootstrp(obj.stat_options.nboot,@(v) mean(v,'omitnan'),r);
        end
        
        %Extract mean and covariance
        m=mean(r,'omitnan');
        cv=cov(r,'omitrows');
        
        obj.results.stat_ellipse{obj.result_ind,1}.mean=m;
        obj.results.stat_ellipse{obj.result_ind,1}.cv=cv;
        obj.results.stat_ellipse{obj.result_ind,1}.major_axis=[];
        obj.results.stat_ellipse{obj.result_ind,1}.minor_axis=[];
        
        conf_sphpoints=sphpoints;
        conf_sphpoints.vertices=bsxfun(@plus,sqrtm(cv)*conf_sphpoints.vertices'*k(obj.stat_options.alpha),m')';
        hndl=patch(conf_sphpoints,'FaceColor',draw_data.color,'EdgeColor','none','LineWidth',2,'FaceAlpha',params.fill_alpha);
        
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