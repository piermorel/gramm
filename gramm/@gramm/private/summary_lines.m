function [values,kinds]=summary_lines(y,lines)
%Values of the summary lines drawn across violins and boxes, from the 'lines'
%option of stat_violin() and stat_boxplot(). lines is 'median', 'quartiles',
%'mean', a cell of these, or numeric quantiles (e.g. [0.1 0.9]). kinds gives
%for each value 'median', 'quantile' or 'mean', which sets the line style.
%Quantiles are computed from the data with prctile(), as in stat_boxplot()

values=[];
kinds={};

y=y(~isnan(y));
if isempty(y)
    return;
end

%Numeric quantiles
if isnumeric(lines)
    values=reshape(prctile(y,100*lines),1,[]);
    kinds=repmat({'quantile'},1,length(values));
    return;
end

if ischar(lines)
    lines={lines};
elseif isstring(lines)
    lines=cellstr(lines);
end

for k=1:length(lines)
    switch lines{k}
        case 'median'
            values=[values prctile(y,50)];
            kinds=[kinds {'median'}];
        case 'quartiles'
            values=[values reshape(prctile(y,[25 75]),1,[])];
            kinds=[kinds {'quantile','quantile'}];
        case 'mean'
            values=[values mean(y)];
            kinds=[kinds {'mean'}];
    end
end

end
