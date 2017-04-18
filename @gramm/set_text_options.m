function obj = set_text_options( obj , varargin )
% set_text_options Provide text size and font options
%
% 'name',value pairs:
% 'base_size': Base text size, corresponds to axis ticks text size (default is 10)
% 'interpreter': 'none'(default), 'tex' or 'latex'
% 'label_scaling': Scaling of axis label sizes relative to base (default is 1)
% 'legend_scaling': Scaling of legend label sizes relative to base (default is 1)
% 'legend_title_scaling': Scaling of legend title sizes relative to base (default is 1.2)
% 'facet_scaling': Scaling of facet title sizes relative to base (default is 1.2)
% 'title_scaling': Scaling of figure title sizes relative to base (default is 1.4)
% 'big_title_scaling': Scaling of overarching figure title size relative to base (default is 1.4)
% 'font': Font to use for text (Default is 'Helvetica')


p=inputParser;
my_addParameter(p,'base_size' , 10 );
my_addParameter(p,'label_scaling', 1 );
my_addParameter(p,'legend_scaling', 1 );
my_addParameter(p,'legend_title_scaling', 1.2 );
my_addParameter(p,'facet_scaling', 1.2 );
my_addParameter(p,'title_scaling', 1.4 );
my_addParameter(p,'big_title_scaling', 1.4 );
my_addParameter(p,'font','Helvetica');
my_addParameter(p,'interpreter','none');
parse(p,varargin{:});

for obj_ind=1:numel(obj)
    obj(obj_ind).text_options=p.Results;
end

end

