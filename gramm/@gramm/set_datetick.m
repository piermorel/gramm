function obj=set_datetick(obj,varargin)
%set_datetick Specify that the x axis has dates
%
% This function can receive the same optional arguments as the
% datetick() function of matlab. In gramm versions before March 2018 the
% behavior was to force the 'keepticks' options. Now the options
% 'keepticks' or 'keeplimits' must be specified.

%This way we can handle multiple calls to set_datetick
for obj_ind=1:numel(obj)
    obj(obj_ind).datetick_params=vertcat(obj.datetick_params,{varargin});
end
end