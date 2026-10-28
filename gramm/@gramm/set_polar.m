function obj=set_polar(obj,varargin)
% set_polar Activate polar axes
%
% This command changes axes to polar form: 'x' then corresponds to the
% angle (theta) and 'y' to the radius (rho). Categorical x values are
% evenly spread around the circle (radar charts). Needs MATLAB R2025a or
% newer.
% Additional parameters:
% 'unit': unit of the x data and of the angle axis, 'radians' (default)
% or 'degrees'. Other angles given to gramm (bin edges, bin widths,
% vline intercepts) are in the same unit. Results stored in g.results are
% in radians.
% 'closed': When plotting lines, connect the first
% and last points when set to true
% 'maxy': set the maximum radius (by default the radius axis spans
% from 0 to the maximum of the data)
%
% Supported: geom_point, geom_jitter, geom_line, geom_count, geom_label,
% geom_bar, geom_interval, geom_vline/hline/abline/funline, stat_bin,
% stat_density, stat_summary, stat_smooth, stat_fit, stat_glm. Other
% geoms and stats, z data, coord_flip(), facet_grid() 'space' and
% set_datetick() give an error.
%
% Angle axis orientation and range can be changed with axe_property(),
% e.g. 'ThetaZeroLocation','top','ThetaDir','clockwise' for compass plots

if isMATLABReleaseOlderThan("R2025a")
    error('gramm:polarRelease','Polar plots need MATLAB R2025a or newer');
end

p=inputParser;
my_addParameter(p,'unit','radians');
my_addParameter(p,'closed',false);
my_addParameter(p,'maxy',-1)
parse(p,varargin{:});

unit=validatestring(p.Results.unit,{'radians','degrees'});

for obj_ind=1:numel(obj)
    obj(obj_ind).polar.is_polar=true;
    obj(obj_ind).polar.is_polar_closed=p.Results.closed;
    obj(obj_ind).polar.max_polar_y=p.Results.maxy;
    obj(obj_ind).polar.unit=unit;
end

end
