function my_addParameter(parser,name,value)
%To maintain compatibility with older versions
persistent old_matlab
if isempty(old_matlab)
    old_matlab=verLessThan('matlab','8.3');
end
if old_matlab
    addParamValue(parser,name,value);
else
    addParameter(parser,name,value);
end

end
