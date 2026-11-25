function obj = set_point_options( obj , varargin )
% set_point_options Set point size and marker options
%
% Example syntax (default arguments): gramm_object.set_point_options('base_size',5,'step_size',2)
% Without a 'size' grouping variable, all points have the size
% 'base_size'. With one, the first size group has 'base_size' and each
% next group is 'step_size' larger. With 'use_input', numeric size data is
% used directly as point sizes instead of as groups.
%
% Parameters given as 'name',value pairs:
% - 'base_size': Size of the points, or of the first size group
%            (default 5)
% - 'step_size': Size difference between successive size groups
%            (default 2)
% - 'size_aes': Points follow the 'size' groups (default true). With
%            false, all points have the size 'base_size' and only the
%            lines follow the 'size' groups (see set_line_options())
% - 'use_input': Use the numeric values of the 'size' data as point
%            sizes, instead of size groups (default false)
% - 'input_fun': Function converting the 'size' data into point sizes
%            when 'use_input' is true, e.g. @(v)v*2 (default @(v)v)
% - 'border_width': Width of the point edges (default 0.5)
% - 'border_color': Color of the point edges (default 'none')
% - 'markers': Markers of the marker groups, in order (default {'o' 's'
%            'd' '^' 'v' '>' '<' 'p' 'h' '*' '+' 'x'})


p=inputParser;
addParameter(p, 'base_size', 5 );
addParameter(p, 'step_size', 2 );
addParameter(p, 'size_aes', true );
addParameter(p, 'use_input', false );
addParameter(p, 'input_fun', @(v)v );
addParameter(p, 'border_width', 0.5);
addParameter(p, 'border_color', 'none');
addParameter(p, 'markers', {'o' 's' 'd' '^' 'v' '>' '<' 'p' 'h' '*' '+' 'x'} );
parse(p,varargin{:});

            
for obj_ind=1:numel(obj)
    obj(obj_ind).point_options=p.Results;
end

end

