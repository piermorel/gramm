function y=unique_and_sort(x,sortopts)
% Unique() function that ignores NaNs in arrays and empty values as well as 'NA' in
% cellstrs, and sorts according to sortopts

persistent old_matlab
if isempty(old_matlab)
    old_matlab=verLessThan('matlab','7.14');
end

%Create unique in original order
if old_matlab
    [y,ia,~]=unique(x);
    [~,ind]=sort(ia); %Trick to get the original order in older matlab versions
    y=y(ind);
else
    y = unique(x,'stable'); %we keep the original order
end

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
    %Do checks on sorting array
    if length(sortopts)==length(y) %Correct length ?
        if isnumeric(sortopts) && sum(sort(sortopts)==(1:length(y))')==numel(y) %If we have integers and all numbers from 1 to N are there we probably have indices
            disp('ordering given as indices')
            y=y(sortopts);
        else
            %warning('Improper order array indices: using default order');
            %return
            disp('ordering given as values')
            try
                [present,order]=ismember(sortopts,y);
                if sum(present)==length(y)
                    y=y(order);
                else
                    warning('Improper ordering values')
                end
            catch
                warning('Improper ordering values')
            end

        end
    else
        warning('Improper order array size: using default order');
        return;
    end
else %Other orderings
    switch sortopts
        case 1
            y=sort(y);
        case -1
            y=flipud(sort(y)); %We use flipud instead of the 'descend' option because somehow it isn't supported for cellstr.
    end
end

end