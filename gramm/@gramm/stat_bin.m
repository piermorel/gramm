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
my_addParameter(p,'nbins',30);
my_addParameter(p,'edges',[]);
my_addParameter(p,'bin_width',[]);
my_addParameter(p,'geom','bar'); %line, bar, overlaid_bar, stacked_bar,stairs, point
my_addParameter(p,'normalization','count');
my_addParameter(p,'fill',[]); %edge,face,all,transparent
my_addParameter(p,'fill_alpha',[]);
my_addParameter(p,'width',[]);
my_addParameter(p,'dodge',[]);
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_bin(dobj,dd,p.Results)});
obj.results.stat_bin={};
end


function hndl=my_bin(obj,draw_data,params)

obj.results.stat_bin{obj.result_ind,1}=my_histplot(obj,draw_data,params,true);

end
