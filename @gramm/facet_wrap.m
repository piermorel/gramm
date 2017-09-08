function obj=facet_wrap(obj,col,varargin)
% facet_grid Create subplots according to one factor, with wrap
%
% Example syntax (default arguments): gramm_object.facet_wrap(variable,'ncols',4,'scale','fixed')
% This is similar to faced_grid except that only one variable
% is given, and subplots are arranged by column, with a wrap
% around to the next row after 'ncols' columns. There is no
% 'space' option.

p=inputParser;
my_addParameter(p,'ncols',4);
my_addParameter(p,'scale','fixed'); %options 'free' 'free_x' 'free_y'
my_addParameter(p,'force_ticks',false);
my_addParameter(p,'column_labels',true);
parse(p,varargin{:});

obj.facet_scale=p.Results.scale;
obj.column_labels=p.Results.column_labels;

if strcmp(obj.facet_scale,'independent') || strcmp(obj.facet_scale,'free') %Force ticks by default in these case
    obj.force_ticks=true;
else
    obj.force_ticks=p.Results.force_ticks;
end

%Handle case where facet_wrap is called after update()
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
        if isempty(col)
            %We go from multiple to one facets
            obj.updater.facet_updated=-1;
        else
            error('Updating facet only works when going from one to multiple facets or vice versa');
        end
    end
end

obj.wrap_ncols=p.Results.ncols;
obj.aes.column=shiftdim(col);
obj.aes.row=[];

end