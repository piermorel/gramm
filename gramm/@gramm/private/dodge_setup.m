function dodge=dodge_setup(obj,temp_aes,uni_color,uni_lightness,uni_marker,uni_linestyle,uni_size)
%Dodging key of every data point, and the global dodging slots (see
%dodge_global): elements are dodged for each combination of the
%aesthetics in dodge_options.by. One column per aesthetic, in a fixed
%order with color and lightness first. With continuous colors, color
%doesn't separate groups. Returns a struct with the keys of the data
%points (keys), the unique keys (uni_keys), their slots (key_index) and
%the number of slots (n)

dodge_order={'color','lightness','marker','linestyle','size','group'};
uni_group=unique_and_sort(temp_aes.group,0);
if ~iscell(uni_group)
    uni_group=num2cell(uni_group);
end
uni=struct('color',{uni_color},'lightness',{uni_lightness},'marker',{uni_marker},...
    'linestyle',{uni_linestyle},'size',{uni_size},'group',{uni_group});

dodge_aes=dodge_order(ismember(dodge_order,obj.dodge_options.by));
if obj.continuous_color_options.active
    dodge_aes(strcmp(dodge_aes,'color'))=[];
end

%The last column is constant, so that the key is never empty
dodge.keys=ones(numel(temp_aes.x),length(dodge_aes)+1);
for k=1:length(dodge_aes)
    dodge.keys(:,k)=dodge_key_ind(temp_aes.(dodge_aes{k}),uni.(dodge_aes{k}));
end

%Number of colors and lightnesses, for the color/lightness columns
cl_aes=dodge_aes(ismember(dodge_aes,{'color','lightness'}));
cl_sizes=zeros(1,length(cl_aes));
for k=1:length(cl_aes)
    cl_sizes(k)=length(uni.(cl_aes{k}));
end

[dodge.uni_keys,dodge.key_index,dodge.n]=dodge_global(dodge.keys,cl_sizes);

end
