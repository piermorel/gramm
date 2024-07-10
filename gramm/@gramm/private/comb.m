function res=comb(dat)
%Combines data in single array if originally in cells
if iscell(dat)
    % Only worked if first element was non empty!
    % if size(dat{1},1)==1 
    %Generic solution
    if max(cellfun('size',dat,1))==1 
        res=horzcat(dat{:});
    else
        res=vertcat(dat{:})';
    end
else
    res=dat;
end
end