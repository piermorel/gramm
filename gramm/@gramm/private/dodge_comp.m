function [fallback,dodge_x,dodge_keys,dodge_ind,dodge_n]=dodge_comp(x,keys)
%Dodging within a facet: for each unique x, the combinations of the dodge
%key aesthetics present there (keys: one row per data point, see
%dodge_global), their rank (dodge_ind) and number (dodge_n), so that
%dodged elements are centered on x even when some groups are missing.
%In fallback mode (x given as cells, or too many unique x) nothing is
%returned, and the global slots of dodge_global() are used instead

dodge_x=zeros(0,1);
dodge_keys=zeros(0,size(keys,2));
dodge_ind=zeros(0,1);
dodge_n=zeros(0,1);

if iscell(x)
    %If x is given as cell, we don't do the advanced dodging
    fallback=true;
    return
end

uni_x=unique(x);
%Here we need to implement a loose 'unique' because of
%potential numerical errors
uni_x(diff(uni_x)<1e-10)=[];

%Fallback if there are too many unique x values (dodging only makes
%sense for discrete x values)... 4000 x unique values is already a lot
%but quick enough to compute below
if numel(uni_x)>2000
    fallback=true;
    return
end
fallback=false;

%Data points with a value missing in one of the aesthetics aren't drawn
valid=all(keys>0,2);

%Preallocate for the largest case, trimmed at the end
N=length(uni_x)*size(unique(keys(valid,:),'rows'),1);
dodge_x=zeros(N,1);
dodge_keys=zeros(N,size(keys,2));
dodge_ind=zeros(N,1);
dodge_n=zeros(N,1);

ind=1;
for ind_x=1:length(uni_x)
    %And here we have a loose selection also because of
    %potential numerical errors
    sel=valid & abs(shiftdim(x)-uni_x(ind_x))<1e-10;

    %Combinations present at this x, sorted (color outer)
    temp_keys=unique(keys(sel,:),'rows');
    n_keys=size(temp_keys,1);

    dodge_x(ind:ind+n_keys-1)=uni_x(ind_x);
    dodge_keys(ind:ind+n_keys-1,:)=temp_keys;
    dodge_ind(ind:ind+n_keys-1)=1:n_keys;
    dodge_n(ind:ind+n_keys-1)=n_keys;
    ind=ind+n_keys;
end

dodge_x=dodge_x(1:ind-1);
dodge_keys=dodge_keys(1:ind-1,:);
dodge_ind=dodge_ind(1:ind-1);
dodge_n=dodge_n(1:ind-1);

end
