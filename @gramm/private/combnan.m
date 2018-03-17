function res=combnan(dat)
%Combines data in single array with NaNs separating original arrays if originally in cells
if iscell(dat)
    %Remove empty cells
    dat = dat(~cellfun(@isempty,dat));
    if isempty(dat)
        res = NaN;
        return;
    end
    
    if ~iscellstr(dat)
        if max(cellfun('size',dat,1))==1  %size(dat{1},1)==1
            dat=cellfun(@(c)[c NaN],dat,'uniformOutput',false);
        else
            dat=cellfun(@(c)[c;NaN],dat,'uniformOutput',false);
        end
    end
    
    if max(cellfun('size',dat,1))==1 % size(dat{1},1)==1
        res=horzcat(dat{:});
    else
        res=vertcat(dat{:})';
    end
else
    res=dat;
end
end