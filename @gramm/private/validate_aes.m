function out=validate_aes(aes)
%Generate useable aes structures: empty fields are replaced with arrays of
%ones of the correct size. The size of the other fields are checked for
%consistency. Handle special case of size parameter that can be set by the
%user


out=aes;
fields=fieldnames(aes);

%Handle special case when Y is a matrix
if ~iscell(out.y)
    if size(out.y,2)>1
        out.y=num2cell(out.y,2); %We convert rows of y to cell elements
        out.y=cellfun(@(c)shiftdim(c),out.y,'uniformOutput',false);
        %out.y=shiftdim(out.y);
    end
end

%Handle special case when Z is a matrix
if ~iscell(out.z)
    if size(out.z,2)>1
        out.z=num2cell(out.z,2); %We convert rows of y to cell elements
        out.z=cellfun(@(c)shiftdim(c),out.z,'uniformOutput',false);
        %out.y=shiftdim(out.y);
    end
end

%Handle special case when Y is a matrix/cell and X is a single vector
if iscell(out.y) && ~iscell(out.x)
    if size(out.x,2)>1 %X is a matrix
        out.x=num2cell(out.x,2);  %We convert rows of x to cell elements
    else %X is a vector
        %We need to duplicate it
        if length(out.x)==length(out.y)
            out.x=num2cell(repmat(shiftdim(out.x),1,length(out.y{1})),2);
        else
            out.x=num2cell(repmat(shiftdim(out.x),1,length(out.y)),1);
        end
    end
    out.x=cellfun(@(c)shiftdim(c),out.x,'uniformOutput',false);
    out.x=shiftdim(out.x);
end



aes_length=-1;
for k=1:length(fields)
    if numel(out.(fields{k}))>0 %Ignore empty ones
        if aes_length==-1 && numel(out.(fields{k}))~=1
            aes_length=numel(out.(fields{k}));
        else
            if aes_length~=numel(out.(fields{k})) && numel(out.(fields{k}))~=1 %Handle special case of size
                error('Aesthetics have fields of different lengths !')
            end
        end
        
        %Convert categorical data to cellstr.
        if iscategorical(aes.(fields{k}))
            out.(fields{k})=cellstr(out.(fields{k}));
        end
        
    end
end



%Special case for size:
if numel(aes.size)==1
    out.size=ones(size(aes.x))*aes.size;
end

%Missing fields are replaced with arrays of ones
for k=1:length(fields)
    if isempty(aes.(fields{k})) && ~strcmp(fields{k},'z') %If z is empty we leave it empty
        
        out.(fields{k})=ones(aes_length,1);
        if strcmp(fields{k},'subset') %Or array of true for 'subset'
            out.(fields{k})=true(aes_length,1);
        end
        
    end

end

end
