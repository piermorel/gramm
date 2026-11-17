function [x,y]=close_polar(obj,x,y)
%In closed polar plots (set_polar('closed',true)), lines are closed by
%repeating their first point at the end. Vectors may hold several lines
%separated by NaNs in x (see combnan()), each closed. x and y are returned
%unchanged otherwise
if ~obj.polar.is_polar || ~obj.polar.is_polar_closed
    return
end
if iscell(x)
    for k=1:length(x)
        [x{k},y{k}]=close_polar(obj,x{k},y{k});
    end
elseif size(shiftdim(x),2)==1 && size(shiftdim(y),2)==1
    x_row=isrow(x);
    y_row=isrow(y);
    x=x(:);
    y=y(:);
    sep=isnan(x);
    starts=find(~sep & [true ; sep(1:end-1)]);
    ends=find(~sep & [sep(2:end) ; true]);
    for k=numel(ends):-1:1
        x=[x(1:ends(k)) ; x(starts(k)) ; x(ends(k)+1:end)];
        y=[y(1:ends(k)) ; y(starts(k)) ; y(ends(k)+1:end)];
    end
    if x_row
        x=x';
    end
    if y_row
        y=y';
    end
end
end
