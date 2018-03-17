function obj=facet_grid(obj,row,col,varargin)
% facet_grid Create subplots according to factors for rows and columns
%
% Example syntax (default arguments): gramm_object.facet_grid(row_variable_column_variable,'scale','fixed')
% This function has two mandatory arguments: the variable used
% to separate data by rows of subplots, and the variable used to
% separate data by columns of subplots. To separate data by
% rows or columns of subplots only, set the other
% argument to [] (empty array). These arguments can be 1D numerical arrays or
% 1D cell arrays of strings of length N.
% This function can receive other arguments as a name value
% pair.
% - 'scale' can be set to either 'fixed', 'free_x',
%   'free_y', 'free', or 'independent' so that the scale of the subplots is respectively
%    the same over all subplots, only x adjusted per columns of subplots ,
%    only y adjusted per rows of subplots, x adjusted per columns and y per rows,
%    or x and y adjusted independently per subplot
% - 'space' can be set to either 'fixed' (default), 'free_x','free_y' or 'free'.
%   'free_x' makes the width of the facets proportional to the
%   extent of the x axis limits, while 'free_y' makes the height of
%   the facets proportional to the extent of the y axis limits. 'free'
%   changes both the width and the height. This option has an
%   effect only if the corresponding 'scale' parameter is set.

p=inputParser;
my_addParameter(p,'scale','fixed'); %options 'free' 'free_x' 'free_y' 'independent'
my_addParameter(p,'space','fixed'); %'free_x','free_y','free'
my_addParameter(p,'force_ticks',false);
my_addParameter(p,'column_labels',true);
my_addParameter(p,'row_labels',true);
parse(p,varargin{:});

obj.facet_scale=p.Results.scale;
obj.facet_space=p.Results.space;
obj.column_labels=p.Results.column_labels;
obj.row_labels=p.Results.row_labels;

if strcmp(obj.facet_scale,'independent') %Force ticks by default in that case
    obj.force_ticks=true;
else
    obj.force_ticks=p.Results.force_ticks;
end

%Handle case where facet_grid is called after update()
if obj.updater.updated
    if isnumeric(obj.aes.row) && isnumeric(obj.aes.column) && all(obj.aes.row==1) && all(obj.aes.column==1)
        if isempty(obj.aes.row) && isempty(obj.aes.column)
            %User probably tried to update all the data
            obj.updater.facet_updated=0;
        else
            %We go from one to multiple facets
            obj.updater.facet_updated=1;
        end
    else
        if isempty(row) && isempty(col)
            %We go from multiple to one facet
            obj.updater.facet_updated=-1;
        else
            error('Updating facet only works when going from one to multiple facets or vice versa');
        end
    end
end

obj.aes.row=shiftdim(row);
obj.aes.column=shiftdim(col);

obj.wrap_ncols=-1;
end