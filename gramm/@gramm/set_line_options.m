function obj = set_line_options( obj , varargin )
% set_line_options Set line width and style options
%
% Example syntax (default arguments): gramm_object.set_line_options('base_size',1.5,'step_size',1)
% Without a 'size' grouping variable, all lines have the width
% 'base_size'. With one, the first size group has 'base_size' and each
% next group is 'step_size' wider. With 'use_input', numeric size data is
% used directly as line widths instead of as groups.
%
% Parameters given as 'name',value pairs:
% - 'base_size': Width of the lines, or of the first size group
%            (default 1.5)
% - 'step_size': Width difference between successive size groups
%            (default 1)
% - 'use_input': Use the numeric values of the 'size' data as line
%            widths, instead of size groups (default false)
% - 'input_fun': Function converting the 'size' data into line widths
%            when 'use_input' is true, e.g. @(v)v/2 (default @(v)v)
% - 'styles': Line styles of the linestyle groups, in order (default
%            {'-' '--' ':' '-.'})
% - 'cap_size': Size of the error bar caps, in points (default 6)


p=inputParser;
addParameter(p, 'base_size', 1.5 );
addParameter(p, 'step_size', 1 );
addParameter(p, 'use_input', false );
addParameter(p, 'input_fun', @(v)v );
addParameter(p, 'styles', {'-' '--' ':' '-.'} );
addParameter(p, 'cap_size', 6 ,@(v) valid_range(v,0,Inf));
parse(p,varargin{:});

for obj_ind=1:numel(obj)
    obj(obj_ind).line_options=p.Results;
end

end

