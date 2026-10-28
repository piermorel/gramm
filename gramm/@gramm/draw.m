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
% call for the redraw() function when the figure is resized.
% To draw a gramm plot in a tile of a tiledlayout, see set_parent().

%We set redraw() as resize callback by default
if nargin<2
    do_redraw=obj(1).layout_options.redraw;
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

    nl=size(obj,1);
    nc=size(obj,2);
    
    %Empty elements of the array are never drawn: the array is drawn for
    %the first time when none of its elements has been drawn
    first_draw=arrayfun(@(o) o.updater.first_draw,obj);
    if all(first_draw(:))
        %The layout holding the gramm plots goes in the parent (figure,
        %panel, or tile of a tiledlayout)
        bigtile = tiledlayout(obj(1).parent,nl,nc,'Padding',obj(1).layout_options.multi_padding,'TileSpacing',obj(1).layout_options.multi_spacing);
        if isa(obj(1).parent,'matlab.graphics.layout.TiledChartLayout')
            bigtile.Layout.Tile=obj(1).parent_tile.tile;
            bigtile.Layout.TileSpan=obj(1).parent_tile.span;
        end

        bigtile.Title.String = obj(1).bigtitle;
        bigtile.Title.FontWeight='bold';
        bigtile.Title.FontSize= obj(1).text_options.base_size*obj(1).text_options.big_title_scaling;
        bigtile.Title.Interpreter=obj(1).text_options.interpreter;
        if ~isempty(obj(1).bigtitle_options)
            set(bigtile.Title,obj(1).bigtitle_options{:});
        end
    else
        %Later draws: elements drawn for the first time go in the layout
        %holding the elements already drawn
        bigtile=obj(find(~first_draw,1)).layout.Parent;
    end

    for l=1:nl
        for c=1:nc
            if obj(l,c).updater.first_draw
                obj(l,c).multi.active=true;
                obj(l,c).set_parent(bigtile,'tile',[l c]);
            end
            draw(obj(l,c));
        end
    end
    
    %Legend vertical scaling, once the whole layout is known
    for k=1:numel(obj)
        scale_legend(obj(k));
    end

    %Set up redrawing on resize for multiple plots
    if do_redraw
        register_redraw(obj);
    end

    %Redraw once the layout is computed (positions of the elements handled
    %by redraw() and title widths are only known then)
    drawnow;
    redraw(obj);
    return;
end

%If x is empty the object probably is so we skip (happens for multiple graphs)
if isempty(obj.aes.x)
    return
end

%If draw() is called a second time without update() having been
%called we skip (silently for the elements of an array of gramm plots that
%were not updated when the array is drawn again)
if (~obj.updater.first_draw && ~obj.updater.updated)
    if ~obj.multi.active
        warning('Multiple draw() calls need update() calls')
    end
    return
end

[obj.aes,obj.axis_types,obj.cat_order]=validate_aes(obj.aes,obj.axis_types,obj.cat_order);
%Polar angles in degrees are converted to radians along with the other
%angles given to gramm (see to_num())
if obj.polar.is_polar && strcmp(obj.polar.unit,'degrees')
    obj.axis_types.x.unit='deg';
elseif strcmp(obj.axis_types.x.type,'numeric')
    obj.axis_types.x.unit='';
end
check_polar(obj);

%Handle multiple figures
uni_fig=unique_and_sort(obj.aes.fig,natural_order(1,obj.cat_order.fig));
if ~iscell(uni_fig)
    uni_fig=num2cell(uni_fig);
end
if numel(uni_fig)>1 %if multiple figures
    fig_pos=get(ancestor(obj.parent,'figure'),'Position'); %We'll create them with the same location and size as the current figure
    %Convert to a cell
    obj={obj};
    for ind_fig=2:numel(uni_fig) %Make shallow copy of original object
        obj{ind_fig}=copy(obj{1});
    end
    for ind_fig=1:numel(uni_fig) %Loop over objects
        %disp(['Plotting Fig ' num2str(ind_fig)])
        %We plot what we want by setlecting within aes on the basis of fig
        obj{ind_fig}.aes=select_aes(obj{ind_fig}.aes,multi_sel(obj{ind_fig}.aes.fig,uni_fig{ind_fig}));
        % Skip if there is no data
        if any(obj{ind_fig}.aes.subset)
            %Set title
            obj{ind_fig}.set_title([obj{ind_fig}.aes_names.fig ': ' num2str(uni_fig{ind_fig})]);
            %Create figure and do the drawing
            if ind_fig>1
                obj{ind_fig}.parent=figure('Position',fig_pos);
            end
            obj{ind_fig}.draw();
        end
    end
    return;
end

if ~any(obj.aes.subset)
    disp('Empty subset, nothing to draw');
    return;
end

%Apply subset
temp_aes=select_aes(obj.aes,obj.aes.subset);

%Convert factor data to numeric
if iscellstr(temp_aes.x)
    obj.x_factor=true;
    obj.x_ticks=unique_and_sort(temp_aes.x,natural_order(obj.order_options.x,obj.cat_order.x));
    tempx=zeros(length(temp_aes.x),1);
    for k=1:length(obj.x_ticks)
        tempx(strcmp(temp_aes.x,obj.x_ticks{k}))=k;
    end
    if obj.polar.is_polar
        %Categories evenly spread around the circle (radar charts)
        tempx=(tempx-1)*2*pi/length(obj.x_ticks);
    end
    temp_aes.x=tempx;
else
    obj.x_factor=false;
    temp_aes.x=to_num(obj.axis_types.x,temp_aes.x); %Degrees to radians
end


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


%Find uniques in aesthetics and sort according to options
uni_row=unique_and_sort(temp_aes.row,natural_order(obj.order_options.row,obj.cat_order.row));
uni_column=unique_and_sort(temp_aes.column,natural_order(obj.order_options.column,obj.cat_order.column));
uni_linestyle=unique_and_sort(temp_aes.linestyle,natural_order(obj.order_options.linestyle,obj.cat_order.linestyle));
uni_marker=unique_and_sort(temp_aes.marker,natural_order(obj.order_options.marker,obj.cat_order.marker));
uni_lightness=unique_and_sort(temp_aes.lightness,natural_order(obj.order_options.lightness,obj.cat_order.lightness));
uni_size=unique_and_sort(temp_aes.size,natural_order(obj.order_options.size,obj.cat_order.size));

%If the color is in a cell array of doubles, we set it as
%continuous color
if iscell(temp_aes.color) && ~iscellstr(temp_aes.color)
    obj.continuous_color_options.active = true;
else
    uni_color=unique_and_sort(temp_aes.color,natural_order(obj.order_options.color,obj.cat_order.color));
    
    % If continous_color is not set and we have too many numerical values 
    % for the color we switch to continuous color
    if isnan(obj.continuous_color_options.active)
        if length(uni_color)>15 && ~iscellstr(uni_color)
            obj.continuous_color_options.active = true;
        else
            obj.continuous_color_options.active = false;
        end
    elseif iscellstr(uni_color) %We can't have continuous color for cellstr input
        obj.continuous_color_options.active = false;
    end
end
if obj.continuous_color_options.active
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
for fn=1:length(aes_names_fieldnames) 
    if ~any(strcmp(aes_names_fieldnames{fn},{'x' 'y' 'z' 'ymin' 'ymax' 'label' 'fig'})) %We ignore x y z and label
        obj.results.(aes_names_fieldnames{fn})=cell(n_groups,1);
        obj.results.(['ind_' aes_names_fieldnames{fn}])=cell(n_groups,1);
    end
end
obj.results.draw_data=cell(n_groups,1);


obj.firstrun=ones(n_rows,n_columns);
%Index in the loops
obj.result_ind=1;

%Initialize facet axes handles (when going from one to many facets after
%update() this is done once the content of the first facet is copied)
if obj.updater.first_draw
    obj.facet_axes_handles=gobjects(length(uni_row),length(uni_column));
end

%Set the dodge width across all facets
draw_data.dodge_avl_w=min(diff(unique(comb(temp_aes.x))));
if isempty(draw_data.dodge_avl_w) || draw_data.dodge_avl_w==0
    draw_data.dodge_avl_w=1;
end

%Initialize tiled layout object. After update() the existing layout is
%reused, unless we go from one to many facets
if obj.updater.facet_updated==1
    %The content of the single facet and the legend axes are set aside in
    %a hidden figure while the layout is rebuilt (creating a tiledlayout in
    %a figure deletes everything in it)
    tmp_f=figure('Visible','off');
    set(0,'CurrentFigure',ancestor(obj.parent,'figure'));
    if obj.polar.is_polar
        tmp_axes = polaraxes(tmp_f);
    else
        tmp_axes = axes(tmp_f);
    end
    first_axes_children = copyobj(allchild(obj.facet_axes_handles(1,1)),tmp_axes);
    obj.legend_axe_handle.Parent=tmp_f;
    delete(obj.layout);
    obj.facet_axes_handles=gobjects(length(uni_row),length(uni_column));
end
if obj.updater.first_draw || obj.updater.facet_updated==1
    if obj.wrap_ncols>0
        grid=[ceil(length(uni_column)/obj.wrap_ncols) obj.wrap_ncols];
    else
        %Facets may span several tiles (facet_grid() 'space' option)
        [grid,facet_tile,facet_row_span,facet_col_span]=facet_layout(obj,length(uni_row),length(uni_column));
    end
    obj.layout = tiledlayout(obj.parent,grid(1),grid(2));
    if isa(obj.parent,'matlab.graphics.layout.TiledChartLayout')
        obj.layout.Layout.Tile=obj.parent_tile.tile;
        obj.layout.Layout.TileSpan=obj.parent_tile.span;
    end
    obj.facet_row_axes=gobjects(1,0);
    obj.layout.TileSpacing = obj.layout_options.spacing;
    obj.layout.Padding = obj.layout_options.padding;
end

obj.data_size=numel(temp_aes.x);


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
        if obj.updater.first_draw || obj.updater.facet_updated==1
            %First draw() call, or update() from one to many facets: the
            %facets are (re)created in the layout
            if obj.wrap_ncols>0
                obj.facet_axes_handles(ind_row,ind_column)=new_facet_axes(obj,ind_column,[1 1]);
            else
                obj.facet_axes_handles(ind_row,ind_column)=new_facet_axes(obj,facet_tile(ind_row,ind_column),...
                    [facet_row_span(ind_row) facet_col_span(ind_column)]);
            end
            set_rulers(obj,obj.facet_axes_handles(ind_row,ind_column));
            if obj.updater.facet_updated==1
                %Copy the content of the former single facet
                copyobj(first_axes_children,obj.facet_axes_handles(ind_row,ind_column));
            end
        elseif obj.updater.facet_updated==-1 && ind_column==1 && ind_row==1
            %update() from many to one facet: new content is drawn in the
            %first facet only, and copied to the others at the end of
            %draw(). Store what is already there to know what is new.
            first_axes_children=allchild(obj.facet_axes_handles(1,1));
        end
        
        %Make axes current (axes() would make an invisible figure visible;
        %groot can't be used here: the assignment would make it a variable)
        set(0,'CurrentFigure',ancestor(obj.facet_axes_handles(ind_row,ind_column),'figure'));
        set(gcf,'CurrentAxes',obj.facet_axes_handles(ind_row,ind_column));
        
        hold on
        
        %Draw polygons before plotting data, so data isn't covered up
        if obj.polygon.on
            draw_polygons(obj);
        end
   
        
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
                        
                        if obj.continuous_color_options.active
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
                            if obj.continuous_color_options.active
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
                                    if ~isempty(temp_aes.label)
                                        draw_data.label=temp_aes.label(sel);
                                    else
                                        draw_data.label=[];
                                    end
                                    draw_data.continuous_color=temp_aes.color(sel);
                                    draw_data.color=cmap((ind_color-1)*length(uni_lightness)+ind_lightness,:);
                                    draw_data.marker=obj.point_options.markers{1+mod(ind_marker-1,length(obj.point_options.markers))};
                                    draw_data.line_style=obj.line_options.styles{1+mod(ind_linestyle-1,length(obj.line_options.styles))};
                                    draw_data.border_width=obj.point_options.border_width;
                                    if strcmp(obj.point_options.border_color,'auto')
                                        draw_data.border_color=draw_data.color;
                                    else
                                        draw_data.border_color=obj.point_options.border_color;
                                    end
                                    if obj.line_options.use_input
                                        draw_data.line_size=obj.line_options.input_fun(uni_size{ind_size});
                                    else
                                        draw_data.line_size=obj.line_options.base_size+(ind_size-1)*obj.line_options.step_size;
                                    end
                                    if obj.point_options.use_input
                                        draw_data.point_size=obj.point_options.input_fun(uni_size{ind_size});
                                    else
                                        draw_data.point_size=obj.point_options.base_size+(ind_size-1)*obj.point_options.step_size;
                                    end
                                    draw_data.color_index=(ind_color-1)*length(uni_lightness)+ind_lightness;
                                    draw_data.n_colors=length(uni_color)*length(uni_lightness);
                                    
                                    
                                    %Loop over geoms
                                    for geom_ind=1:length(obj.geom)
                                        
                                        %Call each geom !
                                        obj.geom{geom_ind}(obj,draw_data);
                                        
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
        if obj.continuous_color_options.active
            colormap(obj.continuous_color_options.colormap);
        end
        
        
        %Show facet values in titles
        if obj.updater.first_draw || obj.updater.facet_updated
            if length(uni_column)>1 && obj.column_labels
                if ~isempty(obj.aes_names.column)
                    column_string=[obj.aes_names.column ': ' num2str(uni_column{ind_column})];
                else
                    column_string=num2str(uni_column{ind_column});
                end
                
                if ind_row==1
                    obj.facet_axes_handles(ind_row,ind_column).Title.String = column_string;
                    obj.facet_text_handles=[obj.facet_text_handles obj.facet_axes_handles(ind_row,ind_column).Title];
                end
            end
            if length(uni_row)>1  && obj.row_labels
                if ~isempty(obj.aes_names.row)
                    row_string=[obj.aes_names.row ': ' num2str(uni_row{ind_row})];
                else
                    row_string=num2str(uni_row{ind_row});
                end
                
                if ind_column==length(uni_column)
                    
                    %Row titles are the right-side YLabel of an empty axes
                    %placed in the same tile as the facet, so that
                    %tiledlayout reserves their space without touching
                    %the facet axes themselves
                    ca=obj.facet_axes_handles(ind_row,ind_column);
                    row_axe=axes(obj.layout);
                    row_axe.Layout.Tile=ca.Layout.Tile;
                    row_axe.Layout.TileSpan=ca.Layout.TileSpan;
                    set(row_axe,'Visible','off','YAxisLocation','right',...
                        'HitTest','off','PickableParts','none','HandleVisibility','off');
                    row_axe.YLabel.String=row_string;
                    set(row_axe.YLabel,'Interpreter',obj.text_options.interpreter,...
                        'FontName',obj.text_options.font,...
                        'FontSize',obj.text_options.base_size*obj.text_options.facet_scaling,...
                        'FontWeight','bold',...
                        'Rotation',-90,'VerticalAlignment','bottom','Visible','on');
                    obj.facet_text_handles=[obj.facet_text_handles row_axe.YLabel];
                    obj.facet_row_axes(ind_row)=row_axe;
                end
            end
        end
        
    end
    
end

%% draw() Title
if ~isempty(obj.title)
    if obj.updater.first_draw || obj.updater.facet_updated==1

        obj.layout.Title.String = obj.title;
        obj.layout.Title.FontWeight='bold';
        obj.layout.Title.FontSize=obj.text_options.base_size*obj.text_options.title_scaling;
        obj.layout.Title.Interpreter=obj.text_options.interpreter;
        obj.title_text_handle = obj.layout.Title;
        
        if ~isempty(obj.title_options)
            set(obj.title_text_handle,obj.title_options{:});
        end
    end
else
end

%% Compute continuous colormap limits

if obj.continuous_color_options.active
    if isempty(obj.continuous_color_options.CLim)
        obj.continuous_color_options.CLim = [min(min(obj.plot_lim.minc)) max(max(obj.plot_lim.maxc))];
    end
    if obj.continuous_color_options.CLim(1) == obj.continuous_color_options.CLim(2)
        if obj.continuous_color_options.CLim(1) == 0
            obj.continuous_color_options.CLim = [-1 1];
        else
            obj.continuous_color_options.CLim(1) = obj.continuous_color_options.CLim(1) - abs(obj.continuous_color_options.CLim(1))/2;
            obj.continuous_color_options.CLim(2) = obj.continuous_color_options.CLim(2) + abs(obj.continuous_color_options.CLim(2))/2;
        end
    end
end

%% draw() legends

% ensuring grouping variables are cellstrs
str_uni_color = cellfun(@num2str,uni_color,'UniformOutput',false);
str_uni_lightness = cellfun(@num2str,uni_lightness,'UniformOutput',false);
str_uni_linestyle = cellfun(@num2str,uni_linestyle,'UniformOutput',false);
str_uni_size = cellfun(@num2str,uni_size,'UniformOutput',false);
str_uni_marker = cellfun(@num2str,uni_marker,'UniformOutput',false);


%Create axes for legends (after update() the same legend axes is reused and
%the new entries are added below the existing ones)
if obj.updater.first_draw
    if strcmp(obj.layout_options.legend_position,'auto')
        obj.legend_axe_handle=axes(obj.layout);
        obj.legend_axe_handle.Layout.Tile='east';
    else
        obj.legend_axe_handle=axes('Position',obj.layout_options.legend_position,...
                'Parent',ancestor(obj.parent,'figure'));
    end
    hold on
    set(obj.legend_axe_handle,'Visible','off','NextPlot','add');
    obj.legend_axe_handle.Toolbar.Visible = 'off';
    obj.legend_axe_handle.Interactions = [];
elseif obj.updater.facet_updated==1
    %Bring back the legend axes set aside while the layout was rebuilt
    if strcmp(obj.layout_options.legend_position,'auto')
        obj.legend_axe_handle.Parent=obj.layout;
        obj.legend_axe_handle.Layout.Tile='east';
    else
        obj.legend_axe_handle.Parent=ancestor(obj.parent,'figure');
    end
    close(tmp_f);
end

legend_y_step=1;
legend_y_additional_step=0.5;

if obj.layout_options.legend
    
    % Color legend
    % If the color groups are the same as marker, linestyle or size groups
    % then there will be a common legend (handled by the marker, linestyle
    % or size legend).
    if length(str_uni_color)>1 && any(strcmp(obj.color_options.legend,{'separate','separate_gray'})) % && ...
            %~(length(str_uni_color)==length(str_uni_marker) && all(strcmp(str_uni_color, str_uni_marker))) && ...
            %~(length(str_uni_color)==length(str_uni_linestyle) && all(strcmp(str_uni_color, str_uni_linestyle))) && ...
            %~(length(str_uni_color)==length(str_uni_size) && all(strcmp(str_uni_color, str_uni_size)))
        
        %Make a colormap with only the colors and no lightness
        color_legend_map=get_colormap(length(str_uni_color),1,obj.color_options);
        
        fill_legend(obj,obj.aes_names.color,...
            str_uni_color,...
            'line',...
            color_legend_map,...
            'o','-',3,0);
    end
    
    %Lightness legend
    if length(uni_lightness)>1 && any(strcmp(obj.color_options.legend,{'separate','separate_gray','merge'}))
        
        if (ischar(obj.color_options.map) || isstring(obj.color_options.map)) && strcmp(obj.color_options.map,'lch') && strcmp(obj.color_options.legend,'separate_gray')
            %With LCH we can generate a correct desaturated legend
            lightness_legend_map=pa_LCH2RGB([linspace(obj.color_options.lightness_range(1),obj.color_options.lightness_range(2),length(uni_lightness))' ...
                zeros(length(uni_lightness),1)...
                zeros(length(uni_lightness),1)]);
        else
            %Make a colormap with the first color
            lightness_legend_map=get_colormap(1,length(str_uni_lightness),obj.color_options);
        end
        
        fill_legend(obj,obj.aes_names.lightness,...
            str_uni_lightness,...
            'line',...
            lightness_legend_map,...
            'o','-',3,0);
    end
    
    if strcmp(obj.color_options.legend,'expand')
        expanded_legend_map = get_colormap(length(str_uni_color),length(str_uni_lightness),obj.color_options);
        expanded_legend_labels = cell(length(str_uni_color)*length(str_uni_lightness),1);
        for uc = 1:length(str_uni_color)
            for ul = 1:length(str_uni_lightness)
                expanded_legend_labels{ (uc-1) * length(str_uni_lightness) + ul } = [str_uni_color{uc} ' / ' str_uni_lightness{ul} ];
            end
        end
        
        fill_legend(obj, [obj.aes_names.color ' / ' obj.aes_names.lightness],...
            expanded_legend_labels,...
            'line',...
            expanded_legend_map,...
            'o','-',3,0);
    end
    
    %Continuous color legend
    if obj.continuous_color_options.active

        fill_gradient_legend(obj,obj.aes_names.color,...
            linspace(obj.continuous_color_options.CLim(1), obj.continuous_color_options.CLim(2), 3),...
            linspace(obj.continuous_color_options.CLim(1), obj.continuous_color_options.CLim(2), 5),...
            4);
        
    end
    
    %marker legend
    if length(str_uni_marker)>1

        % If marker groups are the same as color groups we combine the
        % legends by drawing each marker legend the corresponding color
        if strcmp(obj.color_options.legend,'merge') && length(str_uni_color)==length(str_uni_marker) && all(strcmp(str_uni_color, str_uni_marker))
            color_legend_map = get_colormap(length(str_uni_marker), 1, obj.color_options);
        else
            color_legend_map = [0 0 0]; %zeros(length(str_uni_marker), 3); %Otherwise in black
        end
        
        
        fill_legend(obj,obj.aes_names.marker,...
            str_uni_marker,...
            'point',...
            color_legend_map,...
            obj.point_options.markers,'-',0,obj.point_options.base_size);
    end
    
    %linestyle legend
    if length(str_uni_linestyle)>1

        % If linestyle groups are the same as color groups we combine the
        % legends by drawing each linestyle legend the corresponding color
        if strcmp(obj.color_options.legend,'merge') && length(str_uni_color)==length(str_uni_linestyle) && all(strcmp(str_uni_color, str_uni_linestyle))
            color_legend_map = get_colormap(length(str_uni_linestyle), 1, obj.color_options);
        else
            color_legend_map = [0 0 0]; %Otherwise in black
        end
        
        
        fill_legend(obj,obj.aes_names.linestyle,...
            str_uni_linestyle,...
            'line',...
            color_legend_map,...
            'o',obj.line_options.styles,3,0);
    end
    
    %Size legend
    if length(str_uni_size)>1

        % If size groups are the same as color groups we combine the
        % legends by drawing each size legend the corresponding color
        if strcmp(obj.color_options.legend,'merge') && length(str_uni_color)==length(str_uni_size) && all(strcmp(str_uni_color, str_uni_size))
            color_legend_map = get_colormap(length(str_uni_size), 1, obj.color_options);
        else
            color_legend_map = [0 0 0]; %Otherwise in black
        end
        
        % Handle cases where sizes are defined by the input calues instead
        % of discrete categories ('use_input' in set_line_options() and set_point_options() ) 
        if obj.line_options.use_input
            temp_lw=obj.line_options.input_fun([uni_size{:}]);
        else
            temp_lw=obj.line_options.base_size+(0:length(str_uni_size)-1)*obj.line_options.step_size;
        end
        if obj.point_options.use_input
            temp_ps=obj.point_options.input_fun([uni_size{:}]);
        else
            temp_ps=obj.point_options.base_size+(0:length(str_uni_size)-1)*obj.point_options.step_size;
        end
        
        fill_legend(obj,obj.aes_names.size,...
            str_uni_size,...
            'both',...
            color_legend_map,...
            'o','-',temp_lw,temp_ps);
    end
end

%Group legend objects
tmp = obj.legend_axe_handle.Children;
if isempty(obj.legend_transform) || ~isvalid(obj.legend_transform)
    obj.legend_transform = hgtransform('Parent',obj.legend_axe_handle);
end
tmp(tmp==obj.legend_transform)=[];
set(tmp,'Parent',obj.legend_transform);
%Like the texts, symbols stay visible outside of the axes limits
set(findobj(tmp,'Type','line'),'Clipping','off');

%Set size of legend axes
set(obj.legend_axe_handle,'XLim',[1 8]);
if obj.legend_y<0
    set(obj.legend_axe_handle,'YLim',[obj.legend_y -obj.legend_y]/2);
end

%Make the tiledlayout reserve the legend width. The vertical scaling
%(scale_legend()) is done at the end of draw(), once the layout is complete
reserve_legend_width(obj);



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

set_axis_labels(obj);

if isempty(obj.aes.z)
    axtoolbar(obj.layout,{'datacursor','pan','zoomin','zoomout','pan','restoreview'});
else
    axtoolbar(obj.layout,{'datacursor','rotate','pan','zoomin','zoomout','pan','restoreview'});
end

%How limits are shared between facets, according to facet_scale and
%wrapping
[temp_xscale,temp_yscale,temp_zscale]=facet_scales(obj);
log_lims(obj);

%Set various properties on each of the subplots
for ind_row=1:length(uni_row) %Loop over rows
    
    for ind_column=1:length(uni_column) %Loop over columns
        
        %Set current axes
        ca = obj.facet_axes_handles(ind_row,ind_column);
        
        set(ca,'FontName',obj.text_options.font,...
            'FontSize',obj.text_options.base_size)
       
        
        if obj.continuous_color_options.active
            %Set color limits the same way on each plot
            set(ca,'CLimMode','manual','CLim',obj.continuous_color_options.CLim);
        end
        
        
        %Ad hoc limit correction for empty facets
        obj.plot_lim.maxy(obj.plot_lim.miny==obj.plot_lim.maxy)=obj.plot_lim.maxy(obj.plot_lim.miny==obj.plot_lim.maxy)+0.01;
        obj.plot_lim.maxx(obj.plot_lim.minx==obj.plot_lim.maxx)=obj.plot_lim.maxx(obj.plot_lim.minx==obj.plot_lim.maxx)+0.01;
        obj.plot_lim.maxz(obj.plot_lim.minz==obj.plot_lim.maxz)=obj.plot_lim.maxz(obj.plot_lim.minz==obj.plot_lim.maxz)+0.01;
        
        temp_ylim=facet_lim(obj,'y',temp_yscale,ind_row,ind_column);
        
        if obj.polar.is_polar
            %The radius spans from 0 (or the negative minimum) to the
            %maximum, the angle the full circle
            temp_ylim=[min(0,temp_ylim(1)) temp_ylim(2)+diff(temp_ylim)*obj.ylim_extra(2)];
            if obj.polar.max_polar_y>0
                temp_ylim(2)=obj.polar.max_polar_y;
            end
            if sum(isnan(temp_ylim))==0 && diff(temp_ylim)>0
                ca.RLim=temp_ylim;
            end
            avoid_spikes(ca);
            %Angle ticks at the categories of categorical x, or at the
            %angles of x when there are few of them (e.g. directions
            %sampled at regular intervals)
            if obj.x_factor
                angles=(0:length(obj.x_ticks)-1)*2*pi/length(obj.x_ticks);
            else
                angles=uniquetol(mod(comb(temp_aes.x),2*pi),1e-9);
            end
            if obj.x_factor || (numel(angles)>=3 && numel(angles)<=12)
                if strcmp(obj.polar.unit,'degrees')
                    angles=rad2deg(angles);
                end
                ca.ThetaTick=angles;
            end
            if obj.x_factor
                ca.ThetaTickLabel=obj.x_ticks;
                ca.TickLabelInterpreter='none';
            end
        else
            temp_xlim=facet_lim(obj,'x',temp_xscale,ind_row,ind_column);
            if sum(isnan(temp_xlim))==0
                set_num_lim(ca,'X',pad_lim(temp_xlim,obj.xlim_extra,obj.axis_scale.x));
            end
            if sum(isnan(temp_ylim))==0
                set_num_lim(ca,'Y',pad_lim(temp_ylim,obj.ylim_extra,obj.axis_scale.y));
            end
            log_ticks(ca,'X',obj.axis_scale.x);
            log_ticks(ca,'Y',obj.axis_scale.y);
            
            %Is the axis at interesting locations for ticks/labels?
            on_left=(obj.wrap_ncols==-1 && ind_column==1) || ... %Or if we're in facet grid mode and are in the first column
                    (obj.wrap_ncols>0 && mod(ind_column,obj.wrap_ncols)==1) || ... %Or if we are in facet wrap mode and are in the first "column"
                    (obj.wrap_ncols==1 && ind_column==1); %Special case for single facet in facet_wrap mode
                    
            on_bottom=(obj.wrap_ncols==-1 && ind_row==length(uni_row)) || ... %Or if we're in facet grid mode and we are in the last row
                    (obj.wrap_ncols>0 && (length(uni_column)-ind_column)<obj.wrap_ncols); %Or if we are in facet wrap mode and we are in the last facet on the "column"
                    
            
            if ~isempty(temp_aes.z) %Only do the Z limit stuff if we have z data
                
                temp_zlim=facet_lim(obj,'z',temp_zscale,ind_row,ind_column);
                set(ca,'ZLim',pad_lim(temp_zlim,obj.zlim_extra,obj.axis_scale.z));
                
                %Always have ticks if we have z data
                has_xtick=true;
                has_ytick=true;
                
            else %Only do optional xy ticks if we don't have z data
                
                %Set up logic of plot ticks presence
                has_xtick=obj.force_ticks || ... %Plot has xticks if forced
                    on_bottom ||...
                    strcmp(temp_xscale,'per_plot'); %Or if we were in a per-plot scale mode
                
                has_ytick=obj.force_ticks || ... %Plot has xticks if forced
                    on_left || ... %Special case for single facet in facet_wrap mode
                    strcmp(temp_yscale,'per_plot'); %Or if we were in a per-plot scale mode
            end
            
            %flip tick presence if coordinates are flipped
            if obj.is_flipped
                tmp=has_ytick;
                has_ytick=has_xtick;
                has_xtick=tmp;
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
                    set(ca,'TickLabelInterpreter','none')
                end
            end
            
            %If we have z data
            if ~isempty(temp_aes.z)
                zlabel(ca,obj.aes_names.z,...
                    'Interpreter',obj.text_options.interpreter,...
                    'FontName',obj.text_options.font,...
                    'FontSize',obj.text_options.base_size*obj.text_options.label_scaling) %Add z label
                view(ca,3); %Reset the view so that it is a 3D view
                if ind_row==1 && ind_column==1
                    %Link the camera properties between the
                    %facets so that they all rotate together
                    obj.extra.CamPos_listeners=linkprop(obj.facet_axes_handles(:),'CameraPosition');
                    obj.extra.CamTgt_listeners=linkprop(obj.facet_axes_handles(:),'CameraTarget');
                    obj.extra.CamUp_listeners=linkprop(obj.facet_axes_handles(:),'CameraUpVector');
                end
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
        %With flipped axes, MATLAB displays the y axis on the opposite side
        %when x or y is log
        if obj.is_flipped && any(strcmp({obj.axis_scale.x obj.axis_scale.y},'log')) && strcmp(ca.YAxisLocation,'left')
            ca.YAxisLocation='right';
        end
        
        %Do the datetick (legacy, for datenum x data)
        if ~isempty(obj.datetick_params) && ~strcmp(obj.axis_types.x.type,'numeric')
            if ind_row==1 && ind_column==1
                warning('gramm:datetick','set_datetick() is ignored for datetime/duration x data, which is displayed natively');
            end
        elseif ~isempty(obj.datetick_params)
            for dtk=1:length(obj.datetick_params)
                %Previously used 'keepticks' by default  which could cause a truncation of the axes
                datetick(ca,obj.datetick_params{dtk}{:});
            end
        end
        
        %Set ablines, hlines and vlines (after axe properties in case the limits
        %are changed there
        if obj.abline.on
            draw_ablines(obj,ca,temp_aes);
        end
        
    end
end

%Link the limits of facets that share them
if obj.polar.is_polar
    obj.extra.YLim_listeners=link_lims(obj,'RLim',temp_yscale);
else
    obj.extra.XLim_listeners=link_lims(obj,'XLim',temp_xscale);
    obj.extra.YLim_listeners=link_lims(obj,'YLim',temp_yscale);
    if strcmp(obj.facet_scale,'fixed')
        obj.extra.ZLim_listeners=link_lims(obj,'ZLim',temp_zscale);
    end
end


%Background matching the axes, and black elements following the theme
apply_theme(obj);





%Facet sizes proportional to axes limits (facet_grid() 'space' option)
apply_facet_space(obj);

%Legend vertical scaling (for multiple plots it's done once all are drawn)
if ~obj.multi.active
    scale_legend(obj);
end

%Redrawing for multiple plots is handled at the beginning of draw()
if ~obj.multi.active
    % Set the resize function
    if do_redraw
        register_redraw(obj);
    end

    %Redraw once the layout is computed (positions of the elements handled
    %by redraw() and title widths are only known then)
    drawnow;
    redraw(obj);
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


obj.updater.first_draw=false;
end

function register_redraw(obj)
%All the gramm plots of a figure (arrays, or plots drawn in tiles of a
%tiledlayout with set_parent()) are redrawn when it is resized
fig=ancestor(obj(1).parent,'figure');
plots=reshape(obj,1,[]);
previous=getappdata(fig,'gramm_plots');
for k=1:numel(previous)
    if ~any(previous(k)==plots)
        plots=[plots previous(k)];
    end
end
setappdata(fig,'gramm_plots',plots);
set(fig,'SizeChangedFcn',@(~,~)on_resize(fig));
end

function on_resize(fig)
%Redraw once the resizing has stopped. Until then tiledlayout handles the
%layout alone: during the resize callback the layout still reports sizes
%from before the resize (legend axes width, title space), so redrawing
%there would be both slow and wrong
t=getappdata(fig,'gramm_redraw_timer');
if isempty(t) || ~isvalid(t)
    t=timer('StartDelay',0.15,'ExecutionMode','singleShot','Name','gramm_redraw',...
        'TimerFcn',@(~,~)settled_redraw(fig));
    setappdata(fig,'gramm_redraw_timer',t);
    addlistener(fig,'ObjectBeingDestroyed',@(~,~)delete_timer(t));
end
stop(t);
start(t);
end

function delete_timer(t)
stop(t);
delete(t);
end

function settled_redraw(fig)
if isgraphics(fig)
    drawnow;
    redraw(getappdata(fig,'gramm_plots'));
end
end

function ax=new_facet_axes(obj,tile,span)
%Facet axes in a tile of the layout: polar axes for set_polar()
if obj.polar.is_polar
    ax=polaraxes(obj.layout);
    ax.Layout.Tile=tile;
    ax.Layout.TileSpan=span;
    ax.ThetaAxisUnits=obj.polar.unit;
else
    ax=nexttile(obj.layout,tile,span);
    set(ax,'XScale',obj.axis_scale.x,'YScale',obj.axis_scale.y,'ZScale',obj.axis_scale.z);
end
end


function avoid_spikes(ax)
%MATLAB can draw spikes out of polar axes for lines going through the exact
%center (e.g. empty histogram bins), and for patches with edges that are
%only about a pixel wide (e.g. small histogram wedges). Points at the center
%are moved slightly away from it, and edged polygons (patch columns without
%NaNs, which gramm uses to separate lines) within 1% of the radius range
%from the center are hidden
center=ax.RLim(1);
range=diff(ax.RLim);
objs=findobj(ax,'Type','line','-or','Type','patch');
for k=1:numel(objs)
    r=objs(k).RData;
    if isempty(r)
        continue
    end
    if strcmp(objs(k).Type,'patch') && ~isequal(objs(k).EdgeColor,'none')
        small=max(r,[],1)-center<0.01*range & ~any(isnan(r),1);
        r(:,small)=NaN;
    end
    r(r==center)=center+range*1e-6;
    if ~isequaln(r,objs(k).RData)
        objs(k).RData=r;
    end
end
end


function check_polar(obj)
%Error for what polar plots don't support. Geoms and stats are identified by
%the function they register in obj.geom
if ~obj.polar.is_polar
    return
end
supported={'my_point','my_jitter','my_line','my_count','my_label','my_bar','my_ci',...
    'my_bin','my_density','my_summary','my_smooth','my_fit','my_glm'};
geoms=cellfun(@(f) regexp(func2str(f),'^@\([^)]*\)(\w+)','tokens','once'),obj.geom,'UniformOutput',false);
geoms=[cell(1,0) geoms{:}];
unsupported=setdiff(geoms,supported);
if ~isempty(unsupported)
    what=[strjoin(strrep(unsupported,'my_',''),', ') ' (geom/stat)'];
elseif ~isempty(obj.aes.z)
    what='z data';
elseif obj.is_flipped
    what='coord_flip()';
elseif ~strcmp(obj.facet_space,'fixed')
    what='facet_grid() ''space''';
elseif ~isempty(obj.datetick_params)
    what='set_datetick()';
elseif obj.polygon.on
    what='geom_polygon()';
elseif ~all(strcmp(struct2cell(obj.axis_scale),'linear'))
    what='log axes';
else
    return
end
error('gramm:polarUnsupported','Not supported in polar plots: %s',what);
end


function set_axis_labels(obj)
%x and y names on the shared axis labels of the layout. For polar plots too
%(angle name below, radius name on the left): the labels of polar axes are
%placed by MATLAB over the data and the neighboring facets
if obj.is_flipped
    %With flipped axes, tiledlayout doesn't reserve space for the tick
    %labels of the horizontal axis: an empty first line keeps the label
    %below them
    obj.layout.XLabel.String ={'' obj.aes_names.y};
    obj.layout.YLabel.String =obj.aes_names.x;
else
    obj.layout.XLabel.String =obj.aes_names.x;
    obj.layout.YLabel.String =obj.aes_names.y;
end
set([obj.layout.XLabel obj.layout.YLabel],'Interpreter',obj.text_options.interpreter,...
    'FontName',obj.text_options.font,...
    'FontSize',obj.text_options.base_size*obj.text_options.label_scaling);
end


function [xscale,yscale,zscale]=facet_scales(obj)
%How the axes limits are shared between facets: 'global' (same for all),
%'per_column' and 'per_row' (facet_grid(), swapped for flipped axes) or
%'per_plot', according to facet_scale
if obj.wrap_ncols>0
    free_x='per_plot';
    free_y='per_plot';
else
    free_x='per_column';
    free_y='per_row';
end
switch obj.facet_scale
    case 'fixed'
        xscale='global';
        yscale='global';
        zscale='global';
    case 'free_x'
        xscale=free_x;
        yscale='global';
        zscale='global';
    case 'free_y'
        xscale='global';
        yscale=free_y;
        zscale='global';
    case 'free'
        xscale=free_x;
        yscale=free_y;
        zscale='per_plot';
    otherwise %'independent'
        xscale='per_plot';
        yscale='per_plot';
        zscale='per_plot';
end
end


function log_lims(obj)
%On log axes, lower limits at or below 0 (from data, or from stats and bars
%starting at 0) can't be displayed: they are replaced by the power of 10
%below the smallest positive value drawn in the facet (so that the smallest
%bars remain visible)
for dim='xyz'
    if ~strcmp(obj.axis_scale.(dim),'log')
        continue
    end
    mn=obj.plot_lim.(['min' dim]);
    for k=find(~(mn>0) & isgraphics(obj.facet_axes_handles))'
        data=get(findobj(obj.facet_axes_handles(k),'-property',[upper(dim) 'Data']),[upper(dim) 'Data']);
        if iscell(data)
            data=cellfun(@(v) v(:)',data,'UniformOutput',false);
            data=[data{:}];
        end
        data=data(data>realmin); %Above the bar baselines (see log_base())
        mn(k)=NaN;
        if ~isempty(data)
            mn(k)=10^floor(log10(min(data)));
        end
    end
    obj.plot_lim.(['min' dim])=mn;
end
end


function lim=pad_lim(lim,extra,scale)
%Extend limits beyond the data by a ratio of their range, of their range in
%log space on log axes
if strcmp(scale,'log')
    lim=10.^pad_lim(log10(lim),extra,'linear');
else
    lim=lim+[-diff(lim)*extra(1) diff(lim)*extra(2)];
end
end


function log_ticks(ax,axis_name,scale)
%On log axes spanning several decades, MATLAB sometimes places a single
%tick: ticks are set at regularly spaced decades instead (at most 6)
if ~strcmp(scale,'log')
    return
end
lim=log10(ax.([axis_name 'Lim']));
step=ceil(diff(lim)/6);
decades=ceil(lim(1)/step)*step:step:floor(lim(2));
if numel(decades)>=3
    ax.([axis_name 'Tick'])=10.^decades;
end
end


function lim=facet_lim(obj,dim,scale,ind_row,ind_column)
%Data limits along dim ('x','y' or 'z') of a facet, gathered over the
%facets that share them (see facet_scales())
mn=obj.plot_lim.(['min' dim]);
mx=obj.plot_lim.(['max' dim]);
switch facet_group(obj,scale)
    case 'all'
        lim=[min(mn(:)) max(mx(:))];
    case 'row'
        lim=[min(mn(ind_row,:)) max(mx(ind_row,:))];
    case 'column'
        lim=[min(mn(:,ind_column)) max(mx(:,ind_column))];
    otherwise
        lim=[mn(ind_row,ind_column) mx(ind_row,ind_column)];
end
end


function links=link_lims(obj,prop,scale)
%Link the limits of the facets that share them (see facet_scales())
ax=obj.facet_axes_handles;
switch facet_group(obj,scale)
    case 'all'
        groups={ax(:)};
    case 'row'
        groups=num2cell(ax,2);
    case 'column'
        groups=num2cell(ax,1);
    otherwise
        groups={};
end
links=[];
for k=1:numel(groups)
    g=groups{k}(isgraphics(groups{k}));
    if numel(g)>1
        links=[links linkprop(g,prop)]; %#ok<AGROW>
    end
end
end


function group=facet_group(obj,scale)
%Facets sharing limits: 'all', 'row', 'column' or 'none'. x limits are
%shared along columns, and y limits along rows, unless the axes are flipped
switch scale
    case 'global'
        group='all';
    case 'per_column'
        group='column';
    case 'per_row'
        group='row';
    otherwise
        group='none';
end
if obj.is_flipped && any(strcmp(group,{'row','column'}))
    group=setdiff({'row','column'},group);
    group=group{1};
end
end


function draw_ablines(obj,ca,temp_aes)
%Lines from geom_abline(), geom_vline(), geom_hline() and geom_funline().
%In polar plots they span the full circle (hlines are circles), and vlines
%span the radius axis

%Datetime/duration intercepts (and angles in degrees) are converted to
%numbers
for line_ind=1:length(obj.abline.raw)
    if ~isempty(obj.abline.raw{line_ind})
        if isnan(obj.abline.yintercept(line_ind))
            obj.abline.xintercept(line_ind)=to_num(obj.axis_types.x,obj.abline.raw{line_ind});
        else
            obj.abline.yintercept(line_ind)=to_num(obj.axis_types.y,obj.abline.raw{line_ind});
        end
    end
end
is_polar=obj.polar.is_polar;
is_log=~is_polar && (strcmp(ca.XScale,'log') || strcmp(ca.YScale,'log'));
for line_ind=1:length(obj.abline.intercept)
    if is_polar
        xl=linspace(0,2*pi,100);
    else
        tmp_xl=[obj.var_lim.minx obj.var_lim.maxx];
        tmp_extent=(tmp_xl(2)-tmp_xl(1))*obj.abline.extent(line_ind)/2;
        xl=[mean(tmp_xl)-tmp_extent mean(tmp_xl)+tmp_extent];
        if strcmp(ca.XScale,'log') && xl(1)<0 %Correct negative values if log axes
            xl(1)=1;
        end
    end
    line_opts={obj.abline.style{line_ind},'LineWidth',obj.abline.linewidth(line_ind),'Parent',ca};
    if ~isnan(obj.abline.intercept(line_ind))
        %draw it properly (curved) if log axes
        if is_log
            xl=xl(1):(xl(2)-xl(1))/50:xl(2);
        end
        %abline
        plot(xl,xl*obj.abline.slope(line_ind)+obj.abline.intercept(line_ind),line_opts{:});
    elseif ~isnan(obj.abline.xintercept(line_ind))
        %vline
        if is_polar
            yl=ca.RLim;
        else
            if obj.var_lim.miny == obj.var_lim.maxy %We are probably in a case where y wasn't provided (histogram or raster)
                tmp_yl=[0 numel(temp_aes.x)]; %We scale y according to number of x elements
            else
                tmp_yl=[obj.var_lim.miny obj.var_lim.maxy];
            end
            tmp_extent=(tmp_yl(2)-tmp_yl(1))*obj.abline.extent(line_ind)/2;
            yl=[mean(tmp_yl)-tmp_extent mean(tmp_yl)+tmp_extent];
        end
        plot([obj.abline.xintercept(line_ind) obj.abline.xintercept(line_ind)],yl,line_opts{:});
    elseif ~isnan(obj.abline.yintercept(line_ind))
        %hline
        plot(xl,xl*0+obj.abline.yintercept(line_ind),line_opts{:});
    else
        temp_x=linspace(xl(1),xl(end),500);
        plot(temp_x,obj.abline.fun{line_ind}(temp_x),line_opts{:});
    end
end
end


function out=allmax(in)
%Return maximum of an array or of a cell of arrays
if iscell(in)
    out=max(cellfun(@max,in(~cellfun(@isempty,in)))); %Cellfun on non empty cells
    if isempty(out)
        out=NaN;
    end
else
    out=max(in);
end
end

function out=allmin(in)
%Return minimum of an array or of a cell of arrays
if iscell(in)
    out=min(cellfun(@min,in(~cellfun(@isempty,in))));  %Cellfun on non empty cells
    if isempty(out)
        out=NaN;
    end
else
    out=min(in);
end
end


function opts=natural_order(opts,cat_order)
%Ascending (1) or descending (-1) orders of categorical, datetime and
%duration grouping data follow the natural order of their values
%(categories, chronological order) stored in cat_order by validate_aes(),
%given to unique_and_sort() as a custom order
if numel(cat_order)>1 && isnumeric(opts) && isscalar(opts) && opts~=0
    if opts==-1
        opts=flipud(cat_order(:));
    else
        opts=cat_order(:);
    end
end
end
