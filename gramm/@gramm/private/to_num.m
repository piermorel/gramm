function n=to_num(T,v)
%Convert datetime/duration values (or cells of them) to the numbers used
%internally by gramm, as described by the axis type T (see axis_type()).
%Numeric values are returned unchanged, except angles in degrees (polar x
%axis with unit 'deg'), which are converted to radians
if iscell(v)
    n=cellfun(@(c)to_num(T,c),v,'UniformOutput',false);
elseif isdatetime(v)
    if ~strcmp(T.type,'datetime')
        error('gramm:mixedTypes','datetime values given for a non-datetime axis');
    end
    n=days(v-T.ref);
elseif isduration(v)
    if ~strcmp(T.type,'duration')
        error('gramm:mixedTypes','duration values given for a non-duration axis');
    end
    n=duration_to_num(v,T.unit);
elseif strcmp(T.unit,'deg')
    n=deg2rad(v);
else
    n=v;
end
end

function n=duration_to_num(v,unit)
switch unit
    case 's'
        n=seconds(v);
    case 'm'
        n=minutes(v);
    case 'h'
        n=hours(v);
    otherwise
        n=days(v);
end
end
