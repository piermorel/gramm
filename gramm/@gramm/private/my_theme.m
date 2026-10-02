function output = my_theme(f)
%To maintain compatibility with older versions
persistent has_theme
if isempty(has_theme)
    has_theme=~verLessThan('matlab','25.1');
end

if has_theme
    output = theme(f).Name;
else
    output = 'Light Theme';
end

end

