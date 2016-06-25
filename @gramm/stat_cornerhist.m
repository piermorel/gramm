function obj=stat_cornerhist(obj,varargin)


p=inputParser;
my_addParameter(p,'nbins',30);
my_addParameter(p,'edges',[]);
my_addParameter(p,'geom','bar'); %line, bar, overlaid_bar, stacked_bar,stairs, point
my_addParameter(p,'normalization','count');
my_addParameter(p,'fill',[]); %edge,face,all,transparent
my_addParameter(p,'width',[]);
my_addParameter(p,'dodge',[]);
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dd)my_cornerhist(obj,dd,p.Results)});
obj.results.stat_cornerhist={};
end


function hndl=my_cornerhist(obj,draw_data,params)

%If this is the first call ever, we initialize an array of handles
if isempty(obj.results.stat_cornerhist)
    disp('Corner axes array initialized')
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

new_child=false;
%Create child axis if necessary
if (obj.handle_graphics &&...
        isa(obj.extra.cornerhist_child_axe(obj.current_row,obj.current_column),'matlab.graphics.GraphicsPlaceholder'))...
    || (obj.extra.cornerhist_child_axe(obj.current_row,obj.current_column)==0)


    %If first run, create inset (weird, if cha is not used as intermediary
    %variable, the resize callback doesn't seem to work properly)
    cha=axes('Position',[parent_axe_pos(1) parent_axe_pos(2) parent_axe_pos(3) parent_axe_pos(4)],...
         'Clipping','off');
    
    obj.extra.cornerhist_child_axe(obj.current_row,obj.current_column)=cha;
    
    child_x=max(obj.var_lim.maxx,obj.var_lim.maxy);
    
    % Add callback to that will be called by redraw() on figure resize
    obj.redraw_fun=vertcat(obj.redraw_fun,{@()cornerhist_redraw(parent_axe,cha,child_x)});
    
    %Set properties
    set(cha,'color','none');
    if obj.handle_graphics
        set(cha,'Ycolor','none');
    else
        %No 'none' value possible for older matlabs
        set(cha,'Ycolor',[1 1 1]);
    end
    
   new_child=true;
else
    %If inset already created, just make it active axis
   axes(obj.extra.cornerhist_child_axe(obj.current_row,obj.current_column)); 
end



%Presets for dodge parameter
if isempty(params.dodge)
    if strcmp(params.geom,'bar') && draw_data.n_colors>1  %With 'bar' do we dodge by default if there are several colors
        params.dodge=0.8;
    else
        params.dodge=0; %With all others we put don't dodge
    end
end

%Presets for width parameter
if isempty(params.width)
    if params.dodge>0
        params.width=params.dodge; %If there is a dodge we modify the width accordingly
    else
        params.width=1; %Otherwise we use the full with (histogram).
    end
end


%Set up default fill options for the different geoms
if isempty(params.fill)
    switch params.geom
        case 'bar'
            params.fill='face';
        case 'line'
            params.fill='edge';
        case 'overlaid_bar'
            params.fill='transparent';
        case 'stacked_bar'
            params.fill='face';
        case 'stairs'
            params.fill='edge';
        case 'point'
            params.fill='edge';
    end
end

%Draw data is x-y
draw_data.x=draw_data.x-draw_data.y;

%Compute bins
if isempty(params.edges)
    binranges=linspace(min(draw_data.x),max(draw_data.x),params.nbins+1);
else
    binranges=params.edges;
end

bincenters=(binranges(1:(end-1))+binranges(2:end))/2;


%Find actual counts
if iscell(draw_data.x) %If data was provided as Cell/Matrix
    %We do the count individually for each element and average
    %the counts
    bincounts=zeros(1,length(binranges)-1);
    for k=1:length(draw_data.x)
        bincounts=bincounts+my_histcounts(draw_data.x{k},binranges,params.normalization);
    end
    bincounts=bincounts/length(draw_data.x);
else
    %If data was provided as vector we just count
    bincounts = my_histcounts(comb(draw_data.x),binranges,params.normalization);
end

bincounts=shiftdim(bincounts);

obj.results.stat_cornerhist{obj.result_ind,1}.edges=bincenters;
obj.results.stat_cornerhist{obj.result_ind,1}.counts=bincounts;


%Set up colors according to fill
[face_color , face_alpha , edge_color , edge_alpha] = parse_fill (params.fill,draw_data.color);



%Set up dodging & width for bars
avl_w=diff(binranges);
dodging=avl_w.*params.dodge./(draw_data.n_colors);
if params.dodge>0
    bar_width=avl_w.*params.width./(draw_data.n_colors);
else
    bar_width=avl_w.*params.width;
end
bar_mid=bincenters-0.5*dodging*draw_data.n_colors+dodging*0.5+(draw_data.color_index-1)*dodging;
bar_left=bar_mid-0.5*bar_width;
bar_right=bar_mid+0.5*bar_width;


spacing=1-params.width;

%overlaid_bar is just a bar without dodging
if strcmp(params.geom,'overlaid_bar')
    params.geom='bar';
end

switch params.geom
    case 'bar'
        xpatch=[bar_right ; bar_left ; bar_left ; bar_right];
        ypatch=[zeros(1,length(bincounts)) ; zeros(1,length(bincounts)) ; bincounts' ; bincounts'];
        [xpatch,ypatch]=to_polar(obj,xpatch,ypatch);
        obj.results.stat_cornerhist{obj.result_ind,1}.bar_handle=patch(xpatch,...
            ypatch,...
            [1 1 1],'FaceColor',face_color,'EdgeColor',edge_color,'FaceAlpha',face_alpha,'EdgeAlpha',edge_alpha);
        
    case 'line'
        xtemp=bar_mid;
        ytemp=bincounts(1:end)';
        [xtemp,ytemp]=to_polar(obj,xtemp,ytemp);
        obj.results.stat_cornerhist{obj.result_ind,1}.line_handle=plot(xtemp,ytemp,'LineStyle',draw_data.line_style,'Color',edge_color,'lineWidth',draw_data.size/4);
        xpatch=[bar_mid(1:end-1) ; bar_mid(2:end) ; bar_mid(2:end);bar_mid(1:end-1)];
        ypatch=[zeros(1,length(bincounts)-1) ; zeros(1,length(bincounts)-1) ; bincounts(2:end)' ; bincounts(1:end-1)'];
        [xpatch,ypatch]=to_polar(obj,xpatch,ypatch);
        obj.results.stat_cornerhist{obj.result_ind,1}.fill_handle=patch(xpatch,ypatch,[1 1 1],'FaceColor',face_color,'EdgeColor','none','FaceAlpha',face_alpha);
        
    case 'stacked_bar'
        xpatch=[binranges(1:end-1)+spacing ; binranges(2:end)-spacing ; binranges(2:end)-spacing ; binranges(1:end-1)+spacing];
        ypatch=[obj.extra.stacked_bar_height ; obj.extra.stacked_bar_height ; obj.extra.stacked_bar_height+bincounts' ; obj.extra.stacked_bar_height+bincounts'];
        [xpatch,ypatch]=to_polar(obj,xpatch,ypatch);
        obj.results.stat_cornerhist{obj.result_ind,1}.bar_handle=patch(xpatch,...
            ypatch,...
            [1 1 1],'FaceColor',face_color,'EdgeColor',edge_color,'FaceAlpha',face_alpha,'EdgeAlpha',edge_alpha);
        obj.extra.stacked_bar_height=obj.extra.stacked_bar_height+bincounts';
    case 'stairs'
        xtemp=[binranges(1:end-1) ; binranges(2:end)];
        ytemp=[bincounts' ; bincounts'];
        [xtemp,ytemp]=to_polar(obj,xtemp(:),ytemp(:));
        obj.results.stat_cornerhist{obj.result_ind,1}.line_handle=plot(xtemp,ytemp,'LineStyle',draw_data.line_style,'Color',edge_color,'lineWidth',draw_data.size/4);
        
        xpatch=[binranges(1:end-1) ; binranges(2:end) ; binranges(2:end) ; binranges(1:end-1)];
        ypatch=[obj.extra.stacked_bar_height ; obj.extra.stacked_bar_height ; obj.extra.stacked_bar_height+bincounts' ; obj.extra.stacked_bar_height+bincounts'];
        [xpatch,ypatch]=to_polar(obj,xpatch,ypatch);
        
        obj.results.stat_cornerhist{obj.result_ind,1}.fill_handle=patch(xpatch,ypatch,[1 1 1],'FaceColor',face_color,'EdgeColor','none','FaceAlpha',face_alpha);
        
    case 'point'
        xtemp=bar_mid;
        ytemp=bincounts(1:end)';
        [xtemp,ytemp]=to_polar(obj,xtemp,ytemp);
        obj.results.stat_cornerhist{obj.result_ind,1}.point_handle=plot(xtemp,ytemp,draw_data.marker,'MarkerEdgeColor','none','markerSize',draw_data.size,'MarkerFaceColor',draw_data.color);
end

%Set limits of child axis
set(obj.extra.cornerhist_child_axe(obj.current_row,obj.current_column),'XLim',[min(binranges) max(binranges)]);

if new_child
    %Change limits of parent axis
    if min(binranges)<0
        %obj.plot_lim.maxy(obj.current_row,obj.current_column)=obj.plot_lim.maxy(obj.current_row,obj.current_column)+sqrt(0.6*min(binranges).^2);
        obj.plot_lim.maxy(obj.current_row,obj.current_column)=child_x+sqrt(0.6*min(binranges).^2);
    end
    if max(binranges)>0
        %obj.plot_lim.maxx(obj.current_row,obj.current_column)=obj.plot_lim.maxx(obj.current_row,obj.current_column)+sqrt(0.6*max(binranges).^2);
        obj.plot_lim.maxx(obj.current_row,obj.current_column)=child_x+sqrt(0.6*max(binranges).^2);
    end  
end

axes(parent_axe);

end

function cornerhist_redraw(parent_axe,child_axe,x_pos)


%Get info about updated parent axis
set(parent_axe,'Units','Pixels')
pa_pos=get(parent_axe,'Position');
pa_xlim=get(parent_axe,'XLim');
pa_ylim=get(parent_axe,'YLim');


%To place on unity line
pa_halfxpos=pa_pos(1)+(x_pos-pa_xlim(1))*pa_pos(3)/diff(pa_xlim);
pa_halfypos=pa_pos(2)+(x_pos-pa_ylim(1))*pa_pos(4)/diff(pa_ylim);

angle=atan2(pa_pos(4)/diff(pa_ylim),pa_pos(3)/diff(pa_xlim));



set(child_axe,'Units','Pixels')
ch_pos=get(child_axe,'Position');
ch_xlim=get(child_axe,'XLim');
ch_ylim=get(child_axe,'YLim');
ch_dar=get(child_axe,'DataAspectRatio');
ch_pbar=get(child_axe,'PlotBoxAspectRatio');
ch_va=get(child_axe,'CameraViewAngle')


%Projection of (0,1) from parent axis in pixel coordinates on the line
%perpendicular to the unity line is our x scale for the child axe
new_w=diff(ch_xlim)*cos(angle)*pa_pos(4)/diff(pa_ylim);


%DAR [diff(ch_xlim)/(ch_dar(1)*diff(ch_ylim)) 1 1]
pbar=0.2;


set(child_axe,'Position',[ch_pos(1) ch_pos(2) new_w new_w*pbar],'DataAspectRatio',[diff(ch_xlim)/(diff(ch_ylim)/pbar) 1 1],'PlotBoxAspectRatio',[1/pbar 1 1],'Xlim',ch_xlim,'Ylim',ch_ylim)

place_axes(child_axe,[0 0],[pa_halfxpos pa_halfypos],angle-pi/2);

set(parent_axe,'Units','Normalized')

end

function place_axes(h,origin,position,angle)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

xlim=get(h,'XLim')
ylim=get(h,'YLim')
pos=get(h,'Position')
c_tar=get(h,'CameraTarget')
c_pos=get(h,'CameraPosition')
c_va=get(h,'CameraViewAngle')
c_uv=get(h,'CameraUpVector')
dar=get(h,'DataAspectRatio')
pbar=get(h,'PlotBoxAspectRatio')

%Positions are chosen position + origin offset compensation (relative to
%bottom left edge) + camera target offset compensation (relative to center)
%Setting the data aspect ratio prevents glitches WORKING
set(h,'Position',[position(1)-(origin(1)-xlim(1))*pos(3)/diff(xlim)+(origin(1)-mean(xlim))*pos(3)/diff(xlim)...
    position(2)-(origin(2)-ylim(1))*pos(4)/diff(ylim)+(origin(2)-mean(ylim))*pos(4)/diff(ylim)...
    pos(3) pos(4)],...
     'CameraPosition',[origin(1) origin(2) c_pos(3)],...
     'CameraTarget',[origin(1) origin(2) c_tar(3)],'CameraViewAngle',c_va,'PlotBoxAspectRatio',pbar,'DataAspectRatio',dar,'CameraUpVector',[sin(angle)*dar(1) cos(angle)*dar(2) 0])

%If dar was not set in the previous call, it could be updated so getting it
%again was needed
%dar=get(h,'DataAspectRatio');
%set(h,'CameraUpVector',[sin(angle)*dar(1) cos(angle)*dar(2) 0])

end

