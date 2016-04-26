function obj=set_limit_extra(obj,x_extra,y_extra,z_extra)
%set_limit_extra Add some breathing room around data in plots
%
% Example syntax gramm_object.set_limit_extra(0.1,0.1)
% first argument is XLim extra, second is YLim extra, extra
% room is expressed as ratio to original limits. 0.1 will
% extend by 5% on each side.

if nargin<4
    z_extra=0;
end

for obj_ind=1:numel(obj)
    obj(obj_ind).xlim_extra=x_extra;
    obj(obj_ind).ylim_extra=y_extra;
    obj(obj_ind).zlim_extra=z_extra;
end

end