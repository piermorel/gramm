function obj=stat_fit(obj,varargin)
% stat_fit Display a fit of the data with a custom function
%
% Example syntax: gramm_object.stat_fit('fun',@(alpha,beta,x)alpha*cos(x-beta),'disp_fit',true)
% Uses fit() from the Curve Fitting Toolbox, or fitnlm() from the
% Statistics Toolbox when 'stats' is true. With 'stats', additional
% 'name',value pairs for fitnlm() can be given.
%
% Parameters given as 'name',value pairs:
% - 'fun': Anonymous function fitted to the data, with the parameters as
%            first arguments and x as last argument: @(param1,...,paramN,x).
%            With 'stats', the parameters are given as a vector: @(b,x)
% - 'StartPoint': Starting values of the parameters [param1_start
%            ... paramN_start] (default [])
% - 'fit_options': Fit options from fitoptions(), override 'StartPoint'.
%            With 'stats', options from statset('fitnlm') (default [])
% - 'intopt': Type of bounds computed by predint() (not with 'stats')
%            (default 'observation'):
%       - 'observation': 95% bounds for a new observation
%       - 'functional': 95% bounds for the fitted function
% - 'geom': How the fit is displayed, same as stat_summary() (default
%            'area')
% - 'fill_alpha': Transparency of the 'area' and 'area_only' geoms, from
%            0 (transparent) to 1 (opaque) (default 0.2)
% - 'fill': Aspect of the 'bar' geom, same as stat_summary() (default [])
% - 'fullrange': Display the fit over the whole x axis instead of the
%            range of x values used for the fit (default false)
% - 'disp_fit': Display the fitted parameters (default false)
% - 'stats': Use fitnlm() from the Statistics Toolbox instead of fit()
%            (default false)

p=inputParser;
addParameter(p,'fun',@(a,b,x)a*x+b);
addParameter(p,'StartPoint',[]);
addParameter(p,'fit_options',[]);
addParameter(p,'intopt','observation');
addParameter(p,'geom','area',@(v) valid_choice(v,{'line','lines','area','area_only','solid_area','errorbar','black_errorbar','bar','edge_bar','point','black_point'},true));
addParameter(p,'fill_alpha',0.2,@(v) valid_range(v,0,1));
addParameter(p,'fill',[],@(v) isempty(v) || valid_choice(v,{'edge','face','all','transparent'}));
addParameter(p,'fullrange',false);
addParameter(p,'disp_fit',false);
addParameter(p,'stats',false); 

p.KeepUnmatched=true;
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_fit(dobj,dd,p.Results,p.Unmatched)});
obj.results.stat_fit={};
end



function hndl=my_fit(obj,draw_data,params,unmatched)

combx=comb(draw_data.x);
comby=comb(draw_data.y);

%Remove NaNs
sel=~isnan(combx) & ~isnan(comby);
combx=combx(sel);
comby=comby(sel);

%Do the fit depending on options
if params.stats
    if isempty(params.StartPoint)
        disp('ERROR : must provide start points for statistics toolbox fitmlm');
    else
        if isempty(params.fit_options)
            tmp_args = horzcat({shiftdim(comby), params.fun ,params.StartPoint},namedargs2cell(unmatched));
        else
            tmp_args = horzcat({shiftdim(comby), params.fun ,params.StartPoint,'Options',params.fit_options},namedargs2cell(unmatched));   
        end
        mdl = fitnlm(shiftdim(combx),tmp_args{:});
        gof=[];
    end
else
    if isempty(params.fit_options)
        if isempty(params.StartPoint)
            [mdl, gof]=fit(shiftdim(combx),shiftdim(comby),params.fun);
        else
            [mdl, gof]=fit(shiftdim(combx),shiftdim(comby),params.fun,'StartPoint',params.StartPoint);
        end
    else
        [mdl, gof]=fit(shiftdim(combx),shiftdim(comby),params.fun,params.fit_options);
    end
end

%Create x values for the fit plot
if params.fullrange
    newx=linspace(obj.var_lim.minx,obj.var_lim.maxx,100)';
else
    newx=linspace(min(combx),max(combx),100)';
end

if params.stats
    if strcmp(params.intopt,'observation') %Option names are different for fitnlm !
        [newy,yci]=predict(mdl,newx,'Alpha',obj.stat_options.alpha,'Prediction','observation','Simultaneous',false);
    else
        [newy,yci]=predict(mdl,newx,'Alpha',obj.stat_options.alpha,'Prediction','curve','Simultaneous',false);
    end
else
    %Get fit value and CI
    newy=feval(mdl,newx);
    try
        yci=predint(mdl,newx,1-obj.stat_options.alpha,params.intopt);%'on'
    catch
        disp('ERROR : no prediction intervals');
        yci = [newx  newx]*NaN;
    end
end


obj.results.stat_fit{obj.result_ind,1}.x=newx;
obj.results.stat_fit{obj.result_ind,1}.y=newy;
obj.results.stat_fit{obj.result_ind,1}.yci=yci;
obj.results.stat_fit{obj.result_ind,1}.model=mdl;
obj.results.stat_fit{obj.result_ind,1}.gof=gof;

%Plot fit
hndl=plotci(obj,newx,newy,yci,draw_data,params.geom,[],[],params.fill_alpha,0,params.fill);

%Store plotted handles
hnames=fieldnames(hndl);
for k=1:length(hnames)
    obj.results.stat_fit{obj.result_ind,1}.(hnames{k})=hndl.(hnames{k});
end

%Do we display the results ?
if params.disp_fit
    %Set Y position of display
    if obj.firstrun(obj.current_row,obj.current_column)
        obj.extra.mdltext(obj.current_row,obj.current_column)=0.05;
    else
        obj.extra.mdltext(obj.current_row,obj.current_column)=obj.extra.mdltext(obj.current_row,obj.current_column)+0.03;
    end
    if params.stats
        form = mdl.Formula.char;
        cvals = mdl.Coefficients.Estimate;
        cnames = mdl.CoefficientNames;
    else
        %Get formula and parameters
        form=string(formula(mdl));
        cvals=coeffvalues(mdl);
        cnames=coeffnames(mdl);
        %Replace parameter names by their value in the formula
    end
    for c=1:length(cnames)
        form=strrep(form,cnames{c},num2str(cvals(c),2));
    end
    obj.results.stat_fit{obj.result_ind,1}.text_handle=text('Units','normalized','Position',[0.1 obj.extra.mdltext(obj.current_row,obj.current_column)],'color',draw_data.color,...
        'String',form);
end



end
