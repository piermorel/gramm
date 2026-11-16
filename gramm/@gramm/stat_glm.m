function obj=stat_glm(obj,varargin)
% stat_glm Display a generalized linear model fit of the data with 95% confidence bounds
%
% Example syntax (default arguments): gramm_object.stat_glm('distribution','normal','geom','area','fullrange',false)
% Uses fitglm() from the Statistics Toolbox.
%
% Parameters given as 'name',value pairs:
% - 'distribution': Distribution of the data, as in fitglm(). 'normal'
%            gives a standard linear model (default 'normal')
% - 'geom': How the fit is displayed, same as stat_summary() (default
%            'area')
% - 'fill_alpha': Transparency of the 'area' and 'area_only' geoms, from
%            0 (transparent) to 1 (opaque) (default 0.2)
% - 'fullrange': Display the fit over the whole x axis instead of the
%            range of x values used for the fit (default false)
% - 'disp_fit': Display the fitted parameters and p-value stars
%            (default false)

%Accepted distributions: 'normal' (default) | 'binomial' | 'poisson' | 'gamma' | 'inverse gaussian'
p=inputParser;
addParameter(p,'distribution','normal',@(v) valid_choice(v,{'normal','binomial','poisson','gamma','inverse gaussian'}));
addParameter(p,'geom','area',@(v) valid_choice(v,{'line','lines','area','area_only','solid_area','errorbar','black_errorbar','bar','edge_bar','point','black_point'},true));
addParameter(p,'fill_alpha',0.2,@(v) valid_range(v,0,1));
addParameter(p,'fullrange',false);
addParameter(p,'disp_fit',false);
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_glm(dobj,dd,p.Results)});
obj.results.stat_glm={};
end


function hndl=my_glm(obj,draw_data,params)
combx=comb(draw_data.x)';
comby=comb(draw_data.y)';

if sum(~isnan(combx))>2 && sum(~isnan(comby))>2 %numel(combx)>2 &&
    % Doesn't work in 2012b
    %mdl=fitglm(combx,comby,'Distribution',params.distribution);
    mdl = GeneralizedLinearModel.fit(combx,comby,'Distribution',params.distribution);
    if params.fullrange
        newx=linspace(obj.var_lim.minx,obj.var_lim.maxx,50)';
    else
        newx=linspace(min(combx),max(combx),50)';
    end
    [newy,yci]=predict(mdl,newx,'Alpha',obj.stat_options.alpha);
    
    obj.results.stat_glm{obj.result_ind,1}.x=newx;
    obj.results.stat_glm{obj.result_ind,1}.y=newy;
    obj.results.stat_glm{obj.result_ind,1}.yci=yci;
    obj.results.stat_glm{obj.result_ind,1}.model=mdl;
    
    hndl=plotci(obj,newx,newy,yci,draw_data,params.geom,[],[],params.fill_alpha);
    
    %Store plotted handles
    hnames=fieldnames(hndl);
    for k=1:length(hnames)
        obj.results.stat_glm{obj.result_ind,1}.(hnames{k})=hndl.(hnames{k});
    end
    
    if params.disp_fit
        if obj.firstrun(obj.current_row,obj.current_column)
            obj.extra.mdltext(obj.current_row,obj.current_column)=0.05;
            %obj.firstrun(obj.current_row,obj.current_column)=0;
        else
            obj.extra.mdltext(obj.current_row,obj.current_column)=obj.extra.mdltext(obj.current_row,obj.current_column)+0.03;
        end
        obj.results.stat_glm{obj.result_ind,1}.text_handle=text('Units','normalized','Position',[0.1 obj.extra.mdltext(obj.current_row,obj.current_column)],'color',draw_data.color,...
            'String',[ num2str(mdl.Coefficients.Estimate(1),5) '^{' pval_to_star(mdl.Coefficients.pValue(1)) ...
            '} + ' num2str(mdl.Coefficients.Estimate(2),5) '^{' pval_to_star(mdl.Coefficients.pValue(2)) '} x']);
    end
    
else
    warning('Not enough points for linear fit')
    obj.results.stat_glm{obj.result_ind,1}=[];
end

end