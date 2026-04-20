function obj=stat_fit(obj,varargin)
% stat_fit() Display a custom fit of the data
%
% Example syntax gramm_object.stat_fit('fun',@(alpha,beta,x)alpha*cos(x-beta),'disp_fit',true)
%
% This fuction uses the curve fitting toolbox function fit() to
% fit a provided anonymous function to the data. If the 'stats' argument is set
% to true, the function uses fitnlm() from the statistics toolbox. 
% Parameters:
% - 'fun': anonymous function used for the fit. By default the format of
% the arguments is (param1,param2,...paramN,x). With the 'stats' option set to true,
% function arguments should be in the form (b,x) with b being a vector of parameters
% - 'StartPoint': Array containing starting values for the
% parameter to be fitted [start_param1,start_param2,...start_paramN]
% - 'fit_options' : fit options as obtained using Matlab's fitoptions()
% function. Overrides the 'StartPoint' option. With the 'stats' option set to true
% version, options structure is provided by statset('fitnlm') and the
% 'StartPoint' option is used
% - 'intopt': Option passed to predint() for the type of bounds
% to compute, 'observation' for bounds of a new observation
% (default), or 'functional' for bounds of the fitted curve.
% - 'geom', 'fullrange', 'disp_fit' options: see stat_glm()
% - 'fullrange': set to true if you want the fits to be
%   displayed over the whole width of each subplot instead of
%   being displayed over the range of x values used for the fit
% - 'disp_fit': set to true to display the fitted parameters
% - 'stats' : set to true to use statistics toolbox instead of curve
% fitting ('intopt' and 'fit_options' become inoperant
% - Additional 'name',value agument pairs for fitnlm() can be provided when
% using 'stats',true

p=inputParser;
my_addParameter(p,'fun',@(a,b,x)a*x+b);
my_addParameter(p,'StartPoint',[]);
my_addParameter(p,'fit_options',[]);
my_addParameter(p,'intopt','observation');
my_addParameter(p,'geom','area');
my_addParameter(p,'fullrange',false);
my_addParameter(p,'disp_fit',false);
my_addParameter(p,'stats',false); 

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
hndl=plotci(obj,newx,newy,yci,draw_data,params.geom);

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
