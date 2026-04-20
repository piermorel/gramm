function s=pval_to_star(p)
if p<0.001
    s='***';
elseif p<0.01
    s='**';
elseif p<0.05
    s='*';
else
    s='';
end
end
