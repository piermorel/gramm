function obj = save_plot(obj, varargin)
% save Saves image created for further use
%
% this will create an image of the created plot

p=inputParser;
my_addParameter(p,'file_name','gramm_graphics');
my_addParameter(p,'target_dir', '');
my_addParameter(p,'file_type', 'pdf');
my_addParameter(p,'width', 8);
my_addParameter(p,'height', 5);
parse(p,varargin{:});

% Turn off warning due to a custom defined figure resize function called on save
warning('off', 'MATLAB:print:CustomResizeFcnInPrint');

% building full filename
file_path = fullfile(p.Results.target_dir, p.Results.file_name);

% Retrieve figure handle (all are the same so only the first is ok)
h_fig = obj(1).parent;

% Verify that parent object is a figure object
if ~isa(h_fig, 'matlab.ui.Figure')
	error('Parent gramm object is not a matlab.ui.Figure.')
end

% Save figure in preferred file type
switch p.Results.file_type
	case 'pdf'
		% Cropping paper to fit the figure
		h_fig.Units = 'centimeters';
		h_fig.PaperPosition = [0,0,p.Results.width, p.Results.height]; 
		h_fig.PaperSize = [p.Results.width, p.Results.height];

		print(h_fig, file_path, '-dpdf', '-painters');
	
	case 'eps'
		print(h_fig, file_path, '-depsc', '-painters')

	case 'png'
		print(h_fig, file_path, '-dpng', '-opengl');

	case 'jpg'
		warning('JPEG is not recommanded for saving figures. Use PDF whenever possible');
		print(h_fig, file_path, '-djpeg', '-opengl')
	
end
	
% Turn warning back on
warning('on', 'MATLAB:print:CustomResizeFcnInPrint');

end
