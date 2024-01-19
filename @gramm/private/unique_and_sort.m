function y=unique_and_sort(x,sortopts)
% Unique() function that ignores NaNs in arrays and empty values as well as 'NA' in
% cellstrs, and sorts according to sortopts


%Create unique in original order
y = unique(x,'stable'); %we keep the original order

%Clean up uniques
if ~iscell(x)
    if ~iscategorical(y)
        y(isnan(y)) = []; % remove all nans
    end
else
    y(strcmp(y,'NA'))=[]; %remove all 'NA'
    y(strcmp(y,''))=[]; %remove all ''
end

%Apply sorting options
if numel(sortopts)>1 %Custom ordering
    y=sort(y);%Sort first
    
    sortopts=shiftdim(sortopts);
    %If correct lengt and we have integers and all numbers from 1 to N are there we probably have indices
    if length(sortopts)==length(y) && isnumeric(sortopts) && sum(sort(sortopts)==(1:length(y))')==numel(y)
        disp('ordering given as indices')
        y=y(sortopts);
    else
        disp('ordering given as values')
        try
            %This should work whatever the lengths of either array
            [present,order]=ismember(sortopts,y);
            y=y(order(present));
        catch
            warning('Improper ordering values')
        end
    end
    
else %Other orderings
    switch sortopts
        case 1
            y=sort(y); %default
        case -1
            y=flipud(sort(y)); %We use flipud instead of the 'descend' option because somehow it isn't supported for cellstr.
    end
    %case 0 does nothing (keep original ordering)
end

end