function obj=no_legend(obj)
% no_legend Remove the side legend of the plot (same as set_layout_options('legend',false))
%
% Example syntax: gramm_object.no_legend()
% Useful when plotting multiple gramm objects with the same legend.

obj.layout_options.legend=false;

end