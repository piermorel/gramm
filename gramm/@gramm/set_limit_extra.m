function obj=set_limit_extra(obj,x_extra,y_extra,z_extra)
% set_limit_extra Add some breathing room around the data in the axes
%
% Example syntax: gramm_object.set_limit_extra([0.05 0.2],0.05)
% The extra room is a ratio of the data range: with data from 0 to 10,
% 0.05 extends the axis by 0.5 on each side, giving limits from -0.5 to
% 10.5.
%
% Arguments:
% - x_extra: Extra room on the x axis, a single ratio for both sides, or
%            [lower upper] to set each side separately
% - y_extra: Extra room on the y axis, same format as x_extra
% - z_extra: Optional, extra room on the z axis, same format as x_extra

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