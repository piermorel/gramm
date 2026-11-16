function obj=set_color_options(obj,varargin)
% set_color_options Set the colormaps of color and lightness groups, and their legends
%
% Example syntax (default arguments): gramm_object.set_color_options('map','lch','legend','separate_gray')
% Data can be grouped both by color (hue) and by lightness (light to dark
% shades of each color): the colormap then needs several lightness levels
% per color. The default 'lch' colormap is generated for the number of
% groups, with as many colors and lightness levels as needed. The other
% colormaps have a fixed number of colors and lightness levels, and give an
% error when there are more groups.
%
% Parameters given as 'name',value pairs:
% - 'map': Colormap (default 'lch'):
%       - 'lch': colormap generated in the perceptually uniform LCH color
%            space, supports lightness. Tuned with the 'lightness_range',
%            'chroma_range', 'hue_range', 'lightness' and 'chroma' options
%       - 'matlab': MATLAB's own post 2014b colormap, no lightness
%       - 'brewer1': colorbrewer2.org colormap, no lightness. Also
%            'brewer2', 'brewer3', 'brewer_pastel' and 'brewer_dark'
%       - 'brewer_paired': colorbrewer2.org colormap, 5 colors with 2
%            lightness levels each
%       - 'd3_10': d3.js categorical colormap, 10 colors, no lightness
%       - 'd3_20': d3.js colormap, 10 colors with 2 lightness levels each
%       - 'd3_20b': d3.js colormap, 5 colors with 4 lightness levels each.
%            Also 'd3_20c'
%       - [r g b ; ...]: custom colormap, one RGB row per color/lightness
%            combination, the lightness levels of each color one after the
%            other: color 1 lightness 1, color 1 lightness 2, ..., color 2
%            lightness 1... For instance [1 0 0 ; 1 0.6 0.6 ; 0 0 1 ;
%            0.6 0.6 1] has 2 colors (red and blue) with 2 lightness levels
%            each. Give the numbers of colors and lightness levels with
%            'n_color' and 'n_lightness'
% - 'n_color': Number of colors of a custom colormap (default [])
% - 'n_lightness': Number of lightness levels of a custom colormap. If
%            'n_color' or 'n_lightness' is not given, each row of the
%            custom colormap is a color without lightness levels
%            (default [])
% - 'legend': How colors and lightness levels are shown in legends
%            (default 'separate_gray'):
%       - 'separate_gray': separate color and lightness legends, lightness
%            shown in shades of gray (default for 'lch')
%       - 'separate': separate color and lightness legends, lightness shown
%            in shades of the first color (default for other colormaps)
%       - 'expand': a single legend with all color/lightness combinations
%       - 'merge': color legend merged with the marker/line/size legends
%            when they have the same categories
% - 'lightness_range': For 'lch' with lightness groups: lightness (0-100)
%            of the first and last lightness levels (default [85 15],
%            light to dark)
% - 'chroma_range': For 'lch' with lightness groups: chroma (0-100, the
%            intensity of the color) of the first and last lightness
%            levels. Light colors have a low chroma so that they stay
%            displayable on screens (sRGB) (default [30 90], weak to deep
%            colors)
% - 'hue_range': For 'lch': hues (0-360) of the first and last colors,
%            the others being evenly spaced in between (default [25 385],
%            red to blue)
% - 'lightness': For 'lch' without lightness groups: lightness (0-100) of
%            all colors (default 65)
% - 'chroma': For 'lch' without lightness groups: chroma (0-100) of all
%            colors (default 75)



p=inputParser;
% matlab, brewer1,brewer2,brewer3,brewer_pastel,brewer_dark, brewer_paired, d3_10, d3_20, d3_20b, d3_20c
addParameter(p,'map','lch'); 
addParameter(p,'lightness_range',[85 15]);
addParameter(p,'chroma_range',[30 90]);
addParameter(p,'hue_range',[25 385]);
addParameter(p,'lightness',65);
addParameter(p,'chroma',75);
addParameter(p,'legend','separate_gray'); % 'separate' 'merge' , 'expand' 'grid'
addParameter(p,'n_color',[]);
addParameter(p,'n_lightness',[]);
parse(p,varargin{:});

for obj_ind=1:numel(obj)
    obj(obj_ind).color_options=p.Results;
end
end