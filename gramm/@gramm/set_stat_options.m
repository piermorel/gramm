function obj = set_stat_options( obj , varargin )
% set_stat_options Set options of the statistics computed by stat_ methods
%
% Example syntax (default arguments): gramm_object.set_stat_options('alpha',0.05,'nboot',200)
%
% Parameters given as 'name',value pairs:
% - 'alpha': Alpha level of the confidence intervals (default 0.05)
% - 'nboot': Number of bootstrap samples (default 200)

p=inputParser;
addParameter(p, 'alpha', 0.05 );
addParameter(p, 'nboot', 200 );
parse(p,varargin{:});

for obj_ind=1:numel(obj)
    obj(obj_ind).stat_options=p.Results;
end

end
