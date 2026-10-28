function v=from_num(T,n)
%Convert numbers used internally by gramm back to datetime/duration values,
%as described by the axis type T (see axis_type())
switch T.type
    case 'datetime'
        v=T.ref+days(n);
    case 'duration'
        switch T.unit
            case 's'
                v=seconds(n);
            case 'm'
                v=minutes(n);
            case 'h'
                v=hours(n);
            otherwise
                v=days(n);
        end
    otherwise
        v=n;
end
end
