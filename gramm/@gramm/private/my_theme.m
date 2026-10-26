function output = my_theme(f)
%Figure themes only exist from R2025a, older figures are always light
if isprop(f,'Theme')
    output = f.Theme.Name;
else
    output = 'Light Theme';
end

end

