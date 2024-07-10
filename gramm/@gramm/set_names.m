function obj=set_names(obj,varargin)
% set_names Set names for aesthetics to be displayed in legends and axes
%
% Example syntax : gramm_object.set_names('x','Time (ms)','y','Hand position (mm)','color','Movement direction (°)','row','Subject')
% Supported aesthetics: 'x' 'y' 'z' 'color' 'linestyle' 'size'
% 'marker' 'row' 'column' 'lightness'

p=inputParser;

my_addParameter(p,'x','x');
my_addParameter(p,'y','y');
my_addParameter(p,'z','z');
my_addParameter(p,'label','Label');
my_addParameter(p,'color','Color');
my_addParameter(p,'linestyle','Line Style');
my_addParameter(p,'size','Size');
my_addParameter(p,'marker','Marker');
my_addParameter(p,'row','Row');
my_addParameter(p,'column','Column');
my_addParameter(p,'lightness','Lightness');
my_addParameter(p,'group','Group');
my_addParameter(p,'fig','Figure');

parse(p,varargin{:});

fnames=fieldnames(p.Results);
for k=1:length(fnames)
    for obj_ind=1:numel(obj)
        obj(obj_ind).aes_names.([fnames{k}])=p.Results.(fnames{k});
    end
end

end