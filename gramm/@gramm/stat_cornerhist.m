function obj=stat_cornerhist(obj,varargin)


p=inputParser;
my_addParameter(p,'nbins',30);
my_addParameter(p,'edges',[]);
my_addParameter(p,'geom','overlaid_bar'); %line, bar, overlaid_bar, stacked_bar,stairs, point
my_addParameter(p,'normalization','count');
my_addParameter(p,'fill',[]); %edge,face,all,transparent
my_addParameter(p,'width',[]);
my_addParameter(p,'dodge',[]);
my_addParameter(p,'aspect',0.3); %Aspect ratio of the inset axis
my_addParameter(p,'location',[]); %X/Y location in the main axis of the inset axis
parse(p,varargin{:});

if isempty(p.Results.edges)
    warning('Specifying ''edges'' is recommended with stat_cornerhist()')
end

if strcmp('geom','stacked_bar')
    error('stacked_bar unsupported in stat_cornerhist()')
end
    
obj.geom=vertcat(obj.geom,{@(dobj,dd)my_cornerhist(dobj,dd,p.Results)});
obj.results.stat_cornerhist={};
end


function hndl=my_cornerhist(obj,draw_data,params)

%If this is the first call ever, we initialize an array of handles for the
%child axes
if isempty(obj.results.stat_cornerhist)
    if obj.is_flipped
        warning('coord_flip() breaks stat_cornerhist()');
    end
    if obj.handle_graphics
         obj.extra.cornerhist_child_axe=gobjects(size(obj.facet_axes_handles,1),size(obj.facet_axes_handles,2));
    else
         obj.extra.cornerhist_child_axe=zeros(size(obj.facet_axes_handles,1),size(obj.facet_axes_handles,2));
    end
end

%Get parent axis
parent_axe=obj.facet_axes_handles(obj.current_row,obj.current_column);
parent_axe_pos=get(parent_axe,'Position');
set(parent_axe,'color','none')

%Compute default location of the child axis if needed
if isempty(params.location)
    params.location=max(obj.var_lim.maxx,obj.var_lim.maxy);
end

new_child=false;
%Create child axis if necessary
if (obj.handle_graphics &&...
        isa(obj.extra.cornerhist_child_axe(obj.current_row,obj.current_column),'matlab.graphics.GraphicsPlaceholder'))...
    || (obj.extra.cornerhist_child_axe(obj.current_row,obj.current_column)==0)


    %If first run, create inset axis(weird, if cha is not used as intermediary
    %variable, the resize callback doesn't seem to work properly)
    cha=axes('Position',[parent_axe_pos(1) parent_axe_pos(2) parent_axe_pos(3) parent_axe_pos(4)],...
         'Clipping','off','NextPlot','add');
    
    obj.extra.cornerhist_child_axe(obj.current_row,obj.current_column)=cha;
    

    
    % Add callback for child axis update that will be called by redraw() on figure resize
    obj.redraw_fun=vertcat(obj.redraw_fun,{@()cornerhist_redraw(parent_axe,cha,params.location,params.aspect)});
    
    %Set properties
    set(cha,'color','none','Units','Pixels');
    if obj.handle_graphics
        set(cha,'Ycolor','none','Box','off');
    else
        %No 'none' value possible for older matlabs
        set(cha,'Ycolor',[1 1 1],'Box','off');
    end
    
   new_child=true;
else
    %If inset already created, just make it active axis
   axes(obj.extra.cornerhist_child_axe(obj.current_row,obj.current_column)); 
end

%Draw data is x-y
draw_data.x=draw_data.x-draw_data.y;

%Compute edges here (my_histplot automatic edge computation is based on x
%only)
if isempty(params.edges)
     params.edges=linspace(min(draw_data.x),max(draw_data.x),params.nbins+1);
end

%Draw histogram with my_histplot() (common with stat_bin)
obj.results.stat_cornerhist{obj.result_ind,1}=my_histplot(obj,draw_data,params,false);
obj.results.stat_cornerhist{obj.result_ind,1}.child_axe_handle=obj.extra.cornerhist_child_axe(obj.current_row,obj.current_column);

%Compute limits of child axis
temp_xlim=[min(params.edges) max(params.edges)];
if temp_xlim(1)==temp_xlim(2) %Correct limit values when nothing is plotted
    temp_xlim=[temp_xlim(1)-0.01 temp_xlim(2)+0.01];
end

%Set limits of child axis
set(obj.extra.cornerhist_child_axe(obj.current_row,obj.current_column),'XLim',temp_xlim);

if new_child
    %Change limits of parent axis
    if min(params.edges)<0
        obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(obj.plot_lim.maxy(obj.current_row,obj.current_column),...
            params.location+sqrt(0.6*min(params.edges).^2));
    end
    if max(params.edges)>0
        obj.plot_lim.maxx(obj.current_row,obj.current_column)=max(obj.plot_lim.maxx(obj.current_row,obj.current_column),...
            params.location+sqrt(0.6*max(params.edges).^2));
    end  
end

axes(parent_axe);


end

function cornerhist_redraw(parent_axe,child_axe,x_pos,aspect_ratio)


%Get info about updated parent axis
set(parent_axe,'Units','Pixels')
%pa_pos=get(parent_axe,'Position');
pa_pos=plotboxpos(parent_axe);
pa_xlim=get(parent_axe,'XLim');
pa_ylim=get(parent_axe,'YLim');

%Get info about child axis
ch_xlim=get(child_axe,'XLim');
ch_ylim=get(child_axe,'YLim');
c_tar=get(child_axe,'CameraTarget');
c_pos=get(child_axe,'CameraPosition');


%Compute the desired location at x=x_pos on the unity line in the main axis in (pixel) figure coordinates
pa_loc(1)=pa_pos(1)+(x_pos-pa_xlim(1))*pa_pos(3)/diff(pa_xlim);
pa_loc(2)=pa_pos(2)+(x_pos-pa_ylim(1))*pa_pos(4)/diff(pa_ylim);

% We want to center data point (0,0) of the child axe on the computed
% location
ch_origin=[0 0];

% Compute the absolute angle (using pixels) of the unity line in the main
% axis of the figure
angle=atan2(pa_pos(4)/diff(pa_ylim),pa_pos(3)/diff(pa_xlim));


%Projection of (0,1) from parent axis in pixel coordinates on the line
%perpendicular to the unity line is our x scale for the child axe
new_w=diff(ch_xlim)*cos(angle)*pa_pos(4)/diff(pa_ylim);


%Compute new child axis position
ch_newpos=zeros(1,4);

%Set size according to computed x length and plot box aspect ratio
ch_newpos(3)=new_w;
ch_newpos(4)=new_w*aspect_ratio;

%Positions are chosen position in pixels + origin offset compensation (relative to
%bottom left edge) + camera target offset compensation (relative to center)
ch_newpos(1)=pa_loc(1)-(ch_origin(1)-ch_xlim(1))*ch_newpos(3)/diff(ch_xlim)+(ch_origin(1)-mean(ch_xlim))*ch_newpos(3)/diff(ch_xlim);
ch_newpos(2)=pa_loc(2)-(ch_origin(2)-ch_ylim(1))*ch_newpos(4)/diff(ch_ylim)+(ch_origin(2)-mean(ch_ylim))*ch_newpos(4)/diff(ch_ylim);


%Camera view angle is often reported/set incorrectly by Matlab (bug reported).
%Computing it here to work around the issue
dir_len=norm(c_tar-c_pos); %Distance between camera and axes
c_va=2*atand(1/2*diff(ch_ylim)/dir_len); %Angle is the vertical angle

%Compute data aspect ratio
dar=[diff(ch_xlim)/(diff(ch_ylim)/aspect_ratio) 1 1];

%Update child axis properties
set(child_axe,'Position',ch_newpos,...
    'CameraPosition',[ch_origin(1) ch_origin(2) c_pos(3)],...
    'CameraTarget',[ch_origin(1) ch_origin(2) c_tar(3)],...
    'CameraUpVector',[sin(angle-pi/2)*dar(1) cos(angle-pi/2)*dar(2) 0],...
    'Xlim',ch_xlim,'Ylim',ch_ylim,...
    'CameraViewAngle',c_va,...
    'DataAspectRatio',dar,...
    'PlotBoxAspectRatio',[1/aspect_ratio 1 1]);

%Set parent axes back in normalized coordinates
set(parent_axe,'Units','Normalized')

end

function pos = plotboxpos(h)
%PLOTBOXPOS Returns the position of the plotted axis region
%
% pos = plotboxpos(h)
%
% This function returns the position of the plotted region of an axis,
% which may differ from the actual axis position, depending on the axis
% limits, data aspect ratio, and plot box aspect ratio.  The position is
% returned in the same units as the those used to define the axis itself.
% This function can only be used for a 2D plot.  
%
% Input variables:
%
%   h:      axis handle of a 2D axis (if ommitted, current axis is used).
%
% Output variables:
%
%   pos:    four-element position vector, in same units as h

% Copyright 2010 Kelly Kearney

% Check input

if nargin < 1
    h = gca;
end

if ~ishandle(h) || ~strcmp(get(h,'type'), 'axes')
    error('Input must be an axis handle');
end

% Get position of axis in pixels

currunit = get(h, 'units');
set(h, 'units', 'pixels');
axisPos = get(h, 'Position');
set(h, 'Units', currunit);

% Calculate box position based axis limits and aspect ratios

darismanual  = strcmpi(get(h, 'DataAspectRatioMode'),    'manual');
pbarismanual = strcmpi(get(h, 'PlotBoxAspectRatioMode'), 'manual');

if ~darismanual && ~pbarismanual
    
    pos = axisPos;
    
else

    dx = diff(get(h, 'XLim'));
    dy = diff(get(h, 'YLim'));
    dar = get(h, 'DataAspectRatio');
    pbar = get(h, 'PlotBoxAspectRatio');

    limDarRatio = (dx/dar(1))/(dy/dar(2));
    pbarRatio = pbar(1)/pbar(2);
    axisRatio = axisPos(3)/axisPos(4);

    if darismanual
        if limDarRatio > axisRatio
            pos(1) = axisPos(1);
            pos(3) = axisPos(3);
            pos(4) = axisPos(3)/limDarRatio;
            pos(2) = (axisPos(4) - pos(4))/2 + axisPos(2);
        else
            pos(2) = axisPos(2);
            pos(4) = axisPos(4);
            pos(3) = axisPos(4) * limDarRatio;
            pos(1) = (axisPos(3) - pos(3))/2 + axisPos(1);
        end
    elseif pbarismanual
        if pbarRatio > axisRatio
            pos(1) = axisPos(1);
            pos(3) = axisPos(3);
            pos(4) = axisPos(3)/pbarRatio;
            pos(2) = (axisPos(4) - pos(4))/2 + axisPos(2);
        else
            pos(2) = axisPos(2);
            pos(4) = axisPos(4);
            pos(3) = axisPos(4) * pbarRatio;
            pos(1) = (axisPos(3) - pos(3))/2 + axisPos(1);
        end
    end
end

% Convert plot box position to the units used by the axis

temp = axes('Units', 'Pixels', 'Position', pos, 'Visible', 'off', 'parent', get(h, 'parent'));
set(temp, 'Units', currunit);
pos = get(temp, 'position');
delete(temp);
end