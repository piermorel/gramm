function obj = export(obj, varargin)
% export Export gramm plot to vector or bitmap image
%
% Example syntax: gramm_object.export('file_name','my_figure','export_path','./test/','file_type','pdf')
% export() must be called after a draw() call and will save the plot to
% file using the specified 'name',value options:
% - 'file_name' Desired name for the file. Extension will be added
%   according to 'file_type'
% - 'export_path' Path of the destination folder (absolute or relative). 
    %By default the file is saved in the current folder 
% - 'file_type': supports 'svg','pdf' and 'eps' for vector output, and
%   'png' and 'jpg' for high-resolution bitmap output. The default is 'svg'.
% - 'width' and 'height' allow to set the desired size of the exported
%   figure. By default (recommended), the exported figure will look the same as the on-screen
%   plot. Setting this manually is tricky.
% - 'units' allows to set the units used for the 'width' and 'height'
%   input. Supports 'centimeters' and 'inches'. Default is 'centimeters'.
% - 'resolution' set the resolution in dpi with an integer. Use 0 for
% screen resolution

% Retrieve figure handle (all are the same so only the first is ok)
h_fig = obj(1).parent;

% calculating defaults
fig_pos = getpixelposition(h_fig);
%Resolution in pixels per cm (note: not the actual resolution, Matlab doesn't
%know about real screen size).
resolution = get(0, 'ScreenPixelsPerInch')/2.54;
width_fig = fig_pos(3)/resolution;
height_fig = fig_pos(4)/resolution;

% parse arguments and set defaults
p=inputParser;
my_addParameter(p,'file_name','gramm_export');
my_addParameter(p,'export_path','');
my_addParameter(p,'file_type', 'svg');
my_addParameter(p,'width', width_fig);
my_addParameter(p,'height', height_fig);
my_addParameter(p,'units', 'centimeters');
my_addParameter(p,'resolution', 0);
parse(p,varargin{:});

% Turn off warning due to a custom defined figure resize function called on save
warning('off', 'MATLAB:print:CustomResizeFcnInPrint');

%Verify that the path is correct
if ~isempty(p.Results.export_path) && ~exist(p.Results.export_path,'dir')
    error('The specified folder does not exist')
end

% Building variables from (default) input data
file_path = fullfile(p.Results.export_path, p.Results.file_name);
width = p.Results.width;
height = p.Results.height;


% Verify that parent object is a figure object
if ~isa(h_fig, 'matlab.ui.Figure')
    error('Parent gramm object is not a matlab.ui.Figure.');
end


% In case units are inches, we rescale to cm
if strcmp(p.Results.units, 'inches')
	if ~any(strcmp(p.UsingDefaults, 'width'))
		width = p.Results.width * 2.54;
	end

	if ~any(strcmp(p.UsingDefaults, 'height'))
		height = p.Results.height * 2.54;
	end
end

% Lay the figure out at the export size so that what gramm scales itself
% (legend spacing, stat_cornerhist() insets) is correct in the file: print()
% resizes the figure to the paper size without calling SizeChangedFcn
old_units = h_fig.Units;
old_position = h_fig.Position;
set(h_fig, 'Units', 'centimeters');
if any(abs(h_fig.Position(3:4) - [width height]) > 0.01)
    h_fig.Position(3:4) = [width height];
    drawnow;
    redraw(obj);
    restore = onCleanup(@()restore_figure(obj, h_fig, old_position, old_units));
else
    restore = onCleanup(@()set(h_fig, 'Units', old_units));
end

% Cropping paper to fit the figure
set(h_fig, 'PaperUnits', 'centimeters');
set(h_fig, 'PaperSize', [width, height]);
set(h_fig, 'PaperPosition', [0, 0, width, height]);

% Save figure in preferred file type
switch p.Results.file_type
	case 'pdf'
		print(h_fig, file_path, '-dpdf', '-vector');
	
	case 'eps'
		print(h_fig, file_path, '-depsc', '-vector', ['-r' num2str(p.Results.resolution)]);

	case 'svg'
		print(h_fig, file_path, '-dsvg', '-vector');
		
	case 'png'
		print(h_fig, file_path, '-dpng', '-image', ['-r' num2str(p.Results.resolution)]);

	case 'jpg'
		warning('JPEG is not recommanded for saving figures. Use PDF or SVG whenever possible');
		print(h_fig, file_path, '-djpeg', '-image', ['-r' num2str(p.Results.resolution)]);
		
	otherwise
		error('Argument file_type not recognized. Available options are: pdf, eps, svg, png, jpg.')
end
	
% Turn warning back on
warning('on', 'MATLAB:print:CustomResizeFcnInPrint');

end

function restore_figure(obj, h_fig, old_position, old_units)
% Give the figure back its on-screen size and units after export
if isvalid(h_fig)
    set(h_fig, 'Units', old_units);
    h_fig.Position = old_position;
    drawnow;
    redraw(obj);
end
end
