function output = my_theme(f)
%Figure themes only exist from R2025a, older figures are always light. In
%R2024a/b figures have a Theme property, but it is empty
output = 'Light Theme';
if isprop(f,'Theme') && ~isempty(f.Theme) && isprop(f.Theme,'Name')
    output = f.Theme.Name;
end

end
