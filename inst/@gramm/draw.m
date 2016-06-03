function obj=draw(obj,do_redraw)
% draw Draws the plot in the current figure
%
% syntax: gramm_object.draw()
% Call draw on an array of gramm objects in order to have
% multiple gramms on a single figure.
% An optional logical argument can be given. Use
% gramm_object.draw(false) in order to allow the nex gramm plot to be
% superimposed on the same figure (useful for plotting with
% different grouping aesthetics). When using superimposed
% plots, the last draw() should be given without this false
% argument. Giving false as argument deactivates the automatic
% call for the redraw() function, i.e. deactivates the fancy
% axis placement.

%We set redraw() as resize callback by default
if nargin<2
    do_redraw=true;
end

%If no parent was given we use the current figure
if isempty(obj(1).parent)
    for obj_ind=1:numel(obj)
        obj(obj_ind).parent=gcf;
    end
end


%Handle call of draw() on array of gramm objects by dividing the figure
%up and launching the individual draw functions of each object
if numel(obj)>1
    %Take care of the big title
    if isempty(obj(1).bigtitle)
        maxh=1;
    else
        maxh=0.94;
        tmp=axes('Position',[0.1 0.965 0.8 0.01],'Parent',obj(1).parent);
        set(tmp,'Visible','off','XLim',[-1 1],'YLim',[-1 1]);
        tmp=text(0,0,obj(1).bigtitle,'FontWeight','bold','Interpreter','none','fontSize',14,'HorizontalAlignment','center');
        if ~isempty(obj(1).bigtitle_options)
            set(tmp,obj(1).bigtitle_options{:});
        end
    end
    
    nl=size(obj,1);
    nc=size(obj,2);
    for l=1:nl
        for c=1:nc
            obj(l,c).multi.orig=[(nl-l)*maxh/nl (c-1)/nc];
            obj(l,c).multi.size=[maxh/nl 1/nc];
            obj(l,c).multi.active=true;
            draw(obj(l,c));
        end
    end
    
    %Set up tight redrawing for multiple plots
    if do_redraw
        redraw(obj,0.04);
        if verLessThan('matlab','8.4')
            set(gcf,'ResizeFcn',@(a,b)redraw(obj,0.04));
        else
            set(gcf,'SizeChangedFcn',@(a,b)redraw(obj,0.04));
        end
    end
    return;
end

%If x is empty the object probably is so we skip (happens for multiple graphs)
if isempty(obj.aes.x)
    return
end

%If draw() is called a second time without update() having been
%called we skip
if (~obj.updater.first_draw && ~obj.updater.updated)
    warning('Multiple draw() calls need update() calls')
    return
end

obj.aes=validate_aes(obj.aes);

%Apply subset
temp_aes=select_aes(obj.aes,obj.aes.subset);

%Make sure that we work on cells that are not empty
nonemptycell=@(c)~cellfun(@isempty,c);

if iscell(temp_aes.x)
    nonempty=nonemptycell(temp_aes.x); %Find empty X cells
    
    if iscellstr(temp_aes.x)
        %Convert factor data to numeric
        obj.x_factor=true;
        obj.x_ticks=unique_and_sort(temp_aes.x,obj.order_options.x);
        tempx=zeros(length(temp_aes.x),1);
        for k=1:length(obj.x_ticks)
            tempx(strcmp(temp_aes.x,obj.x_ticks{k}))=k;
        end
        temp_aes.x=tempx;
    else
        obj.x_factor=false;
    end
else
    nonempty=true(length(temp_aes.y),1);
end

if iscell(temp_aes.y)
    nonempty=nonempty & nonemptycell(temp_aes.y); %Find empty Y cells
end

if ~isempty(temp_aes.z) && iscell(temp_aes.z)
    nonempty=nonempty & nonemptycell(temp_aes.z); %Find empty Z cells
end


%Remove empty cells
temp_aes=select_aes(temp_aes,nonempty);

%Compute x limits
obj.var_lim.maxx=allmax(temp_aes.x);
obj.var_lim.minx=allmin(temp_aes.x);

%Depending on whether ymin of ymax are present we change what to pick for Y
%limit computation
if ~isempty(temp_aes.ymin) && ~isempty(temp_aes.ymax)
    tmp_y_for_min=temp_aes.ymin;
    tmp_y_for_max=temp_aes.ymax;
else
    tmp_y_for_min=temp_aes.y;
    tmp_y_for_max=temp_aes.y;
end

%Compute y limits
obj.var_lim.maxy=allmax(tmp_y_for_max);
obj.var_lim.miny=allmin(tmp_y_for_min);

%Compute z limits
if ~isempty(temp_aes.z)
   obj.var_lim.maxz=allmax(temp_aes.z);
   obj.var_lim.minz=allmin(temp_aes.z);
end


%Handles the multiple gramm case: we set up subtightplot so
%that it restricts the drawing (using margins) to a portion of
%the figure
mysubtightplot=@(m,n,p,gap,marg_h,marg_w)my_tightplot(m,n,p,...
    [gap(1)*obj.multi.size(1) gap(2)*obj.multi.size(2)],...
    [obj.multi.orig(1)+obj.multi.size(1)*marg_h(1) 1-obj.multi.orig(1)-obj.multi.size(1)*(1-marg_h(2))],...
    [obj.multi.orig(2)+obj.multi.size(2)*marg_w(1) 1-obj.multi.orig(2)-obj.multi.size(2)*(1-marg_w(2))],'Parent',obj.parent);

%Set subplot generation parameters and functions
if obj.force_ticks  %Independent scales require more space between subplots for ticks
    mysubplot=@(nrow,ncol,row,col)mysubtightplot(nrow,ncol,(row-1)*ncol+col,[0.06 0.06],[0.1 0.2],[0.1 0.2]);
else
    mysubplot=@(nrow,ncol,row,col)mysubtightplot(nrow,ncol,(row-1)*ncol+col,[0.02 0.02],[0.1 0.2],[0.1 0.2]);
end
%Subplots for wraps leave more space above axes for column
%legend
mysubplot_wrap=@(ncol,col)mysubtightplot(ceil(ncol/obj.wrap_ncols),obj.wrap_ncols,col,[0.09 0.03],[0.1 0.2],[0.1 0.2]);

%Find uniques in aesthetics and sort according to options
uni_row=unique_and_sort(temp_aes.row,obj.order_options.row);
uni_column=unique_and_sort(temp_aes.column,obj.order_options.column);
uni_linestyle=unique_and_sort(temp_aes.linestyle,obj.order_options.linestyle);
uni_marker=unique_and_sort(temp_aes.marker,obj.order_options.marker);
uni_lightness=unique_and_sort(temp_aes.lightness,obj.order_options.lightness);
uni_size=unique_and_sort(temp_aes.size,obj.order_options.size);

%If the color is in a cell array of doubles, we set it as
%continuous color
if iscell(temp_aes.color) && ~iscellstr(temp_aes.color)
    obj.continuous_color=true;
else
    uni_color=unique_and_sort(temp_aes.color,obj.order_options.color);
    
    %If we have too many numerical values for the color we
    %switch to continuous color
    if length(uni_color)>15 && ~iscellstr(uni_color)
        obj.continuous_color=true;
    end
end
if obj.continuous_color
    uni_color={1};
end

%Transform all aesthetics in cell arrays (makes it easier to handle after)
if ~iscell(uni_row)
    uni_row=num2cell(uni_row);
end
if ~iscell(uni_column)
    uni_column=num2cell(uni_column);
end
if ~iscell(uni_color)
    uni_color=num2cell(uni_color);
end
if ~iscell(uni_lightness)
    uni_lightness=num2cell(uni_lightness);
end
if ~iscell(uni_linestyle)
    uni_linestyle=num2cell(uni_linestyle);
end
if ~iscell(uni_size)
    uni_size=num2cell(uni_size);
end
if ~iscell(uni_marker)
    uni_marker=num2cell(uni_marker);
end

%Correct empty facets when wrapping
if obj.wrap_ncols>length(uni_column)
    obj.wrap_ncols=length(uni_column);
end

%The plot minimums and maximums are stored in arrays the size of the
%number of subplots
n_columns=length(uni_column);
n_rows=length(uni_row);
if obj.updater.first_draw || obj.updater.facet_updated==1
    obj.plot_lim.minx=nan(n_rows,n_columns);
    obj.plot_lim.maxx=nan(n_rows,n_columns);
    obj.plot_lim.miny=nan(n_rows,n_columns);
    obj.plot_lim.maxy=nan(n_rows,n_columns);
    obj.plot_lim.minz=nan(n_rows,n_columns);
    obj.plot_lim.maxz=nan(n_rows,n_columns);
    obj.plot_lim.minc=nan(n_rows,n_columns);
    obj.plot_lim.maxc=nan(n_rows,n_columns);
end

%Get colormap
cmap=get_colormap(length(uni_color),length(uni_lightness),obj.color_options);


%Initialize results structure (n_groups is an overestimate if
%there are redundant groups
n_groups=length(uni_row)*length(uni_column)*length(uni_marker)...
    *length(uni_size)*length(uni_linestyle)*length(uni_color)*length(unique(temp_aes.group));
aes_names_fieldnames=fieldnames(obj.aes_names);
for fn=4:length(aes_names_fieldnames) %Starting from 4 we ignore x y and z
    obj.results.(aes_names_fieldnames{fn})=cell(n_groups,1);
    obj.results.(['ind_' aes_names_fieldnames{fn}])=cell(n_groups,1);
end
obj.results.draw_data=cell(n_groups,1);

%Store different line styles
line_styles={'-' '--' ':' '-.'};
%Store different sizes
markers={'o' 's' 'd' '^' 'v' '>' '<' 'p' 'h' '*' '+' 'x'};
if length(uni_size)>1
    sizes=linspace(4,12,length(uni_size));
else
    if uni_size{1}==1
        sizes=6;
    else
        sizes=uni_size{1};
    end
end

obj.firstrun=ones(n_rows,n_columns);
%Index in the loops
obj.result_ind=1;

%Initialize facet axes handles
if obj.updater.first_draw
    if obj.handle_graphics %Post 2014b we return objects
        obj.facet_axes_handles=gobjects(length(uni_row),length(uni_column));
    else
        obj.facet_axes_handles=zeros(length(uni_row),length(uni_column));
    end
end

%Set the dodge width across all facets
draw_data.dodge_avl_w=min(diff(unique(comb(temp_aes.x))));
if isempty(draw_data.dodge_avl_w) || draw_data.dodge_avl_w==0
    draw_data.dodge_avl_w=1;
end


%% draw() looping
%Loop over rows
for ind_row=1:length(uni_row)
    
    sel_row=multi_sel(temp_aes.row,uni_row{ind_row});
    
    obj.current_row=ind_row;
    
    %Loop over columns
    for ind_column=1:length(uni_column)
        
        sel_column=sel_row & multi_sel(temp_aes.column,uni_column{ind_column});
        
        obj.current_column=ind_column;
        
        %Store limits of the subplots
        if sum(sel_column)>0
            %Here we do max/min with the current values for draw after
            %update() calls
            obj.plot_lim.maxx(obj.current_row,obj.current_column)=max(allmax(temp_aes.x(sel_column)),...
                obj.plot_lim.maxx(obj.current_row,obj.current_column));
            obj.plot_lim.minx(obj.current_row,obj.current_column)=min(allmin(temp_aes.x(sel_column)),...
                obj.plot_lim.minx(obj.current_row,obj.current_column));
            
            obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(allmax(tmp_y_for_max(sel_column)),...
                obj.plot_lim.maxy(obj.current_row,obj.current_column));
            obj.plot_lim.miny(obj.current_row,obj.current_column)=min(allmin(tmp_y_for_min(sel_column)),...
                obj.plot_lim.miny(obj.current_row,obj.current_column));
            
            if ~isempty(temp_aes.z) 
                obj.plot_lim.maxz(obj.current_row,obj.current_column)=max(allmax(temp_aes.z(sel_column)),...
                    obj.plot_lim.maxz(obj.current_row,obj.current_column));
                obj.plot_lim.minz(obj.current_row,obj.current_column)=min(allmin(temp_aes.z(sel_column)),...
                    obj.plot_lim.minz(obj.current_row,obj.current_column)); 
            else
                obj.plot_lim.maxz(obj.current_row,obj.current_column)=0;
                obj.plot_lim.minz(obj.current_row,obj.current_column)=0;
            end
        end
        
        
        %Create subplot (much faster to do it here at the most upper level: changing subplot takes a
        %long time in Matlab)
        if obj.updater.first_draw %If we are in the normal case (first draw() call)
            if obj.wrap_ncols>0
                obj.facet_axes_handles(ind_row,ind_column)=mysubplot_wrap(length(uni_column),ind_column);
            else
                obj.facet_axes_handles(ind_row,ind_column)=mysubplot(length(uni_row),length(uni_column),ind_row,ind_column);
            end            
        else %If we are in a draw() call after an update() call
            if obj.updater.facet_updated==1 %If faceting was updated from one to multiple facets
                if ind_column==1 && ind_row==1 %If we are in the first facet
                    %We don't need to create it again, it exists
                    %axes(obj.facet_axes_handles(ind_row,ind_column));
                    %Store content of first facet for copying it on the other facets !
                    first_axes_children=allchild(obj.facet_axes_handles(ind_row,ind_column));
                else
                    %We need to create the next facets because they don't exist
                    if obj.wrap_ncols>0
                        obj.facet_axes_handles(ind_row,ind_column)=mysubplot_wrap(length(uni_column),ind_column);
                    else
                        obj.facet_axes_handles(ind_row,ind_column)=mysubplot(length(uni_row),length(uni_column),ind_row,ind_column);
                    end
                    %And we copy the contents of the first facet in the new ones
                    copyobj(first_axes_children,obj.facet_axes_handles(ind_row,ind_column));
                end
            %else
                %In other cases (same facets or multiple to
                %one facet), the facets already exist
                %axes(obj.facet_axes_handles(ind_row,ind_column));
            end
            
            if obj.updater.facet_updated==-1 %If facets were updated from many to one facets
                if ind_column==1 && ind_row==1
                    %We store the current content of the first
                    %facet so that we can check which new
                    %things are going to be drawn in
                    first_axes_children=allchild(obj.facet_axes_handles(ind_row,ind_column));
                end
            end
        end
        
        %Make axes current
         axes(obj.facet_axes_handles(ind_row,ind_column));
        
        
        hold on
        
        
        %Store all the X used for the current facet (useful for
        %correct spacing of dodged bars and boxplots when
        %missing data).
        draw_data.facet_x=temp_aes.x(sel_column);
        
        %Store data for advanced dodging
        [dodge_data.fallback,dodge_data.x,dodge_data.color,dodge_data.lightness,dodge_data.ind,dodge_data.n]=dodge_comp(temp_aes.x(sel_column),temp_aes.color(sel_column),temp_aes.lightness(sel_column),uni_color,uni_lightness);
        
        %Loop over point shapes
        for ind_marker=1:length(uni_marker)
            
            sel_marker=sel_column & multi_sel(temp_aes.marker,uni_marker{ind_marker});
            
            %Loop over line types
            for ind_linestyle=1:length(uni_linestyle)
                
                sel_linestyle=sel_marker & multi_sel(temp_aes.linestyle,uni_linestyle{ind_linestyle});
                
                %Loop over sizes
                for ind_size=1:length(uni_size)
                    
                    sel_size=sel_linestyle & multi_sel(temp_aes.size,uni_size{ind_size});
                    
                    %Loop over colors
                    for ind_color=1:length(uni_color)
                        
                        if obj.continuous_color
                            sel_color=sel_size;
                        else
                            sel_color=sel_size & multi_sel(temp_aes.color,uni_color{ind_color});
                        end
                        
                        %loop over lightness
                        for ind_lightness=1:length(uni_lightness)
                            
                            sel_lightness=sel_color & multi_sel(temp_aes.lightness,uni_lightness{ind_lightness});
                            
                            %We create the groups only within lightness and subplots for speed
                            uni_group=unique_and_sort(temp_aes.group(sel_lightness),0);
                            if isnumeric(uni_group)
                                uni_group=num2cell(uni_group);
                            end
                            
                            %Select dodging parameters for current color
                            %and lightness
                            if obj.continuous_color
                                sel_dodge=true(size(dodge_data.color));
                            else
                                sel_dodge=multi_sel(dodge_data.color,uni_color{ind_color}) & multi_sel(dodge_data.lightness,uni_lightness{ind_lightness});
                            end
                            
                            draw_data.dodge_fallback=dodge_data.fallback;
                            draw_data.dodge_x=dodge_data.x(sel_dodge);
                            draw_data.dodge_ind=dodge_data.ind(sel_dodge);
                            draw_data.dodge_n=dodge_data.n(sel_dodge);
                            
                            %Loop over groups
                            for ind_group=1:length(uni_group)
                                
                                sel=sel_lightness & multi_sel(temp_aes.group,uni_group{ind_group});
                                
                                %Fill out results struct
                                obj.results.row{obj.result_ind}=uni_row{ind_row};
                                obj.results.column{obj.result_ind}=uni_column{ind_column};
                                obj.results.marker{obj.result_ind}=uni_marker{ind_marker};
                                obj.results.linestyle{obj.result_ind}=uni_linestyle{ind_linestyle};
                                obj.results.size{obj.result_ind}=uni_size{ind_size};
                                obj.results.color{obj.result_ind}=uni_color{ind_color};
                                obj.results.lightness{obj.result_ind}=uni_lightness{ind_lightness};
                                obj.results.group{obj.result_ind}=uni_group{ind_group};
                                
                                obj.results.ind_row{obj.result_ind}=ind_row;
                                obj.results.ind_column{obj.result_ind}=ind_column;
                                obj.results.ind_marker{obj.result_ind}=ind_marker;
                                obj.results.ind_linestyle{obj.result_ind}=ind_linestyle;
                                obj.results.ind_size{obj.result_ind}=ind_size;
                                obj.results.ind_color{obj.result_ind}=ind_color;
                                obj.results.ind_lightness{obj.result_ind}=ind_lightness;
                                obj.results.ind_group{obj.result_ind}=ind_group;
                                
                                
                                
                                if ~isempty(sel)
                                    
                                    %Fill up the draw_data
                                    %structure passed to the
                                    %individual geoms
                                    draw_data.x=temp_aes.x(sel);
                                    draw_data.y=temp_aes.y(sel);
                                    if ~isempty(temp_aes.ymin) && ~isempty(temp_aes.ymax)
                                        draw_data.ymin=temp_aes.ymin(sel);
                                        draw_data.ymax=temp_aes.ymax(sel);
                                    else
                                        draw_data.ymin=[];
                                        draw_data.ymax=[];
                                    end
                                    if ~isempty(temp_aes.z)
                                        draw_data.z=temp_aes.z(sel);
                                    else
                                        draw_data.z=[];
                                    end
                                    draw_data.continuous_color=temp_aes.color(sel);
                                    draw_data.color=cmap((ind_color-1)*length(uni_lightness)+ind_lightness,:);
                                    draw_data.marker=markers{1+mod(ind_marker-1,length(markers))};
                                    draw_data.line_style=line_styles{1+mod(ind_linestyle-1,length(line_styles))};
                                    draw_data.size=sizes(ind_size);
                                    draw_data.color_index=(ind_color-1)*length(uni_lightness)+ind_lightness;
                                    draw_data.n_colors=length(uni_color)*length(uni_lightness);
                                    
                                    
                                    %Loop over geoms
                                    for geom_ind=1:length(obj.geom)
                                        
                                        %Call each geom !
                                        obj.geom{geom_ind}(draw_data);
                                        
                                    end
                                    obj.firstrun(obj.current_row,obj.current_column)=0;
                                    
                                    draw_data=rmfield(draw_data,{'x','y','z','continuous_color','color_index','n_colors'});
                                    obj.results.draw_data{obj.result_ind}=draw_data;
                                    
                                    %Iterate loop counter
                                    obj.result_ind=obj.result_ind+1;
                                end
                                
                                
                            end
                        end
                    end
                end
            end
        end
        
        %Set colormap of subplot if needed
        if obj.continuous_color
            colormap(obj.continuous_color_colormap);
        end
        
        
        %Show facet values in titles
        if obj.updater.first_draw || obj.updater.facet_updated
            if length(uni_column)>1
                if ~isempty(obj.aes_names.column)
                    column_string=[obj.aes_names.column ': ' num2str(uni_column{ind_column})];
                else
                    column_string=num2str(uni_column{ind_column});
                end
                
                if ind_row==1
                    obj.facet_text_handles=[obj.facet_text_handles ...
                        text('Interpreter','none','String',column_string,'Rotation',0,...
                        'Units','normalized',...
                        'Position',[0.5 1.05 2],...
                        'BackgroundColor','none',...
                        'HorizontalAlignment','Center',...
                        'VerticalAlignment','bottom',...
                        'FontWeight','bold',...
                        'fontSize',12,...
                        'Parent',obj.facet_axes_handles(ind_row,ind_column))];
                end
            end
            if length(uni_row)>1
                if ~isempty(obj.aes_names.row)
                    row_string=[obj.aes_names.row ': ' num2str(uni_row{ind_row})];
                else
                    row_string=num2str(uni_row{ind_row});
                end
                
                if ind_column==length(uni_column)
                    obj.facet_text_handles=[obj.facet_text_handles ...
                        text('Interpreter','none','String',row_string,'Rotation',-90,...
                        'Units','normalized',...
                        'Position',[1.05 0.5 2],...
                        'BackgroundColor','none',...
                        'HorizontalAlignment','Center',...
                        'VerticalAlignment','bottom',...
                        'FontWeight','bold',...
                        'fontSize',12,...
                        'Parent',obj.facet_axes_handles(ind_row,ind_column))];
                end
            end
        end
        
    end
    
end

%% draw() Title
if ~isempty(obj.title) && obj.updater.first_draw
    obj.title_axe_handle=axes('Position',[obj.multi.orig(2)+0.1*obj.multi.size(2)...
        obj.multi.orig(1)+0.90*obj.multi.size(1) 0.8*obj.multi.size(2) 0.05*obj.multi.size(1)],...
        'Parent',obj.parent);
    
    set(obj.title_axe_handle,'Visible','off','XLim',[-1 1],'YLim',[-1 1]);
    obj.title_text_handle=text(0,0,obj.title,'FontWeight','bold','Interpreter','none','fontSize',14,'HorizontalAlignment','center','Parent',obj.title_axe_handle);
    if ~isempty(obj.title_options)
        set(obj.title_text_handle,obj.title_options{:});
    end
else
    obj.title_axe_handle=[];
end

%% draw() legends

%Create axes for legends
if obj.updater.first_draw
    obj.legend_axe_handle=axes('Position',[obj.multi.orig(2)+0.85*obj.multi.size(2)...
        obj.multi.orig(1)+0.1*obj.multi.size(1) 0.15*obj.multi.size(2) 0.8*obj.multi.size(1)],...
        'Parent',obj.parent);
    hold on
    set(obj.legend_axe_handle,'Visible','off','NextPlot','add');
else
    axes(obj.legend_axe_handle)
end

legend_y_step=1;
legend_y_additional_step=0.5;

if obj.with_legend
    %Color legend
    if length(uni_color)>1
        %Make a colormap with only the colors and no lightness
        color_legend_map=get_colormap(length(uni_color),1,obj.color_options);
        
        obj.legend_text_handles=[obj.legend_text_handles...
            text(1,obj.legend_y,obj.aes_names.color,'FontWeight','bold','Interpreter','none','fontSize',12,'Parent',obj.legend_axe_handle)];
        obj.legend_y=obj.legend_y-legend_y_step;
        for ind_color=1:length(uni_color)
            plot([1 2],[obj.legend_y obj.legend_y],'-','Color',color_legend_map(ind_color,:),'lineWidth',3,'Parent',obj.legend_axe_handle)
            %line(1.5,obj.legend_y,'lineStyle','none','Marker','s','MarkerSize',12,'MarkerFaceColor',color_legend_map(ind_color,:),'MarkerEdgeColor','none')
            %rectangle('Position',[1.25 obj.legend_y-0.25 0.5 0.5],'EdgeColor','none','FaceColor',color_legend_map(ind_color,:));
            obj.legend_text_handles=[obj.legend_text_handles...
                text(2.5,obj.legend_y,num2str(uni_color{ind_color}),'Interpreter','none','Parent',obj.legend_axe_handle)];
            obj.legend_y=obj.legend_y-legend_y_step;
        end
    end
    
    
    %Lightness legend
    if length(uni_lightness)>1
        obj.legend_y=obj.legend_y-legend_y_additional_step;
        
        lightness_legend_map=pa_LCH2RGB([linspace(obj.color_options.lightness_range(1),obj.color_options.lightness_range(2),length(uni_lightness))' ...
            zeros(length(uni_lightness),1)...
            zeros(length(uni_lightness),1)]);
        obj.legend_text_handles=[obj.legend_text_handles...
            text(1,obj.legend_y,obj.aes_names.lightness,'FontWeight','bold','Interpreter','none','fontSize',12,'Parent',obj.legend_axe_handle)];
        obj.legend_y=obj.legend_y-legend_y_step;
        for ind_lightness=1:length(uni_lightness)
            plot([1 2],[obj.legend_y obj.legend_y],'-','Color',lightness_legend_map(ind_lightness,:),'lineWidth',3,'Parent',obj.legend_axe_handle)
            %line(1.5,obj.legend_y,'lineStyle','none','Marker','s','MarkerSize',12,'MarkerFaceColor',lightness_legend_map(ind_lightness,:),'MarkerEdgeColor','none')
            obj.legend_text_handles=[obj.legend_text_handles...
                text(2.5,obj.legend_y,num2str(uni_lightness{ind_lightness}),'Interpreter','none','Parent',obj.legend_axe_handle)];
            obj.legend_y=obj.legend_y-legend_y_step;
        end
    end
    
    %Continuous color legend
    if obj.continuous_color
        obj.legend_y=obj.legend_y-legend_y_additional_step;
        
        obj.legend_text_handles=[obj.legend_text_handles...
            text(1,obj.legend_y,obj.aes_names.color,'FontWeight','bold','Interpreter','none','fontSize',12,'Parent',obj.legend_axe_handle)];
        
        obj.legend_y=obj.legend_y-legend_y_step; %HACK here, we have to multiply by 2 ??
        
        %                 image(ones(1,length(obj.continuous_color_colormap))+0.5,...
        %                     linspace(obj.legend_y-2,obj.legend_y,length(obj.continuous_color_colormap)),...
        %                     reshape(obj.continuous_color_colormap,length(obj.continuous_color_colormap),1,3));
        
        tmp_N=100;
        imagesc([1 1.5],[obj.legend_y-legend_y_step*2 obj.legend_y],linspace(min(min(obj.plot_lim.minc)),max(max(obj.plot_lim.maxc)),tmp_N)','Parent',obj.legend_axe_handle);
        
        line([1.8 2.2 ; 1.8 2.2 ;1.8  2.2]',[obj.legend_y obj.legend_y;obj.legend_y-legend_y_step obj.legend_y-legend_y_step ;obj.legend_y-legend_y_step*2 obj.legend_y-legend_y_step*2 ]','Color','k','Parent',obj.legend_axe_handle)
        
        colormap(obj.continuous_color_colormap)
        caxis([min(min(obj.plot_lim.minc)) max(max(obj.plot_lim.maxc))]);
        
        obj.legend_text_handles=[obj.legend_text_handles...
            text(2.5,obj.legend_y,num2str(max(max(obj.plot_lim.maxc))),'Parent',obj.legend_axe_handle)];
        
        obj.legend_text_handles=[obj.legend_text_handles...
            text(2.5,obj.legend_y-legend_y_step,num2str((max(max(obj.plot_lim.maxc))+min(min(obj.plot_lim.minc)))/2),'Parent',obj.legend_axe_handle)];
        
        obj.legend_text_handles=[obj.legend_text_handles...
            text(2.5,obj.legend_y-legend_y_step*2,num2str(min(min(obj.plot_lim.minc))),'Parent',obj.legend_axe_handle)];
        
        obj.legend_y=obj.legend_y-legend_y_step*3;
    end
    
    %marker legend
    if length(uni_marker)>1
        obj.legend_y=obj.legend_y-legend_y_additional_step;
        
        obj.legend_text_handles=[obj.legend_text_handles...
            text(1,obj.legend_y,obj.aes_names.marker,'FontWeight','bold','Interpreter','none','fontSize',12,'Parent',obj.legend_axe_handle)];
        obj.legend_y=obj.legend_y-legend_y_step;
        for ind_marker=1:length(uni_marker)
            plot(1.5,obj.legend_y,markers{ind_marker},'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0],'Parent',obj.legend_axe_handle)
            obj.legend_text_handles=[obj.legend_text_handles...
                text(2.5,obj.legend_y,num2str(uni_marker{ind_marker}),'Interpreter','none','Parent',obj.legend_axe_handle)];
            obj.legend_y=obj.legend_y-legend_y_step;
        end
    end
    
    %linestyle legend
    if length(uni_linestyle)>1
        obj.legend_y=obj.legend_y-legend_y_additional_step;
        
        obj.legend_text_handles=[obj.legend_text_handles...
            text(1,obj.legend_y,obj.aes_names.linestyle,'FontWeight','bold','Interpreter','none','fontSize',12,'Parent',obj.legend_axe_handle)];
        obj.legend_y=obj.legend_y-legend_y_step;
        for ind_linestyle=1:length(uni_linestyle)
            plot([1 2],[obj.legend_y obj.legend_y],line_styles{ind_linestyle},'Color',[0 0 0],'Parent',obj.legend_axe_handle)
            obj.legend_text_handles=[obj.legend_text_handles...
                text(2.5,obj.legend_y,num2str(uni_linestyle{ind_linestyle}),'Interpreter','none','Parent',obj.legend_axe_handle)];
            obj.legend_y=obj.legend_y-legend_y_step;
        end
    end
    
    %Size legend
    if length(uni_size)>1
        obj.legend_y=obj.legend_y-legend_y_additional_step;
        
        obj.legend_text_handles=[obj.legend_text_handles...
            text(1,obj.legend_y,obj.aes_names.size,'FontWeight','bold','Interpreter','none','fontSize',12,'Parent',obj.legend_axe_handle)];
        obj.legend_y=obj.legend_y-legend_y_step;
        for ind_size=1:length(uni_size)
            plot([1 2],[obj.legend_y obj.legend_y],'lineWidth',sizes(ind_size)/4,'Color',[0 0 0],'Parent',obj.legend_axe_handle)
            plot(1.5,obj.legend_y,'o','markerSize',sizes(ind_size),'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0],'Parent',obj.legend_axe_handle)
            obj.legend_text_handles=[obj.legend_text_handles...
                text(2.5,obj.legend_y,num2str(uni_size{ind_size}),'Interpreter','none','Parent',obj.legend_axe_handle)];
            obj.legend_y=obj.legend_y-legend_y_step;
        end
    end
end
%Set size of legend axes
set(obj.legend_axe_handle,'XLim',[1 8])
%xlim([1 8])
if obj.legend_y<0
    set(obj.legend_axe_handle,'YLim',[obj.legend_y 1])
    %ylim([obj.legend_y 1])
end


%If we go from many to one facet, the new content is drawn only
%on the first facet so needs to be copied in the other one
if obj.updater.facet_updated==-1
    %Get all content from the first facet
    new_first_axes_children=allchild(obj.facet_axes_handles(1,1));
    %Check what is new there by comparing the handles with the
    %ones we stored before drawing new content
    todraw=setdiff(new_first_axes_children,first_axes_children);
    %Copy the new stuff to all other facets
    for k=2:numel(obj.facet_axes_handles)
        copyobj(todraw,obj.facet_axes_handles(k));
    end
end

%% draw() axes modifications

%Set various properties on each of the subplots
for ind_row=1:length(uni_row) %Loop over rows
    
    for ind_column=1:length(uni_column) %Loop over columns
        
        %Set current axes
        ca = obj.facet_axes_handles(ind_row,ind_column);
        

        
        if obj.continuous_color
            %Set color limits the same way on each plot
            set(ca,'CLimMode','manual','CLim',[min(min(obj.plot_lim.minc)) max(max(obj.plot_lim.maxc))]);
        end
        
        
        %Ad hoc limit correction for empty facets
        obj.plot_lim.maxy(obj.plot_lim.miny==obj.plot_lim.maxy)=obj.plot_lim.maxy(obj.plot_lim.miny==obj.plot_lim.maxy)+0.01;
        obj.plot_lim.maxx(obj.plot_lim.minx==obj.plot_lim.maxx)=obj.plot_lim.maxx(obj.plot_lim.minx==obj.plot_lim.maxx)+0.01;
        obj.plot_lim.maxz(obj.plot_lim.minz==obj.plot_lim.maxz)=obj.plot_lim.maxz(obj.plot_lim.minz==obj.plot_lim.maxz)+0.01;
        
        
        if ~obj.polar.is_polar % XY Limits are only useful for non-polar plots
            
            %Set axes limits logic according to facet_scale and
            %wrapping. Also set up corresponding axis linking, using tip from
            % http://undocumentedmatlab.com/blog/using-linkaxes-vs-linkprop#more-5928
            if (obj.wrap_ncols>0)
                switch obj.facet_scale
                    case 'fixed'
                        temp_xscale='global';
                        temp_yscale='global';
                        temp_zscale='global';
                        
                        %Both XLims and YLims are linked across
                        %all plots
                        if ind_row==1 && ind_column==1
                            obj.extra.YLim_listeners=linkprop(obj.facet_axes_handles(:),'YLim');
                            obj.extra.XLim_listeners=linkprop(obj.facet_axes_handles(:),'XLim');
                            obj.extra.ZLim_listeners=linkprop(obj.facet_axes_handles(:),'ZLim');
                        end
                    case 'free_x'
                        temp_xscale='per_plot';
                        temp_yscale='global';
                        temp_zscale='global';
                        
                        %XLims are linked across all plots
                        if ind_row==1 && ind_column==1
                            obj.extra.YLim_listeners=linkprop(obj.facet_axes_handles(:),'YLim');
                        end
                    case 'free_y'
                        temp_xscale='global';
                        temp_yscale='per_plot';
                        temp_zscale='global';
                        
                        %YLims are linked across all plots
                        if ind_row==1 && ind_column==1
                            obj.extra.XLim_listeners=linkprop(obj.facet_axes_handles(:),'XLim');
                        end
                    case 'free'
                        temp_xscale='per_plot';
                        temp_yscale='per_plot';
                        temp_zscale='per_plot';
                    case 'independent'
                        temp_xscale='per_plot';
                        temp_yscale='per_plot';
                        temp_zscale='per_plot';
                end
            else
                switch obj.facet_scale
                    case 'fixed'
                        temp_xscale='global';
                        temp_yscale='global';
                        temp_zscale='global';
                        
                        %Both XLim and YLim are linked across
                        %all plots
                        if ind_row==1 && ind_column==1
                            obj.extra.YLim_listeners=linkprop(obj.facet_axes_handles(:),'YLim');
                            obj.extra.XLim_listeners=linkprop(obj.facet_axes_handles(:),'XLim');
                            obj.extra.ZLim_listeners=linkprop(obj.facet_axes_handles(:),'ZLim');
                        end
                    case 'free_x'
                        temp_xscale='per_column';
                        temp_yscale='global';
                        temp_zscale='global';
                        
                        %YLims are linked across all plots,
                        %XLims are linked within columns
                        if ind_row==1 && ind_column==1
                            obj.extra.YLim_listeners=linkprop(obj.facet_axes_handles(:),'YLim');
                        end
                        if ind_row==1
                            obj.extra.XLim_listeners(ind_column)=linkprop(obj.facet_axes_handles(:,ind_column),'XLim');
                        end
                    case 'free_y'
                        temp_xscale='global';
                        temp_yscale='per_row';
                        temp_zscale='global';
                        
                        %XLims are linked across all plots,
                        %YLims are linked within rows
                        if ind_row==1 && ind_column==1
                            obj.extra.XLim_listeners=linkprop(obj.facet_axes_handles(:),'XLim');
                        end
                        if ind_column==1
                            obj.extra.YLim_listeners(ind_row)=linkprop(obj.facet_axes_handles(ind_row,:),'YLim');
                        end
                    case 'free'
                        temp_xscale='per_column';
                        temp_yscale='per_row';
                        
                        %XLims are linked within columns
                        %YLims are linked within rows
                        if ind_row==1
                            obj.extra.XLim_listeners(ind_column)=linkprop(obj.facet_axes_handles(:,ind_column),'XLim');
                        end
                        if ind_column==1
                            obj.extra.YLim_listeners(ind_row)=linkprop(obj.facet_axes_handles(ind_row,:),'YLim');
                        end
                    case 'independent'
                        temp_xscale='per_plot';
                        temp_yscale='per_plot';
                        temp_zscale='per_plot';
                end
            end
            
            
            
            %Actually set the axes scales and presence of
            %labels depending on logic determined above
            switch temp_xscale
                case 'global'
                    temp_xlim=[min(min(obj.plot_lim.minx(:,:))) max(max(obj.plot_lim.maxx(:,:)))];
                case 'per_column'
                    temp_xlim=[min(obj.plot_lim.minx(:,ind_column)) max(obj.plot_lim.maxx(:,ind_column))];
                case 'per_plot'
                    temp_xlim=[obj.plot_lim.minx(ind_row,ind_column) obj.plot_lim.maxx(ind_row,ind_column)];
            end
            if sum(isnan(temp_xlim))==0
                set(ca,'XLim',temp_xlim+[-diff(temp_xlim)*obj.xlim_extra*0.5 diff(temp_xlim)*obj.xlim_extra*0.5]);
            end
            
            switch temp_yscale
                case 'global'
                    temp_ylim=[min(min(obj.plot_lim.miny(:,:))) max(max(obj.plot_lim.maxy(:,:)))];
                case 'per_row'
                    temp_ylim=[min(obj.plot_lim.miny(ind_row,:)) max(obj.plot_lim.maxy(ind_row,:))];
                case 'per_plot'
                    temp_ylim=[obj.plot_lim.miny(ind_row,ind_column) obj.plot_lim.maxy(ind_row,ind_column)];
            end
            if sum(isnan(temp_ylim))==0
                set(ca,'YLim',temp_ylim+[-diff(temp_ylim)*obj.ylim_extra*0.5 diff(temp_ylim)*obj.ylim_extra*0.5]);
            end
            
            if ~isempty(temp_aes.z) %Only do the Z limit stuff if we have z data
                
                switch temp_zscale
                    case 'global'
                        temp_zlim=[min(min(obj.plot_lim.minz(:,:))) max(max(obj.plot_lim.maxz(:,:)))];
                    case 'per_plot'
                        temp_zlim=[obj.plot_lim.minz(ind_row,ind_column) obj.plot_lim.maxz(ind_row,ind_column)];
                end
                set(ca,'ZLim',temp_zlim+[-diff(temp_zlim)*obj.zlim_extra*0.5 diff(temp_zlim)*obj.zlim_extra*0.5]);
                
                %Always have ticks if we have z data
                has_xtick=true;
                has_ytick=true;
                
            else %Only do optional xy ticks if we don't have z data
                
                %Set up logic of plot ticks presence
                has_xtick=obj.force_ticks || ... %Plot has xticks if forced
                    (obj.wrap_ncols==-1 && ind_row==length(uni_row)) || ... %Or if we're in facet grid mode and we are in the last row
                    (obj.wrap_ncols>0 && (length(uni_column)-ind_column)<obj.wrap_ncols) ||... %Or if we are in facet wrap mode and we are in the last facet on the "column"
                    strcmp(temp_xscale,'per_plot'); %Or if we were in a per-plot scale mode
                
                has_ytick=obj.force_ticks || ... %Plot has xticks if forced
                    (obj.wrap_ncols==-1 && ind_column==1) || ... %Or if we're in facet grid mode and are in the first column
                    (obj.wrap_ncols>0 && mod(ind_column,obj.wrap_ncols)==1) || ... %Or if we are in facet wrap mode and are in the first "column"
                    strcmp(temp_yscale,'per_plot'); %Or if we were in a per-plot scale mode
            end
            
            %Remove ticks if necessary
            if ~has_xtick
                set(ca,'XTickLabel','');
            end
            if ~has_ytick
                set(ca,'YTickLabel','');
            end
            
            
            %Set appropriate x ticks if labeled
            if obj.x_factor
                temp_xlim=get(ca,'xlim');
                set(ca,'XLim',[temp_xlim(1)-0.6 temp_xlim(2)+0.6]);
                set(ca,'XTick',1:length(obj.x_ticks))
                if has_xtick
                    set(ca,'XTickLabel',obj.x_ticks)
                    if isprop(ca,'TickLabelInterpreter') %Just try it (doesn't exist in pre-2014b)
                        set(ca,'TickLabelInterpreter','none')
                    end
                end
            end
            
            %Add axes labels on right and botttom graphs only
            if ind_column==1 || (obj.wrap_ncols>0 && mod(ind_column,obj.wrap_ncols)==1) || ~isempty(temp_aes.z)
                ylabel(ca,obj.aes_names.y,'Interpreter','none'); %,'Units','normalized','position',[-0.2 0.5 1]
            end
            if (ind_row==length(uni_row) && obj.wrap_ncols<=0) || (obj.wrap_ncols>0 && (length(uni_column)-ind_column)<obj.wrap_ncols) || ~isempty(temp_aes.z)
                xlabel(ca,obj.aes_names.x,'Interpreter','none')
            end
            %If we have z data
            if ~isempty(temp_aes.z)
                zlabel(ca,obj.aes_names.z,'Interpreter','none') %Ass z label
                view(ca,3); %Reset the view so that it is a 3D view
                if ind_row==1 && ind_column==1
                    %Link the camera properties between the
                    %facets so that they all rotate together
                    obj.extra.CamPos_listeners=linkprop(obj.facet_axes_handles(:),'CameraPosition');
                    obj.extra.CamTgt_listeners=linkprop(obj.facet_axes_handles(:),'CameraTarget');
                    obj.extra.CamUp_listeners=linkprop(obj.facet_axes_handles(:),'CameraUpVector');
                end
            end
            
        else
            %Make polar axes
            if obj.polar.max_polar_y<0
                if strcmp(obj.facet_scale,'fixed')
                    draw_polar_axes(ca,max(max(obj.plot_lim.maxy(:,:))));
                else
                    draw_polar_axes(ca,obj.plot_lim.maxy(ind_row,ind_column));
                end
            else
                draw_polar_axes(ca,obj.polar.max_polar_y)
            end
        end
        
        
        %Set custom axes properties
        if ~isempty(obj.axe_properties)
            for ap=1:size(obj.axe_properties,1)
                if isprop(ca,obj.axe_properties{ap,1})
                    set(ca,obj.axe_properties{ap,1},obj.axe_properties{ap,2})
                else
                    warning(['Improper ''' obj.axe_properties{ap,1} ''' custom axe property'])
                end
            end
        end
        
        %Do the datetick
        if ~isempty(obj.datetick_params)
            for dtk=1:length(obj.datetick_params)
                datetick(ca,obj.datetick_params{dtk}{:},'keepticks');
            end
        end
        
        %Set ablines, hlines and vlines (after axe properties in case the limits
        %are changed there
        if obj.abline.on
            xl=get(ca,'xlim');
            for line_ind=1:length(obj.abline.intercept)
                if ~isnan(obj.abline.intercept(line_ind))
                    %abline
                    plot(xl,xl*obj.abline.slope(line_ind)+obj.abline.intercept(line_ind),obj.abline.style{line_ind},'Parent',ca);
                else
                    if ~isnan(obj.abline.xintercept(line_ind))
                        %vline
                        yl=get(ca,'ylim');
                        plot([obj.abline.xintercept(line_ind) obj.abline.xintercept(line_ind)],yl,obj.abline.style{line_ind},'Parent',ca);
                    else
                        if ~isnan(obj.abline.yintercept(line_ind))
                            %hline
                            plot(xl,[obj.abline.yintercept(line_ind) obj.abline.yintercept(line_ind)],obj.abline.style{line_ind},'Parent',ca);
                        else
                            temp_x=linspace(xl(1),xl(2),100);
                            plot(temp_x,obj.abline.fun{line_ind}(temp_x),obj.abline.style{line_ind},'Parent',ca);
                        end
                    end
                end
            end
            
        end
        
        
    end
end


%White background !
set(gcf,'color','w');

% Make everything tight and set the resize function so that it stays so
if do_redraw  && ~obj.multi.active %Redrawing for multiple plots is handled at the beginning of draw()
    redraw(obj,0.04);
    if verLessThan('matlab','8.4')
        set(gcf,'ResizeFcn',@(a,b)redraw(obj,0.04));
    else
        set(gcf,'SizeChangedFcn',@(a,b)redraw(obj,0.04));
    end
end


%Clean up results
result_fields=fieldnames(obj.results);
if obj.result_ind>1
    for rf=1:length(result_fields)
        %Resize
        obj.results.(result_fields{rf})=obj.results.(result_fields{rf})(1:obj.result_ind-1);
        %Transform non cell strings in arrays
        if ~iscellstr(obj.results.(result_fields{rf}))
            obj.results.(result_fields{rf})=[obj.results.(result_fields{rf}){:}]';
        end
    end
else
    obj.results=[];
end

%There are bugs with the openGL renderer in pre 2014b version,
%on Mac OS and Win the x and y axes become invisible and on
%Windows the patch objects behave strangely. So we switch to
%painters renderer
if verLessThan('matlab','8.4')
    warning('Pre-2014b version detected, forcing to ''Painters'' renderer which is less buggy. Use set(gcf,''Renderer'',''OpenGL'') to restore transparency')
    set(gcf,'Renderer','Painters')
end

obj.updater.first_draw=false;
end

function out=allmax(in)
%Return maximum of an array or of a cell of arrays
if iscell(in)
    out=max(cellfun(@max,in(~cellfun(@isempty,in)))); %Cellfun on non empty cells
else
    out=max(in);
end
end

function out=allmin(in)
%Return minimum of an array or of a cell of arrays
if iscell(in)
    out=min(cellfun(@min,in(~cellfun(@isempty,in))));  %Cellfun on non empty cells
else
    out=min(in);
end
end