function obj=facet_grid(obj,row,col,varargin)
% facet_grid Create subplots according to factors for rows and columns
%
% Example syntax (default arguments): gramm_object.facet_grid(row_variable,column_variable,'scale','fixed')
% To separate data by rows or columns of subplots only, set the other
% argument to [] (empty array).
%
% Arguments:
% - row: Variable separating data by rows of subplots, 1D numerical array
%            or cellstr of length N
% - col: Variable separating data by columns of subplots, 1D numerical
%            array or cellstr of length N
%
% Parameters given as 'name',value pairs:
% - 'scale': Axis limits shared between subplots (default 'fixed'):
%       - 'fixed': same x and y limits on all subplots
%       - 'free_x': same y limits on all subplots, x limits adjusted to the
%            data of each column
%       - 'free_y': same x limits on all subplots, y limits adjusted to the
%            data of each row
%       - 'free': x limits per column, y limits per row
%       - 'independent': independent limits on each subplot (forces
%            'force_ticks')
% - 'space': Subplot sizes. Used with free scales, so that one x (or y)
%            unit has the same length in all subplots (default 'fixed'):
%       - 'fixed': all subplots have the same size
%       - 'free_x': column widths proportional to their x range (needs
%            'scale' 'free_x' or 'free')
%       - 'free_y': row heights proportional to their y range (needs
%            'scale' 'free_y' or 'free')
%       - 'free': both (needs 'scale' 'free')
% - 'force_ticks': Show tick labels on all subplots (default false)
% - 'column_labels': Label the columns of subplots (default true)
% - 'row_labels': Label the rows of subplots (default true)

p=inputParser;
addParameter(p,'scale','fixed',@(v) valid_choice(v,{'fixed','free_x','free_y','free','independent'})); %options 'free' 'free_x' 'free_y' 'independent'
addParameter(p,'space','fixed',@(v) valid_choice(v,{'fixed','free_x','free_y','free'})); %'free_x','free_y','free'
addParameter(p,'force_ticks',false);
addParameter(p,'column_labels',true);
addParameter(p,'row_labels',true);
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