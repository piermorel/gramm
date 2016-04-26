function obj=set_color_options(obj,varargin)
% set_color_options() Set options used to generate colormaps
%
% Parameters:
% 'map': Set custom colormap. Available colormaps are 'lch'
% (default, supports lightness), 'matlab' (post-2014b default
% colormap), 'brewer1', 'brewer2', 'brewer3', 'brewer_pastel',
%'brewer_dark' for the corresponding brewer colormaps from
% colorbrewer2.org. It is also possible to provide a custom
% colormap by providing a N-by-3 matrix (columns are R,G,B).
%
% The other options allow to sepecify color generation
% parameters for the default 'lch' colormap:
%
% 'lightness_range': 2-element vector indicating the range of
% lightness values (0-100) used when generating plots with
% lightness variations. Default is [85 15] (light to dark)
%
% 'chroma_range': 2-element vector indicating the range of
% chroma values (0-100) used when generating plots with
% lightness variations (chroma is the intensity of the color).
% Default is [30 90] (weak color to deeper color)
%
% 'hue_range': 2-element vector indicating the range of
% hue values (0-360) used when generating color plots. Default is
% [25 385] (red to blue).
%
% 'lightness': Lightness used when generating plots without
% lightness variations. Default is 60
%
% 'chroma': Chroma used when generating plots without chroma
% variations. Default is 70

p=inputParser;
my_addParameter(p,'map','lch'); %matlab, brewer1,brewer2,brewer3,brewer_pastel,brewer_dark
my_addParameter(p,'lightness_range',[85 15]);
my_addParameter(p,'chroma_range',[30 90]);
my_addParameter(p,'hue_range',[25 385]);
my_addParameter(p,'lightness',65);
my_addParameter(p,'chroma',75);
parse(p,varargin{:});

for obj_ind=1:numel(obj)
    obj(obj_ind).color_options=p.Results;
end
end