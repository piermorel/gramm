function obj=update(obj,varargin)
% update update grouping factors in order to superimpose layers in the same
% figure.
% Update takes the same arguments as the constructor gramm(). Only provide
% the data you want to replace.

%Parse new aes
new_aes=parse_aes(varargin{:});

%Do we have new x values?
if ~isempty(new_aes.x) && numel(new_aes.x)~=numel(obj.aes.x)
    disp('New X of different size given, all data from first gramm cleared')
    %if so we clear everything
    obj.row_facet=[]
    obj.col_facet=[];
    obj.aes=new_aes;
else
    %Replace fields given here in the original aes
    new_fields=varargin(1:2:end);
    for k=1:length(new_fields)
        obj.aes.(new_fields{k})=new_aes.(new_fields{k});
    end
end



%Initialize geoms
obj.geom={};

obj.updater.updated=true;

%Remove ablines
obj.abline=[];
obj.abline.on=false;

%Remove cache
obj.redraw_cache=[];

%Reinitialize results
obj.results=[];
end