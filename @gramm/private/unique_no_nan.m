function y = unique_no_nan(x)
% Unique() function that ignores NaNs in arrays and 'NA' in cellstr.


y = unique(x,'stable'); %we keep the original order

%y = unique(x); %we keep the original order
if ~iscell(x)
    y(isnan(y)) = []; % remove all nans
else
    y(strcmp(y,'NA'))=[]; %remove all 'NA'
end

end