function obj=stat_summary(obj,varargin)
% stat_summary Display the location and variability of y for each unique value of x
%
% Example syntax (default arguments): gramm_object.stat_summary('type','ci','geom','area','setylim',false)
% By default, all y values with the same x value are summarized. If x and
% y are 1D arrays but x values are not discrete enough, the summaries can
% be computed over x bins with 'bin_in' or 'bin_width'. If x and y are
% given as matrices or cells with non-aligned x values, 'interp_in' must
% be used to align them by interpolation.
%
% Parameters given as 'name',value pairs:
% - 'type': What is computed, or a function handle taking y values (as
%            an n_repetitions x n_data_points matrix) and returning
%            [y_central ; y_CI_low ; y_CI_high], see example below
%            (default 'ci'):
%       - 'ci': mean and 95% confidence interval of the mean (assuming
%            normal data)
%       - 'bootci': mean and bootstrapped 95% confidence interval of the
%            mean
%       - 'sem': mean and standard error of the mean
%       - 'std': mean and standard deviation
%       - 'quartile': median and 25%/75% percentiles
%       - '95percentile': median and 2.5%/97.5% percentiles
%       - 'fitnormalci': mean and 95% CI from a fitted normal distribution
%       - 'fitpoissonci': mean and 95% CI from a fitted Poisson
%            distribution
%       - 'fitnegbinomialci': mean and 95% CI from a fitted negative
%            binomial distribution
%       - 'fitbinomialci': mean and 95% CI from a fitted binomial
%            distribution
%       - 'fitgammaci': scale and 95% CI from a fitted gamma distribution
%       - 'fitinvgaussianci': mean and 95% CI from a fitted inverse
%            Gaussian distribution
%       - 'fit95percentile': median and 2.5%/97.5% percentiles of a fitted
%            normal distribution
% - 'geom': How the summaries are displayed, one or a cell of several of
%            the following, e.g. {'bar','black_errorbar'} (default 'area'):
%       - 'area': central values (mean or median) connected by a line,
%            variability (CI, std...) as a shaded transparent area
%       - 'lines': central values connected by a line, variability as
%            thin lines
%       - 'line': central values connected by a line
%       - 'area_only': variability as a shaded transparent area, no line
%       - 'solid_area': central values connected by a line, variability
%            as a solid area
%       - 'errorbar': variability as colored error bars
%       - 'black_errorbar': variability as black error bars
%       - 'bar': central values as colored bars
%       - 'edge_bar': central values as colored bars with black edges
%            (same as 'bar' with 'fill','face')
%       - 'point': central values as points
%       - 'black_point': central values as black points
% - 'dodge': Spacing between elements of different colors within an
%            unique x value, as a ratio of the x intervals. 0 deactivates
%            dodging (default [], 0.6 for bars with several colors, 0
%            otherwise)
% - 'width': Width of the bars (default [], 0.8 times 'dodge' if dodging,
%            0.5 otherwise). The size of error bar caps is set with
%            set_line_options('cap_size',...)
% - 'nudge': Fixed horizontal shift of the summaries, in the same units
%            as 'width', e.g. to place a mean and CI next to a boxplot
%            (default 0)
% - 'setylim': Set the y axis limits from the summaries instead of the
%            data (default false)
% - 'interp': Interpolate the output, with the interpolation methods of
%            interp1() ('linear', 'spline'...). 'polar' (and closed polar
%            plots) uses interpft(), which assumes a regular sampling around
%            the circle (default 'none')
% - 'interp_in': Number of x values over which the input is linearly
%            interpolated. Must be used when x and y are given as cells
%            and x values are not aligned. Ideally higher than the x
%            resolution of the data, otherwise some data is unused
%            (default -1, no interpolation)
% - 'bin_in': Number of x bins over which the 1D input is summarized, or
%            bin edges as an array (numeric, datetime or duration)
%            (default [])
% - 'bin_width': Bins the input like 'bin_in', with bins of a given width:
%            numeric (in x units), a duration or calendarDuration (e.g.
%            minutes(5) or calweeks(1)), or the name of a time unit for
%            datetime/duration x data ('second', 'minute', 'hour', 'day',
%            'week', 'month', 'quarter', 'year'...). Bins then fall on round
%            values (calendar boundaries for dates). Takes precedence over
%            'bin_in' (default [])
% - 'fill_alpha': Transparency of the 'area' and 'area_only' geoms, from
%            0 (transparent) to 1 (opaque) (default 0.2)
% - 'fill': Aspect of the 'bar' geom, same as stat_bin() (default [],
%            'all' for 'bar' and 'face' for 'edge_bar'). The areas aren't
%            affected, see 'fill_alpha'
%
% Custom summary function, here the trimmed mean with bootstrapped CI:
%   custom_statfun = @(y)([trimmean(y,2.5);bootci(500,{@(ty)trimmean(ty,2.5),y},'alpha',0.05)]);
%   gramm_object.stat_summary('type', custom_statfun)
%
% Effect of 'dodge' and 'width' on bars of two colors:
%   'dodge',1,'width',1: fully dodged bars, not separated, occupying the
%   full interval between x values
%   * __    *
%   *|  |__ *
%   *|  |  |*
%   *|__|__|*
%   'dodge',0.8,'width',0.8: fully dodged bars, not separated
%   *  _    *
%   * | |_  *
%   * | | | *
%   * |_|_| *
%   'dodge',0.8,'width',0.6: spacing between the bars
%   *  _      *
%   * | |  _  *
%   * | | | | *
%   * |_| |_| *
%   'dodge',0.8,'width',1: dodged but overlapping bars
%   *  ___    *
%   * |  _|_  *
%   * | |   | *
%   * |_|___| *



p=inputParser;
addParameter(p,'type','ci',@(v) isa(v,'function_handle') || valid_choice(v,{'ci','bootci','sem','std','quartile','95percentile','fitnormalci','fitpoissonci','fitnegbinomialci','fitbinomialci','fitgammaci','fitinvgaussianci','fit95percentile'})); %'95percentile'
addParameter(p,'geom','area',@(v) valid_choice(v,{'line','lines','area','area_only','solid_area','errorbar','black_errorbar','bar','edge_bar','point','black_point'},true));
addParameter(p,'dodge',[],@(v) valid_range(v,0,Inf,true));
addParameter(p,'width',[],@(v) valid_range(v,0,Inf,true));
addParameter(p,'nudge',0,@(v) valid_range(v,-Inf,Inf));
addParameter(p,'setylim',false);
addParameter(p,'interp','none');
addParameter(p,'interp_in',-1);
addParameter(p,'bin_in',[]);
addParameter(p,'bin_width',[]);
addParameter(p,'fill_alpha',0.2,@(v) valid_range(v,0,1));
addParameter(p,'fill',[],@(v) isempty(v) || valid_choice(v,{'edge','face','all','transparent'}));
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_summary(dobj,dd,p.Results)});
obj.results.stat_summary={};
end




function hndl=my_summary(obj,draw_data,params)

params.geom=cellstr(params.geom); %char, string, cell or string array

%Advanced defaults
if isempty(params.dodge)
    if (sum(strcmp(params.geom,'bar'))>0 || sum(strcmp(params.geom,'edge_bar'))>0) && draw_data.n_dodge>1 %If we have a bar as geom, we dodge
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
        uni_x=mean(x,'omitnan');
        %Add a check for X alignment
        x_diff=max(x)-min(x);
        if  size(x,1)>1 && any(x_diff(1:end-1)>diff(uni_x)/10) %More than a tenth of delta x variation
            warning(['some repeated X values are misaligned (max ' num2str(max(x_diff)) '), use ''interp_in'' in stat_summary() or live with the consequences'])
        end
    end
    
    if (~isempty(params.bin_in) || ~isempty(params.bin_width))
        warning('bin_in/bin_width in stat_summary() not supported for Matrix/Cell X/Y inputs');
    end
    
    if (ischar(params.type) || isstring(params.type)) && ~isempty(strfind(params.type,'fit'))
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
    
    if (~isempty(params.bin_in) || ~isempty(params.bin_width))
        %If X binning was requested we do it
        if isscalar(params.bin_in) %Number of bins
            binranges=bin_edges(obj,[],params.bin_width,params.bin_in);
        else %Bin edges
            binranges=bin_edges(obj,params.bin_in,params.bin_width,[]);
        end
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
if sum(strcmp(params.geom,'bar'))>0 || sum(strcmp(params.geom,'edge_bar'))>0
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
if (~isempty(params.bin_in) || ~isempty(params.bin_width)) || params.interp_in>0 || ~strcmp(params.interp,'none')
    %We reinitialize dodging parameters for plotci to work correctly
    draw_data.dodge_avl_w=uni_x(2)-uni_x(1);
    draw_data.dodge_fallback=true;
end

%Store results
obj.results.stat_summary{obj.result_ind,1}.x=uni_x;
obj.results.stat_summary{obj.result_ind,1}.y=ymean;
obj.results.stat_summary{obj.result_ind,1}.yci=yci;

%Do the actual plotting
hndl=plotci(obj,uni_x,ymean,yci,draw_data,params.geom,params.dodge,params.width,params.fill_alpha,params.nudge,params.fill);

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

ymean=mean(y,'omitnan');

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
            yci=bootci(nboot,{@(ty)mean(ty,'omitnan'),y},'alpha',alpha);
        case 'ci'
            %ci=1.96*std(y,'omitnan')./sqrt(sum(~isnan(y)));
            %Correction for small samples (equivalent to fitnormalci)
            ci=tinv(1-alpha/2,sum(~isnan(y))-1).*std(y,'omitnan')./sqrt(sum(~isnan(y)));
            yci=bsxfun(@plus,ymean,[-ci;ci]);
        case 'std'
            ci=std(y,'omitnan');
            yci=bsxfun(@plus,ymean,[-ci;ci]);
        case 'sem'
            ci=std(y,'omitnan')./sqrt(sum(~isnan(y)));
            yci=bsxfun(@plus,ymean,[-ci;ci]);
        case 'quartile'
            ymean=median(y,'omitnan');
            yci=prctile(y,[25 75]);
        case '95percentile'
            ymean=median(y,'omitnan');
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
        case 'fitgammaci'
            pd=fitdist(y,'Gamma');
            ymean=pd.b;
            ci=paramci(pd,'Alpha',alpha,'Parameter','b');
            yci=ci';
        case 'fitinvgaussianci'
            pd=fitdist(y,'InverseGaussian');
            ymean=pd.mu;
            ci=paramci(pd,'Alpha',alpha,'Parameter','mu');
            yci=ci';
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
