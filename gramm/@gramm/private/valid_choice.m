function ok=valid_choice(value,choices,allow_several)
%Validation function for inputParser: value must be one of the given text
%choices (case-sensitive), as char or string. With allow_several, a cell
%array or string array of choices is accepted as well. Errors with the
%list of choices otherwise
if nargin<3
    allow_several=false;
end
if allow_several && iscell(value) && ~isempty(value)
    values=value;
elseif allow_several && isstring(value) && ~isempty(value)
    values=num2cell(value);
else
    values={value};
end
ok=all(cellfun(@(v) (ischar(v) && isrow(v)) || (isstring(v) && isscalar(v)),values)) ...
    && all(ismember(cellfun(@char,values,'UniformOutput',false),choices));
if ~ok
    list=strjoin(strcat('''',choices,''''),', ');
    if allow_several
        error('Value must be one of %s, or a cell or string array of them.',list);
    else
        error('Value must be one of %s.',list);
    end
end
end
