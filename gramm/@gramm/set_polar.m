function obj=set_polar(obj,varargin)
% set_polar Activate polar axes
%
% This command changes axes to polar form. 'x' then corresponds
% to theta
% Additional parameters:
% 'closed': When plotting lines, connect the first
% and last points when set to true
% 'maxy': set the maximum y value (automatic scaling can't work
% properly on polar plots.



p=inputParser;
my_addParameter(p,'closed',false);
my_addParameter(p,'maxy',-1)
parse(p,varargin{:});

for obj_ind=1:numel(obj)
    obj(obj_ind).polar.is_polar=true;
    obj(obj_ind).polar.is_polar_closed=p.Results.closed;
    obj(obj_ind).polar.max_polar_y=p.Results.maxy;
end

end