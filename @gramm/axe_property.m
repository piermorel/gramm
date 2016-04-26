function obj=axe_property(obj,varargin)
% axe_property Add a matlab axes property to apply to all subplots
%
% Example syntax: gramm_object.axe_property('ylim',[0 1])
% Arguments are given as a name,value pairs. The accepted
% arguments are the same as in matlab's own set(gca,'propertyname',propertyvalue)

if mod(nargin-1,2)==0
    for obj_ind=1:numel(obj)
        for k=1:2:length(varargin)
            obj(obj_ind).axe_properties=vertcat(obj(obj_ind).axe_properties,{varargin{k},varargin{k+1}});
        end
    end
else
    error('Arguments of axe_property() must be given as ''name'',value pairs')
end
end