function obj=stat_glm(obj,varargin)
% stat_glm Display a generalized linear model fit of the data
%
% Example syntax (default arguments): gramm_object.stat_glm('distribution','normal','geom','lines','fullrange','false')
% This will fit a generalized linear model to the data, display
% the fit results with 95% confidence bounds. The optional
% 'name',value pairs are the following.
% - 'distribution' corresponds to the distribution of the data.
%   'normal', the default value leads to a standard linear model
%   fit. Possible values are 'normal', 'binomial', 'poisson', 'gamma', and 'inverse gaussian'
% - 'geom': defines the way to display the confidence bouds.
%   See the help of stat_summary().
% - 'fullrange': set to true if you want the fits to be
%   displayed over the whole width of each subplot instead of
%   being displayed over the range of x values used for the fit
% - 'disp_fit': set to true to display the fitted parameters and
% corresponding p-value stars.

%Accepted distributions: 'normal' (default) | 'binomial' | 'poisson' | 'gamma' | 'inverse gaussian'
p=inputParser;
my_addParameter(p,'distribution','normal');
my_addParameter(p,'geom','area');
my_addParameter(p,'fullrange',false);
my_addParameter(p,'disp_fit',false);
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
    
    hndl=plotci(obj,newx,newy,yci,draw_data,params.geom);
    
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