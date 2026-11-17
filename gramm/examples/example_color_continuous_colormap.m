%% Continuous colormap
% <matlab:edit('example_color_continuous_colormap.m') Open this example in the editor> - <index.html All gramm examples> - <../gramm_cheat_sheet.html#set_continuous_color set_continuous_color() in the cheat sheet>
%
% We start by loading the sample data (structure created from the carbig
% dataset)
%%
load example_data;

%% Using a continuous color scale
% By default, gramm uses a categorical color scale, with one group per
% color value. With set_continuous_color(), numeric color values are shown
% with a gradient-based continuous color scale: each point gets the color
% of its value, and lines can be colored along their length.

load example_spectra.mat

%Here we create x as a 1xN array (see example above), and use a MxN matrix
%for y. Color applies to the M rows of y.
g18=gramm('x',900:2:1700,'y',NIR,'color',octane);
g18.set_names('x','Wavelength (nm)','y','NIR','color','Octane');
g18.set_continuous_color('colormap','hot');
g18.geom_line;
figure('Position',[100 100 1100 450]);
g18.draw();