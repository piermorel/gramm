function [n,ind]=my_histcounts(X,edges,normalization)
persistent old_matlab
if isempty(old_matlab)
    old_matlab=verLessThan('matlab','8.4');
end
if old_matlab
    %We make histc behave like histcounts
    [n,ind]=histc(X,edges);
    ind(ind==length(n))=length(n)-1;
    n(end-1)=n(end-1)+n(end);
    n(end)=[];
    
    switch normalization
        case 'probability'
            n=n./sum(n);
        case 'count'
        otherwise
            warning('Other types of normalization are not supported on older Matlab versions')
    end
else
    [n, ~, ind]=histcounts(X,edges,'Normalization',normalization);
end
end


