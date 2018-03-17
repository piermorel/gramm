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
%   'png' and 'jpg' for high-resolution bitmap output. The default is 'svg' on 2014b+ Matlab
%   versions, and 'pdf' on older versions.
% - 'width' and 'height' allow to set the desired size of the exported
%   figure. By default (recommended), the exported figure will look the same as the on-screen
%   plot. Setting this manually is tricky.
% - 'units' allows to set the units used for the 'width' and 'height'
%   input. Supports 'centimeters' and 'inches'. Default is 'centimeters'.

% Retrieve figure handle (all are the same so only the first is ok)
h_fig = obj(1).parent;

% calculating defaults
fig_pos = getpixelposition(h_fig);
%Resolution in pixels per cm (note: not the actual resolution, Matlab doesn't
%know about real screen size).
resolution = get(0, 'ScreenPixelsPerInch')/2.54;
width_fig = fig_pos(3)/resolution;
height_fig = fig_pos(4)/resolution;

%SVG is unsupported on older Matlab versions
if obj(1).handle_graphics
    default_file_type='svg';
else
    default_file_type='pdf';
end

% parse arguments and set defaults
p=inputParser;
my_addParameter(p,'file_name','gramm_export');
my_addParameter(p,'export_path','');
my_addParameter(p,'file_type', default_file_type);
my_addParameter(p,'width', width_fig);
my_addParameter(p,'height', height_fig);
my_addParameter(p,'units', 'centimeters');
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
if obj(1).handle_graphics
    if ~isa(h_fig, 'matlab.ui.Figure')
        error('Parent gramm object is not a matlab.ui.Figure.');
    end
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

% Cropping paper to fit the figure
set(h_fig, 'Units', 'centimeters');
set(h_fig, 'PaperUnits', 'centimeters');
set(h_fig, 'PaperSize', [width, height]);
set(h_fig, 'PaperPosition', [0, 0, width, height]);

% Save figure in preferred file type
switch p.Results.file_type
	case 'pdf'
		print(h_fig, file_path, '-dpdf', '-painters');
	
	case 'eps'
		print(h_fig, file_path, '-depsc', '-painters', '-r300');

	case 'svg'
		print(h_fig, file_path, '-dsvg', '-painters');
		
	case 'png'
		print(h_fig, file_path, '-dpng', '-opengl', '-r300');

	case 'jpg'
		warning('JPEG is not recommanded for saving figures. Use PDF or SVG whenever possible');
		print(h_fig, file_path, '-djpeg', '-opengl', '-r300');
		
	otherwise
		error('Argument file_type not recognized. Available options are: pdf, eps, svg, png, jpg.')
end
	
% Turn warning back on
warning('on', 'MATLAB:print:CustomResizeFcnInPrint');

end
