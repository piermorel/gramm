function sel=multi_sel(to_sel,value)
%Do a selection on the basis of string equality or numerical equality

if ischar(value)
    sel=strcmp(to_sel,value);
else
    sel=to_sel==value;
end

end