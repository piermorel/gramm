function obj=axe_property(obj,varargin)
% axe_property Set MATLAB axes properties on all subplots
%
% Example syntax: gramm_object.axe_property('YLim',[0 1],'XGrid','on')
% Takes any 'name',value pairs accepted by set(gca,...) (XLim, XGrid,
% DataAspectRatio...).

if mod(nargin-1,2)==0
    for obj_ind=1:numel(obj)
        for k=1:2:length(varargin)
            obj(obj_ind).axe_properties=vertcat(obj(obj_ind).axe_properties,{varargin{k},varargin{k+1}});
            %Axis scales are also recorded for draw() (see set_scale())
            if any(strcmpi(varargin{k},{'XScale','YScale','ZScale'}))
                obj(obj_ind)=set_scale(obj(obj_ind),lower(varargin{k}(1)),varargin{k+1});
            end
        end
    end
else
    error('Arguments of axe_property() must be given as ''name'',value pairs')
end
end