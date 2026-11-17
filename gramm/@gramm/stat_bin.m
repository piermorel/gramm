function obj=stat_bin(obj,varargin)
% stat_bin Displays an histogram of the data in x
%
% Example syntax (default arguments): gramm_object.stat_bin('nbins',30,'geom','bar')
% Bins are given by 'edges' if set, otherwise by 'bin_width' if set,
% otherwise by 'nbins'. If the bin widths are not equal (e.g. months), it's
% recommended to use 'countdensity' or 'pdf' for normalization.
%
% Parameters given as 'name',value pairs:
% - 'nbins': Number of bins of equal width spanning the x data (default 30)
% - 'edges': Bin edges, as numeric, datetime or duration values
% - 'bin_width': Bin width, numeric (in x units), a duration or
%            calendarDuration (e.g. hours(2) or calmonths(1)), or the name
%            of a time unit for datetime/duration x data ('second',
%            'minute', 'hour', 'day', 'week', 'month', 'quarter',
%            'year'...), in which case the bins follow calendar boundaries
% - 'geom': How the bin counts are displayed (default 'bar'):
%       - 'bar': dodged bars
%       - 'overlaid_bar': overlaid bars (use transparency)
%       - 'stacked_bar': stacked bars
%       - 'line': counts connected by a line
%       - 'stairs': stair line
%       - 'point': counts as points
% - 'normalization': Normalization of the bin counts, same as the
%            'Normalization' argument of histcounts() (default 'count'):
%       - 'count': number of points in each bin
%       - 'probability': counts divided by the number of points (sum to 1)
%       - 'countdensity': counts divided by the bin widths
%       - 'pdf': probability density estimate (integrates to 1)
%       - 'cumcount': cumulative counts
%       - 'cdf': cumulative distribution (ends at 1)
% - 'fill': Aspect of the geom (default [], set by the
%            geom: 'face' for bars, 'transparent' for 'overlaid_bar',
%            'edge' otherwise):
%       - 'face': colored faces with black edges
%       - 'edge': colored edges, no faces
%       - 'all': colored faces, no edges
%       - 'transparent': colored edges and transparent colored faces
% - 'fill_alpha': Transparency of the faces, from 0 (transparent) to 1
%            (opaque) (default [], set by 'fill')
% - 'width': Width of the bars, relative to the bin width (default [],
%            same as 'dodge' if dodging, 1 otherwise)
% - 'dodge': Spacing between bars of different colors within a bin
%            (default [], 0.8 for 'bar' with several colors, 0 otherwise)

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
