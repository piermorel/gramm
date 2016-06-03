function obj=set_continuous_color(obj,varargin)
%set_continuous_color Force the use of a continuous color
%scheme
%
% Parameters as name,value pairs:
% 'colormap' set continuous colormap by
% name: 'hot,'cool', or 'parula'
% 'LCH_colormap' set colormap by Lightness-Chroma-Hue values
% using a matrix organized this way:
% [L_start L_end; C_start C_end ; H_start H_end]

obj.continuous_color=true;

p=inputParser;
my_addParameter(p,'colormap','hot');
my_addParameter(p,'LCH_colormap',[]);
parse(p,varargin{:});

switch p.Results.colormap
    case 'hot'
        obj.continuous_color_colormap=pa_LCH2RGB([linspace(0,100,256)'...
            repmat(100,256,1)...
            linspace(30,90,256)']);
    case 'parula'
        obj.continuous_color_colormap=colormap('parula');
    case 'cool'
        obj.continuous_color_colormap=pa_LCH2RGB([linspace(0,80,256)'...
            repmat(100,256,1)...
            linspace(200,260,256)']);
    otherwise
        obj.continuous_color_colormap=pa_LCH2RGB([linspace(0,100,256)'...
            repmat(100,256,1)...
            linspace(30,90,256)']);
end

if ~isempty(p.Results.LCH_colormap)
    obj.continuous_color_colormap=pa_LCH2RGB([linspace(p.Results.LCH_colormap(1,1),p.Results.LCH_colormap(1,2),256)'...
        linspace(p.Results.LCH_colormap(2,1),p.Results.LCH_colormap(2,2),256)'...
        linspace(p.Results.LCH_colormap(3,1),p.Results.LCH_colormap(3,2),256)']);
end


end