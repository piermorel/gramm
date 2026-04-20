function obj = set_line_options( obj , varargin )
% set_line_options Set line size and style options
%
% 'name',value pairs:
% 'base_size': Default/starting line width for geoms that take in account size
% aesthetics. Default is 1.5
% 'step_size': Increment in line width for 'size' categories. Default is 1
% 'use_input': Set to true if a size aesthetic is given as numbers in order
% to use the given size values as line width values. Default is false
% 'input_fun': Provide a function handle to transform the 'size' aesthetic
% values in actual sizes when 'use_input' is set to true. Default is
% identity
% 'styles': Provide order for line style categories. Default is {'-' '--' ':' '-.'}


p=inputParser;
my_addParameter(p, 'base_size', 1.5 );
my_addParameter(p, 'step_size', 1 );
my_addParameter(p, 'use_input', false );
my_addParameter(p, 'input_fun', @(v)v );
my_addParameter(p, 'styles', {'-' '--' ':' '-.'} );
parse(p,varargin{:});

for obj_ind=1:numel(obj)
    obj(obj_ind).line_options=p.Results;
end

end

