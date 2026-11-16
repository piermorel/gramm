function obj=set_names(obj,varargin)
% set_names Set names of the variables, displayed in axes labels, legends and facet titles
%
% Example syntax: gramm_object.set_names('x','Time (ms)','y','Hand position (mm)','color','Movement direction','row','Subject')
%
% Parameters given as 'name',value pairs:
% - 'x': Label of the x axes (default 'x')
% - 'y': Label of the y axes (default 'y')
% - 'z': Label of the z axes (default 'z')
% - 'label': Name of the label variable (default 'Label')
% - 'color': Title of the color legend (default 'Color')
% - 'linestyle': Title of the line style legend (default 'Line Style')
% - 'size': Title of the size legend (default 'Size')
% - 'marker': Title of the marker legend (default 'Marker')
% - 'row': Title of the row facets, combined with each value (default
%            'Row')
% - 'column': Title of the column facets, combined with each value
%            (default 'Column')
% - 'lightness': Title of the lightness legend (default 'Lightness')
% - 'group': Name of the group variable (default 'Group')
% - 'fig': Title of the separate figures, combined with each value
%            (default 'Figure')

p=inputParser;

addParameter(p,'x','x');
addParameter(p,'y','y');
addParameter(p,'z','z');
addParameter(p,'label','Label');
addParameter(p,'color','Color');
addParameter(p,'linestyle','Line Style');
addParameter(p,'size','Size');
addParameter(p,'marker','Marker');
addParameter(p,'row','Row');
addParameter(p,'column','Column');
addParameter(p,'lightness','Lightness');
addParameter(p,'group','Group');
addParameter(p,'fig','Figure');

parse(p,varargin{:});

fnames=fieldnames(p.Results);
for k=1:length(fnames)
    for obj_ind=1:numel(obj)
        obj(obj_ind).aes_names.([fnames{k}])=p.Results.(fnames{k});
    end
end

end