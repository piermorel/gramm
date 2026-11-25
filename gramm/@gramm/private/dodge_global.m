function [uni_keys,key_index,n_dodge]=dodge_global(keys,cl_sizes)
%Global dodging slots, over all facets. keys has one row per data point
%and one column per aesthetic of the dodge key (indices in their unique
%values, see dodge_key_ind), color and lightness first. cl_sizes gives the
%number of unique values of these first color/lightness columns.
%As before dodging was extended to the other aesthetics, every combination
%of color and lightness has a slot, present or not. Within each, there are
%as many slots as the largest number of combinations of the other
%aesthetics found in a color/lightness combination. So when the other
%aesthetics are the same as color (or absent), nothing changes.
%Returns the unique keys (sorted, color outer), the slot of each
%(key_index) and the number of slots (n_dodge)

n_cl=length(cl_sizes);

%Data points with a value missing in one of the aesthetics aren't drawn
keys=keys(all(keys>0,2),:);
if isempty(keys)
    uni_keys=zeros(0,size(keys,2));
    key_index=zeros(0,1);
    n_dodge=1;
    return
end
uni_keys=unique(keys,'rows');

%Index of the color/lightness combination, with all combinations counted
cl_index=ones(size(uni_keys,1),1);
for k=1:n_cl
    cl_index=(cl_index-1)*cl_sizes(k)+uni_keys(:,k);
end

%Rank of the other aesthetics within their color/lightness combination
%(keys are sorted, so the ranks follow the order of the aesthetics)
extra_rank=ones(size(uni_keys,1),1);
for k=2:size(uni_keys,1)
    if cl_index(k)==cl_index(k-1)
        extra_rank(k)=extra_rank(k-1)+1;
    end
end
n_extra=max(extra_rank);

key_index=(cl_index-1)*n_extra+extra_rank;
n_dodge=prod(cl_sizes)*n_extra;

end
