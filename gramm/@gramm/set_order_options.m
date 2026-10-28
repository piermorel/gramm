function obj=set_order_options(obj,varargin)
% set_order_options() Set ordering options for categorical
% variables
%
% Ordering options are available for 'x', 'color', 'marker',
% 'size', 'linestyle', 'row', 'column', 'lightness'
% For each variable, the option is provided with a 'name',
% value pair. Example for setting the ordering for the 'color' variable:
%
% 'color',1     This is the default, orders variable in
% ascending order: numerical for numbers, alphabetical for text,
% order of the categories for categorical arrays, chronological for
% datetime and duration arrays. To get the alphabetical order of a
% categorical array, give it to gramm as cellstr(categorical_array)
%
% 'color',0     Keeps the order of appearance in the
% original variable
%
% 'color',-1    Orders variable in descending order (reverse of the
% order above)
%
% 'color',[10 34 20 5], or 'color',{'S' 'M' 'L' 'XL'} Allows to directly describe
% the desired order by giving an array or a cell array.
% The values in the array should correspond to the unique
% values of the variable used for grouping (they can also be given as
% categorical, datetime or duration arrays). This case is robust to
% missing unique values (data can be truncated when categories are missing)
%
% 'color',[4 3 5 1 2]   Uses a custom order provided with
% indices provided as an array. The indices are indices
% corresponding to unique values sorted in ascending order (as for 1)
% The array length must be equal to the number of unique
% values for the variable and must contain all the integers
% between 1 and the number of unique values.

p=inputParser;
my_addParameter(p,'x',1);
my_addParameter(p,'color',1);
my_addParameter(p,'marker',1);
my_addParameter(p,'size',1);
my_addParameter(p,'linestyle',1);
my_addParameter(p,'row',1);
my_addParameter(p,'column',1);
my_addParameter(p,'lightness',1);
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