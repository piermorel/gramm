function output = my_theme(f)
%Figure themes only exist from R2025a, older figures are always light. In
%R2024a/b figures have a Theme property, but it holds an empty
%GraphicsPlaceholder without a Name
output = 'Light Theme';
if isprop(f,'Theme') && isprop(f.Theme,'Name')
    output = f.Theme.Name;
end

end
