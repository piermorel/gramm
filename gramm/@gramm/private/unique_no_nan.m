function y = unique_no_nan(x)
% Unique() function that ignores NaNs in arrays and 'NA' in cellstr.

persistent old_matlab
if isempty(old_matlab)
    old_matlab=verLessThan('matlab','7.14');
end
if old_matlab
    [y,ia,ic]=unique(x);
    [~,ind]=sort(ia); %Trick to get the original order in older matlab versions
    y=y(ind);
else
    y = unique(x,'stable'); %we keep the original order
end
%y = unique(x); %we keep the original order
if ~iscell(x)
    y(isnan(y)) = []; % remove all nans
else
    y(strcmp(y,'NA'))=[]; %remove all 'NA'
end

end