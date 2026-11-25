function obj=stat_ellipse(obj,varargin)
% stat_ellipse Display confidence ellipses around 2D groups of points
%
% Example syntax (default arguments): gramm_object.stat_ellipse('type','95percentile','fill','transparent')
%
% Parameters given as 'name',value pairs:
% - 'type': What the ellipse contains (default '95percentile'):
%       - '95percentile': 95% of the points (assuming a bivariate normal
%            distribution)
%       - 'ci': 95% of the bootstrapped 2D means
% - 'fill': Aspect of the ellipses, same as stat_bin() (default [], set by
%            'geom': 'transparent' for 'area', 'edge' for 'line')
% - 'fill_alpha': Transparency of the faces, from 0 (transparent) to 1
%            (opaque) (default [], 0.2 with 'transparent', otherwise set by
%            'fill')
% - 'geom': Former way of setting 'fill' (default 'area'):
%       - 'area': shaded area with outline, same as 'fill','transparent'
%       - 'line': outline only, same as 'fill','edge'
% - 'patch_opts': Additional patch() properties, as a cell of 'name',value
%            pairs (default {})

p=inputParser;
addParameter(p,'type','95percentile',@(v) valid_choice(v,{'95percentile','ci'})); %ci
addParameter(p,'geom','area',@(v) valid_choice(v,{'area','line'})); %line
addParameter(p,'fill',[],@(v) isempty(v) || valid_choice(v,{'edge','face','all','transparent'}));
addParameter(p,'fill_alpha',[],@(v) valid_range(v,0,1,true));
addParameter(p,'patch_opts',{});
parse(p,varargin{:});

params=p.Results;

%Advanced defaults: the fill style comes from the former 'geom' option,
%and transparent ellipses are lighter than the general 'transparent' style
if isempty(params.fill)
    if strcmp(params.geom,'line')
        params.fill='edge';
    else
        params.fill='transparent';
    end
end
if isempty(params.fill_alpha) && strcmp(params.fill,'transparent')
    params.fill_alpha=0.2;
end

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_ellipse(dobj,dd,params)});
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
        
        [face_color,face_alpha,edge_color,edge_alpha]=parse_fill(params.fill,draw_data.color,params.fill_alpha);
        hndl=patch(conf_elpoints(1,:)+m(1),conf_elpoints(2,:)+m(2),draw_data.color,...
            'FaceColor',face_color,...
            'FaceAlpha',face_alpha,...
            'EdgeColor',edge_color,...
            'EdgeAlpha',edge_alpha,...
            'LineWidth',draw_data.edge_size,...
            'LineStyle',draw_data.line_style);
        %set() without property names would list all settable values
        if ~isempty(params.patch_opts)
            set(hndl,params.patch_opts{:});
        end
        
        
        
        %The center is a data point, but keeps its '+' marker whatever the
        %marker groups
        center_hndl=plot(m(1),m(2),'+','MarkerFaceColor',draw_data.color,'MarkerEdgeColor',draw_data.color,'MarkerSize',draw_data.point_size);
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
        %Ellipsoids are always drawn as surfaces, without edges (a face
        %transparency of 0 with 'edge' would hide them)
        [face_color,face_alpha]=parse_fill(params.fill,draw_data.color,params.fill_alpha);
        if face_alpha==0
            face_alpha=0.2;
        end
        hndl=patch(conf_sphpoints,'FaceColor',face_color,'EdgeColor','none','FaceAlpha',face_alpha);
        
        center_hndl=plot3(m(1),m(2),m(3),'+','MarkerFaceColor',draw_data.color,'MarkerEdgeColor',draw_data.color,'MarkerSize',draw_data.point_size);
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