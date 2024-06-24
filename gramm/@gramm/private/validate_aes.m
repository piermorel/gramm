function out=validate_aes(aes)
%Generate useable aes structures: empty fields are replaced with arrays of
%ones of the correct size. The size of the other fields are checked for
%consistency. Handle special case of size parameter that can be set by the
%user

%Old matlab test for iscategorical absent from pre 2013b
persistent old_matlab
if isempty(old_matlab)
    old_matlab=verLessThan('matlab','8.2');
end

out=aes;
fields=fieldnames(aes);

%Handle special case when Y is a matrix (convert to cell)
out.y=process_mat(out.y);
out.ymin=process_mat(out.ymin);
out.ymax=process_mat(out.ymax);

%Handle special case when Z is a matrix (convert to cell)
out.z=process_mat(out.z);

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

if iscell(out.y) && iscell(out.x) && ~iscellstr(out.x)
    equal_lengths=cellfun(@(x,y)length(x)==length(y),out.x,out.y);
    if ~all(equal_lengths)
        error('Cells in X and Y have different lengths');
    end
    
    %Process facultative data that can be in cells
    to_process = {'z' , 'ymin', 'ymax'};
    for k = 1:length(to_process)
        if iscell(out.(to_process{k}))
            % Check lengths
            equal_lengths=cellfun(@(y,z)length(y)==length(z),out.y,out.(to_process{k}));
            if ~all(equal_lengths)
                error(['Cells in ' to_process{k} ' and X/Y have different lengths']);
            end
            % Shiftdim cell contents
            out.(to_process{k})=cellfun(@(c)shiftdim(c),out.(to_process{k}),'uniformOutput',false);
        end
    end
end


aes_length=-1;
for k=1:length(fields)
    if numel(out.(fields{k}))>0 %Ignore empty ones
        if aes_length==-1 %First aesthetic
            aes_length=numel(out.(fields{k}));
        else
            if aes_length~=numel(out.(fields{k}))
                error('Data inputs have different lengths !')
            end
        end
        
        %Convert categorical data to cellstr.
        if ~old_matlab && iscategorical(aes.(fields{k}))
            out.(fields{k})=cellstr(out.(fields{k}));
        end
        
    end
end


%Missing fields are replaced with arrays of ones
for k=1:length(fields)
    if isempty(aes.(fields{k})) && sum(strcmp(fields{k},{'z' 'ymin' 'ymax' 'label'}))==0 %If z, ymin, ymax are empty we leave them empty
        
        out.(fields{k})=ones(aes_length,1);
        if strcmp(fields{k},'subset') %Or array of true for 'subset'
            out.(fields{k})=true(aes_length,1);
        end
        
    end

end

end

function m=process_mat(m)
if ~iscell(m)
    if size(m,2)>1
        m=num2cell(m,2); %We convert rows of y to cell elements
        m=cellfun(@(c)shiftdim(c),m,'uniformOutput',false);
    end
end
end
