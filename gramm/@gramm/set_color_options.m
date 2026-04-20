function obj=set_color_options(obj,varargin)
% set_color_options() Set options used to generate colormaps and color
% legends
%
% Parameters:
% 'map': Set custom colormap. Available colormaps are:
%     - 'lch' : default, supports lightness
%     - 'matlab' : post-2014b default colormap (no lightness support)
%     - 'brewer1', 'brewer2', 'brewer3', 'brewer_pastel', 'brewer_dark' :
%          brewer colormaps from colorbrewer2.org (no ligthness support)
%     - 'brewer_paired' : brewer colormap that supports two lightness levels
%     - 'd3_10' : standard d3.js categorical colormap (no lightness support)
%     - 'd3_20' : d3.js categorical colormap with two lightness levels
%     - 'd3_20b', 'd3_20c' : d3.js categorical colormap with four lightness levels
% It is also possible to provide a custom
% colormap by providing a N-by-3 matrix (columns are R,G,B), with N
% corresponding to n_color categories times n_lightness categories (see
% below). Row ordering should be color#1/lightness#1 ; color#1/lightness#2 ;
% ... ; color#1/lightness#n ; color#2/lightness#1 ; ... ; color#n/lightness#n
%
% 'n_color' number of color categories when using a custom colormap
% 'n_lightness' number of lightness categories when using a custom colormap
%
% 'legend': How are color and lightness handled in legends
%       - 'separate_gray' : default for LCH colormap, shows colors and
%                           lightness in separate legends, lightness is
%                           displayed in a gray scale
%       - 'separate'      : default for other colormaps, shows colors and
%                           ligtness in separate legends, lightness is
%                           displayed using the first color
%       - 'expand'        : displays all color/lightness combinations
%       - 'merge'         : merge color legends with marker/line/size 
%                           legends if the categoriesare the same
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
% By default there is a low chroma for light colors in order to stay in a
% displayable color range (sRGB).
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
% matlab, brewer1,brewer2,brewer3,brewer_pastel,brewer_dark, brewer_paired, d3_10, d3_20, d3_20b, d3_20c
my_addParameter(p,'map','lch'); 
my_addParameter(p,'lightness_range',[85 15]);
my_addParameter(p,'chroma_range',[30 90]);
my_addParameter(p,'hue_range',[25 385]);
my_addParameter(p,'lightness',65);
my_addParameter(p,'chroma',75);
my_addParameter(p,'legend','separate_gray'); % 'separate' 'merge' , 'expand' 'grid'
my_addParameter(p,'n_color',[]);
my_addParameter(p,'n_lightness',[]);
parse(p,varargin{:});

for obj_ind=1:numel(obj)
    obj(obj_ind).color_options=p.Results;
end
end