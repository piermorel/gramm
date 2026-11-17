function set_rulers(obj,ax)
%Give the axes datetime/duration rulers when x or y data was datetime or
%duration. The data itself is plotted as numbers (see validate_aes()), which
%these rulers accept. Matlab has no direct way to create such rulers: they
%are created by plotting a datetime/duration value, and this invisible
%placeholder line must stay in the axes (with visible handle: hiding it
%turns the rulers back to numeric)
T=obj.axis_types;
if strcmp(T.x.type,'numeric') && strcmp(T.y.type,'numeric')
    return
end
if obj.polar.is_polar
    error('gramm:unsupportedType','datetime and duration data are not supported in polar plots');
end
hold(ax,'on');
%The numbers of a duration ruler are in the unit of the first duration
%plotted, so the placeholder is NaN in the chosen unit
plot(ax,from_num(T.x,NaN),from_num(T.y,NaN),'PickableParts','none','Tag','gramm_ruler');
set_ruler(ax.XAxis,T.x);
set_ruler(ax.YAxis,T.y);
end

function set_ruler(ruler,T)
switch T.type
    case 'datetime'
        ruler.ReferenceDate=T.ref;
    case 'duration'
        ruler.TickLabelFormat=T.unit;
end
end
