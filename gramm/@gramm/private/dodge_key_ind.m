function ind=dodge_key_ind(values,uni_values)
%Index of each value of an aesthetic in its sorted unique values, as a
%column. Values that are not in uni_values (NaN, 'NA'...) get 0
ind=zeros(numel(values),1);
for k=1:length(uni_values)
    sel=multi_sel(values,uni_values{k});
    ind(sel(:))=k;
end
end
