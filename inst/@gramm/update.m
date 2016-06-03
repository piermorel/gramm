function obj=update(obj,varargin)
% update update grouping factors in order to superimpose layers in the same
% figure.
% Update takes the same arguments as the constructor gramm(). Only provide
% the data you want to replace.

if numel(obj)>1
    error('update() can only be called on a single gramm object');
end

%Automatically draw if not done yet
if obj.updater.first_draw
    draw(obj);
end

%Parse new aes
new_aes=parse_aes(varargin{:});

%Do we have new x values?
if (~isempty(new_aes.x) && numel(new_aes.x)~=numel(obj.aes.x)) || (~isempty(new_aes.y) && numel(new_aes.y)~=numel(obj.aes.y))
    disp('New X or Y of different size given, all data from first gramm cleared')
    %if so we clear everything
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
obj.updater.facet_updated=false;

%Remove ablines
obj.abline=[];
obj.abline.on=false;

%Remove cache
obj.redraw_cache=[];

%Reinitialize results
obj.results=[];
end