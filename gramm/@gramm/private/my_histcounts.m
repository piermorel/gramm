function [n,ind]=my_histcounts(X,edges,normalization)
[n, ~, ind]=histcounts(X,edges,'Normalization',normalization);
end
