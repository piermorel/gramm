function obj=update(obj,varargin)
% update update grouping factors in order to superimpose layers in the same
% figure.
% Update takes the same arguments as the constructor gramm(). Only provide
% the data you want to replace.

%Parse new aes
new_aes=parse_aes(varargin{:});
%Replace fields given here in the original aes
new_fields=varargin(1:2:end);
for k=1:length(new_fields)
    obj.aes.(new_fields{k})=new_aes.(new_fields{k});
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