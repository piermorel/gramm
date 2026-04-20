function obj=set_limit_extra(obj,x_extra,y_extra,z_extra)
%set_limit_extra Add some breathing room around data in plots
%
% Example syntax gramm_object.set_limit_extra([0.05 0.2],0.05)
% first argument is XLim extra, second is YLim extra, extra
% room is expressed as ratio to original limits. It is possible to set
% extra room separately for upper and lower limits by giving a 2x1 array.
% If not, the lower and uupper limit extra will be the same

if nargin<4
    z_extra=0;
end

%If only one element is given we use it for upper and lower extra
if numel(x_extra==1)
    x_extra=[x_extra x_extra];
end
if numel(y_extra==1)
    y_extra=[y_extra y_extra];
end
if numel(z_extra==1)
    z_extra=[z_extra z_extra];
end

for obj_ind=1:numel(obj)
    obj(obj_ind).xlim_extra=x_extra;
    obj(obj_ind).ylim_extra=y_extra;
    obj(obj_ind).zlim_extra=z_extra;
end

end