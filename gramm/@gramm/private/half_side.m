function [side,dodge]=half_side(half,color_index,dodge)
%Side on which half violins or swarms are drawn ('none', 'left' or
%'right'), from the 'half' option of stat_violin() and geom_swarm().
%Logical values are kept for backward compatibility (true is 'color'). In
%'color' mode two colors share the same x, alternating sides, so we don't
%dodge

if islogical(half) || isnumeric(half)
    if half
        half='color';
    else
        half='none';
    end
end

switch half
    case 'color'
        dodge=0;
        if ~mod(color_index,2) %Right half if even index
            side='right';
        else %Left half if odd
            side='left';
        end
    otherwise
        side=char(half);
end

end
