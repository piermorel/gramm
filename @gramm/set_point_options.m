function obj = set_point_options( obj , varargin )
% set_point_options Set point size and marker options
%
% 'name',value pairs:
% 'base_size': Default/starting point size for geoms that take in account size
% aesthetics. Default is 5
% 'step_size': Increment in point size for 'size' categories. Default is 2
% 'use_input': Set to true if a size aesthetic is given as numbers in order
% to use the given size values as point size values. Default is false
% 'input_fun': Provide a function handle to transform the 'size' aesthetic
% values in actual sizes when 'use_input' is set to true. Default is
% identity
% 'styles': Provide order for marker style categories. Default is {'o' 's' 'd' '^' 'v' '>' '<' 'p' 'h' '*' '+' 'x'}


p=inputParser;
my_addParameter(p, 'base_size', 5 );
my_addParameter(p, 'step_size', 2 );
my_addParameter(p, 'use_input', false );
my_addParameter(p, 'input_fun', @(v)v );
my_addParameter(p, 'markers', {'o' 's' 'd' '^' 'v' '>' '<' 'p' 'h' '*' '+' 'x'} );
parse(p,varargin{:});
            
for obj_ind=1:numel(obj)
    obj(obj_ind).point_options=p.Results;
end

end

