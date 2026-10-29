function obj=stat_bin(obj,varargin)
% stat_bin Displays an histogram of the data in x
%
% Example syntax (default arguments): gramm_object.stat_bin('nbins',30,'geom','bar')
% Options can be given as 'name',value pairs:
% - 'geom' can be 'bar', 'overlaid_bar', 'line', 'stairs', 'point' or 'stacked_bar'
% The 'normalization' argument allows to optionally normalize
% the bin counts (see the doc for Matlab's histcounts() ).
% Default is 'count', for normalization to 1 use 'probability'
% Instead of 'nbins', it is possible to directly specify bin
% edges with 'edges' (numeric, datetime or duration values), or the
% bin width with 'bin_width'. 'bin_width' can be numeric (in x units),
% a duration or calendarDuration (e.g. hours(2) or calmonths(1)), or the
% name of a time unit for datetime/duration x data ('second',
% 'minute', 'hour', 'day', 'week', 'month', 'quarter', 'year'...),
% in which case the bins follow calendar boundaries. If the bin
% widths are not equal (e.g. months), it's recommended to use
% 'countdensity' or 'pdf' for normalization. Aspect of the geoms can be
% customized with the 'fill' option
% ('edge','face','all','transparent'), and the transparency of faces with
% 'fill_alpha', from 0 (transparent) to 1 (opaque). If empty, it is set
% by the fill style (default [])

p=inputParser;
addParameter(p,'nbins',30);
addParameter(p,'edges',[]);
addParameter(p,'bin_width',[]);
addParameter(p,'geom','bar',@(v) valid_choice(v,{'bar','overlaid_bar','stacked_bar','line','stairs','point'}));
addParameter(p,'normalization','count',@(v) valid_choice(v,{'count','probability','countdensity','pdf','cumcount','cdf'}));
addParameter(p,'fill',[],@(v) isempty(v) || valid_choice(v,{'edge','face','all','transparent'}));
addParameter(p,'fill_alpha',[],@(v) valid_range(v,0,1,true));
addParameter(p,'width',[],@(v) valid_range(v,0,Inf,true));
addParameter(p,'dodge',[],@(v) valid_range(v,0,Inf,true));
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_bin(dobj,dd,p.Results)});
obj.results.stat_bin={};
end


function hndl=my_bin(obj,draw_data,params)

obj.results.stat_bin{obj.result_ind,1}=my_histplot(obj,draw_data,params,true);

end
