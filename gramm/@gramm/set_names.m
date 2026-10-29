function obj=set_names(obj,varargin)
% set_names Set names for aesthetics to be displayed in legends and axes
%
% Example syntax : gramm_object.set_names('x','Time (ms)','y','Hand position (mm)','color','Movement direction (°)','row','Subject')
% Supported aesthetics: 'x' 'y' 'z' 'color' 'linestyle' 'size'
% 'marker' 'row' 'column' 'lightness'

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