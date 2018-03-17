function obj=redraw(obj,spacing,display)
% redraw Optimize location and size of axes in figure after resizing
%
% Syntax: gramm_object.redraw(spacing,display)
% spacing is an optional argument that indicates how far apart
% the elements should be. It is expressed in normalized units
% of the figure's smallest dimension. Default value is 0.03
% When display is set to true (default is false), the bounding boxes of all
% elements are drawn in a separate figure




if nargin<2
    spacing=obj(1).layout_options.redraw_gap;
else
    nl=size(obj,1);
    nc=size(obj,2);
    spacing=spacing/max(nl,nc);
    for l=1:nl
        for c=1:nc
            obj(l,c).layout_options.redraw_gap=spacing;
        end
    end
end

if nargin<3
    display=0;
end

%Handle multiple objects case
if numel(obj)>1
    nl=size(obj,1);
    nc=size(obj,2);
    for l=1:nl
        for c=1:nc
            %Make multiple calls to redraw with smaller spacing
            %other parameters should be fine
            redraw(obj(l,c),obj(l,c).layout_options.redraw_gap,display);
        end
    end
    return;
end


%Cool way to prevent reentrant callbacks !
%             persistent inCallback
%             if ~isempty(inCallback)
%                 return;
%             end
%             inCallback = true;
%If x is empty the object probably is so we skip (happens for multiple graphs)
if isempty(obj.aes.x) || ~obj.layout_options.redraw
    return
end


set(gcf,'Unit','pixels');
figure_position=get(gcf,'Position');

%The spacing is relative to the smallest side
if figure_position(3)>figure_position(4)
    spacing_h=spacing;
    spacing_w=spacing*figure_position(4)/figure_position(3);
else
    spacing_w=spacing;
    spacing_h=spacing*figure_position(3)/figure_position(4);
end

%Position here should be the standard stuff
%set(findobj(gcf,'Type','axes'),'ActivePositionProperty','Position');

%Retrieve axes positions
facet_pos=get(obj.facet_axes_handles,'Position');
facet_inset=get(obj.facet_axes_handles,'TightInset');
facet_outer=get(obj.facet_axes_handles,'OuterPosition');

%Handle case of single facet
if length(obj.facet_axes_handles)==1
    facet_pos={facet_pos};
    facet_inset={facet_inset};
    facet_outer={facet_outer};
end


%Retrieve legend position
legend_pos=get(obj.legend_axe_handle,'Position');
legend_inset=get(obj.legend_axe_handle,'TightInset');
legend_outer=get(obj.legend_axe_handle,'OuterPosition');

%Get legend axis width because units on legend text are not set
%to normalized
legend_xlim=get(obj.legend_axe_handle,'XLim');
legend_axis_width=diff(legend_xlim);


if isempty(obj.redraw_cache) %Takes a long time so we only do it once
    %Needed for the rest to work
    set(obj.title_text_handle,'Unit','normalized');
    set(obj.facet_text_handles,'Unit','normalized');
    %set(obj.legend_text_handles,'Unit','normalized');
    first_redraw=true;
else
    first_redraw=false;
end

if display
    text_handles=findobj(gcf,'Type','text');
    figure(100)
    hold on
    rectangle('Position',[0 0 1 1])
    
    %Display facets boxes
    cellfun(@(fp)rectangle('Position',fp,'EdgeColor','r'),facet_pos);
    cellfun(@(fo)rectangle('Position',fo,'EdgeColor','m','LineStyle',':'),facet_outer);
    cellfun(@(fp,fi)rectangle('Position',[fp(1)-fi(1) fp(2)-fi(2) fp(3)+fi(3)+fi(1)  fp(4)+fi(4)+fi(2)],'EdgeColor','m'),facet_pos,facet_inset);
    
    %Display legend boxes
    rectangle('Position',legend_pos,'EdgeColor','b');
    rectangle('Position',legend_outer,'EdgeColor','c','LineStyle',':');
    rectangle('Position',[legend_pos(1)-legend_inset(1) legend_pos(2)-legend_inset(2) legend_pos(3)+legend_inset(3)+legend_inset(1)  legend_pos(4)+legend_inset(4)+legend_inset(2)],'EdgeColor','c');
    
    
    %Retrieve text handles
    
    set(obj.legend_text_handles,'Unit','normalized');
    %display text boxes
    for t=1:length(text_handles)
        parent_axe=ancestor(text_handles(t),'axes');
        axpos=get(parent_axe,'Position');
        txtpos=get(text_handles(t),'Extent');
        %rectangle('Position',[txtpos(1)+axpos(1) txtpos(2)+axpos(2) txtpos(3) txtpos(4)],'EdgeColor','g');
        rectangle('Position',[txtpos(1)*axpos(3)+axpos(1) txtpos(2)*axpos(4)+axpos(2) txtpos(3)*axpos(3) txtpos(4)*axpos(4)],'EdgeColor','g');
    end
    set(obj.legend_text_handles,'Unit','data');
end

%% Move legend

%Get the position of the longest text element
if first_redraw || ~isfield(obj.redraw_cache,'max_legend_ind')
    legend_text_pos=get(obj.legend_text_handles,'Extent'); %On first redraw we get all extents
else
    %On next redraws we only get extent of the rightmost one
    legend_text_pos=get(obj.legend_text_handles(obj.redraw_cache.max_legend_ind),'Extent');
    if ~isempty(legend_text_pos) && ~iscell(legend_text_pos)
        legend_text_pos={legend_text_pos};
    end
end

%Move legend
if strcmp(obj.layout_options.legend_position,'auto')
    if strcmp(obj.layout_options.legend_width,'auto') % If we do not have a custom legend width
        if ~isempty(legend_text_pos)
            %Here we correct by the width to get the coordinates in
            %normalized values
            [max_text_x,max_ind]=max(cellfun(@(p)legend_pos(1)+legend_pos(3)*(p(1)+p(3))/legend_axis_width,legend_text_pos));
            if first_redraw
                obj.redraw_cache.max_legend_ind=max_ind; %Cache the index of which text object is the rightmost
            end
            %Move accordingly (here the max available x position takes
            %in account the multiple plots
            legend_pos = legend_pos+[obj.multi.orig(2)+obj.multi.size(2)-spacing_w-max_text_x 0 0 0];
        else
            legend_pos = [obj.multi.orig(2)+obj.multi.size(2) legend_pos(2) legend_pos(3) legend_pos(4)];
        end
    else
        %Set legend position according to custom legend width
        legend_pos = [obj.multi.orig(2)+(1-obj.layout_options.legend_width)*obj.multi.size(2) legend_pos(2) legend_pos(3) legend_pos(4)];
    end
    set(obj.legend_axe_handle,'Position',legend_pos);
else
    % We need something in legend_pos but don't actually move the legend
    legend_pos = [obj.multi.orig(2)+obj.multi.size(2) 0 0 0];
end

%% Move title

%Move title to the top and center it according to axes
if ~isempty(obj.title_axe_handle)
    title_text_pos=get(obj.title_text_handle,'Extent');
    title_pos=get(obj.title_axe_handle,'Position');
    max_text_y=title_pos(2)+title_pos(4)*title_text_pos(2)+title_pos(4)*title_text_pos(4);
    switch obj.layout_options.title_centering
        case 'axes'
            %title_pos = [obj.multi.orig(2) title_pos(2)+obj.multi.orig(1)+obj.multi.size(1)-spacing_h-max_text_y legend_pos(1)-obj.multi.orig(2) title_pos(4)];
            tmp = vertcat(facet_pos{:});
            title_pos = [min(tmp(:,1)) title_pos(2)+obj.multi.orig(1)+obj.multi.size(1)-spacing_h-max_text_y legend_pos(1)-min(tmp(:,1))-spacing_w title_pos(4)];
        case 'plot'
            title_pos = title_pos+[0 obj.multi.orig(1)+obj.multi.size(1)-spacing_h-max_text_y 0 0];
    end
    set(obj.title_axe_handle,'Position',title_pos);
end

%% Move facets

%Move facets to the right
%Get the leftmost facet part (should be y legend)
min_facet_x=min(cellfun(@(fp,fi)fp(1)-fi(1),facet_pos,facet_inset));
min_facet_y=min(cellfun(@(fp,fi)fp(2)-fi(2),facet_pos,facet_inset));
for a=1:numel(obj.facet_axes_handles)
    %Moving to the right is relative to the multi origin
    set(obj.facet_axes_handles(a),'Position',facet_pos{a}+[obj.multi.orig(2)+spacing_w-min_facet_x obj.multi.orig(1)+spacing_h-min_facet_y 0 0]); %was spacing_x-min_facet_y
end

%Move and rescale facets to fill up the available space
%Get positions of facet text objects (row titles are the
%rightmost things)
if first_redraw || ~isfield(obj.redraw_cache,'max_facet_ind')
    facet_text_pos=get(obj.facet_text_handles,'Extent'); %On first call get all positions
 else
     % On the next calls we only get the extents of rightmost
     % and topmost text objects
     facet_text_pos=get(obj.facet_text_handles(obj.redraw_cache.max_facet_ind),'Extent');
     if ~isempty(facet_text_pos) && ~iscell(facet_text_pos)
         facet_text_pos={facet_text_pos};
     end
 end

if ~isempty(facet_text_pos)
    %Get positions of the corresponding parent axes
    %axe_text_pos=get(cell2mat(ancestor(findobj(obj.facet_axes_handles,'Type','text'),'axes')),'Position');
    %%didn't work with HG2 graphics
    if first_redraw
        temp_handles=ancestor(obj.facet_text_handles,'axes');
    else
        temp_handles=ancestor(obj.facet_text_handles(obj.redraw_cache.max_facet_ind),'axes');
    end
    
    %HACK (when there no color and no legend but a single piece of text from the
    %glm fits we don't get cells here so the cellfuns get broken
    if ~iscell(temp_handles)
        temp_handles={temp_handles};
    end
    
    axe_text_pos=cellfun(@(a)get(a,'Position'),temp_handles,'UniformOutput',false);
    if ~iscell(axe_text_pos)
        axe_text_pos={axe_text_pos};
    end
    
    %Compute rightmost and topmost text
    [max_facet_x_text,max_indx]=max(cellfun(@(tp,ap)ap(1)+ap(3)*tp(1)+tp(3)*ap(3),facet_text_pos,axe_text_pos));
    [max_facet_y_text,max_indy]=max(cellfun(@(tp,ap)ap(2)+ap(4)*tp(2)+tp(4)*ap(4),facet_text_pos,axe_text_pos));
    
    %Cache rightmost and topmost text object handles for speed
    if first_redraw
        if max_indx==max_indy
            obj.redraw_cache.max_facet_ind=max_indx;
        else
            obj.redraw_cache.max_facet_ind=[max_indx,max_indy];
        end
    end
else
    max_facet_x_text=0;
    max_facet_y_text=0;
end



%Get updated position
facet_pos=get(obj.facet_axes_handles,'Position');
%Handle case of single facet
if length(obj.facet_axes_handles)==1
    facet_pos={facet_pos};
end

%Get extent
max_facet_x=max(cellfun(@(p)p(1)+p(3),facet_pos));
min_facet_x=min(cellfun(@(p)p(1),facet_pos));
max_facet_y=max(cellfun(@(p)p(2)+p(4),facet_pos));
min_facet_y=min(cellfun(@(p)p(2),facet_pos));

% max_facet_x_text
% max_facet_x

%Correction if no row  or column legends
max_facet_x_text=max(max_facet_x_text,max_facet_x);
max_facet_y_text=max(max_facet_y_text,max_facet_y);

%If we don't have legends on the right then we use the multi parameters
temp_available_x=obj.multi.orig(2)+obj.multi.size(2)-spacing_w;
if strcmp(obj.layout_options.legend_position,'auto')
    if strcmp(obj.layout_options.legend_width,'auto')
        if ~isempty(legend_text_pos)%  && obj.with_legend %Place relative to legend axis if we have one
            tmp=get(obj.legend_axe_handle,'Position');
            temp_available_x=tmp(1);
        end
    else
        temp_available_x=obj.multi.orig(2)+(1-obj.layout_options.legend_width)*obj.multi.size(2)-spacing_w;
    end
end
max_available_x=temp_available_x-spacing_w-(max_facet_x_text-max_facet_x);

% temp_available_x
% max_available_x

temp_available_y=obj.multi.orig(1)+obj.multi.size(1);
%Place relative to title axis
if ~isempty(obj.title_axe_handle)
    title_text_pos=get(obj.title_text_handle,'Extent');
    title_pos=get(obj.title_axe_handle,'Position');
    temp_available_y=title_pos(2)+title_pos(4)*title_text_pos(2);
    %temp_available_y=tmp(2);
end
%For the available room on top we take in account multi as well
max_available_y=temp_available_y-spacing_h-(max_facet_y_text-max_facet_y);


facet_spacing_w = spacing_w;
facet_spacing_h = spacing_h;

%Compute additional spacing for x y axis labels if idependent
%(or if free with wrapping)
if obj.force_ticks || (obj.wrap_ncols>0)% && ~isempty(strfind(obj.facet_scale,'free')))
    %use top left inset as reference
    top_right_inset=get(obj.facet_axes_handles(1,end),'TightInset');
    facet_spacing_w=top_right_inset(1)+facet_spacing_w;
    facet_spacing_h=top_right_inset(2)+facet_spacing_h;
    %             else
    %                 %Compute additional spacing for titles if column wrap (this
    %                 %is in the else to prevent too large increase of spacing in
    %                 % facet_wrap
    %                 if obj.wrap_ncols>0
    %                     outerpos=get(obj.facet_axes_handles(1,1),'OuterPosition');
    %                     innerpos=get(obj.facet_axes_handles(1,1),'Position');
    %                     facet_spacing_h=facet_spacing_h+(outerpos(4)-innerpos(4)-(innerpos(2)-outerpos(2)))*1.5;
    %                 end
end




%Do the move
if obj.wrap_ncols>0
    nr=ceil(length(obj.facet_axes_handles)/obj.wrap_ncols);
    nc=obj.wrap_ncols;
    neww=abs(max_available_x-min_facet_x-facet_spacing_w*(nc-1))/nc;
    newh=abs(max_available_y-min_facet_y-facet_spacing_h*(nr-1))/nr;
    ind=1;
    for r=1:nr
        for c=1:nc
            if ind<=length(obj.facet_axes_handles)
                %axpos=get(obj.facet_axes_handles(ind),'Position');
                set(obj.facet_axes_handles(ind),'Position',[min_facet_x+(neww+facet_spacing_w)*(c-1) min_facet_y+(newh+facet_spacing_h)*(nr-r) neww newh]);
            end
            ind=ind+1;
        end
    end
else
    nr=size(obj.facet_axes_handles,1);
    nc=size(obj.facet_axes_handles,2);
    %OLD
    %                 %We don't let those go below a small value (spacing)
    %                 neww=max((max_available_x-min_facet_x-facet_spacing_w*(nc-1))/nc,facet_spacing_w);
    %                 newh=max((max_available_y-min_facet_y-facet_spacing_h*(nr-1))/nr,facet_spacing_h);
    %                 for r=1:nr
    %                     for c=1:nc
    %                         %axpos=get(obj.facet_axes_handles(r,c),'Position');
    %                         set(obj.facet_axes_handles(r,c),'Position',[min_facet_x+(neww+facet_spacing_w)*(c-1) min_facet_y+(newh+facet_spacing_h)*(nr-r) neww newh]);
    %                     end
    %                 end
    
    %NEW
    %Available space for axes
    avl_x=max_available_x-min_facet_x-facet_spacing_w*(nc-1);
    avl_y=max_available_y-min_facet_y-facet_spacing_h*(nr-1);
    facet_width=ones(1,nc)*avl_x/nc;
    facet_height=ones(1,nr)*avl_y/nr;
    if (strcmp(obj.facet_space,'free') || strcmp(obj.facet_space,'free_x')) && ~strcmp(obj.facet_scale,'independent')
        if obj.is_flipped %If flipped, x axes are along rows
            %Get axes limits for spacing computation
            xdataw=zeros(1,nr);
            for r=1:nr
                tmp_xlim=get(obj.facet_axes_handles(r,1),'XLim');
                xdataw(r)=tmp_xlim(2)-tmp_xlim(1);
            end
            %Compute axis width depending on data width
            x_scale_ratio=xdataw/sum(xdataw);
            facet_height=avl_y*x_scale_ratio;
        else %If non flipped, x axes are along columns
            %Get axes limits for spacing computation
            xdataw=zeros(1,nc);
            for c=1:nc
                tmp_xlim=get(obj.facet_axes_handles(1,c),'XLim');
                xdataw(c)=tmp_xlim(2)-tmp_xlim(1);
            end
            %Compute axis width depending on data width
            x_scale_ratio=xdataw/sum(xdataw);
            facet_width=avl_x*x_scale_ratio;
        end
    end
    if (strcmp(obj.facet_space,'free') || strcmp(obj.facet_space,'free_y')) && ~strcmp(obj.facet_scale,'independent')
        if obj.is_flipped %If flipped, y axes are along columns
            ydataw=zeros(1,nc);
            for c=1:nc
                tmp_ylim=get(obj.facet_axes_handles(1,c),'YLim');
                ydataw(c)=tmp_ylim(2)-tmp_ylim(1);
            end
            y_scale_ratio=ydataw/sum(ydataw);
            facet_width=avl_x*y_scale_ratio;
        else %If not flipped, y axes are along rows
            ydataw=zeros(1,nr);
            for r=1:nr
                tmp_ylim=get(obj.facet_axes_handles(r,1),'YLim');
                ydataw(r)=tmp_ylim(2)-tmp_ylim(1);
            end
            y_scale_ratio=ydataw/sum(ydataw);
            facet_height=avl_y*y_scale_ratio;
        end
    end
    
    %safeguards
    facet_width(facet_width<=0)=0.01;
    facet_height(facet_height<=0)=0.01;
    
    for r=1:nr
        for c=1:nc
            %Compute facet x offset
            if c>1
                x_offset=min_facet_x+sum(facet_width(1:c-1))+facet_spacing_w*(c-1);
            else
                x_offset=min_facet_x;
            end
            %compute facet y offset
            if r==nr
                y_offset=min_facet_y;
            else
                y_offset=min_facet_y+sum(facet_height(r+1:nr))+facet_spacing_h*(nr-r);
            end
            %Place facet
            set(obj.facet_axes_handles(r,c),'Position',[x_offset y_offset facet_width(c) facet_height(r)]);
        end
    end
end

%% Move title again

%Get updated position
facet_pos=get(obj.facet_axes_handles,'Position');
%Handle case of single facet
if length(obj.facet_axes_handles)==1
    facet_pos={facet_pos};
end

%Move title to the top and center it according to axes
if ~isempty(obj.title_axe_handle)
    title_text_pos=get(obj.title_text_handle,'Extent');
    title_pos=get(obj.title_axe_handle,'Position');
    max_text_y=title_pos(2)+title_pos(4)*title_text_pos(2)+title_pos(4)*title_text_pos(4);
    switch obj.layout_options.title_centering
        case 'axes'
            tmp = vertcat(facet_pos{:});
            %title_pos = [min(tmp(:,1)) title_pos(2)+obj.multi.orig(1)+obj.multi.size(1)-spacing_h-max_text_y legend_pos(1)-min(tmp(:,1))-spacing_w title_pos(4)];
            title_pos = [tmp(1,1) title_pos(2)+obj.multi.orig(1)+obj.multi.size(1)-spacing_h-max_text_y tmp(end,1)+tmp(end,3)-tmp(1,1) title_pos(4)];
        case 'plot'
            title_pos = title_pos+[0 obj.multi.orig(1)+obj.multi.size(1)-spacing_h-max_text_y 0 0];
    end
    set(obj.title_axe_handle,'Position',title_pos);
end


%% Resize legend
%Resize legend y axis in order to get constant spacing between
%legend entries
L=length(obj.legend_text_handles);
if L>1
    legend_ylim=get(obj.legend_axe_handle,'YLim');
    %              legend_text_pos=get(obj.legend_text_handles,'Extent');
    %              legend_text_pos=vertcat(legend_text_pos{:});
    %              legend_height=nanmean(legend_text_pos(:,4));
    %              legend_spacing=nanmean(legend_text_pos(1:end-1,2)-(legend_text_pos(2:end,2)+legend_text_pos(2:end,4)));
    %              legend_top=legend_text_pos(1,2)+legend_text_pos(1,4);
    %              legend_bottom=legend_text_pos(end,2);
    
    % We use the first and second legends to compute spacing,
    % first and last for top and bottom
    legend_text_pos=get(obj.legend_text_handles([1 end]),'Extent');
    legend_height=legend_text_pos{1}(4);
    %legend_spacing=legend_text_pos{1}(2)-(legend_text_pos{2}(2)+legend_text_pos{2}(4));
    legend_top=legend_text_pos{1}(2)+legend_text_pos{1}(4);
    legend_bottom=legend_text_pos{2}(2);
    
    %disp(['height: ' num2str(legend_height) ' spacing: ' num2str(legend_spacing) ])
    %Theoretical resizing
    %ratio=(legend_top-legend_bottom)/(legend_ylim(2)-legend_ylim(1));
    
    %Future text height stays visually constant so scales inversely
    %relative to limits
    %height_in_mod=legend_height*ratio;
    
    %Future spacing gets adjsuted according to relative text
    %size and number of text labels
    %spacing_in_mod=((legend_top-legend_bottom)-(height_in_mod*L))/(L-1);
    
    %disp(['mod height: ' num2str(height_in_mod) ' mod spacing: ' num2str(spacing_in_mod) ])
    %set(obj.legend_axe_handle,'YLim',[legend_bottom legend_top]);
    
    %Here we want future text height=future spacing so by
    %solving for ratio we get
    ratio=((legend_top-legend_bottom)/(L-1))/(legend_height+legend_height*L/(L-1));
    
    new_ylim=legend_ylim*ratio*1.4; %Correct the ratio to get text lines closer to each other
    
    %Center the limits relative to top and bottom
    new_ylim=new_ylim-(new_ylim(2)-legend_top)+(new_ylim(2)-legend_top+legend_bottom-new_ylim(1))/2;
    
    %Only adjust if it's not going tocut our legend.
    if new_ylim(1)<(-L+1) && new_ylim(2)>1
        set(obj.legend_axe_handle,'YLim',new_ylim);
    end
end


if ~isempty(obj.redraw_fun)
    for k=1:length(obj.redraw_fun)
        obj.redraw_fun{k}();
    end
end

%inCallback = [];
end