function obj = set_layout_options( obj , varargin )
% set_layout_options Change figure layout options
%
% 'name',value pairs:
% 'position':       specify the position of the gramm plot in the figure, using
%                   normalized coordinates (between 0 and 1) [left bottom width height]
%                   Default is 'auto', which sets the positions/sizes 
%                   according to the gramm object array indices
% 'legend':         specify (true/false) whether the side legend will be
%                   displayed. set_layout_options('legend',false)
%                   replaces no_legend()
% 'legend_width':   specify the proportion of the gramm plot occupied by the
%                   side legend (between 0 and 1). Default is 'auto'. In
%                   order to set the legend width in figure normalized
%                   coordinates, divide by the plot width specified in the
%                   'position' argument.
% 'legend_position':Separates the legend from the gramm plot and puts in a 
%                   custom position in the figure (normalized coordinates).
% 'title_centering' specify whether the plot title is aligned relative to
%                   the whole plot including legends 'plot' or relative to
%                   the plot without legends 'axes' (default)
% 'redraw'          true (default) / false. Specify whether the figure gets
%                   automatically redrawn and adjusted after initial draw
%                   and on resize. Must be set on the first element when
%                   using an array of gramm objects
% 'redraw_gap'      gap between elements during automatic redraw
% 'margin_height'   2-element vector indicating the bottom and top vertical
%                   margins. Used only when 'redraw' is false
% 'margin_width'    2-element vector indicating the left and right
%                   horizontal margins. Used only when 'redraw' is false
% 'gap'             2-element vector indicating the gaps between facet
%                   subplots in the format [width height]). 'auto' by
%                   default. Useful only when 'redraw' is false, otherwise
%                   'redraw_gap' is used. Default values are with ticks [0.06 0.06],
%                   without ticks [0.02 0.02], facet wrap [0.09 0.03].

p=inputParser;
my_addParameter(p,'position' , 'auto' );
my_addParameter(p,'legend', true );
my_addParameter(p,'legend_width', 'auto' );
my_addParameter(p,'legend_position', 'auto' );
my_addParameter(p,'title_centering', 'axes');
my_addParameter(p,'redraw',true);
my_addParameter(p,'redraw_gap',0.04);
my_addParameter(p,'margin_height',[0.1 0.2]);
my_addParameter(p,'margin_width',[0.1 0.2]);
my_addParameter(p,'gap','auto'); 
parse(p,varargin{:});

for obj_ind=1:numel(obj)
    obj(obj_ind).layout_options=p.Results;
end

end