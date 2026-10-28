function T=axis_type(T,vals)
%Describe how datetime/duration data is converted to numbers for an axis.
%T is a structure with fields type ('numeric', 'datetime' or 'duration'),
%ref (reference date for datetime: numbers are days since ref) and unit
%('s','m','h' or 'd' for durations: numbers are in that unit). vals is a
%cell of the arrays (or cells of arrays) plotted along the axis. When T
%already has the same type (after update()), it is kept so that the
%existing axes stay valid. Numeric data leaves T unchanged.
if nargin<1 || isempty(T)
    T=struct('type','numeric','ref',NaT,'unit','');
end
if nargin<2
    return
end
vals=vals(~cellfun(@isempty,vals));
is_dt=cellfun(@(v) isdatetime(v) || (iscell(v) && isdatetime(v{1})),vals);
is_du=cellfun(@(v) isduration(v) || (iscell(v) && isduration(v{1})),vals);
if ~any(is_dt) && ~any(is_du) %Numeric data
    return
end
if ~all(is_dt) && ~all(is_du)
    error('gramm:mixedTypes','Data along the same axis must all be datetime, all duration, or all numeric');
end
%Gather all the values
for k=1:numel(vals)
    if iscell(vals{k})
        vals{k}=cellfun(@(c) c(:),vals{k},'UniformOutput',false);
        vals{k}=vertcat(vals{k}{:});
    end
    vals{k}=vals{k}(:);
end
all_vals=vertcat(vals{:});
if all(is_dt)
    if ~strcmp(T.type,'datetime')
        ref=dateshift(min(all_vals),'start','day');
        if isnat(ref)
            ref=dateshift(datetime('now','TimeZone',all_vals.TimeZone),'start','day');
        end
        T=struct('type','datetime','ref',ref,'unit','');
    end
elseif ~strcmp(T.type,'duration')
    %The unit is chosen from the span of the data
    span=max(all_vals)-min(all_vals);
    if ~(span>0)
        span=max(abs(all_vals));
    end
    if span<minutes(2)
        unit='s';
    elseif span<hours(2)
        unit='m';
    elseif span<days(2)
        unit='h';
    else
        unit='d';
    end
    T=struct('type','duration','ref',NaT,'unit',unit);
end
end
