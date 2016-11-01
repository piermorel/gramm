function obj = fig(obj,fig)
% fig Create separate figures according to one factor
%
% Example syntax : gramm_object.fig(variable)
% For each unique value of variable, a new gramm figure will be created,
% containing only the corresponding data. Useful when facet_ generates too
% crowded figures. Warning: the generated gramm figures are independent: no
% common legend, axis limits, etc.

obj.aes.fig=shiftdim(fig);

end

