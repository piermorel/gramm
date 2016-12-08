function obj = save_plot(obj, varargin)
% save Saves image created for further use
%
% this will create an image of the created plot

% Retrieve figure handle (all are the same so only the first is ok)
h_fig = obj(1).parent;

% calculating defaults
fig_pos = getpixelposition(h_fig);
resolution = get(0, 'ScreenPixelsPerInch');
width_fig = fig_pos(3)/resolution;
height_fig = fig_pos(4)/resolution;

% parse arguments and set defaults
p=inputParser;
my_addParameter(p,'file_name','gramm_graphics');
my_addParameter(p,'target_dir', '');
my_addParameter(p,'file_type', 'pdf');
my_addParameter(p,'width', width_fig);
my_addParameter(p,'height', height_fig);
parse(p,varargin{:});

% Turn off warning due to a custom defined figure resize function called on save
warning('off', 'MATLAB:print:CustomResizeFcnInPrint');

% building full filename
file_path = fullfile(p.Results.target_dir, p.Results.file_name);

% Verify that parent object is a figure object
if ~isa(h_fig, 'matlab.ui.Figure')
	error('Parent gramm object is not a matlab.ui.Figure.')
end

% Cropping paper to fit the figure
set(h_fig, 'Units', 'inches');
set(h_fig, 'PaperUnits', 'inches');
set(h_fig, 'PaperSize', [p.Results.width, p.Results.height]);
set(h_fig, 'PaperPosition', [0, 0, p.Results.width, p.Results.height]);

% Save figure in preferred file type
switch p.Results.file_type
	case 'pdf'
		print(h_fig, file_path, '-dpdf', '-painters', '-r300');
	
	case 'eps'
		print(h_fig, file_path, '-depsc', '-opengl', '-r300');

	case 'svg'
		print(h_fig, file_path, '-dsvg', '-painters', '-r300');
		
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
