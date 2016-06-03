function res=combnan(dat)
%Combines data in single array with NaNs separating original arrays if originally in cells
if iscell(dat) 
    if ~iscellstr(dat)
        if size(dat{1},1)==1
            dat=cellfun(@(c)[c NaN],dat,'uniformOutput',false);
        else
            dat=cellfun(@(c)[c;NaN],dat,'uniformOutput',false);
        end
    end
    
    if size(dat{1},1)==1
        res=horzcat(dat{:});
    else
        res=vertcat(dat{:})';
    end
else
    res=dat;
end
end