function ok=valid_range(value,low,high,allow_empty)
%Validation function for inputParser: value must be numeric, with all its
%elements between low and high. With allow_empty, [] (automatic value) is
%accepted as well. Errors with the expected range otherwise
if nargin>3 && allow_empty && isempty(value)
    ok=true;
    return
end
ok=isnumeric(value) && isreal(value) && ~isempty(value) && all(value(:)>=low & value(:)<=high);
if ~ok
    if isinf(high)
        range=sprintf('greater than or equal to %g',low);
    else
        range=sprintf('between %g and %g',low,high);
    end
    if nargin>3 && allow_empty
        error('Value must be numeric and %s, or empty for the automatic value.',range);
    else
        error('Value must be numeric and %s.',range);
    end
end
end
