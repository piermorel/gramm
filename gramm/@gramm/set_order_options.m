function obj=set_order_options(obj,varargin)
% set_order_options Set the order of the categories of grouping variables
%
% Example syntax: gramm_object.set_order_options('x',0,'color',{'S' 'M' 'L' 'XL'})
% The order of the categories sets their positions along categorical x
% axes, the order of the colors, markers... in the legends, and the order
% of the rows and columns of facets. Each grouping variable given to
% gramm() (except y) has an option with its name, set as for 'x' below.
%
% By default, categories are sorted in ascending order: numerical for
% numbers, alphabetical for text, the order of the categories for
% categorical arrays, and chronological for datetime and duration arrays.
% To get the alphabetical order of a categorical array, give it to gramm as
% cellstr(categorical_array).
%
% Example, with clothing sizes {'L' 'S' 'XL' 'M' 'S' ...} given as color:
%   'color',1                  L, M, S, XL (ascending, alphabetical)
%   'color',0                  L, S, XL, M (order of appearance)
%   'color',-1                 XL, S, M, L (descending)
%   'color',{'S' 'M' 'L' 'XL'} S, M, L, XL (given order)
%   'color',[3 2 1 4]          S, M, L, XL (indices in the ascending order)
%
% Parameters given as 'name',value pairs:
% - 'x': Order of the x values (default 1):
%       - 1: ascending order (see above)
%       - 0: order of first appearance in the data
%       - -1: descending order
%       - {'S' 'M' 'L' 'XL'}: the values themselves, in the desired order.
%            Numeric, categorical, datetime or duration arrays work too
%            ([10 34 20 5]). Values not in the data are ignored, and data
%            whose value is missing from the list is not displayed
%       - [3 2 1 4]: the order given as indices into the values sorted in
%            ascending order. Must contain each integer from 1 to the
%            number of values once
% - 'color': Order of the color groups, same values as 'x' (default 1)
% - 'marker': Order of the marker groups, same values as 'x' (default 1)
% - 'size': Order of the size groups, same values as 'x' (default 1)
% - 'linestyle': Order of the line style groups, same values as 'x'
%            (default 1)
% - 'row': Order of the rows of facets, same values as 'x' (default 1)
% - 'column': Order of the columns of facets, same values as 'x'
%            (default 1)
% - 'lightness': Order of the lightness groups, same values as 'x'
%            (default 1)

p=inputParser;
addParameter(p,'x',1);
addParameter(p,'color',1);
addParameter(p,'marker',1);
addParameter(p,'size',1);
addParameter(p,'linestyle',1);
addParameter(p,'row',1);
addParameter(p,'column',1);
addParameter(p,'lightness',1);
parse(p,varargin{:});

%Custom orders given as categorical, string, datetime or duration arrays are
%converted to cellstr, like the grouping data they apply to
opts=p.Results;
for f=fieldnames(opts)'
    v=opts.(f{1});
    if iscategorical(v) || isstring(v) || isdatetime(v) || isduration(v)
        opts.(f{1})=cellstr(string(v));
    end
end

for obj_ind=1:numel(obj)
    obj(obj_ind).order_options=opts;
end

end