function obj = set_text_options( obj , varargin )
% set_text_options Set text size and font options
%
% Example syntax (default arguments): gramm_object.set_text_options('base_size',10,'font','Helvetica')
%
% Parameters given as 'name',value pairs:
% - 'base_size': Base text size, the size of axis tick labels (default 10)
% - 'label_scaling': Size of axis labels, relative to base (default 1)
% - 'legend_scaling': Size of legend labels, relative to base (default 1)
% - 'legend_title_scaling': Size of legend titles, relative to base
%            (default 1.2)
% - 'facet_scaling': Size of facet titles, relative to base (default 1.2)
% - 'title_scaling': Size of the plot title, relative to base (default
%            1.4)
% - 'big_title_scaling': Size of the title of an array of gramm plots,
%            relative to base (default 1.4)
% - 'font': Font of all text (default 'Helvetica')
% - 'interpreter': Interpretation of text characters (default 'none'):
%       - 'none'
%       - 'tex'
%       - 'latex'
% - 'wrap': Wrap long titles (overall, facet and row titles) on several
%            lines to fit the available space. The title of an array of
%            gramm plots follows the setting of its first plot (default
%            true)


p=inputParser;
addParameter(p,'base_size' , 10 );
addParameter(p,'label_scaling', 1 );
addParameter(p,'legend_scaling', 1 );
addParameter(p,'legend_title_scaling', 1.2 );
addParameter(p,'facet_scaling', 1.2 );
addParameter(p,'title_scaling', 1.4 );
addParameter(p,'big_title_scaling', 1.4 );
addParameter(p,'font','Helvetica');
addParameter(p,'interpreter','none');
addParameter(p,'wrap',true);
parse(p,varargin{:});

for obj_ind=1:numel(obj)
    obj(obj_ind).text_options=p.Results;
end

end

