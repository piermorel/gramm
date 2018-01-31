function obj=stat_summary(obj,varargin)
% stat_summary Display summarized data for each value of X
%
% Example syntax (default arguments): gramm_object.stat_summary('type','ci','geom','lines','setylim',false)
% For each unique value of x, this can display various estimates of
% the location and variability of the corresponding y distribution.
% The optional 'name',value pairs can ne the following:
% - 'type':
%       - 'ci' : display the mean and the 95% confidence
%       interval of the mean (based on the assumption of a normal
%       distribution)
%       - 'bootci' : display the mean and the 95% confidence
%       interval of the mean computed by bootstrap
%       - 'sem' : display the mean and the standard error of
%       the mean
%       - 'std' : display the mean and the standard deviation
%       and the mean
%       - 'quartile': display the 25% 50% (median) and 75%
%       percentiles
%       - '95percentile': display the median and 2.5 and 97.5
%       percentiles
%       - 'fitnormalci'
%       - 'fitpoissonci'
%       - 'fitbinomialci'
%       - 'fit95percentile'
%       - @function : provide a the handle to a custom function that takes 
%       y values (as an n_repetitions x n_data_points matrix) and returns 
%       both the central value and the CI with a matrix [y_central ; yc_CI_low ; y_CI_high]
%       (with y_central, and y_CIs being 1 x n_data_points arrays).
%       Example that uses the trimmed mean instead of regular mean:
%
%       custom_statfun = @(y)([trimmean(y,2.5);bootci(500,{@(ty)trimmean(ty,2.5),y},'alpha',0.05)]); 
%       gramm_object.stat_summary('type', custom_statfun)
%
% - 'geom' (possibility to combine them using a cellstr, e.g. 'geom',{'bar','black_errorbar'} ):
%       - 'line': displays a line that connects the central locations
%       (mean,median)
%       - 'lines': displays a line that connects the central locations
%       and lighter lines for the variabilities
%       - 'area': displays a line that connects the central locations
%       and a transparent area for the variabilities. WARNING:
%       this changes the renderer to opengl and disables proper
%       vector output on older matlab versions
%       - 'area_only': displays the variabilities only, using a transparent area
%       - 'solid_area': displays a line that connects the locations
%       and a solid area for the variabilities. Use this for
%       export to vector output.
%       - 'errorbar': displays error bars for variabilities.
%       - 'black_errorbar': displays black error bars for variabilities.
%       - 'bar': displays the locations as bars
%       - 'edge_bar': displays the locations as bars with black edge
%       - 'point': displays the locations as points
% - 'setylim': set to true if you want the y axis limits to be
% set by the summarized data instead of the underlying data
% points.
% - 'interp': Use to interpolate the output, takes the same parameters as
% interp1 in order to specify the interpolation type. When the
% polar mode is specified as closed, or when 'interp','polar' is used
% the interpolation uses interpft, which supposes regular sampling around the circle.
% - 'interp_in': Use to (linearly) interpolate the input. This is intended
% for input given as cells when the x value is different for
% each cell and not aligned. The argument corresponds to the
% number of points used to generate the interpolation. Ideally
% for this the number of number of points should be higher than
% the x resolution of the data, otherwise some data will be
% unused.
% - 'bin_in': Use to bin the input. This is intended for input
% given as a 1-D array, creates bins over x and computes the summary
% over the binned data. Argument corresponds to the number of
% bins
% - 'dodge': use to dodge the plotted elements depending on
% color (recommended for 'bar', 'errorbar', 'black_errorbar').
% A value of 0 deactivates dodging. Other values set the space
% between the dodged elements as ratio of the x intervals.
% - 'width': use to set the width of bars and error bars (error
% bars are 1/4 th the width of bars).
%
% A setting of 'dodge',1,'width',1 will create bars that are
% fully dodged (ie don't overlap, but are not separated) and where
% all bars occupy the full interval between the x values, e.g.:
% * __    *
% *|  |__ *
% *|  |  |*
% *|__|__|*
%
% A setting of 'dodge',0.8,'width',0.8 will have fully dodged bars that are
% not separated, but only occupy 50% of the space between x
% values, e.g.:
% *  _    *
% * | |_  *
% * | | | *
% * |_|_| *
%
%A setting of 'dodge',0.8,'width',0.6 will add some
% spacing between the bars, e.g.:
% *  _      *
% * | |  _  *
% * | | | | *
% * |_| |_| *
%
% A setting of 'dodge',0.8,'width',1 will create dodged but overlapping
% bars, e.g.:
% *  ___    *
% * |  _|_  *
% * | |   | *
% * |_|___| *



p=inputParser;
my_addParameter(p,'type','ci'); %'95percentile'
my_addParameter(p,'geom','area');
my_addParameter(p,'dodge',[]);
my_addParameter(p,'width',[]);
my_addParameter(p,'setylim',false);
my_addParameter(p,'interp','none');
my_addParameter(p,'interp_in',-1);
my_addParameter(p,'bin_in',-1);
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_summary(dobj,dd,p.Results)});
obj.results.stat_summary={};
end




function hndl=my_summary(obj,draw_data,params)

%Advanced defaults
if isempty(params.dodge)
    if sum(strcmp(params.geom,'bar'))>0 && draw_data.n_colors>1 %If we have a bar as geom, we dodge
        params.dodge=0.6;
    else
        params.dodge=0;
    end
end

if isempty(params.width) %If no width given
    if params.dodge>0 %Equal to dodge if dodge given
        params.width=params.dodge*0.8;
    else
        params.width=0.5;
    end
end



if iscell(draw_data.x) || iscell(draw_data.y) %If input was provided as cell/matrix
    
    if params.interp_in>0
        %If requested we interpolate the input
        uni_x=linspace(obj.var_lim.minx,obj.var_lim.maxx,params.interp_in);
        [x,y]=cellfun(@(x,y)deal(uni_x,interp1(x,y,uni_x,'linear')),draw_data.x,draw_data.y,'UniformOutput',false,'ErrorHandler',@(st,a,b)deal([],[]));
        y=padded_cell2mat(y);
        if isempty(y) %likely because we had only single points
            y = nan(size(uni_x));
            disp('Error in summary input interpolation... nothing plotted')
        end
    else
        %If not we just make a padded matrix for fast
        %computations (we'll assume that X are roughly at the
        %same location for the same indices)
        x=padded_cell2mat(draw_data.x);
        y=padded_cell2mat(draw_data.y);
        uni_x=nanmean(x);
        %Add a check for X alignment
        x_diff=max(x)-min(x);
        if  size(x,1)>1 && any(x_diff(1:end-1)>diff(uni_x)/10) %More than a tenth of delta x variation
            warning(['some repeated X values are misaligned (max ' num2str(max(x_diff)) '), use ''interp_in'' in stat_summary() or live with the consequences'])
        end
    end
    
    if params.bin_in>0
        warning('bin_in in stat_summary() not supported for Matrix/Cell X/Y inputs');
    end
    
    if ischar(params.type) && ~isempty(strfind(params.type,'fit'))
        %If we have a params.type using distributions fits we
        %can't vectorize the call to computeci so we do it in a for
        %loop
        ymean=zeros(length(uni_x),1);
        yci=zeros(length(uni_x),2);
        for ind_x=1:length(uni_x)
            [ymean(ind_x),yci(ind_x,:)]=computeci(y(:,ind_x),params.type,obj.stat_options.alpha,obj.stat_options.nboot);
        end
    else
        if size(y,1)==1
            ymean=y;
            yci=nan(length(uni_x),2);
        else
            [ymean,yci]=computeci(y,params.type,obj.stat_options.alpha,obj.stat_options.nboot);
        end
    end
    
else %If input was provided as 1D array
    
    x=comb(draw_data.x);
    y=comb(draw_data.y);
    
    if params.bin_in>0
        %If X binning was requested we do it
        binranges=linspace(obj.var_lim.minx,obj.var_lim.maxx,params.bin_in+1);
        bincenters=(binranges(1:(end-1))+binranges(2:end))/2;
        [~,binind]=my_histcounts(x,binranges,'count');
        uni_x=bincenters;
        sel=binind~=0; %histcounts can return zero as bin index if NaN data we remove them here
        x=bincenters(binind(sel));
        y=y(sel);
    else
        %         if sum(strcmp(params.geom,'area'))>0 || sum(strcmp(params.geom,'line'))>0 ||...
        %                 sum(strcmp(params.geom,'lines'))>0  || sum(strcmp(params.geom,'solid_area'))>0
        %             %To avoid interruptions in line and area plots we
        %             %compute uniques over current data only
        %             uni_x=unique(x); %Sorted is the default
        %         else
        %             if obj.x_factor
        %                 %If x is a factor we space everything as one
        %                 uni_x=obj.var_lim.minx:1:obj.var_lim.maxx;
        %             else
        %                 %compute unique Xs at the facet level to avoid
        %                 %weird bar sizing issues when dodging and when
        %                 %colors are missing
        %                 facet_x=comb(draw_data.facet_x);
        %                 uni_x=unique(facet_x);
        %             end
        %         end
        
        uni_x=unique(x);
        
        %Here we need to implement a loose 'unique' because of
        %potential numerical errors
        uni_x(diff(uni_x)<1e-10)=[];
    end
    
    if params.interp_in>0
        warning('interp_in in stat_summary() not supported for non Matrix/Cell X/Y inputs');
    end
    
    ymean=nan(length(uni_x),1);
    yci=nan(length(uni_x),2);
    
    %Loop over unique X values
    for ind_x=1:length(uni_x)
        %And here we have a loose selection also because of
        %potential numerical errors
        ysel=y(abs(x-uni_x(ind_x))<1e-10);
        
        if ~isempty(ysel)
            [ymean(ind_x),yci(ind_x,:)]=computeci(ysel,params.type,obj.stat_options.alpha,obj.stat_options.nboot);
        end
    end
end


%Do we set the y limits according to the smoothed curves or to
%the original data ?
if params.setylim
    if sum(sum(isnan(yci)))~=numel(yci) %We only do this if yci is not weird
        if obj.firstrun(obj.current_row,obj.current_column) %Initialize for the first run in the subplot
            obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(max(yci));
            obj.plot_lim.miny(obj.current_row,obj.current_column)=min(min(yci));
        else %Update for subsequent runs in the subplot
            if max(max(yci))>obj.plot_lim.maxy(obj.current_row,obj.current_column)
                obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(max(yci));
            end
            if min(min(yci))<obj.plot_lim.miny(obj.current_row,obj.current_column)
                obj.plot_lim.miny(obj.current_row,obj.current_column)=min(min(yci));
            end
        end
    end
end

%When we do bar plots we want to have zero in the y axis anyway
if sum(strcmp(params.geom,'bar'))>0
    if obj.plot_lim.miny(obj.current_row,obj.current_column)>0 %Values above zero -> change miny
        obj.plot_lim.miny(obj.current_row,obj.current_column)=0;
    end
    if obj.plot_lim.maxy(obj.current_row,obj.current_column)<0 %Values below zero -> change maxy
        obj.plot_lim.maxy(obj.current_row,obj.current_column)=0;
    end
end

%Do we interpolate the summary results for display ?
if ~strcmp(params.interp,'none')
    if size(yci,1)>2
        yci=yci';
    end
    
    if obj.polar.is_polar && obj.polar.is_polar_closed && ~strcmp(params.interp,'polar')
        disp([params.interp ' interpolation overriden, ''polar'' used']);
        params.interp='polar'; %%If the plot is polar we override the interpolation type do an optimal fft interpolation
    end
    
    if strcmp(params.interp,'polar')
        %Perform checks on uni_x
        dx=unique_no_nan(diff([uni_x ; uni_x(1)+2*pi])); %compute step
        if any(abs(diff(dx))>1e-12) %handle numerical precision problems (exact version would be length(dx)>1 )
            disp('ERROR: ''polar'' interpolation requires periodic sampling, displayed results are incorrect');
        end
        uni_x=uni_x(1):pi/50:uni_x(1)+99*pi/50;
        ymean=interpft(ymean,100);
        tmp_yci1=interpft(yci(1,:),100);
        tmp_yci2=interpft(yci(2,:),100);
        yci=[tmp_yci1 ; tmp_yci2];
    else
        %For non polar plots we do a regular interpolation
        new_x=linspace(min(uni_x),max(uni_x),100);
        ymean=interp1(uni_x,ymean,new_x,params.interp);
        tmp_yci1=interp1(uni_x,yci(1,:),new_x,params.interp);
        tmp_yci2=interp1(uni_x,yci(2,:),new_x,params.interp);
        yci=[tmp_yci1 ; tmp_yci2];
        uni_x=new_x;
    end
end

%If X were modified
if params.bin_in>0 || params.interp_in>0 || ~strcmp(params.interp,'none')
    %We reinitialize dodging parameters for plotci to work correctly
    draw_data.dodge_avl_w=uni_x(2)-uni_x(1);
    draw_data.dodge_fallback=true;
    draw_data.dodge_x=1;
    draw_data.dodge_n=draw_data.n_colors;
    draw_data.dodge_ind=draw_data.color_index;
    
    %draw_data.dodge_x=shiftdim(uni_x);
    %draw_data.dodge_n=repmat(draw_data.n_colors,length(uni_x),1);
    %draw_data.dodge_ind=repmat(draw_data.color_index,length(uni_x),1);
end

%Store results
obj.results.stat_summary{obj.result_ind,1}.x=uni_x;
obj.results.stat_summary{obj.result_ind,1}.y=ymean;
obj.results.stat_summary{obj.result_ind,1}.yci=yci;

%Do the actual plotting
hndl=plotci(obj,uni_x,ymean,yci,draw_data,params.geom,params.dodge,params.width);

%Copy handles
if isstruct(hndl)
    hnames=fieldnames(hndl);
    for k=1:length(hnames)
        obj.results.stat_summary{obj.result_ind,1}.(hnames{k})=hndl.(hnames{k});
    end
else
    disp('Nothing plotted... Error in summary computation?')
end
end



function [ymean,yci]=computeci(y,type,alpha,nboot)

ymean=nanmean(y);

%Check number of samples
nsamp=size(y,1);
if nsamp<3 && strcmp(type,'bootci')
    disp('Less than 3 samples for bootstrap CI computation...Skipping')
    yci=repmat([NaN NaN],size(y,2));
    return;
end
if nsamp<2
    disp('Less than 2 samples for CI computation...Skipping')
    yci=repmat([NaN NaN],size(y,2));
    return;
end

if isa(type,'function_handle')
    try
        temp=type(y);
        ymean=temp(1,:);
        yci=temp(2:3,:);
    catch ME
        disp(['Error in custom summary computation: ' ME.message ' ...skipping']);
        yci=repmat([NaN NaN],size(y,2));
        ymean=nan(size(y,2),1);
    end
    return;
end

try
    switch type
        case 'bootci'
            yci=bootci(nboot,{@(ty)nanmean(ty),y},'alpha',alpha);
        case 'ci'
            %ci=1.96*nanstd(y)./sqrt(sum(~isnan(y)));
            %Correction for small samples (equivalent to fitnormalci)
            ci=tinv(1-alpha/2,sum(~isnan(y))-1).*nanstd(y)./sqrt(sum(~isnan(y)));
            yci=bsxfun(@plus,ymean,[-ci;ci]);
        case 'std'
            ci=nanstd(y);
            yci=bsxfun(@plus,ymean,[-ci;ci]);
        case 'sem'
            ci=nanstd(y)./sqrt(sum(~isnan(y)));
            yci=bsxfun(@plus,ymean,[-ci;ci]);
        case 'quartile'
            ymean=nanmedian(y);
            yci=prctile(y,[25 75]);
        case '95percentile'
            ymean=nanmedian(y);
            yci=prctile(y,[2.5 97.5]);
        case 'fitnormalci'
            pd=fitdist(y,'Normal');
            ymean=pd.mean();
            ci=paramci(pd,alpha);
            yci=ci(:,1)';
        case 'fitpoissonci'
            pd=fitdist(y,'Poisson');
            ymean=pd.mean();
            ci=paramci(pd,alpha);
            yci=ci(:,1)';
        case 'fitnegbinomialci'
            pd=fitdist(y,'NegativeBinomial');
            ymean=pd.mean();
            ci=paramci(pd,alpha);
            yci=ci(:,1)';
        case 'fitbinomialci'
            pd=fitdist(y,'Binomial');
            ymean=pd.mean;
            ci=paramci(pd,alpha);
            yci=ci(:,2)';
        case 'fit95percentile'
            pd=fitdist(y,'Normal');
            ymean=pd.icdf(0.5);
            yci=pd.icdf([0.025 0.975]);
        otherwise
            warning(['Unknown CI type ' type]);
    end
catch ME
    disp(['Error in CI computation: ' ME.message ' ...skipping']);
    yci=repmat([NaN NaN],size(y,2));
end
end
