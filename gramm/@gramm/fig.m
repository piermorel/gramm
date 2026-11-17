function obj = fig(obj,fig)
% fig Create separate figures according to one factor
%
% Example syntax: gramm_object.fig(variable)
% Useful when facet_ generates too crowded figures. Warning: the generated
% gramm figures are independent: no common legend, axis limits, etc.
%
% Arguments:
% - fig: Variable separating data by figures, 1D numerical array or
%            cellstr of length N. For each unique value, a new figure is
%            created with the corresponding data

obj.aes.fig=shiftdim(fig);

end

