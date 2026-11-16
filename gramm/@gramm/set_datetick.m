function obj=set_datetick(obj,varargin)
% set_datetick Display datenum x values as dates (legacy, use datetime x data instead)
%
% Example syntax: gramm_object.set_datetick('x',1,'keepticks')
% Only for dates given as datenum numbers. Dates given as datetime (and
% durations) are displayed natively by gramm and don't need
% set_datetick(), which is then ignored: convert datenum values with
% datetime(x,'ConvertFrom','datenum'). Takes the same arguments as
% datetick() (tick axis, date format, 'keepticks', 'keeplimits').

%This way we can handle multiple calls to set_datetick
for obj_ind=1:numel(obj)
    obj(obj_ind).datetick_params=vertcat(obj(obj_ind).datetick_params,{varargin});
end
end
