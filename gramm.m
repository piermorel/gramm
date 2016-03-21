classdef gramm < handle
    %GRAMM Implementation of the features from R's ggplot2 (GRAMmar of graphics plots) in Matlab
    % Pierre Morel 2015
    
    properties (Access=public)
        facet_axes_handles %Stores the handles of the facet axes
        results %Stores the results of the draw functions and statistics computations
    end
        
    properties (Access=protected,Hidden=true)
        aes %aesthetics (contains data set by the constructor and used to generate the plots)
        aes_names %Name of the aesthetics and column/rows for the legend
        row_facet %Contains data used to set subplot rows
        col_facet %Contains data used to set subplot columns
        
        axe_properties %Contains the axes properties to be set to each subplot
        
        geom %Cell containing successive plotting function handles
        geom_aes %(unused for now) geom-specific aesthetics
        
        var_lim %Contains the min and max values of variables (minx,maxx,miny,maxy)
   
        %Contains the min and max values of variables in sub plots
        %(minx,maxx,miny,maxy,minc,maxc), c being for the continuous color
        %values. Each of these is a matrix 
        %corresponding to the facets, used to set axis limits
        plot_lim 
        
        xlim_extra %extend range of XLim (ratio of original XLim width)
        ylim_extra %extend range of XLim (ratio of original YLim width)
        
         %Structure containing polar-related parameters: is_polar stores
         %whether to display polar plots, is_polar_closed to  set if the
         %polar lines must close around the circle, and max_polar_y to
         %define the limits in radius.
        polar
        
        x_factor %Is X a categorical variable ?
        x_ticks %Store the ticks used for x
        
        multi %store variables used when making multiple gramm plots in the same window:
              % orig: origin (x,y) of the current gramm plot in normalized
              % values (0,0) by default for single graph
              % size: size (w,h) of the current gramm plot in normalized values
              % (1,1) by default for single graph
              % active: true or false
        
        firstrun %Is it the first time the plotting function is run
        r_ind %current index in the draw loops
        
        wrap_ncols %After how many columns do we wrap around subplots
        facet_scale %Do we have independent scales between facets ?
        force_ticks %Do we force ticks on all facets
        
        abline %structure containing the abline parameters: on, slope, intercept,style,xintercept,yintecept
        datetick_params %cell containng datetick parameters
        current_row %What is the currently drawn row of the subplot
        current_column %What is the currently drawn column of the subplot
        continuous_color %Do we use continuous colors (rather than discrete)
        continuous_color_colormap %Store the continuous color colormap
        color_options %Store options for generating colors
        order_options %Store options for sorting data/categories
        
        with_legend %Do we have a side legend for colors etc. ?
        
        
        legend_axe_handle %Store the handle of the legend axis
        
        extra %Store extra geom-specific info
        
    end
    
    methods (Access=public)
%% Constructor

        function obj=gramm(varargin)
            % gramm Constructor for the class
            %
            % Example syntax (default arguments): gramm_object=gramm('x',x_variable,'y',y_variable,'color',color_variable)
            % This function is used to create a gramm object, and provide
            % it with the data that will be plotted. Arguments are given as
            % 'name',value pairs. The possible arguments are:
            %
            %   - 'x' for the data to plot as abcissa, or the data that
            %      will be used to construct histograms/density estimates
            %   - 'y' for the data to plot as ordinate
            %   - 'color' for the data that determines color (hue)
            %   - 'lightness' for the data that determines lightness
            %   - 'linestyle' for the data that determines line style
            %   - 'size' for the data that determines line/point size
            %   - 'marker' for the data that determines point shape
            %   - 'group' for the data that determines groups
            %
            % The arguments can be of the following type, N being te number
            % of observations:
            %   - color, lightness, linestyle, size or marker can be 1D numerical arrays
            %     or 1D cell arrays of strings of length N. Note that they are used to
            %     represent categories.
            %   - y can be a 1D numerical array of length N. It can also be
            %     a 2D numerical array of size N*M, or a 1D cell array of
            %     length N containing arrays of various sizes. In the last
            %     two cases, all the points from each row of the array/each
            %     array from the cell will be colored/shaped/etc similarly
            %     and according to the other aesthetics.
            %   - x can be a 1D numerical array or a 1D cell array of
            %     strings of size N (if y is a 1D numerical array). If y is
            %     a 1D cell array of numerical arrays or a 2D numerical
            %     array, x can be either a 1D cell array containing
            %     numerical arrays of the same size, or a 2D numerical
            %     array of the same size (N*M). It can also be a 1D numerical
            %     array of size M, in which case the same abcissa will be
            %     used for every row of y.
            
            obj.aes=parse_aes(varargin{:});
            
            %Set default names
            obj.aes_names.x='x';
            obj.aes_names.y='y';
            obj.aes_names.color='Color';
            obj.aes_names.marker='Marker';
            obj.aes_names.linestyle='Line Style';
            obj.aes_names.size='Size';
            obj.aes_names.row='Row';
            obj.aes_names.column='Column';
            obj.aes_names.lightness='Lightness';
            obj.aes_names.group='Group';
            
            %Initialize geoms
            obj.geom={};
            
            %Initialize facets
            obj.row_facet=[];
            obj.col_facet=[];
            obj.facet_scale='fixed';
            obj.force_ticks=false;
            
            %Initialize axes properties
            obj.axe_properties={};
            
            obj.abline.on=false;
            obj.abline.slope=[];
            obj.abline.intercept=[];
            obj.abline.xintercept=[];
            obj.abline.yintercept=[];
            obj.abline.style={};
            obj.abline.fun={};
            
            % 10% default extra on limits
            obj.xlim_extra=0.1;
            obj.ylim_extra=0.1;
            
            obj.datetick_params={};
            
            %Initialize wrapping
            obj.wrap_ncols=-1;
            
            obj.polar.is_polar=false;
            obj.polar.is_polar_closed=false;
            
            %Set default values
            obj.multi.orig=[0 0];
            obj.multi.size=[1 1];
            obj.multi.active=false;
            
            obj.continuous_color=false;
            %Default to hot colormap
            obj.continuous_color_colormap=pa_LCH2RGB([linspace(0,100,256)'...
                repmat(100,256,1)...
                linspace(30,90,256)']);
            
            obj.color_options.lightness_range=[85 15];
            obj.color_options.chroma_range=[30 90];
            obj.color_options.hue_range=[25 385];
            obj.color_options.lightness=65;
            obj.color_options.chroma=75;
            obj.color_options.map='lch';
            
            obj.order_options.x=1;
            obj.order_options.color=1;
            obj.order_options.marker=1;
            obj.order_options.linestyle=1;
            obj.order_options.size=1;
            obj.order_options.row=1;
            obj.order_options.column=1;
            obj.order_options.lightness=1;
            
            obj.with_legend=true;
        end
        
%          function disp(obj)
%              %Empty to silence output
%          end
%% Faceting methods

        function obj=facet_grid(obj,row,col,varargin)
            % facet_grid Create subplots according to factors for rows and columns
            %
            % Example syntax (default arguments): gramm_object.facet_grid(row_variable_column_variable,'scale','fixed')
            % This function has two mandatory arguments: the variable used
            % to separate data by rows of subplots, and the variable used to
            % separate data by columns of subplots. To separate data by
            % rows or columns of subplots only, set the other
            % argument to [] (empty array). These arguments can be 1D numerical arrays or
            % 1D cell arrays of strings of length N.
            % This function can receive an other argument as a name value
            % pair. 'scale' can be set to either 'fixed', 'free_x',
            % 'free_y', 'free', or 'independent' so that the scale of the subplots is respectively
            % the same over all subplots, x adjusted per columns of subplots ,
            % y adjusted per rows of subplots, x adjusted per rows and y per columns,
            % or x and y adjusted independently per subplot
            
            p=inputParser;
            my_addParameter(p,'scale','fixed'); %options 'free' 'free_x' 'free_y' 'independent'
            my_addParameter(p,'force_ticks',false);
            parse(p,varargin{:});
            
            obj.facet_scale=p.Results.scale;
            
            if strcmp(obj.facet_scale,'independent') %Force ticks by default in that case
                obj.force_ticks=true;
            else
                obj.force_ticks=p.Results.force_ticks;
            end
            
            obj.row_facet=shiftdim(row);
            obj.col_facet=shiftdim(col);
            obj.wrap_ncols=-1;
        end
        
        function obj=facet_wrap(obj,col,varargin)
            % facet_grid Create subplots according to one factor, with wrap
            %
            % Example syntax (default arguments): gramm_object.facet_wrap(variable,'ncols',4,'scale','fixed')
            % This is similar to faced_grid except that only one variable
            % is given, and subplots are arranged by column, with a wrap
            % around to the tnext row after 'ncols' columns.
            
            p=inputParser;
            my_addParameter(p,'ncols',4);
            my_addParameter(p,'scale','fixed'); %options 'free' 'free_x' 'free_y'
            my_addParameter(p,'force_ticks',false); 
            parse(p,varargin{:});
            
            obj.facet_scale=p.Results.scale;
            
            if strcmp(obj.facet_scale,'independent') || strcmp(obj.facet_scale,'free') %Force ticks by default in these case
                obj.force_ticks=true;
            else
                obj.force_ticks=p.Results.force_ticks;
            end
            
            obj.wrap_ncols=p.Results.ncols;
            obj.col_facet=shiftdim(col);
            obj.row_facet=[];
        end
        
%% Customization methods

        function obj=set_polar(obj,varargin)
            % set_polar Activate polar axes
            %
            % This command changes axes to polar form. 'x' then corresponds
            % to theta
            % Additional parameters:
            % 'closed': When plotting lines, connect the first
            % and last points when set to true
            % 'maxy': set the maximum y value (automatic scaling can't work
            % properly on polar plots.
            
           
            
            p=inputParser;
            my_addParameter(p,'closed',false);
            my_addParameter(p,'maxy',-1)
            parse(p,varargin{:});
            
            for obj_ind=1:numel(obj)
                obj(obj_ind).polar.is_polar=true;
                obj(obj_ind).polar.is_polar_closed=p.Results.closed;
                obj(obj_ind).polar.max_polar_y=p.Results.maxy;
            end
            
        end
        
        function obj=set_color_options(obj,varargin)
            % set_color_options() Set options used to generate colormaps
            %
            % Parameters:
            % 'map': Set custom colormap. Available colormaps are 'lch'
            % (default, supports lightness), 'matlab' (post-2014b default
            % colormap), 'brewer1', 'brewer2', 'brewer3', 'brewer_pastel', 
            %'brewer_dark' for the corresponding brewer colormaps from
            % colorbrewer2.org. It is also possible to provide a custom
            % colormap by providing a N-by-3 matrix (columns are R,G,B).
            %
            % The other options allow to sepecify color generation
            % parameters for the default 'lch' colormap:
            %
            % 'lightness_range': 2-element vector indicating the range of 
            % lightness values (0-100) used when generating plots with
            % lightness variations. Default is [85 15] (light to dark)
            %
            % 'chroma_range': 2-element vector indicating the range of 
            % chroma values (0-100) used when generating plots with
            % lightness variations (chroma is the intensity of the color).
            % Default is [30 90] (weak color to deeper color)
            %
            % 'hue_range': 2-element vector indicating the range of 
            % hue values (0-360) used when generating color plots. Default is
            % [25 385] (red to blue).
            %
            % 'lightness': Lightness used when generating plots without
            % lightness variations. Default is 60
            %
            % 'chroma': Chroma used when generating plots without chroma
            % variations. Default is 70
            
            p=inputParser;
            my_addParameter(p,'map','lch'); %matlab, brewer1,brewer2,brewer3,brewer_pastel,brewer_dark
            my_addParameter(p,'lightness_range',[85 15]);
            my_addParameter(p,'chroma_range',[30 90]);
            my_addParameter(p,'hue_range',[25 385]);
            my_addParameter(p,'lightness',65);
            my_addParameter(p,'chroma',75);
            parse(p,varargin{:});
            
            for obj_ind=1:numel(obj)
                obj(obj_ind).color_options=p.Results;  
            end
        end
        
        function obj=set_order_options(obj,varargin)
            % set_order_options() Set ordering options for categorical
            % variables
            %
            % Ordering options are available for 'x', 'color', 'marker',
            % 'size', 'linestyle', 'row', 'column', 'lightness'
            % For each variable, the option is provided with a 'name',
            % value pair. Example for setting the ordering for the 'color' variable:
            %
            % 'color',1     This is the default, orders  variable in
            % ascending order (alphabetical or numerical)
            %
            % 'color',0     Keeps the order of appearance in the
            % original variable
            %
            % 'color',-1    Orders variable in descending order
            % (alphabetical or numerical)
            %
            % 'color',[4 3 5 1 2]   Uses a custom order provided with 
            %indices provided as an array. The indices are indices 
            %corresponding to unique values in sorted in ascending order
            % The array length must be equal to the number of unique
            % values for the variable and must contain all the integers
            % between 1 and the number of unique values.
            
            p=inputParser;
            my_addParameter(p,'x',1);
            my_addParameter(p,'color',1);
            my_addParameter(p,'marker',1);
            my_addParameter(p,'size',1);
            my_addParameter(p,'linestyle',1);
            my_addParameter(p,'row',1);
            my_addParameter(p,'column',1);
            my_addParameter(p,'lightness',1);
            parse(p,varargin{:});
            
            for obj_ind=1:numel(obj)
                obj(obj_ind).order_options=p.Results;
            end
            
        end
        
        function obj=set_continuous_color(obj,varargin)
            %set_continuous_color Force the use of a continuous color
            %scheme
            %
            % Parameters as name,value pairs:
            % 'colormap' set continuous colormap by
            % name: 'hot,'cool', or 'parula'
            % 'LCH_colormap' set colormap by Lightness-Chroma-Hue values
            % using a matrix organized this way:
            % [L_start L_end; C_start C_end ; H_start H_end]
            
            obj.continuous_color=true;
            
            p=inputParser;
            my_addParameter(p,'colormap','hot');
            my_addParameter(p,'LCH_colormap',[]);
            parse(p,varargin{:});
            
            switch p.Results.colormap
                case 'hot'
                    obj.continuous_color_colormap=pa_LCH2RGB([linspace(0,100,256)'...
                        repmat(100,256,1)...
                        linspace(30,90,256)']);
                case 'parula'
                    obj.continuous_color_colormap=colormap('parula');
                case 'cool'
                    obj.continuous_color_colormap=pa_LCH2RGB([linspace(0,80,256)'...
                        repmat(100,256,1)...
                        linspace(200,260,256)']);
                otherwise
                    obj.continuous_color_colormap=pa_LCH2RGB([linspace(0,100,256)'...
                        repmat(100,256,1)...
                        linspace(30,90,256)']);
            end
            
            if ~isempty(p.Results.LCH_colormap) 
                obj.continuous_color_colormap=pa_LCH2RGB([linspace(p.Results.LCH_colormap(1,1),p.Results.LCH_colormap(1,2),256)'...
                        linspace(p.Results.LCH_colormap(2,1),p.Results.LCH_colormap(2,2),256)'...
                        linspace(p.Results.LCH_colormap(3,1),p.Results.LCH_colormap(3,2),256)']); 
            end
            
            
        end
        
        function obj=no_legend(obj)
            % no_legend() remove side legend on the plot
            %
            % Useful when plotting multiple gramm objects with the same
            % legend
            
            obj.with_legend=false;
        end
        

        function obj=set_limit_extra(obj,x_extra,y_extra)
            %set_limit_extra Add some breathing room around data in plots
            %
            % Example syntax gramm_object.set_limit_extra(0.1,0.1)
            % first argument is XLim extra, second is YLim extra, extra
            % room is expressed as ratio to original limits. 0.1 will
            % extend by 5% on each side.
            
            
            for obj_ind=1:numel(obj)
                obj(obj_ind).xlim_extra=x_extra;
                obj(obj_ind).ylim_extra=y_extra;
            end
            
        end
        
        function obj=axe_property(obj,varargin)
            % axe_property Add a matlab axes property to apply to all subplots
            %
            % Example syntax: gramm_object.axe_property('ylim',[0 1])
            % Arguments are given as a name,value pairs. The accepted
            % arguments are the same as in matlab's own set(gca,'propertyname',propertyvalue)
            
            if mod(nargin-1,2)==0
                for obj_ind=1:numel(obj)
                    for k=1:2:length(varargin)
                        obj(obj_ind).axe_properties=vertcat(obj(obj_ind).axe_properties,{varargin{k},varargin{k+1}});
                    end
                end
            else
                error('Arguments of axe_property() must be given as ''name'',value pairs')
            end
        end
        
        function obj=set_datetick(obj,varargin)
            %set_datetick Specify that the x axis has dates
            %
            % This function can receive the same optional arguments as the
            % datetick() function of matlab
            
            %This way we can handle multiple calls to set_datetick
            for obj_ind=1:numel(obj)
                obj(obj_ind).datetick_params=vertcat(obj.datetick_params,{varargin});
            end
        end
        
        function obj=set_names(obj,varargin)
            % set_names Set names for aesthetics to be displayed in legends and axes
            %
            % Example syntax : gramm_object.set_names('x','Time (ms)','y','Hand position (mm)','color','Movement direction (°)','row','Subject')
            
            p=inputParser;
            
            my_addParameter(p,'x','x');
            my_addParameter(p,'y','y');
            my_addParameter(p,'color','Color');
            my_addParameter(p,'linestyle','Line Style');
            my_addParameter(p,'size','Size');
            my_addParameter(p,'marker','Marker');
            my_addParameter(p,'row','Row');
            my_addParameter(p,'column','Column');
            my_addParameter(p,'lightness','Lightness');
            my_addParameter(p,'group','Group');
            
            parse(p,varargin{:});
            
            fnames=fieldnames(p.Results);
            for k=1:length(fnames)
                for obj_ind=1:numel(obj)
                    obj(obj_ind).aes_names.([fnames{k}])=p.Results.(fnames{k});
                end
            end
            
        end
        
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
                spacing=0.02;
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
                        redraw(obj(l,c),spacing/max(nl,nc),display); 
                    end
                end
                return;
            end
            
            %If x is empty the object probably is so we skip (happens for multiple graphs)
            if isempty(obj.aes.x) 
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
            %set(obj.facet_axes_handles(a),'Unit','pixels');
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
            %set(obj.legend_axe_handle,'Unit','pixels');
            legend_pos=get(obj.legend_axe_handle,'Position');
            legend_inset=get(obj.legend_axe_handle,'TightInset');
            legend_outer=get(obj.legend_axe_handle,'OuterPosition');
            
            %Retrieve text handles
            text_handles=findobj(gcf,'Type','text');
            %Needed for the rest to work
            set(text_handles,'Unit','normalized');
            
            if display
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
                
                
                %display text boxes
                for t=1:length(text_handles)
                    parent_axe=ancestor(text_handles(t),'axes');
                    axpos=get(parent_axe,'Position');
                    txtpos=get(text_handles(t),'Extent');
                    %rectangle('Position',[txtpos(1)+axpos(1) txtpos(2)+axpos(2) txtpos(3) txtpos(4)],'EdgeColor','g');
                    rectangle('Position',[txtpos(1)*axpos(3)+axpos(1) txtpos(2)*axpos(4)+axpos(2) txtpos(3)*axpos(3) txtpos(4)*axpos(4)],'EdgeColor','g');
                end
                
            end
            
            %Move legend to the right
            %Get rightmost text
            legend_text_pos=get(findobj(obj.legend_axe_handle,'Type','text'),'Extent');
            if ~isempty(legend_text_pos)
                max_text_x=max(cellfun(@(p)legend_pos(1)+legend_pos(3)*p(1)+legend_pos(3)*p(3),legend_text_pos));
                %Move accordingly (here the max available x position takes
                %in account the multiple plots
                set(obj.legend_axe_handle,'Position',legend_pos+[obj.multi.orig(2)+obj.multi.size(2)-spacing_w-max_text_x 0 0 0]);
            end
            
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
            facet_text_pos=get(findobj(obj.facet_axes_handles,'Type','text'),'Extent');
            
            if ~isempty(facet_text_pos)
                %Get positions of the corresponding parent axes
                %axe_text_pos=get(cell2mat(ancestor(findobj(obj.facet_axes_handles,'Type','text'),'axes')),'Position');
                %%didn't work with HG2 graphics
                temp_handles=ancestor(findobj(obj.facet_axes_handles,'Type','text'),'axes');
                
                %HACK (when there no color and no legend but a single piece of text from the
                %glm fits we don't get cells here so the cellfuns get broken
                if ~iscell(temp_handles)
                    temp_handles={temp_handles};
                    facet_text_pos={facet_text_pos};
                end
                
                axe_text_pos=cellfun(@(a)get(a,'Position'),temp_handles,'UniformOutput',false);
               
                
                %Compute rightmost and topmost text
                max_facet_x_text=max(cellfun(@(tp,ap)ap(1)+ap(3)*tp(1)+tp(3)*ap(3),facet_text_pos,axe_text_pos));
                max_facet_y_text=max(cellfun(@(tp,ap)ap(2)+ap(4)*tp(2)+tp(4)*ap(4),facet_text_pos,axe_text_pos));
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
            
            %Correction if no row  or column legends
            max_facet_x_text=max(max_facet_x_text,max_facet_x);
            max_facet_y_text=max(max_facet_y_text,max_facet_y);
            
            %Place relative to legend axis
            tmp=get(obj.legend_axe_handle,'Position');
            if isempty(legend_text_pos)%If we don't have legends on the right then we use the multi parameters
                tmp(1)=obj.multi.orig(2)+obj.multi.size(2)-spacing_w;
            end
            max_available_x=tmp(1)-spacing_w-(max_facet_x_text-max_facet_x);
            %For the available room on top we take in account multi as well
            max_available_y=obj.multi.orig(1)+obj.multi.size(1)-spacing_h-(max_facet_y_text-max_facet_y);
            
            
            %Compute additional spacing for x y axis labels if idependent
            %(or if free with wrapping)
            if obj.force_ticks || (obj.wrap_ncols>0)% && ~isempty(strfind(obj.facet_scale,'free')))
                %use top left inset as reference
                top_right_inset=get(obj.facet_axes_handles(1,end),'TightInset');
                spacing_w=top_right_inset(1)+spacing_w;
                spacing_h=top_right_inset(2)+spacing_h;
%             else
%                 %Compute additional spacing for titles if column wrap (this
%                 %is in the else to prevent too large increase of spacing in
%                 % facet_wrap
%                 if obj.wrap_ncols>0
%                     outerpos=get(obj.facet_axes_handles(1,1),'OuterPosition');
%                     innerpos=get(obj.facet_axes_handles(1,1),'Position');
%                     spacing_h=spacing_h+(outerpos(4)-innerpos(4)-(innerpos(2)-outerpos(2)))*1.5;
%                 end
            end
            
            %Do the move
            if obj.wrap_ncols>0
                nr=ceil(length(obj.facet_axes_handles)/obj.wrap_ncols);
                nc=obj.wrap_ncols;
                neww=abs(max_available_x-min_facet_x-spacing_w*(nc-1))/nc;
                newh=abs(max_available_y-min_facet_y-spacing_h*(nr-1))/nr;
                ind=1;
                for r=1:nr
                    for c=1:nc
                        if ind<=length(obj.facet_axes_handles)
                            axpos=get(obj.facet_axes_handles(ind),'Position');
                            set(obj.facet_axes_handles(ind),'Position',[min_facet_x+(neww+spacing_w)*(c-1) min_facet_y+(newh+spacing_h)*(nr-r) neww newh]);
                        end
                        ind=ind+1;
                    end
                end
            else
                nr=size(obj.facet_axes_handles,1);
                nc=size(obj.facet_axes_handles,2);
                %We don't let those go below a small value (spacing)
                neww=max((max_available_x-min_facet_x-spacing_w*(nc-1))/nc,spacing_w);
                newh=max((max_available_y-min_facet_y-spacing_h*(nr-1))/nr,spacing_h);
                for r=1:nr
                    for c=1:nc
                        axpos=get(obj.facet_axes_handles(r,c),'Position');
                        set(obj.facet_axes_handles(r,c),'Position',[min_facet_x+(neww+spacing_w)*(c-1) min_facet_y+(newh+spacing_h)*(nr-r) neww newh]);
                    end
                end
            end
                  
        end
        
        
        %% draw() initialization
        function draw(obj)
            % draw Draws the plot in the current figure
            %
            % syntax: gramm_object.draw()
            % Call draw on an array of gramm objects in order to have
            % multiple gramms on a single figure.
            
            
            %Handle call of draw() on array of gramm objects by dividing the figure
            %up and launching the individual draw functions of each object
            if numel(obj)>1
                nl=size(obj,1);
                nc=size(obj,2);
                for l=1:nl
                    for c=1:nc
                        obj(l,c).multi.orig=[(nl-l)/nl (c-1)/nc];
                        obj(l,c).multi.size=[1/nl 1/nc];
                        obj(l,c).multi.active=true;
                        draw(obj(l,c));
                    end
                end
                
                %Set up tight redrawing for multiple plots
                 redraw(obj,0.04);
                 if verLessThan('matlab','8.4')
                     set(gcf,'ResizeFcn',@(a,b)redraw(obj,0.04));
                 else
                     set(gcf,'SizeChangedFcn',@(a,b)redraw(obj,0.04));
                 end
                 
                return;
            end
            
            %If x is empty the object probably is so we skip (happens for multiple graphs)
            if isempty(obj.aes.x) 
                return
            end
            
            temp_aes=validate_aes(obj.aes);
            
            % Create replacement row_facet and color_facet if they were
            % empty
            if isempty(obj.row_facet)
                 obj.row_facet=ones(size(temp_aes.subset));
            end
            
            if isempty(obj.col_facet)
                 obj.col_facet=ones(size(temp_aes.subset));
            end
            
            temp_row_facet=obj.row_facet(temp_aes.subset);
            temp_col_facet=obj.col_facet(temp_aes.subset);
            
            temp_aes=select_aes(temp_aes,temp_aes.subset);
            
            %Find min and max of x and y to have homogenous scales
            nonemptycell=@(c)~cellfun(@isempty,c);
            cellmax=@(c)max(cellfun(@max,c(nonemptycell(c))));
            cellmin=@(c)min(cellfun(@min,c(nonemptycell(c))));
            
            %Convert categorical x to cellstr
            if iscategorical(temp_aes.x)
                temp_aes.x=cellstr(temp_aes.x);
            end
            
            if iscell(temp_aes.x)
                nonempty=nonemptycell(temp_aes.x);
                
                if iscellstr(temp_aes.x)
                    %Convert factor data to numeric
                    obj.x_factor=true;
                    %obj.x_ticks=unique(temp_aes.x);
                    obj.x_ticks=unique_and_sort(temp_aes.x,obj.order_options.x);
                    tempx=zeros(length(temp_aes.x),1);
                    for k=1:length(obj.x_ticks)
                        tempx(strcmp(temp_aes.x,obj.x_ticks{k}))=k;
                    end
                    temp_aes.x=tempx;
                    
                    obj.var_lim.maxx=max(temp_aes.x);
                    obj.var_lim.minx=min(temp_aes.x);
                else
                    obj.var_lim.maxx=cellmax(temp_aes.x);
                    obj.var_lim.minx=cellmin(temp_aes.x);
                    
                    obj.x_factor=false;
                end
            else
                nonempty=true(length(temp_aes.y),1);
                obj.var_lim.maxx=max(max(temp_aes.x));
                obj.var_lim.minx=min(min(temp_aes.x));
            end
            
            if iscell(temp_aes.y)
                nonempty=nonempty & nonemptycell(temp_aes.y);
                
                obj.var_lim.maxy=cellmax(temp_aes.y);
                obj.var_lim.miny=cellmin(temp_aes.y);
            else
                obj.var_lim.maxy=max(max(temp_aes.y));
                obj.var_lim.miny=min(min(temp_aes.y));
            end
            
            temp_aes=select_aes(temp_aes,nonempty);
            temp_row_facet=temp_row_facet(nonempty);
            temp_col_facet=temp_col_facet(nonempty);
            
            %Handles the multiple gramm case: we set up subtightplot so
            %that it restricts the drawing (using margins) to a portion of
            %the figure
            mysubtightplot=@(m,n,p,gap,marg_h,marg_w)my_tightplot(m,n,p,...
                [gap(1)*obj.multi.size(1) gap(2)*obj.multi.size(2)],...
                [obj.multi.orig(1)+obj.multi.size(1)*marg_h(1) 1-obj.multi.orig(1)-obj.multi.size(1)*(1-marg_h(2))],...
                [obj.multi.orig(2)+obj.multi.size(2)*marg_w(1) 1-obj.multi.orig(2)-obj.multi.size(2)*(1-marg_w(2))]);
            
            %Set subplot generation parameters and functions
            if obj.force_ticks %strcmp(obj.facet_scale,'independent')  %Independent scales require more space between subplots for ticks
                mysubplot=@(nrow,ncol,row,col)mysubtightplot(nrow,ncol,(row-1)*ncol+col,[0.06 0.06],[0.1 0.08],[0.1 0.2]);
            else
                mysubplot=@(nrow,ncol,row,col)mysubtightplot(nrow,ncol,(row-1)*ncol+col,[0.02 0.02],[0.1 0.08],[0.1 0.2]);
            end
            %Subplots for wraps leave more space above axes for column
            %legend
            mysubplot_wrap=@(ncol,col)mysubtightplot(ceil(ncol/obj.wrap_ncols),obj.wrap_ncols,col,[0.09 0.03],[0.1 0.08],[0.1 0.2]);
            
            %Find uniques in aesthetics and sort according to options
            uni_row=unique_and_sort(temp_row_facet,obj.order_options.row);
            uni_column=unique_and_sort(temp_col_facet,obj.order_options.column);
            uni_linestyle=unique_and_sort(temp_aes.linestyle,obj.order_options.linestyle);
            uni_marker=unique_and_sort(temp_aes.marker,obj.order_options.marker);
            uni_lightness=unique_and_sort(temp_aes.lightness,obj.order_options.lightness);
            uni_size=unique_and_sort(temp_aes.size,obj.order_options.size);
            
            %If the color is in a cell array of doubles, we set it as
            %continuous color
            if iscell(temp_aes.color) && ~iscellstr(temp_aes.color)
                obj.continuous_color=true;
            else
                %uni_color=unique_no_nan(temp_aes.color);
                %uni_color=sort(uni_color); %We do the sorting here
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
            
            %Correct empty facet_grids
            if obj.wrap_ncols>length(uni_column)
                obj.wrap_ncols=length(uni_column);
            end

            %The plot minumums and maximums arrays the size of the
            %number of subplots
            n_columns=length(uni_column);
            n_rows=length(uni_row);
            obj.plot_lim.minx=nan(n_rows,n_columns);
            obj.plot_lim.maxx=nan(n_rows,n_columns);
            obj.plot_lim.miny=nan(n_rows,n_columns);
            obj.plot_lim.maxy=nan(n_rows,n_columns);
            obj.plot_lim.minc=nan(n_rows,n_columns);
            obj.plot_lim.maxc=nan(n_rows,n_columns);
            
            %Create color map (HSV color map)
            %cmap=colormap(hsv(length(uni_color)));
            
            %Create color map (~isoluminant L*ch color map, needs image processing toolbox)
            %             map=horzcat(ones(length(uni_color),1)*50,...
            %                 ones(length(uni_color),1)*100,...
            %                 mod(220+(0:((360+0.0001)/(length(uni_color))):360)',360)); %Only the hue component is  varied across conditions
            %             ind_color=makecform('lch2lab');
            %             map=applycform(map,ind_color);
            %             ind_color=makecform('lab2srgb');
            %             cmap=applycform(map,ind_color);
            

            cmap=get_colormap(length(uni_color),length(uni_lightness),obj.color_options);
            
            %Initialize results structure (n_groups is an overestimate if
            %there are redundant groups
            n_groups=length(uni_row)*length(uni_column)*length(uni_marker)...
                *length(uni_size)*length(uni_linestyle)*length(uni_color)*length(unique(temp_aes.group));
            aes_names_fieldnames=fieldnames(obj.aes_names);
            for fn=3:length(aes_names_fieldnames)
                obj.results.(aes_names_fieldnames{fn})=cell(n_groups,1);
                obj.results.(['ind_' aes_names_fieldnames{fn}])=cell(n_groups,1);
            end
            obj.results.draw_data=cell(n_groups,1);

            %Store different line styles
            line_styles={'-' '--' ':' '-.'};
            %Store different sizes
            markers={'o' 's' 'd' '^' 'v' '>' '<' 'p' 'h' '*' '+' 'x'};
            if length(uni_size)>1
                sizes=linspace(4,15,length(uni_size));
            else
                if uni_size{1}==1
                    sizes=6;
                else
                    sizes=uni_size{1};
                end
            end
            
            obj.firstrun=ones(n_rows,n_columns);
            %Index in the loops
            obj.r_ind=1;
            
            %% draw() looping
            
            %Loop over rows
            for ind_row=1:length(uni_row)
                
                sel_row=multi_sel(temp_row_facet,uni_row{ind_row});
                
                obj.current_row=ind_row;
                
                %Loop over columns
                for ind_column=1:length(uni_column)
                    
                    sel_column=sel_row & multi_sel(temp_col_facet,uni_column{ind_column});
                    
                    obj.current_column=ind_column;
                    
                    %Store limits of the subplots
                    if sum(sel_column)>0
                        if iscell(temp_aes.x(sel_column))
                            obj.plot_lim.maxx(obj.current_row,obj.current_column)=cellmax(temp_aes.x(sel_column));
                            obj.plot_lim.minx(obj.current_row,obj.current_column)=cellmin(temp_aes.x(sel_column));
                        else
                            obj.plot_lim.maxx(obj.current_row,obj.current_column)=max(temp_aes.x(sel_column));
                            obj.plot_lim.minx(obj.current_row,obj.current_column)=min(temp_aes.x(sel_column));
                        end
                        if iscell(temp_aes.y(sel_column))
                            obj.plot_lim.maxy(obj.current_row,obj.current_column)=cellmax(temp_aes.y(sel_column));
                            obj.plot_lim.miny(obj.current_row,obj.current_column)=cellmin(temp_aes.y(sel_column));
                        else
                            obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(temp_aes.y(sel_column));
                            obj.plot_lim.miny(obj.current_row,obj.current_column)=min(temp_aes.y(sel_column));
                        end
                    else
                        obj.plot_lim.maxy(obj.current_row,obj.current_column)=0;
                        obj.plot_lim.miny(obj.current_row,obj.current_column)=0;
                        obj.plot_lim.maxx(obj.current_row,obj.current_column)=0;
                        obj.plot_lim.minx(obj.current_row,obj.current_column)=0;
                    end
                    

                    %Create subplot (much faster to do it here at the most upper level: changing subplot takes a
                    %long time in Matlab)
                    if obj.wrap_ncols>0
                        obj.facet_axes_handles(ind_column)=mysubplot_wrap(length(uni_column),ind_column);
                    else
                        obj.facet_axes_handles(ind_row,ind_column)=mysubplot(length(uni_row),length(uni_column),ind_row,ind_column);
                    end
                    
                   
                    hold on
                    
                    
                    %Store all the X used for the current facet (useful for
                    %correct spacing of dodged bars and boxplots when
                    %missing data).
                    draw_data.facet_x=temp_aes.x(sel_column);
                    
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
                                        
                                        %Loop over groups
                                        for ind_group=1:length(uni_group)
                                            
                                            sel=sel_lightness & multi_sel(temp_aes.group,uni_group{ind_group});
                                            
                                            %Fill out results struct
                                            obj.results.row{obj.r_ind}=uni_row{ind_row};
                                            obj.results.column{obj.r_ind}=uni_column{ind_column};
                                            obj.results.marker{obj.r_ind}=uni_marker{ind_marker};
                                            obj.results.linestyle{obj.r_ind}=uni_linestyle{ind_linestyle};
                                            obj.results.size{obj.r_ind}=uni_size{ind_size};
                                            obj.results.color{obj.r_ind}=uni_color{ind_color};
                                            obj.results.lightness{obj.r_ind}=uni_lightness{ind_lightness};
                                            obj.results.group{obj.r_ind}=uni_group{ind_group};
                                            
                                            obj.results.ind_row{obj.r_ind}=ind_row;
                                            obj.results.ind_column{obj.r_ind}=ind_column;
                                            obj.results.ind_marker{obj.r_ind}=ind_marker;
                                            obj.results.ind_linestyle{obj.r_ind}=ind_linestyle;
                                            obj.results.ind_size{obj.r_ind}=ind_size;
                                            obj.results.ind_color{obj.r_ind}=ind_color;
                                            obj.results.ind_lightness{obj.r_ind}=ind_lightness;
                                            obj.results.ind_group{obj.r_ind}=ind_group;
                                            
                                            
                                            
                                            if ~isempty(sel)
                                                
                                                %Fill up the draw_data
                                                %structure passed to the
                                                %individual geoms
                                                draw_data.x=temp_aes.x(sel);
                                                draw_data.y=temp_aes.y(sel);
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
                                                
                                                draw_data=rmfield(draw_data,{'x','y','continuous_color','color_index','n_colors'});
                                                obj.results.draw_data{obj.r_ind}=draw_data;
                                                
                                                %Iterate loop counter
                                                obj.r_ind=obj.r_ind+1;
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
                    if length(uni_column)>1
                        if ~isempty(obj.aes_names.column)
                            column_string=[obj.aes_names.column ': ' num2str(uni_column{ind_column})];
                        else
                            column_string=num2str(uni_column{ind_column});
                        end
                        
                        if ind_row==1
                            text('Interpreter','none','String',column_string,'Rotation',0,...
                                'Units','normalized',...
                                'Position',[0.5 1.05 2],...
                                'BackgroundColor','none',...
                                'HorizontalAlignment','Center',...
                                'VerticalAlignment','bottom',...
                                'FontWeight','bold',...
                                'fontSize',12);
                        end
                    end
                    if length(uni_row)>1
                        if ~isempty(obj.aes_names.row)
                            row_string=[obj.aes_names.row ': ' num2str(uni_row{ind_row})];
                        else
                            row_string=num2str(uni_row{ind_row});
                        end
                        
                        if ind_column==length(uni_column)
                            text('Interpreter','none','String',row_string,'Rotation',-90,...
                                'Units','normalized',...
                                'Position',[1.05 0.5 2],...
                                'BackgroundColor','none',...
                                'HorizontalAlignment','Center',...
                                'VerticalAlignment','bottom',...
                                'FontWeight','bold',...
                                'fontSize',12);
                        end
                    end
                    
                    %title(title_string,'Interpreter','none')
                    % annotation('rectangle',[1 0.1 0.1 0.5],'Units','normalized','FaceColor',[0.5 0.5 0.5])
                    
                    %legend(tmp,color_handle,cellfun(@(x)num2str(x),uni_color,'UniformOutput',0));
                    %set(tmp,'vis','off')
                end
                
            end
            
            
            %% draw() legends
            
            %Create axes for legends
            %obj.legend_axe_handle=subplot('Position',[0.85 0.1 0.15 0.8]);
            obj.legend_axe_handle=subplot('Position',[obj.multi.orig(2)+0.85*obj.multi.size(2)...
                obj.multi.orig(1)+0.1*obj.multi.size(1) 0.15*obj.multi.size(2) 0.8*obj.multi.size(1)]);
            hold on
            set(obj.legend_axe_handle,'Visible','off');
            
            ind_scale=0;
            ind_scale_step=1;
            
            if obj.with_legend
                %Color legend
                if length(uni_color)>1
                    %Make a colormap with only the colors and no lightness
                    color_legend_map=get_colormap(length(uni_color),1,obj.color_options);
                    
                    text(1,ind_scale,obj.aes_names.color,'FontWeight','bold','Interpreter','none','fontSize',12)
                    ind_scale=ind_scale-ind_scale_step;
                    for ind_color=1:length(uni_color)
                        plot([1 2],[ind_scale ind_scale],'-','Color',color_legend_map(ind_color,:),'lineWidth',2)
                        text(2.5,ind_scale,num2str(uni_color{ind_color}),'Interpreter','none')
                        ind_scale=ind_scale-ind_scale_step;
                    end
                end
                
                %Lightness legend
                if length(uni_lightness)>1
                    
                    lightness_legend_map=pa_LCH2RGB([linspace(obj.color_options.lightness_range(1),obj.color_options.lightness_range(2),length(uni_lightness))' ...
                        zeros(length(uni_lightness),1)...
                        zeros(length(uni_lightness),1)]);
                    
                    text(1,ind_scale,obj.aes_names.lightness,'FontWeight','bold','Interpreter','none','fontSize',12)
                    ind_scale=ind_scale-ind_scale_step;
                    for ind_lightness=1:length(uni_lightness)
                        plot([1 2],[ind_scale ind_scale],'-','Color',lightness_legend_map(ind_lightness,:),'lineWidth',2)
                        text(2.5,ind_scale,num2str(uni_lightness{ind_lightness}),'Interpreter','none')
                        ind_scale=ind_scale-ind_scale_step;
                    end
                end
                
                %Continuous color legend
                if obj.continuous_color
                    text(1,ind_scale,obj.aes_names.color,'FontWeight','bold','Interpreter','none','fontSize',12)
                    ind_scale=ind_scale-ind_scale_step;
                    
                    %                 image(ones(1,length(obj.continuous_color_colormap))+0.5,...
                    %                     linspace(ind_scale-2,ind_scale,length(obj.continuous_color_colormap)),...
                    %                     reshape(obj.continuous_color_colormap,length(obj.continuous_color_colormap),1,3));
                    
                    tmp_N=100;
                    imagesc([1.3 1.7],[ind_scale-2 ind_scale],linspace(min(min(obj.plot_lim.minc)),max(max(obj.plot_lim.maxc)),tmp_N)')
                    
                    colormap(obj.continuous_color_colormap)
                    caxis([min(min(obj.plot_lim.minc)) max(max(obj.plot_lim.maxc))]);
                    
                    text(2.5,ind_scale,num2str(max(max(obj.plot_lim.maxc))));
                    text(2.5,ind_scale-2,num2str(min(min(obj.plot_lim.minc))));
                    
                    ind_scale=ind_scale-ind_scale_step*3;
                end
                
                %marker legend
                if length(uni_marker)>1
                    text(1,ind_scale,obj.aes_names.marker,'FontWeight','bold','Interpreter','none','fontSize',12)
                    ind_scale=ind_scale-ind_scale_step;
                    for ind_marker=1:length(uni_marker)
                        plot(1.5,ind_scale,markers{ind_marker},'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0])
                        text(2.5,ind_scale,num2str(uni_marker{ind_marker}),'Interpreter','none')
                        ind_scale=ind_scale-ind_scale_step;
                    end
                end
                
                %linestyle legend
                if length(uni_linestyle)>1
                    text(1,ind_scale,obj.aes_names.linestyle,'FontWeight','bold','Interpreter','none','fontSize',12)
                    ind_scale=ind_scale-ind_scale_step;
                    for ind_linestyle=1:length(uni_linestyle)
                        plot([1 2],[ind_scale ind_scale],line_styles{ind_linestyle},'Color',[0 0 0])
                        text(2.5,ind_scale,num2str(uni_linestyle{ind_linestyle}),'Interpreter','none')
                        ind_scale=ind_scale-ind_scale_step;
                    end
                end
                
                %Size legend
                if length(uni_size)>1
                    text(1,ind_scale,obj.aes_names.size,'FontWeight','bold','Interpreter','none','fontSize',12)
                    ind_scale=ind_scale-ind_scale_step;
                    for ind_size=1:length(uni_size)
                        plot([1 2],[ind_scale ind_scale],'lineWidth',sizes(ind_size)/4,'Color',[0 0 0])
                        plot(1.5,ind_scale,'o','markerSize',sizes(ind_size),'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0])
                        text(2.5,ind_scale,num2str(uni_size{ind_size}),'Interpreter','none')
                        ind_scale=ind_scale-ind_scale_step;
                    end
                end
            end
            %Set size of legend axes
            xlim([1 8])
            if ind_scale<0
                ylim([ind_scale 1])
            end
            %ylim([ind_scale/2-8 ind_scale/2+8])
            %ylim([ind_scale-0.1 0.1])
            
            %% draw() axes modifications
            
            %Set various properties on each of the subplots
            for ind_row=1:length(uni_row)
                %Loop over columns
                for ind_column=1:length(uni_column)
                    
                    %Set current axes
                    axes(obj.facet_axes_handles(ind_row,ind_column));
                    
                    %Do the datetick
                    if ~isempty(obj.datetick_params)
                        for dtk=1:length(obj.datetick_params)
                            datetick(obj.datetick_params{dtk}{:});
                        end
                    end
                    
                    if obj.continuous_color
                        %Set color limits the same way on each plot
                        caxis([min(min(obj.plot_lim.minc)) max(max(obj.plot_lim.maxc))]);
                    end
                    
                    
                    %Ad hoc limit correction for empty facets
                    obj.plot_lim.maxy(obj.plot_lim.miny==obj.plot_lim.maxy)=obj.plot_lim.maxy(obj.plot_lim.miny==obj.plot_lim.maxy)+0.01;
                    obj.plot_lim.maxx(obj.plot_lim.minx==obj.plot_lim.maxx)=obj.plot_lim.maxx(obj.plot_lim.minx==obj.plot_lim.maxx)+0.01;
                    
                    if ~obj.polar.is_polar % XY Limits are only useful for non-polar plots
                        
                        %Set axes limits logic according to facet_scale and
                        %wrapping. Also set up corresponding axis linking, using tip from 
                        % http://undocumentedmatlab.com/blog/using-linkaxes-vs-linkprop#more-5928
                        if (obj.wrap_ncols>0) 
                            switch obj.facet_scale
                                case 'fixed'
                                    temp_xscale='global';
                                    temp_yscale='global';
                                    
                                    %Both XLims and YLims are linked across
                                    %all plots
                                    if ind_row==1 && ind_column==1
                                        obj.extra.YLim_listeners=linkprop(obj.facet_axes_handles(:),'YLim');
                                        obj.extra.XLim_listeners=linkprop(obj.facet_axes_handles(:),'XLim');
                                    end  
                                case 'free_x'
                                    temp_xscale='per_plot';
                                    temp_yscale='global';
                                    
                                    %XLims are linked across all plots
                                    if ind_row==1 && ind_column==1
                                        obj.extra.YLim_listeners=linkprop(obj.facet_axes_handles(:),'YLim');
                                    end
                                case 'free_y'
                                    temp_xscale='global';
                                    temp_yscale='per_plot';
                                    
                                    %YLims are linked across all plots
                                    if ind_row==1 && ind_column==1
                                        obj.extra.XLim_listeners=linkprop(obj.facet_axes_handles(:),'XLim');
                                    end
                                case 'free'
                                    temp_xscale='per_plot';
                                    temp_yscale='per_plot';
                                case 'independent'
                                    temp_xscale='per_plot';
                                    temp_yscale='per_plot';
                            end
                        else
                            switch obj.facet_scale
                                case 'fixed'
                                    temp_xscale='global';
                                    temp_yscale='global';
                                    
                                    %Both XLim and YLim are linked across
                                    %all plots
                                    if ind_row==1 && ind_column==1
                                         obj.extra.YLim_listeners=linkprop(obj.facet_axes_handles(:),'YLim');
                                         obj.extra.XLim_listeners=linkprop(obj.facet_axes_handles(:),'XLim');
                                    end
                                case 'free_x'
                                    temp_xscale='per_column';
                                    temp_yscale='global';

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
                        xlim(temp_xlim+[-diff(temp_xlim)*obj.xlim_extra*0.5 diff(temp_xlim)*obj.xlim_extra*0.5]);
                        
                        switch temp_yscale
                            case 'global'
                                temp_ylim=[min(min(obj.plot_lim.miny(:,:))) max(max(obj.plot_lim.maxy(:,:)))];
                            case 'per_row'
                                temp_ylim=[min(obj.plot_lim.miny(ind_row,:)) max(obj.plot_lim.maxy(ind_row,:))];
                            case 'per_plot'
                                temp_ylim=[obj.plot_lim.miny(ind_row,ind_column) obj.plot_lim.maxy(ind_row,ind_column)];
                        end
                         ylim(temp_ylim+[-diff(temp_ylim)*obj.ylim_extra*0.5 diff(temp_ylim)*obj.ylim_extra*0.5]);
                            
                        
                        %Set up logic of plot ticks presence
                        has_xtick=obj.force_ticks || ... %Plot has xticks if forced
                            (obj.wrap_ncols==-1 && ind_row==length(uni_row)) || ... %Or if we're in facet grid mode and we are in the last row
                            (obj.wrap_ncols>0 && (length(uni_column)-ind_column)<obj.wrap_ncols) ||... %Or if we are in facet wrap mode and we are in the last facet on the "column"
                            strcmp(temp_xscale,'per_plot'); %Or if we were in a per-plot scale mode
                        
                        has_ytick=obj.force_ticks || ... %Plot has xticks if forced
                            (obj.wrap_ncols==-1 && ind_column==1) || ... %Or if we're in facet grid mode and are in the first column
                            (obj.wrap_ncols>0 && mod(ind_column,obj.wrap_ncols)==1) || ... %Or if we are in facet wrap mode and are in the first "column"
                            strcmp(temp_yscale,'per_plot'); %Or if we were in a per-plot scale mode
                        
                        %Remove ticks if necessary 
                        if ~has_xtick
                            set(gca,'XTickLabel','');
                        end
                        if ~has_ytick
                            set(gca,'YTickLabel','');
                        end
                        
                        
                        %Set appropriate x ticks if labeled
                        if obj.x_factor
                            temp_xlim=get(gca,'xlim');
                            xlim([temp_xlim(1)-1 temp_xlim(2)+1])
                            set(gca,'XTick',1:length(obj.x_ticks))
                            if has_xtick
                                set(gca,'XTickLabel',obj.x_ticks)
                                try
                                    set(gca,'TickLabelInterpreter','none')%Just try it (doesn't exist in pre-2014b)
                                end
                                %set(gca,'XTickLabelRotation',30)
                            end
                        end
                        
                        %Add axes labels on right and botttom graphs only
                        if ind_column==1 || (obj.wrap_ncols>0 && mod(ind_column,obj.wrap_ncols)==1)
                            ylabel(obj.aes_names.y,'Interpreter','none'); %,'Units','normalized','position',[-0.2 0.5 1]
                        end
                        if (ind_row==length(uni_row) && obj.wrap_ncols<=0) || (obj.wrap_ncols>0 && (length(uni_column)-ind_column)<obj.wrap_ncols)
                            xlabel(obj.aes_names.x,'Interpreter','none')
                        end
                    else
                        %Make polar axes
                        if obj.polar.max_polar_y<0
                            if strcmp(obj.facet_scale,'fixed')
                                draw_polar_axes(max(max(obj.plot_lim.maxy(:,:))));
                            else
                                draw_polar_axes(obj.plot_lim.maxy(ind_row,ind_column));
                            end
                        else
                            draw_polar_axes(obj.polar.max_polar_y)
                        end
                    end
                    

                    %Set custom axes properties
                    if ~isempty(obj.axe_properties)
                        for ap=1:size(obj.axe_properties,1)
                            set(gca,obj.axe_properties{ap,1},obj.axe_properties{ap,2})
                        end
                    end
                    
                    %Set ablines, hlines and vlines (after axe properties in case the limits
                    %are changed there
                    if obj.abline.on
                        xl=get(gca,'xlim');
                        for line_ind=1:length(obj.abline.intercept)
                            if ~isnan(obj.abline.intercept(line_ind))
                                %abline
                                plot(xl,xl*obj.abline.slope(line_ind)+obj.abline.intercept(line_ind),obj.abline.style{line_ind});
                            else
                                if ~isnan(obj.abline.xintercept(line_ind))
                                    %vline
                                     yl=get(gca,'ylim');
                                     plot([obj.abline.xintercept(line_ind) obj.abline.xintercept(line_ind)],yl,obj.abline.style{line_ind});
                                else
                                    if ~isnan(obj.abline.yintercept(line_ind))
                                        %hline
                                        plot(xl,[obj.abline.yintercept(line_ind) obj.abline.yintercept(line_ind)],obj.abline.style{line_ind});
                                    else
                                        temp_x=linspace(xl(1),xl(2),100);
                                        plot(temp_x,obj.abline.fun{line_ind}(temp_x),obj.abline.style{line_ind});
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
            if ~obj.multi.active %This doesn't work for multiple plots at that point
                redraw(obj,0.04);
                if verLessThan('matlab','8.4')
                    set(gcf,'ResizeFcn',@(a,b)redraw(obj,0.04));
                else
                    set(gcf,'SizeChangedFcn',@(a,b)redraw(obj,0.04));
                end
            end
            
            
            %Clean up results
            result_fields=fieldnames(obj.results);
            if obj.r_ind>1
                for rf=1:length(result_fields)
                    %Resize
                    obj.results.(result_fields{rf})=obj.results.(result_fields{rf})(1:obj.r_ind-1);
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
                set(gcf,'Renderer','Painters')
            end
        end
        
%% geom public methods
        function obj=geom_line(obj)
            % geom_line Display data as lines
            %
            % This will add a layer that will display data as lines
            % If the data is not properly grouped/ordered things can look weird.
            
            obj.geom=vertcat(obj.geom,{@(dd)obj.my_line(dd)});
        end
        
        function obj=geom_point(obj)
            % geom_point Display data as points
            %
            % This will add a layer that will display data as points
            
            obj.geom=vertcat(obj.geom,{@(dd)obj.my_point(dd)});
        end
        
        function obj=geom_count(obj,varargin)
            %geom_count Display data as points which size vary with with
            %count
            %
            % Parameters:
            % 'scale': set the scaling factor between count and area
            % 'point_color': set how the points are colored 'edge', 'face',
            % 'all'
            
            p=inputParser;
            my_addParameter(p,'scale',20);
            my_addParameter(p,'point_color','all'); %edge,face,all
            parse(p,varargin{:});
            obj.geom=vertcat(obj.geom,{@(dd)obj.my_count(dd,p.Results)});
            
        end
        
        function obj=geom_jitter(obj,varargin)
            % geom_jitter Display data as jittered points
            %
            % Example syntax (default arguments): gramm_object.geom_jitter('width',0.2,'height',0.2)
            % In case datapoints are grouped together and are hard to see,
            % it's possible to randomly jitter them in an area of width
            % 'width' and height 'height' using this function.
            
            p=inputParser;
            my_addParameter(p,'width',0.2);
            my_addParameter(p,'height',0.2);
            parse(p,varargin{:});
            
            obj.geom=vertcat(obj.geom,{@(dd)obj.my_jitter(dd,p.Results)});
        end
        
        function obj=geom_abline(obj,varargin)
            % geom_abline Display y=ax+b reference lines in each facet
            %
            % Example syntax: gramm_object.geom_abline('slope',1,'intercept',0,'style','k--')
            % 'slope' and 'intercept' can be 1D arrays of the same size in
            % order to draw multiple lines. In that case, 'style' can
            % either be a single style string (all lines will have the same
            % style), or a cell array of strings to define one style per
            % line.
            
            p=inputParser;
            my_addParameter(p,'slope',1);
            my_addParameter(p,'intercept',0);
            my_addParameter(p,'style','k--');
            parse(p,varargin{:});
            
            for obj_ind=1:numel(obj)
                obj(obj_ind).abline=fill_abline(obj(obj_ind).abline,p.Results.slope,p.Results.intercept,NaN,NaN,@(x)x,p.Results.style);
            end
        end
        
        function obj=geom_vline(obj,varargin)
            % geom_abline Display vertical reference lines in each facet
            %
            % Example syntax: gramm_object.geom_abline('xintercept',1,'style','k--')
            % See geom_abline for details
            
            p=inputParser;
            my_addParameter(p,'xintercept',0);
            my_addParameter(p,'style','k--');
            parse(p,varargin{:});
            
            for obj_ind=1:numel(obj)
                obj(obj_ind).abline=fill_abline(obj(obj_ind).abline,NaN,NaN,p.Results.xintercept,NaN,@(x)x,p.Results.style);
            end
        end
        
        function obj=geom_hline(obj,varargin)
            % geom_abline Display an horizontal reference lines in each facet
            %
            % Example syntax: gramm_object.geom_abline('yintercept',1,'style','k--')
            % See geom_abline for details
            
            p=inputParser;
            my_addParameter(p,'yintercept',0);
            my_addParameter(p,'style','k--');
            parse(p,varargin{:});
            
            for obj_ind=1:numel(obj)
                obj(obj_ind).abline=fill_abline(obj(obj_ind).abline,NaN,NaN,NaN,p.Results.yintercept,@(x)x,p.Results.style);
            end
        end
        
        function obj=geom_funline(obj,varargin)
            p=inputParser;
            my_addParameter(p,'fun',@(x)x);
            my_addParameter(p,'style','k--');
            parse(p,varargin{:});
            
            for obj_ind=1:numel(obj)
                obj(obj_ind).abline=fill_abline(obj(obj_ind).abline,NaN,NaN,NaN,NaN,p.Results.fun,p.Results.style);
            end
        end
        
        
        
        function obj=geom_raster(obj,varargin)
            % geom_raster Plot X data as a raster plot
            %
            % Option 'geom': 'line' or 'point'
            p=inputParser;
            my_addParameter(p,'geom','point');
            parse(p,varargin{:});
            
            obj.geom=vertcat(obj.geom,{@(dd)obj.my_raster(dd,p.Results)});
        end
        
       function obj=geom_bar(obj,varargin)
            % geom_point Display data as bars
            %
            % Example syntax (default arguments): gramm_object.geom_bar(0.8)
            % This will add a layer that will display data as bars. When
            % data in several colors has to be displayed, the bars of
            % different colors are dodged. The function can receive an
            % optional argument specifying the width of the bar
            
            p=inputParser;
            my_addParameter(p,'width',0.80);
            my_addParameter(p,'stacked',false);
            parse(p,varargin{:});
            
            obj.geom=vertcat(obj.geom,{@(dd)obj.my_bar(dd,p.Results)});
            
        end
        
%% stat public methods    
        function obj=stat_smooth(obj,varargin)
            % stat_smooth Display a smoothed estimate of the data with
            % optional 95% confidence interval
            %
            % Warning: If used with repeated data (ie when y is given as 2D
            % array or cell array), the confidence interval will probably
            % be too small; it's better to use stat_summary in that case.
            
            p=inputParser;
            my_addParameter(p,'lambda',1000);
            my_addParameter(p,'geom','area');
            my_addParameter(p,'npoints',100);
            parse(p,varargin{:});
            
            obj.geom=vertcat(obj.geom,{@(dd)obj.my_smooth(dd,p.Results)});
            obj.results.smooth={};
        end
        
        
        
        
        function obj=stat_summary(obj,varargin)
            % stat_summary Display summarized data for each value of X
            %
            % Example syntax (default arguments): gramm_object.stat_summary('type','ci','geom','lines','setylim',false)
            % For each unique value of x, this can display various estimates of
            % the location and variability of the corresponding y distribution.
            % The optional 'name',value pairs can ne the following:
            % - 'type':
            %       - 'ci' : display the mean and the 95% confidence
            %       interval of the mean (based on the assumption of a normal
            %       distribution
            %       - 'bootci' : display the mean and the 95% confidence
            %       interval of the mean computed by bootstrap
            %       - 'sem' : display the mean and the standard error of
            %       the mean
            %       - 'std' : display the mean and the standard deviation
            %       and the mean
            %       - 'quartile': display the 25% 50% (median) and 75%
            %       percentiles
            %       - '95percentile': display the median and 2.5 and 97.5
            %       percentiles
            %        - 'fitnormalci'
            %       - 'fitpoissonci'
            %        - 'fit95percentile'
            % - 'geom':
            %       - 'line': displays a line the connects the locations
            %       (mean,median)
            %       - 'lines': displays a line that connects the locations
            %       and lighter lines for the variabilities
            %       - 'area': displays a line that connects the locations
            %       and a transparent area for the variabilities. WARNING:
            %       this changes the renderer to opengl and disables proper
            %       vector output on older matlab versions
            %       - 'solid_area': displays a line that connects the locations
            %       and a solid area for the variabilities. Use this for
            %       export to vector output.
            %       - 'errorbar': displays error bars for variabilities.
            %       - 'black_errorbar': displays black error bars for variabilities.
            %       - 'bar': displays the locations as bars
            % - 'setylim': set to true if you want the y axis limits to be
            % set by the summarized data instead of the underlying data
            % points.
            % - 'interp': Use to interpolate the output, takes the same parameters as
            % interp1 in order to specify the interpolation type. When the
            % polar mode is specified as closed, the interpolation uses
            % interpft, which supposes regular sampling around the circle.
            % - 'interp_in': Use to (linearly) interpolate the input. This is intended
            % for input given as cells when the x value is different for
            % each cell and not aligned. The argument corresponds to the
            % number of points used to generate the interpolation. Ideally
            % for this the number of number of points should be higher than
            % the x resolution of the data, otherwise some data will be
            % unused.
            % - 'bin_in': Use to bin the input. This is intended for input
            % given as array, creates bins over x and computes the summary
            % over the binned data. Argument corresponds to the number of
            % bins
            % - 'dodge': use to dodge the plotted elements depending on
            % color (recommended for 'bar', 'errorbar', 'black_errorbar').
            % Negative values deactivate dodging (default), other values set the space
            % between the dodged elements as ratio of the x intervals. Set
            % to 0 for bars to touch each other, increase for inceased
            % spacing.
            
            
            
            
            p=inputParser;
            my_addParameter(p,'type','ci'); %'95percentile'
            my_addParameter(p,'geom','area');
            my_addParameter(p,'dodge',-1);
            my_addParameter(p,'setylim',false);
            my_addParameter(p,'interp','none');
            my_addParameter(p,'interp_in',-1);
            my_addParameter(p,'bin_in',-1);
            parse(p,varargin{:});
            
            obj.geom=vertcat(obj.geom,{@(dd)obj.my_summary(dd,p.Results)});
            obj.results.summary={};
        end
        
        function obj=stat_boxplot(obj,varargin)
            %stat_boxplot() Create box and whiskers plots 
            %
            % stat_boxplot() will create boc and whisker plots of Y values for
            %unique values of X. The box is drawn between the 25 and 75
            %percentiles, with a line indicating the median. The wiskers
            %extend above and below the box by a distance equal to 1.5
            %times the interquartile range. Points outside the whiskers
            %ranges are plotted.
            % - 'spacing' allows to set the spacing between boxes or groups
            %   of boxes between unique values of x (expressed as a ratio)
            % - 'dodge' allows to set the spacing between boxes of
            %   different colors within an unique value of x. Set to a
            %   negative value to deactivate dodging. Set to zero for boxes
            %   touching.
            
            p=inputParser;
            my_addParameter(p,'spacing',0.2);
            my_addParameter(p,'dodge',0.1);
            parse(p,varargin{:});
            
            obj.geom=vertcat(obj.geom,{@(dd)obj.my_boxplot(dd,p.Results)});
            %obj.results.boxplot={};
            
        end
        
        function obj=stat_ellipse(obj,varargin)
            %stat_ellipse() Create confidence ellipses around 2D groups of
            % points
            %
            % Parameters:
            % 'type': The default '95percentile' displays an ellipse that
            % contains 95% of the points (assuming a bivariate normal
            % distribution). The option 'ci' will first compute boostrapped
            % 2D means and plot the 95% ellipse around these means
            % 'geom': Sets how to display the result 'area' for a shaded
            % area or 'line' for a simple contour line.
            % 'patch_opts': Provide additional patch properties as name-value 
            % pairs in a cell array (as if those were options for Matlab's
            % built in patch() function)

            p=inputParser;
            my_addParameter(p,'type','95percentile'); %ci
            my_addParameter(p,'geom','area'); %line
            my_addParameter(p,'patch_opts',{});
            parse(p,varargin{:});
            
            obj.geom=vertcat(obj.geom,{@(dd)obj.my_ellipse(dd,p.Results)});
            obj.results.ellipse={};
        end
        
        
        function obj=stat_glm(obj,varargin)
            % stat_glm Display a generalized linear model fit of the data
            %
            % Example syntax (default arguments): gramm_object.stat_glm('distribution','normal','geom','lines','fullrange','false')
            % This will fit a generalized linear model to the data, display
            % the fit results with 95% confidence bounds. The optional
            % 'name',value pairs are the following.
            % - 'distribution' corresponds to the distribution of the data.
            %   'normal', the default value leads to a standard linear model
            %   fit. Possible values are 'normal', 'binomial', 'poisson', 'gamma', and 'inverse gaussian'
            % - 'geom': defines the way to display the confidence bouds.
            %   See the help of stat_summary().
            % - 'fullrange': set to true if you want the fits to be
            %   displayed over the whole width of each subplot instead of
            %   being displayed over the range of x values used for the fit
            % - 'disp_fit': set to true to display the fitted parameters and
            % corresponding p-value stars.
            
            %Accepted distributions: 'normal' (default) | 'binomial' | 'poisson' | 'gamma' | 'inverse gaussian'
            p=inputParser;
            my_addParameter(p,'distribution','normal');
            my_addParameter(p,'geom','area');
            my_addParameter(p,'fullrange',false);
            my_addParameter(p,'disp_fit',false);
            parse(p,varargin{:});
            
            obj.geom=vertcat(obj.geom,{@(dd)obj.my_glm(dd,p.Results)});
            obj.results.glm={};
        end
        
        function obj=stat_fit(obj,varargin)
            % stat_fit() Display a custom fit of the data
            %
            % Example syntax gramm_object.stat_fit('fun',@(alpha,beta,x)alpha*cos(x-beta),'disp_fit',true)
            %
            % This fuction uses the curve fitting toolbox function fit() to
            % fit a provided anonymous function with arguments
            % (param1,param2,...paramN,x) to the data. 
            % Parameters:
            % - 'fun': anonymous function used for the fit
            % - 'StartPoint': Array containing starting values for the
            % parameter to be fitted [start_param1,start_param2,...start_paramN]
            % - 'intopt': Option passed to predint() for the type of bounds
            % to compute, 'observation' for bounds of a new observation
            % (default), or 'functional' for bounds of the fitted curve.
            % - 'geom', 'fullrange', 'disp_fit' options: see stat_glm()
            
            p=inputParser;
            my_addParameter(p,'fun',@(a,b,x)a*x+b);
            my_addParameter(p,'StartPoint',[]);
            my_addParameter(p,'intopt','observation');
            my_addParameter(p,'geom','area');
            my_addParameter(p,'fullrange',false);
            my_addParameter(p,'disp_fit',false);
            parse(p,varargin{:});
            obj.geom=vertcat(obj.geom,{@(dd)obj.my_fit(dd,p.Results)});
            obj.results.fit={};
        end
        
        

        
        
        
        function obj=stat_bin(obj,varargin)
            % geom_point Displays an histogram of the data in x
            %
            % Example syntax (default arguments): gramm_object.stat_bin('nbins',30,'geom','bar')
            % 'geom' can be 'bar', 'overlaid_bar', 'line', 'stairs', 'point' or 'stacked_bar'
            % The 'normalization' argument allows to optionally normalize
            % the bin counts (see the doc for Matlab's histcounts() ).
            % Default is 'count', for normalization to 1 use 'probability'
            % Instead of 'nbins', it is possible to directly specify bin
            % edges with 'edges'. If the specified bin widths are not
            % equal, it's recommended to use 'countdensity'
            % or 'pdf' for normalization. Aspect of the geoms can be
            % customized with the 'fill' option
            % ('edge','face','all','transparent')
            
            p=inputParser;
            my_addParameter(p,'nbins',30);
            my_addParameter(p,'edges',[]);
            my_addParameter(p,'geom','bar'); %line, bar, overlaid_bar, stacked_bar,stairs, point
            my_addParameter(p,'normalization','count');
            my_addParameter(p,'fill',[]); %edge,face,all,transparent
            my_addParameter(p,'bar_spacing',[]);
            parse(p,varargin{:});

            temp=p.Results;
            
            %Set up default fill options for the different geoms
            if isempty(temp.fill)
                switch temp.geom
                    case 'bar'
                        temp.fill='face';
                    case 'line'
                        temp.fill='edge';
                    case 'overlaid_bar'
                        temp.fill='transparent';
                    case 'stacked_bar'
                        temp.fill='face';
                    case 'stairs'
                        temp.fill='edge';
                    case 'point'
                        temp.fill='edge';
                end
            end
            
            obj.geom=vertcat(obj.geom,{@(dd)obj.my_bin(dd,temp)});
            obj.results.bin={};
        end
        
        function obj=stat_bin2d(obj,varargin)
            % stat_bin2d() Makes 2D bins of X and Y data and displays count
            %
            % Parameters as 'name',value pairs:
            % - 'nbins': Array in the form of [nxbins nybins] to set the
            % number of bins in each dimension
            % - 'edges': Cell in the form of {[x__edges] [y_edges]} to set
            % custom bin edges for each dimension
            % - 'geom': Set how results are displayed. 'image' uses a
            % heatmap (default), 'contour' uses a contour plot. 'point'
            % uses circles of varying size.
            
            p=inputParser;
            my_addParameter(p,'nbins',[30 30]);
            my_addParameter(p,'edges',{});
            my_addParameter(p,'geom','image'); %contour
            
            parse(p,varargin{:});
            
            obj.geom=vertcat(obj.geom,{@(dd)obj.my_bin2d(dd,p.Results)});
            obj.results.bin2d={};
        end
        
        
        
        function obj=stat_density(obj,varargin)
            % geom_point Displays an smooth density estimate of the data in x
            %
            % Example syntax (default arguments): gramm_object.stat_density('function','pdf','kernel','normal','npoints',100)
            % the 'function','kernel', and 'bandwidth' arguments are the
            % ones used by the underlying matlab function ksdensity
            % 'npoints' is used to set how many x values are used to
            % display the density estimates.
            % 'extra_x' is used to increase the range of x values over
            % which the estimated density function is displayed. Values
            % will be extended to the right and to the left by extra_x
            % times the range of x data.
            
            p=inputParser;
            my_addParameter(p,'bandwidth',-1);
            my_addParameter(p,'function','pdf')
            my_addParameter(p,'kernel','normal')
            my_addParameter(p,'npoints',100)
            my_addParameter(p,'extra_x',0.1)
            parse(p,varargin{:});
            
            obj.geom=vertcat(obj.geom,{@(dd)obj.my_density(dd,p.Results)});
            obj.results.density={};
        end
        
        function obj=stat_qq(obj,varargin)
            % stat_qq Makes a quantile-quantile plot from the data in x
            %
            % 'distribution' is used to provide a custom distribution
            % constructed with Matlab's makedist(). Default is
            % makedist('Normal',0,1). Use 'y' instead of a custom
            % distrubution to plot the distribution of y against the
            % distribution of x
           
            p=inputParser;
            my_addParameter(p,'distribution',makedist('Normal',0,1));

            parse(p,varargin{:});
            
            obj.geom=vertcat(obj.geom,{@(dd)obj.my_qq(dd,p.Results)});
        end
        
        

    end
    
    methods (Access=protected,Hidden=true)
        
        function [x,y]=to_polar(obj,theta,rho)
            %If the graph is set as polar, x and y are interpreted as rho and
            %theta respectively, and data is converted in cartesian x and
            %y. Passthrough if is_polar is false
            
            if obj.polar.is_polar
                if iscell(theta)
                    x=cell(size(theta));
                    y=cell(size(theta));
                    for k=1:length(theta)
                        [x{k},y{k}]=pol2cart(theta{k},rho{k});
                        
                        %We close the plot by repeating the first point at
                        %the end
                        if obj.polar.is_polar_closed
                            x{k}(end+1)=x{k}(1);
                            y{k}(end+1)=y{k}(1);
                        end
                        
                    end
                else
                    [x,y]=pol2cart(theta,rho);
                    if obj.polar.is_polar_closed && size(shiftdim(x),2)==1 && size(shiftdim(y),2)==1
                        x(end+1)=x(1);
                        y(end+1)=y(1);
                    end
                end
            else
                x=theta;
                y=rho;
            end
        end
        
        function hndl=my_point(obj,draw_data)
            
            
            if obj.continuous_color
                if iscell(draw_data.x)
                    [x,y]=obj.to_polar(draw_data.x,draw_data.y);
                    if iscell(draw_data.continuous_color)
                        for k=1:length(x)
                            hndl=scatter(comb(x),comb(y),draw_data.size,comb(draw_data.continuous_color),draw_data.marker,'MarkerFaceColor','flat','MarkerEdgeColor','none');
                        end
                    else
                        hndl=scatter(x{k},y{k},draw_data.size,repmat(draw_data.continuous_color(k),length(x{k}),1),draw_data.marker,'MarkerFaceColor','flat','MarkerEdgeColor','none');
                    end
                else
                    [x,y]=obj.to_polar(comb(draw_data.x),comb(draw_data.y));
                    hndl=scatter(x,y,draw_data.size*6,draw_data.continuous_color,draw_data.marker,'MarkerFaceColor','flat','MarkerEdgeColor','none');
                end
                obj.plot_lim.maxc(obj.current_row,obj.current_column)=max(obj.plot_lim.maxc(obj.current_row,obj.current_column),max(comb(draw_data.continuous_color)));
                obj.plot_lim.minc(obj.current_row,obj.current_column)=min(obj.plot_lim.maxc(obj.current_row,obj.current_column),min(comb(draw_data.continuous_color)));
                
                
            else
                [x,y]=obj.to_polar(comb(draw_data.x),comb(draw_data.y));
                hndl=plot(x,y,draw_data.marker,'MarkerEdgeColor','none','markerSize',draw_data.size,'MarkerFaceColor',draw_data.color);
            end
            
        end
        
        function hndl=my_line(obj,draw_data)
            
            [x,y]=obj.to_polar(draw_data.x,draw_data.y);
            
            if obj.continuous_color
                
                obj.plot_lim.maxc(obj.current_row,obj.current_column)=max(obj.plot_lim.maxc(obj.current_row,obj.current_column),max(comb(draw_data.continuous_color)));
                obj.plot_lim.minc(obj.current_row,obj.current_column)=min(obj.plot_lim.minc(obj.current_row,obj.current_column),min(comb(draw_data.continuous_color)));
                
                
                if iscell(x)
                    for k=1:length(x)
                        %p=patch(draw_data.x{k},draw_data.y{k},draw_data.continuous_color,'faceColor','none','EdgeColor','interp','lineWidth',draw_data.size/4,'LineStyle',draw_data.line_style);
                        if iscell(draw_data.continuous_color)
                            %p=patch([obj.var_lim.minx-obj.var_lim.maxx ; x{k} ; obj.var_lim.maxx*2],[obj.var_lim.miny-10 ;y{k} ; obj.var_lim.miny-10],[draw_data.continuous_color{k}(1) ; draw_data.continuous_color{k} ; draw_data.continuous_color{k}(end)],'faceColor','none','EdgeColor','flat','lineWidth',draw_data.size/4,'LineStyle',draw_data.line_style);
                           p=patch([shiftdim(x{k}) ; flipud(shiftdim(x{k}))],[shiftdim(y{k}) ; flipud(shiftdim(y{k}))],[shiftdim(draw_data.continuous_color{k}) ; flipud(shiftdim(draw_data.continuous_color{k}))],'faceColor','none','EdgeColor','flat','lineWidth',draw_data.size/4,'LineStyle',draw_data.line_style);
                        else
                           %p=patch([obj.var_lim.minx-obj.var_lim.maxx ; x{k} ; obj.var_lim.maxx*2],[obj.var_lim.miny-10 ;y{k} ; obj.var_lim.miny-10],repmat(draw_data.continuous_color(k),length(x{k})+2,1),'faceColor','none','EdgeColor','flat','lineWidth',draw_data.size/4,'LineStyle',draw_data.line_style);
                           p=patch([shiftdim(x{k}) ; flipud(shiftdim(x{k}))],[shiftdim(y{k}) ; flipud(shiftdim(y{k}))],repmat(draw_data.continuous_color(k),length(x{k})*2,1),'faceColor','none','EdgeColor','flat','lineWidth',draw_data.size/4,'LineStyle',draw_data.line_style);
                        end
                    end
                else
                    %p=patch([draw_data.x;flipud(draw_data.x)],[draw_data.y;flipud(draw_data.y)],[draw_data.continuous_color;flipud(draw_data.continuous_color)],'faceColor','none','EdgeColor','flat','lineWidth',draw_data.size/4,'LineStyle',draw_data.line_style);
                    %p=patch([obj.var_lim.minx-obj.var_lim.maxx ; x ; obj.var_lim.maxx*2],[obj.var_lim.miny-10 ; y ; obj.var_lim.miny-10],[draw_data.continuous_color(1) ; draw_data.continuous_color ; draw_data.continuous_color(end)],'faceColor','none','EdgeColor','flat','lineWidth',draw_data.size/4,'LineStyle',draw_data.line_style);
                    p=patch([shiftdim(x) ; flipud(shiftdim(x))],[shiftdim(y) ; flipud(shiftdim(y))],[shiftdim(draw_data.continuous_color) ; flipud(shiftdim(draw_data.continuous_color))],'faceColor','none','EdgeColor','flat','lineWidth',draw_data.size/4,'LineStyle',draw_data.line_style);
                end
                
                
            else
                if iscell(x)
                    for k=1:length(draw_data.x)
                        hndl=plot(x{k},y{k},'LineStyle',draw_data.line_style,'lineWidth',draw_data.size/4,'Color',draw_data.color);
                    end
                else
                    hndl=plot(x,y,'LineStyle',draw_data.line_style,'lineWidth',draw_data.size/4,'Color',draw_data.color);
                end
            end
            
        end
        
        function  hndl=my_jitter(obj,draw_data,params)
            
            draw_data.x=draw_data.x+rand(size(draw_data.x))*params.width-params.width/2;
            draw_data.y=draw_data.y+rand(size(draw_data.y))*params.height-params.height/2;
            
            %[x,y]=obj.to_polar(x,y);
            
            %We adjust axes limits to accomodate for the jittering
            if max(draw_data.x)>obj.plot_lim.maxx(obj.current_row,obj.current_column);
                obj.plot_lim.maxx(obj.current_row,obj.current_column)=max(draw_data.x);
            end
            if min(draw_data.x)<obj.plot_lim.minx(obj.current_row,obj.current_column);
                obj.plot_lim.minx(obj.current_row,obj.current_column)=min(draw_data.x);
            end
            if max(draw_data.y)>obj.plot_lim.maxy(obj.current_row,obj.current_column);
                obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(draw_data.y);
            end
            if min(draw_data.y)<obj.plot_lim.miny(obj.current_row,obj.current_column);
                obj.plot_lim.miny(obj.current_row,obj.current_column)=min(draw_data.y);
            end
            
            %hndl=plot(x,y,draw_data.marker,'MarkerEdgeColor','none','markerSize',draw_data.size,'MarkerFaceColor',draw_data.color);
            hndl=my_point(obj,draw_data)
        end
        
        function hndl=my_count(obj,draw_data,params)
            
           if obj.continuous_color
               disp('geom_count() unsupported with continuous color')               
            else
                [x,y]=obj.to_polar(comb(draw_data.x),comb(draw_data.y));
                
                [C,ia,ic]=unique([shiftdim(x) shiftdim(y)],'rows');
                counts=accumarray(ic,1);
                
                switch params.point_color
                    case 'face'
                        edge='k';
                        face=draw_data.color;
                    case 'edge'
                        edge=draw_data.color;
                        face='none';
                    otherwise
                        edge='none';
                        face=draw_data.color;
                end
                
                hndl=scatter(C(:,1),C(:,2),counts*params.scale,draw_data.marker,'MarkerEdgeColor',edge,'MarkerFaceColor',face);
                
                %hndl=my_point(obj,draw_data);
            end
            
            
        end
        
        
        function hndl=my_raster(obj,draw_data,params)
            
            %Reset raster position for new subplot
            if obj.firstrun(obj.current_row,obj.current_column)
                obj.extra.raster_position=0;
            end
            
            if iscell(draw_data.x)
                
                temp_x=padded_cell2mat(draw_data.x);
                temp_y=ones(size(temp_x));
                temp_y=bsxfun(@times,temp_y,shiftdim(obj.extra.raster_position:obj.extra.raster_position+length(draw_data.x)-1));
                
                obj.extra.raster_position=obj.extra.raster_position+length(draw_data.x);
                
                if strcmp(params.geom,'line')
                    %Slow version
                    %line([temp_x(:) temp_x(:)]',[temp_y(:) temp_y(:)+1]','color',draw_data.color,'lineWidth',draw_data.size/4);
                    
                    %Fast version
                    allx=[temp_x(:) temp_x(:) temp_x(:)]';
                    ally=[temp_y(:) temp_y(:)+0.9 NaN(numel(temp_x),1)]';
                    plot(allx(:),ally(:),'color',draw_data.color,'lineWidth',draw_data.size/4);
                else
                    plot(temp_x,temp_y,'o','MarkerEdgeColor','none','markerSize',draw_data.size,'MarkerFaceColor',draw_data.color);
                end

            else
                
                if strcmp(params.geom,'line')
                    hndl=line([shiftdim(draw_data.x) shiftdim(draw_data.x)]',...
                        repmat([obj.extra.raster_position;obj.extra.raster_position+1],1,length(draw_data.x)),...
                        'color',draw_data.color,'lineWidth',draw_data.size/4);
                else
                    plot(shiftdim(draw_data.x),repmat(obj.extra.raster_position,1,length(draw_data.x)),...
                        'o','MarkerEdgeColor','none','markerSize',draw_data.size,'MarkerFaceColor',draw_data.color);
                end
                obj.extra.raster_position=obj.extra.raster_position+1;
                
            end
            
            obj.plot_lim.miny(obj.current_row,obj.current_column)=0;
            obj.plot_lim.maxy(obj.current_row,obj.current_column)=obj.extra.raster_position;
        end
        
        function hndl=my_smooth(obj,draw_data,params)
            
            if iscell(draw_data.x) || iscell(draw_data.y) %If input was provided as cell/matrix
                
                %Duplicate the draw data
                new_draw_data=draw_data;
                
                tempx=zeros(length(draw_data.y),params.npoints);
                tempy=zeros(length(draw_data.y),params.npoints);
                for k=1:length(draw_data.y) %then we smooth each trajectory independently
                    %[new_draw_data.y{k},new_draw_data.x{k}, ~] = turbotrend(draw_data.x{k}, draw_data.y{k}, params.lambda, 100);
                    [tempy(k,:),tempx(k,:), ~] = turbotrend(draw_data.x{k}, draw_data.y{k}, params.lambda, params.npoints);
                end
                plot(tempx',tempy','LineStyle',draw_data.line_style,'lineWidth',draw_data.size/4,'Color',draw_data.color);
                
%                 %Create fake params for call to stat_summary
%                 summ_params.type='ci';
%                 summ_params.geom=params.geom;
%                 summ_params.dodge=false;
%                 summ_params.setylim=false;
%                 summ_params.interp='none';
%                 summ_params.interp_in=100;
%                 summ_params.bin_in=-1;
%                 
%                 %Call summary to do the actual plotting
%                 obj.my_summary(new_draw_data,summ_params);
                 
                 obj.results.smooth{obj.r_ind,1}.x=[];
                 obj.results.smooth{obj.r_ind,1}.y=[];
                 obj.results.smooth{obj.r_ind,1}.yci=[];
                 
            else
                
                combx=comb(draw_data.x);
                [combx,i]=sort(combx);
                comby=comb(draw_data.y);
                comby=comby(i);
                
                %Remove NaN
                idnan=isnan(combx) | isnan(comby);
                combx(idnan)=[];
                comby(idnan)=[];
                
                %Slow
                %newy=smooth(combx,comby,0.2,'loess');
                %plot(combx,newy,'Color',c,'LineWidth',2)
                
                %Super fast spline smoothing !!
                if length(combx)>3
                    [newy,newx, yfit] = turbotrend(combx, comby, params.lambda, params.npoints);
                    
                else
                    newx=NaN;
                    newy=NaN;
                end
                
                if length(combx)>10
                    booty=bootstrp(200,@(ax,ay)turbotrend(ax,ay,params.lambda,params.npoints),combx,comby);
                    yci=prctile(booty,[2.5 97.5]);
                else
                    yci=nan(2,length(newx));
                end
                
                
                obj.results.smooth{obj.r_ind,1}.x=newx;
                obj.results.smooth{obj.r_ind,1}.y=newy;
                obj.results.smooth{obj.r_ind,1}.yci=yci;
                
                %For some reason bootci is super slow there ! %zci=bootci(50,@(ax,ay)turbotrend(ax,ay,10,100),combx,comby);
                
                %Spline smoothing
                %             newx=linspace(min(combx),max(combx),100);
                %             curve = fit(combx,comby,'smoothingspline','SmoothingParam',smoothparam); %'smoothingspline','SmoothingParam',0.1
                %             newy=feval(curve,newx);
                %             yci=bootci(200,@(ax,ay)feval(fit(ax,ay,'smoothingspline','SmoothingParam',smoothparam),newx),combx,comby);
                
                
                %hndl=plotci(newx,newy,yci,c,lt,sz,geom);
                hndl=obj.plotci(newx,newy,yci,draw_data,params.geom);
                
                %cfit=fit(combx,comb(y)','smoothingspline');
                %newx=linspace(min(combx),max(combx),100);
                %hndl=plot(newx,cfit(newx),'Color',c);
            end
        end
        
        
        function hndl=my_summary(obj,draw_data,params)
            
            if iscell(draw_data.x) || iscell(draw_data.y) %If input was provided as cell/matrix
                
                if params.interp_in>0 
                    %If requested we interpolate the input
                    uni_x=linspace(obj.var_lim.minx,obj.var_lim.maxx,params.interp_in);
                    [x,y]=cellfun(@(x,y)deal(uni_x,interp1(x,y,uni_x,'linear')),draw_data.x,draw_data.y,'UniformOutput',false);
                    y=padded_cell2mat(y);
                else
                    %If not we just make a padded matrix for fast
                    %computations (we'll assume that X are roughly at the
                    %same location for the same indices)
                    x=padded_cell2mat(draw_data.x);
                    y=padded_cell2mat(draw_data.y);
                    uni_x=nanmean(x);
                end
                
                if params.bin_in>0
                    warning('bin_in in stat_summary() not supported for Matrix/Cell X/Y inputs');
                end
                
                if strfind(params.type,'fit')
                    %If we have a params.type using distributions fits we
                    %can't vectorize the call to computeci so we do it in a for
                    %loop
                    ymean=zeros(length(uni_x),1);
                    yci=zeros(length(uni_x),2);
                    for ind_x=1:length(uni_x)
                        [ymean(ind_x),yci(ind_x,:)]=computeci(y(:,ind_x),params.type);
                    end
                else
                    [ymean,yci]=computeci(y,params.type);
                end
                
            else %If input was provided as 1D array
                
                x=comb(draw_data.x);
                y=comb(draw_data.y);
                
                if params.bin_in>0
                    %If X binning was requested we do it
                    binranges=linspace(obj.var_lim.minx,obj.var_lim.maxx,params.bin_in+1);
                    bincenters=(binranges(1:(end-1))+binranges(2:end))/2;
                    [~,binind]=my_histcounts(x,binranges,'count');
                    uni_x=bincenters;
                    x=bincenters(binind);
                else
                    %NEW: compute unique Xs at the facet level to avoid
                    %weird bar sizing issues when dodging and when
                    %colors are missing
                    facet_x=comb(draw_data.facet_x);
                    uni_x=unique(facet_x);
            
                    %OLD
                    %uni_x=unique(x); %Sorted is the default
                    
                    %Here we need to implement a loose 'unique' because of
                     %potential numerical errors
                    uni_x(diff(uni_x)<1e-10)=[];
                end
                
                if params.interp_in>0
                    warning('inter_in in stat_summary() not supported for non Matrix/Cell X/Y inputs');
                end
                
                ymean=nan(length(uni_x),1);
                yci=nan(length(uni_x),2);
                
                %Loop over unique X values
                for ind_x=1:length(uni_x)
                    %And here we have a loose selection also because of
                    %potential numerical errors
                    ysel=y(abs(x-uni_x(ind_x))<1e-10);
                    
                    if ~isempty(ysel)
                        [ymean(ind_x),yci(ind_x,:)]=computeci(ysel,params.type);
                    end
                end
            end
            
            %Do we set the y limits according to the smoothed curves or to
            %the original data ?
            if params.setylim
                if sum(sum(isnan(yci)))~=numel(yci) %We only do this if yci is not weird
                    if obj.firstrun(obj.current_row,obj.current_column) %Initialize for the first run in the subplot
                        obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(max(yci));
                        obj.plot_lim.miny(obj.current_row,obj.current_column)=min(min(yci));
                    else %Update for subsequent runs in the subplot
                        if max(max(yci))>obj.plot_lim.maxy(obj.current_row,obj.current_column)
                            obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(max(yci));
                        end
                        if min(min(yci))<obj.plot_lim.miny(obj.current_row,obj.current_column)
                            obj.plot_lim.miny(obj.current_row,obj.current_column)=min(min(yci));
                        end
                    end
                end
            end
            
            %Do we interpolate the summary results for display ?
            if ~strcmp(params.interp,'none')
                if size(yci,1)>2
                    yci=yci';
                end
                
                if obj.polar.is_polar && obj.polar.is_polar_closed 
                    %If the plot is polar we override the interpolation typ do an optimal fft interpolation
                    uni_x=0:pi/50:2*pi-pi/50;
                    ymean=interpft(ymean,100);
                    tmp_yci1=interpft(yci(1,:),100);
                    tmp_yci2=interpft(yci(2,:),100);
                    yci=[tmp_yci1 ; tmp_yci2];
                else
                    %For non polar plots we do a regular interpolation
                    new_x=linspace(min(uni_x),max(uni_x),100);
                    ymean=interp1(uni_x,ymean,new_x,params.interp);
                    tmp_yci1=interp1(uni_x,yci(1,:),new_x,params.interp);
                    tmp_yci2=interp1(uni_x,yci(2,:),new_x,params.interp);
                    yci=[tmp_yci1 ; tmp_yci2];
                    uni_x=new_x;
                end
            end
            
            %Store results
            obj.results.summary{obj.r_ind,1}.x=uni_x;
            obj.results.summary{obj.r_ind,1}.y=ymean;
            obj.results.summary{obj.r_ind,1}.yci=yci;
            
            %Do the actual plotting
            hndl=obj.plotci(uni_x,ymean,yci,draw_data,params.geom,params.dodge);
            
        end
        
        function hndl=my_boxplot(obj,draw_data,params)
            
            x=comb(draw_data.x);
            y=comb(draw_data.y);
            
            %NEW: compute unique Xs at the facet level (to avoid problems
            %with bar dodging width computation)
            facet_x=comb(draw_data.facet_x);
            uni_x=unique(facet_x);
            
            %OLD
            %uni_x=unique(x); %Sorted is the default
            
            
            %Here we need to implement a loose 'unique' because of
            %potential numerical errors
            uni_x(diff(uni_x)<1e-10)=[];
            
            %Initialize arrays
            p=zeros(length(uni_x),5);
            outliersx=[];
            outliersy=[];
            
            %Adaptive width
%             dx=diff(uni_x);
%             if isempty(dx);
%                 dx=1;
%             end
%             avl_w=zeros(length(uni_x),1);


            
            %Loop over unique X values
            for ind_x=1:length(uni_x)
                %And here we have a loose selection also because of
                %potential numerical errors
                ysel=y(abs(x-uni_x(ind_x))<1e-10);
                
                %Percentiles for box and wiskers
                %p(ind_x,:)=prctile(ysel,[2 25 50 75 98]);
                
                %Quartiles
                temp=prctile(ysel,[25 50 75]);
                %Wiskers at 1.5 Inter Quartile Range
                p(ind_x,:)=[temp(1)-1.5*(temp(3)-temp(1)) , temp , temp(3)+1.5*(temp(3)-temp(1))];
                
                
                %Outliers
                sel_outlier=ysel<p(ind_x,1) | ysel>p(ind_x,5);
                if sum(sel_outlier)>0
                    outliersy=[outliersy ysel(sel_outlier)'];
                    outliersx=[outliersx repmat(ind_x,1,sum(sel_outlier))];
                end
                
                %Code for adaptive width
                %Compute available width for boxes
%                 if ind_x==1
%                     avl_w(ind_x)=dx(ind_x); %Twice the space between 1 and 2 for the first
%                 else
%                     if ind_x==length(uni_x)
%                         avl_w(ind_x)=dx(ind_x-1); %Twice the space between last and second to last for last
%                     else
%                         avl_w(ind_x)=(dx(ind_x-1)+dx(ind_x))/2; %Space between previous and space between next
%                     end
%                 end

            end
            
            %Constant width: we pick the the minimum available width over
            %the dataset for the span of dodged boxplots
            avl_w=min(diff(uni_x));
            if isempty(avl_w)
                avl_w=1;
            end
            
            
            
            
            if params.dodge>=0
                spacing=avl_w*params.spacing; %Actual distance between groups of boxes in x 
                dodging=avl_w*params.dodge./(draw_data.n_colors-1);% (Ncolors-1) spaces between boxes
                boxw=avl_w*(1-params.spacing-params.dodge)./draw_data.n_colors; % Box width
                boxleft=uni_x-0.5*avl_w+spacing*0.5+(draw_data.color_index-1)*(dodging+boxw); %We jump by box_width+spacing for each color
                boxright=uni_x-0.5*avl_w+spacing*0.5+(draw_data.color_index-1)*(dodging+boxw)+boxw;
            else
                boxw=(1-params.spacing)*avl_w; %Box width
                boxleft=uni_x-0.5*avl_w+avl_w*params.spacing*0.5;
                boxright=uni_x-0.5*avl_w+avl_w*params.spacing*0.5+boxw;
            end
            
            xpatch=[boxleft' ; boxright' ; boxright' ; boxleft'];
            ypatch=[p(:,2)' ; p(:,2)' ; p(:,4)' ; p(:,4)'];
            
            %Draw boxes
            hndl=patch(xpatch,...
                ypatch,...
                [1 1 1],'FaceColor',draw_data.color,'EdgeColor','k','FaceAlpha',1,'EdgeAlpha',1);
            
            %Draw medians
            line([boxleft' ; boxright'],[p(:,3)' ; p(:,3)'],'Color','k');
            
            %Draw wiskers
            boxmid=(boxleft+boxright)/2;
            line([boxmid' ; boxmid'],[p(:,1)' ; p(:,2)'],'Color','k')
            line([boxmid' ; boxmid'],[p(:,4)' ; p(:,5)'],'Color','k')
            
            %Draw outliers
            plot(boxmid(outliersx),outliersy,'o','MarkerEdgeColor','none','MarkerFaceColor',draw_data.color);
            
            %Adjust limits
            obj.plot_lim.maxx(obj.current_row,obj.current_column)=max(max(boxright),obj.plot_lim.maxx(obj.current_row,obj.current_column));
            obj.plot_lim.minx(obj.current_row,obj.current_column)=min(min(boxleft),obj.plot_lim.minx(obj.current_row,obj.current_column));
            
            obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(max(p(:,5)),obj.plot_lim.maxy(obj.current_row,obj.current_column));
            obj.plot_lim.miny(obj.current_row,obj.current_column)=min(min(p(:,1)),obj.plot_lim.miny(obj.current_row,obj.current_column));
            
            
        end
        
        function hndl=my_ellipse(obj,draw_data,params)
            
            
            persistent elpoints

            %Cache unity ellipse points
            if isempty(elpoints)
                res=30;
                ang=0:pi/(0.5*res):2*pi;
                elpoints=[cos(ang); sin(ang)];
            end
            
            combx=shiftdim(comb(draw_data.x));
            comby=shiftdim(comb(draw_data.y));
            
            %If we have "enough" points
            if sum(~isnan(combx))>2 && sum(~isnan(comby))>2
                
                r=[combx comby];
                
                %If a CI on the mean is requested, we replace the original points
                %with bootstrapped mean samples
                if strcmp(params.type,'ci')
                    r=bootstrp(1000,@nanmean,r);
                end
                
                %Extract mean and covariance
                m=nanmean(r);
                cv=nancov(r);
                
                %Using a chi square with 2 degrees of freedom is proper
                %here (tested: generated ellipse do contain 1-alpha of the
                %points)
                k=@(alpha) sqrt(chi2inv(1-alpha,2));
                
                %Compute ellipse points
                conf_elpoints=sqrtm(cv)*elpoints*k(0.05);
                
                %Compute ellipse axes
                [evec,eval]=eig(cv);
                if eval(2,2)>eval(1,1) %Reorder
                    evec=fliplr(evec);
                    eval=fliplr(flipud(eval));
                end
                elaxes=sqrtm(cv)*evec*k(0.05);
                
                
                obj.results.ellipse{obj.r_ind,1}.mean=m;
                obj.results.ellipse{obj.r_ind,1}.cv=cv;
                obj.results.ellipse{obj.r_ind,1}.major_axis=elaxes(:,1)';
                obj.results.ellipse{obj.r_ind,1}.minor_axis=elaxes(:,2)';
                
                %plot([0 elaxes(1,1)]+m(1),[0 elaxes(2,1)]+m(2),'k')
                %plot([0 elaxes(1,2)]+m(1),[0 elaxes(2,2)]+m(2),'k')
                
                switch params.geom
                    case 'area'
                        hndl=patch(conf_elpoints(1,:)+m(1),conf_elpoints(2,:)+m(2),draw_data.color,'FaceColor',draw_data.color,'EdgeColor',draw_data.color,'LineWidth',2,'FaceAlpha',0.2);
                        
                    case 'line'
                        hndl=patch(conf_elpoints(1,:)+m(1),conf_elpoints(2,:)+m(2),draw_data.color,'FaceColor','none','EdgeColor',draw_data.color,'LineWidth',2);
                end
                set(hndl,params.patch_opts{:}); %displays a lot of stuff if we don't have an output value !
                
                plot(m(1),m(2),'+','MarkerFaceColor',draw_data.color,'MarkerEdgeColor',draw_data.color,'MarkerSize',10);
                
            else
                warning('Not enough points for ellipse')
            end
        end
        
        
        function hndl=my_glm(obj,draw_data,params)
            combx=comb(draw_data.x)';
            comby=comb(draw_data.y)';
            
            if sum(~isnan(combx))>2 && sum(~isnan(comby))>2 %numel(combx)>2 &&
                % Doesn't work in 2012b
                %mdl=fitglm(combx,comby,'Distribution',params.distribution);
                mdl = GeneralizedLinearModel.fit(combx,comby,'Distribution',params.distribution);
                if params.fullrange
                    newx=linspace(obj.var_lim.minx,obj.var_lim.maxx,50)';
                else
                    newx=linspace(min(combx),max(combx),50)';
                end
                [newy,yci]=predict(mdl,newx);
                
                obj.results.glm{obj.r_ind,1}.x=newx;
                obj.results.glm{obj.r_ind,1}.y=newy;
                obj.results.glm{obj.r_ind,1}.yci=yci;
                obj.results.glm{obj.r_ind,1}.model=mdl;
                
                hndl=obj.plotci(newx,newy,yci,draw_data,params.geom);

                if params.disp_fit
                    if obj.firstrun(obj.current_row,obj.current_column)
                        obj.extra.mdltext(obj.current_row,obj.current_column)=0.05;
                        %obj.firstrun(obj.current_row,obj.current_column)=0;
                    else
                        obj.extra.mdltext(obj.current_row,obj.current_column)=obj.extra.mdltext(obj.current_row,obj.current_column)+0.03;
                    end
                    text('Units','normalized','Position',[0.1 obj.extra.mdltext(obj.current_row,obj.current_column)],'color',draw_data.color,...
                        'String',[ num2str(mdl.Coefficients.Estimate(1),5) '^{' pval_to_star(mdl.Coefficients.pValue(1)) ...
                        '} + ' num2str(mdl.Coefficients.Estimate(2),5) '^{' pval_to_star(mdl.Coefficients.pValue(2)) '} x']);
                end
                 
            else
                warning('Not enough points for linear fit')
            end
            
        end
        
        
        function hndl=my_fit(obj,draw_data,params)
            
            combx=comb(draw_data.x)';
            comby=comb(draw_data.y)';
            
            %Do the fit depending on options
            if isempty(params.StartPoint)
                mdl=fit(combx',comby',params.fun);
            else
                mdl=fit(combx',comby',params.fun,'StartPoint',params.StartPoint);
            end
            
            %Create x values for the fit plot
            if params.fullrange
                newx=linspace(obj.var_lim.minx,obj.var_lim.maxx,100)';
            else
                newx=linspace(min(combx),max(combx),100)';
            end
            %Get fit value and CI
            newy=feval(mdl,newx);
            yci=predint(mdl,newx,0.95,params.intopt);
            
            
            obj.results.fit{obj.r_ind,1}.x=newx;
            obj.results.fit{obj.r_ind,1}.y=newy;
            obj.results.fit{obj.r_ind,1}.yci=yci;
            obj.results.fit{obj.r_ind,1}.model=mdl;
            
            %Plot fit
            hndl=obj.plotci(newx,newy,yci,draw_data,params.geom);
            
            %Do we display the results ?
            if params.disp_fit
                %Set Y position of display
                if obj.firstrun(obj.current_row,obj.current_column)
                    obj.extra.mdltext(obj.current_row,obj.current_column)=0.05;
                else
                    obj.extra.mdltext(obj.current_row,obj.current_column)=obj.extra.mdltext(obj.current_row,obj.current_column)+0.03;
                end
                %Get formula and parameters
                form=formula(mdl)
                cvals=coeffvalues(mdl);
                cnames=coeffnames(mdl);
                %Replace parameter names by their value in the formula
                for c=1:length(cnames)
                    form=strrep(form,cnames{c},num2str(cvals(c),2));
                end
                text('Units','normalized','Position',[0.1 obj.extra.mdltext(obj.current_row,obj.current_column)],'color',draw_data.color,...
                    'String',form);
            end
            
            
            
        end
        
        function hndl=my_bar(obj,draw_data,params)
            width=params.width;
            x=comb(draw_data.x);
            y=comb(draw_data.y);
            obj.plot_lim.miny(obj.current_row,obj.current_column)=0;
            
            if params.stacked
                
                x=shiftdim(x)';
                y=shiftdim(y)';
                
                %Problem with stacked bar when different x values are used 
                if obj.firstrun(obj.current_row,obj.current_column)
                    obj.extra.stacked_bar_height=zeros(1,length(x));
                    obj.plot_lim.minx(obj.current_row,obj.current_column)=min(x)-width;
                    obj.plot_lim.maxx(obj.current_row,obj.current_column)=max(x)+width;
                    %obj.firstrun(obj.current_row,obj.current_column)=0;
                end
                
                hndl=patch([x-width/2 ; x+width/2 ; x+width/2 ; x-width/2],...
                        [obj.extra.stacked_bar_height ; obj.extra.stacked_bar_height ; obj.extra.stacked_bar_height+y ; obj.extra.stacked_bar_height+y],...
                        draw_data.color,'EdgeColor','k');
                    
                obj.extra.stacked_bar_height=obj.extra.stacked_bar_height+y;
                
                if obj.plot_lim.maxy(obj.current_row,obj.current_column)<max(obj.extra.stacked_bar_height)
                    obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(obj.extra.stacked_bar_height);
                end
                
            else

                if min(x+(draw_data.color_index/(draw_data.n_colors+1)-0.5)*width-width/(draw_data.n_colors+1))<obj.plot_lim.minx(obj.current_row,obj.current_column)
                    obj.plot_lim.minx(obj.current_row,obj.current_column)=min((draw_data.color_index/(draw_data.n_colors+1)-0.5)*width-width/(draw_data.n_colors+1));
                end
                if max(x+(draw_data.color_index/(draw_data.n_colors+1)-0.5)*width+width/(draw_data.n_colors+1))>obj.plot_lim.maxx(obj.current_row,obj.current_column)
                    obj.plot_lim.maxx(obj.current_row,obj.current_column)=max(x+(draw_data.color_index/(draw_data.n_colors+1)-0.5)*width+width/(draw_data.n_colors+1));
                end
                
                hndl=bar(x+(draw_data.color_index/(draw_data.n_colors+1)-0.5)*width,y,width/(draw_data.n_colors+1),'faceColor',draw_data.color,'EdgeColor','none');
            end
        end
        
        
        function hndl=my_bin(obj,draw_data,params)
            
            %Compute bins
            if obj.x_factor %For categorical Xs (placed at integer values), we override and make the bins 0.5 1.5 2.5 ...
                binranges=(0:length(obj.x_ticks))+0.5;
                bincenters=1:length(obj.x_ticks);
            else
                if obj.polar.is_polar %For polar coordinates we make bin around 0:2pi
                    %Make data modulo 2pi
                    draw_data.x=mod(comb(draw_data.x),2*pi);
                    if isempty(params.edges)
                        binranges=linspace(0,2*pi,params.nbins+1);
                    else
                        if max(params.edges)>2*pi || min(params.edges)<0
                            warning('Bin edges exceed the polar ranges (O-2pi)')
                        end
                        binranges=params.edges;
                    end
                else
                    if isempty(params.edges)
                        binranges=linspace(obj.var_lim.minx,obj.var_lim.maxx,params.nbins+1);
                    else
                        binranges=params.edges;
                    end
                end
                bincenters=(binranges(1:(end-1))+binranges(2:end))/2;
            end
            
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
            
            obj.results.bin{obj.r_ind,1}.edges=bincenters;
            obj.results.bin{obj.r_ind,1}.counts=bincounts;
            
            %Set axis limits
            obj.plot_lim.miny(obj.current_row,obj.current_column)=0;
            if obj.firstrun(obj.current_row,obj.current_column)
                obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(bincounts);
                
                if ~isempty(params.edges) %If edges are specified we use those for x scale
                    obj.plot_lim.minx(obj.current_row,obj.current_column)=binranges(1)-nanmean(diff(binranges));
                    obj.plot_lim.maxx(obj.current_row,obj.current_column)=binranges(end)+nanmean(diff(binranges));
                end
                
                %obj.firstrun(obj.current_row,obj.current_column)=0;
                obj.aes_names.y=params.normalization;
                %Initialize stacked bar
                obj.extra.stacked_bar_height=zeros(size(bincenters));
            else
                 if max(obj.extra.stacked_bar_height+bincounts(1:end)')>obj.plot_lim.maxy(obj.current_row,obj.current_column)
                         obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(bincounts(1:end)'+obj.extra.stacked_bar_height);
                 end
                if max(bincounts)>obj.plot_lim.maxy(obj.current_row,obj.current_column)
                    obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(bincounts);
                end
            end
            
            
            if isempty(params.bar_spacing)
                if strcmp(params.geom,'bar') && draw_data.n_colors>1
                    params.bar_spacing=0.2;
                else
                    params.bar_spacing=0;
                end
                    
            end
            
            
            
            
            face_alpha=1;
            edge_alpha=0.8;
            switch params.fill
                case 'edge'
                    edge_color=draw_data.color;
                    face_color='none';
                case 'face'
                    edge_color='k';
                    face_color=draw_data.color;
                case 'all'
                    edge_color='none';
                    face_color=draw_data.color;
                case 'transparent'
                    edge_color=draw_data.color;
                    face_color=draw_data.color;
                    face_alpha=0.4;
            end
            
            
            %All subplots/colors have the same bins, so dodginc
            %computations are simple
            spacing=0.5*params.bar_spacing*diff(binranges);
            
            switch params.geom
                case 'bar'
                    if draw_data.n_colors==1
                        %hndl=bar(bincenters,bincounts(1:end),1,'faceColor',draw_data.color,'EdgeColor','k');
%                         hndl=patch([binranges(1:end-1)+spacing ; binranges(2:end)-spacing ; binranges(2:end)-spacing ; binranges(1:end-1)+spacing],...
%                         [zeros(1,length(bincounts)) ; zeros(1,length(bincounts)) ; bincounts' ; bincounts'],...
%                         [1 1 1],'FaceColor',face_color,'EdgeColor',edge_color,'FaceAlpha',face_alpha,'EdgeAlpha',edge_alpha);
                        xpatch=[binranges(1:end-1)+spacing ; binranges(2:end)-spacing ; binranges(2:end)-spacing ; binranges(1:end-1)+spacing];
                        ypatch=[zeros(1,length(bincounts)) ; zeros(1,length(bincounts)) ; bincounts' ; bincounts'];
                        [xpatch,ypatch]=to_polar(obj,xpatch,ypatch);
                        hndl=patch(xpatch,...
                        ypatch,...
                        [1 1 1],'FaceColor',face_color,'EdgeColor',edge_color,'FaceAlpha',face_alpha,'EdgeAlpha',edge_alpha);
                    else
                        %hndl=bar(bincenters+(draw_data.color_index/(draw_data.n_colors+1)-0.5)*(binranges(2)-binranges(1)),bincounts(1:end),1/(draw_data.n_colors+1),'faceColor',draw_data.color,'EdgeColor','k');
                        barleft=binranges(1:end-1)+spacing+(1-params.bar_spacing)*(draw_data.color_index-1)*diff(binranges)./draw_data.n_colors;
                        barright=binranges(1:end-1)+spacing+(1-params.bar_spacing)*(draw_data.color_index)*diff(binranges)./draw_data.n_colors;
%                         hndl=patch([barleft ; barright ; barright ; barleft],...
%                         [zeros(1,length(bincounts)) ; zeros(1,length(bincounts)) ; bincounts' ; bincounts'],...
%                         [1 1 1],'FaceColor',face_color,'EdgeColor',edge_color,'FaceAlpha',face_alpha,'EdgeAlpha',edge_alpha);
                        xpatch=[barleft ; barright ; barright ; barleft];
                        ypatch=[zeros(1,length(bincounts)) ; zeros(1,length(bincounts)) ; bincounts' ; bincounts'];
                        [xpatch,ypatch]=to_polar(obj,xpatch,ypatch);
                        hndl=patch(xpatch,...
                        ypatch,...
                        [1 1 1],'FaceColor',face_color,'EdgeColor',edge_color,'FaceAlpha',face_alpha,'EdgeAlpha',edge_alpha);
                        %set(gca,'XTick',binranges);
                        %plot(binranges,zeros(length(binranges),1),'k.','MarkerSize',10);
                    end
                case 'overlaid_bar'
                    xpatch=[binranges(1:end-1)+spacing ; binranges(2:end)-spacing ; binranges(2:end)-spacing ; binranges(1:end-1)+spacing];
                    ypatch=[zeros(1,length(bincounts)) ; zeros(1,length(bincounts)) ; bincounts' ; bincounts'];
                    [xpatch,ypatch]=to_polar(obj,xpatch,ypatch);
                    hndl=patch(xpatch,...
                        ypatch,...
                        [1 1 1],'FaceColor',face_color,'EdgeColor',edge_color,'FaceAlpha',face_alpha,'EdgeAlpha',edge_alpha);
                case 'line'
                    xtemp=bincenters;
                    ytemp=bincounts(1:end)';
                    [xtemp,ytemp]=to_polar(obj,xtemp,ytemp);
                    hndl=plot(xtemp,ytemp,'LineStyle',draw_data.line_style,'Color',edge_color,'lineWidth',draw_data.size/4);
                    xpatch=[bincenters(1:end-1) ; bincenters(2:end) ; bincenters(2:end);bincenters(1:end-1)];
                    ypatch=[zeros(1,length(bincounts)-1) ; zeros(1,length(bincounts)-1) ; bincounts(2:end)' ; bincounts(1:end-1)'];
                    [xpatch,ypatch]=to_polar(obj,xpatch,ypatch);
                    patch(xpatch,ypatch,[1 1 1],'FaceColor',face_color,'EdgeColor','none','FaceAlpha',face_alpha);
                    
                case 'stacked_bar'
                    xpatch=[binranges(1:end-1)+spacing ; binranges(2:end)-spacing ; binranges(2:end)-spacing ; binranges(1:end-1)+spacing];
                    ypatch=[obj.extra.stacked_bar_height ; obj.extra.stacked_bar_height ; obj.extra.stacked_bar_height+bincounts' ; obj.extra.stacked_bar_height+bincounts'];
                    [xpatch,ypatch]=to_polar(obj,xpatch,ypatch);
                    hndl=patch(xpatch,...
                        ypatch,...
                        [1 1 1],'FaceColor',face_color,'EdgeColor',edge_color,'FaceAlpha',face_alpha,'EdgeAlpha',edge_alpha);
                    obj.extra.stacked_bar_height=obj.extra.stacked_bar_height+bincounts';
                case 'stairs'
                    xtemp=[binranges(1:end-1) ; binranges(2:end)];
                    ytemp=[bincounts' ; bincounts'];
                    [xtemp,ytemp]=to_polar(obj,xtemp(:),ytemp(:));
                    hndl=plot(xtemp,ytemp,'LineStyle',draw_data.line_style,'Color',edge_color,'lineWidth',draw_data.size/4);
                    
                    xpatch=[binranges(1:end-1)+spacing ; binranges(2:end)-spacing ; binranges(2:end)-spacing ; binranges(1:end-1)+spacing];
                    ypatch=[obj.extra.stacked_bar_height ; obj.extra.stacked_bar_height ; obj.extra.stacked_bar_height+bincounts' ; obj.extra.stacked_bar_height+bincounts'];
                    [xpatch,ypatch]=to_polar(obj,xpatch,ypatch);
                    patch(xpatch,ypatch,[1 1 1],'FaceColor',face_color,'EdgeColor','none','FaceAlpha',face_alpha);
                    
                    %hndl=stairs(binranges,[bincounts' bincounts(end)],'LineStyle',draw_data.line_style,'Color',draw_data.color,'lineWidth',draw_data.size/4);
                case 'point'
                    xtemp=bincenters;
                    ytemp=bincounts(1:end)';
                    [xtemp,ytemp]=to_polar(obj,xtemp,ytemp);
                    hndl=plot(xtemp,ytemp,draw_data.marker,'MarkerEdgeColor','none','markerSize',draw_data.size,'MarkerFaceColor',draw_data.color);
            end
            
        end
        
        function hndl=my_density(obj,draw_data,params)
            

            if obj.polar.is_polar
                %Make x data modulo 2 pi
                draw_data.x=mod(comb(draw_data.x),2*pi);
                warning('Polar density estimate is probably not proper for circular data, use custom bandwidth');
                %Let's try to make boundaries a bit more proper by
                %repeating values below 0 and above 2 pi
                draw_data.x=[draw_data.x-2*pi;draw_data.x;draw_data.x+2*pi];
                extra_x=0;
                binranges=linspace(0,2*pi,params.npoints);
            else
                extra_x=(obj.var_lim.maxx-obj.var_lim.minx)*params.extra_x;
                binranges=linspace(obj.var_lim.minx-extra_x,obj.var_lim.maxx+extra_x,params.npoints);
            end
            
            if params.bandwidth>0
                [f,xi] = ksdensity(comb(draw_data.x),binranges,'function',params.function,'bandwidth',params.bandwidth,'kernel',params.kernel);
            else
                [f,xi] = ksdensity(comb(draw_data.x),binranges,'function',params.function,'kernel',params.kernel);
            end
            
            obj.plot_lim.minx(obj.current_row,obj.current_column)=obj.var_lim.minx-extra_x;
            obj.plot_lim.maxx(obj.current_row,obj.current_column)=obj.var_lim.maxx+extra_x;
            obj.plot_lim.miny(obj.current_row,obj.current_column)=0;
            if obj.firstrun(obj.current_row,obj.current_column)
                obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(f);
                %obj.firstrun(obj.current_row,obj.current_column)=0;
                obj.aes_names.y=[obj.aes_names.x ' ' params.function];
            else
                if max(f)>obj.plot_lim.maxy(obj.current_row,obj.current_column)
                    obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(f);
                end
            end
            
            obj.results.density{obj.r_ind,1}.x=xi;
            obj.results.density{obj.r_ind,1}.y=f;
            
            [xi,f]=to_polar(obj,xi,f);
            hndl=plot(xi,f,'LineStyle',draw_data.line_style,'Color',draw_data.color,'lineWidth',draw_data.size/4);
        end
        
        function hndl=my_bin2d(obj,draw_data,params)
            
            x=comb(draw_data.x);
            y=comb(draw_data.y);
            
            if isempty(params.edges)
                [N,C] = hist3([shiftdim(x),shiftdim(y)],params.nbins);
            else
                [N,C] = hist3([shiftdim(x),shiftdim(y)],'Edges',params.edges);
                
                obj.plot_lim.minx(obj.current_row,obj.current_column)=params.edges{1}(1);
                obj.plot_lim.maxx(obj.current_row,obj.current_column)=params.edges{1}(end);
                obj.plot_lim.miny(obj.current_row,obj.current_column)=params.edges{2}(1);
                obj.plot_lim.maxy(obj.current_row,obj.current_column)=params.edges{2}(end);
                
                %Put values on the upper edges as if they were in the last
                %bin
                N(:,end-1)=N(:,end-1)+N(:,end);
                N(end-1,:)=N(end-1,:)+N(end,:);
                
                %Remove upper edge
                N(:,end)=[];
                N(end,:)=[];
                
            end
            
            obj.results.bin2d{obj.r_ind,1}.edges=C;
            obj.results.bin2d{obj.r_ind,1}.counts=N;
            
            switch params.geom
                case 'contour'
                    
                    hndl=contour(C{1},C{2},N',5,'Color',draw_data.color);
                    
                case 'image'
                    %Set colormap
                    %colormap(pa_statcolor(256,'sequential','luminancechroma',[0 100 100 260]));
                    %colormap(pa_statcolor(256,'sequential','luminancechroma',[60 0 100 260]));
                    %cmap=pa_statcolor(256,'sequential','luminancechromahue',[80 0 100 80 240 240]);
                    %colormap(cmap);
                    
                    %Useless because there is only one colormap per subplot
                    %cmap=pa_statcolor(256,'sequential','luminancechromahue',[70 0 100 80 draw_data.hue draw_data.hue])
                    
                    Nr=reshape(N',1,numel(N));
                    sel=Nr>0;
                    %sel=true(size(Nr));
                    
                    if isempty(params.edges)
                        %Get polygon half widths
                        wx=(C{1}(2)-C{1}(1))/2;
                        wy=(C{2}(2)-C{2}(1))/2;
                        
                        %Generate polygon edges
                        [X,Y] = meshgrid(C{1},C{2});
                        
                        X=reshape(X,1,numel(X));
                        Y=reshape(Y,1,numel(Y));
                        
                        
                        patchesx=[X(sel)-wx ; X(sel)-wx ; X(sel)+wx ; X(sel)+wx ];
                        patchesy=[Y(sel)-wy ; Y(sel)+wy ; Y(sel)+wy ; Y(sel)-wy ];
                        
                        
                    else
                        [Xs, Ys]=meshgrid(params.edges{1}(1:end-1),params.edges{2}(1:end-1));
                        [Xe, Ye]=meshgrid(params.edges{1}(2:end),params.edges{2}(2:end));
                        
                        Xs=reshape(Xs,1,numel(Xs));
                        Ys=reshape(Ys,1,numel(Ys));
                        Xe=reshape(Xe,1,numel(Xe));
                        Ye=reshape(Ye,1,numel(Ye));
                        
                        patchesx=[Xs(sel) ; Xs(sel) ; Xe(sel) ; Xe(sel)];
                        patchesy=[Ys(sel) ; Ye(sel) ; Ye(sel) ; Ys(sel)];
                        
                        %If we have varied-size patches (we use rounding to
                        %get away with numerical issues of unique
                        if length(unique(round(diff(params.edges{1})*1e10)))>1 || length(unique(round(diff(params.edges{2})*1e10)))>1
                            %Correct values by the area of each patch ?
                            Nr=Nr./((Xe-Xs).*(Ye-Ys));
                            obj.aes_names.color='Count/area';
                        else
                            obj.aes_names.color='Count';
                        end
                        
                    end
                    
                    
                    

                    
                    %patchesz=[Nr(sel) ; Nr(sel) ; Nr(sel) ; Nr(sel) ];
                    
                    %p=patch(patchesx,patchesy,patchesz,Nr(sel));
                    hndl=patch(patchesx,patchesy,Nr(sel));
                    set(hndl,'edgeColor','none')
                    
                    %Store color values
                    obj.plot_lim.maxc(obj.current_row,obj.current_column)=max(Nr);
                    obj.plot_lim.minc(obj.current_row,obj.current_column)=min(Nr);
                    
                    obj.continuous_color=true;
                    
                    %imagesc([C{1}(1)-(C{1}(2)-C{1}(1))/2 C{1}(end)+(C{1}(2)-C{1}(1))/2],...
                    %   [C{2}(1)-(C{2}(2)-C{2}(1))/2 C{2}(end)+(C{2}(2)-C{2}(1))/2],...
                    %   N);
                case 'point'
                    [X,Y] = meshgrid(C{1},C{2});
                    X=reshape(X,1,numel(X));
                    Y=reshape(Y,1,numel(Y));
                    Nr=reshape(N',1,numel(N));
                    sel=Nr>0;
                    hndl=point_patch(X(sel),Y(sel),Nr(sel)*(C{1}(2)-C{1}(1))/30,draw_data.color,20);
                    %p=scatter(X(sel),Y(sel),Nr(sel),draw_data.marker,'MarkerEdgeColor',draw_data.color,'MarkerFaceColor','none');
            end
            
        end
        
        function hndl=my_qq(obj,draw_data,params)
            
            if strcmp(params.distribution,'y')
                %If we compare the distribution of x and y
                x=comb(draw_data.x);
                y=comb(draw_data.y);
                
                y=sort(y(~isnan(y) & ~isnan(x)));
                xdist=sort(x(~isnan(y) & ~isnan(x)));
                
                if obj.r_ind==1
                    obj.aes_names.y=[obj.aes_names.y ' quantiles'];
                    obj.aes_names.x=[obj.aes_names.x ' quantiles'];
                end
                
            else
                %if we compare x to a theoretical distribution
                x=comb(draw_data.x);
                
                y=sort(x(~isnan(x))); %X values will actually be plotted on the y axis
                
                xeval=((1:length(y))-0.5)/length(y); %We find out the points at which we estimate the theoretical quantiles
                xdist=icdf(params.distribution,xeval); %Compute the theoretical quantiles
                
                
                %Set proper names
                if obj.r_ind==1
                    obj.aes_names.y=[obj.aes_names.x ' quantiles'];
                    dist_params=num2str(params.distribution.ParameterValues,'%g,');
                    obj.aes_names.x=['Theroretical ' params.distribution.DistributionName '(' dist_params(1:end-1) ') quantiles'];
                end
                
            end
            
            hndl=plot(xdist,y,draw_data.marker,'MarkerEdgeColor','none','markerSize',draw_data.size,'MarkerFaceColor',draw_data.color);
            
            obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(max(y),obj.plot_lim.maxy(obj.current_row,obj.current_column));
            obj.plot_lim.miny(obj.current_row,obj.current_column)=min(min(y),obj.plot_lim.miny(obj.current_row,obj.current_column));
            
            obj.plot_lim.maxx(obj.current_row,obj.current_column)=max(max(xdist),obj.plot_lim.maxx(obj.current_row,obj.current_column));
            obj.plot_lim.minx(obj.current_row,obj.current_column)=min(min(xdist),obj.plot_lim.minx(obj.current_row,obj.current_column));
            
        end
        
        function hndl=plotci(obj,x,y,yci,draw_data,geom,dodge)
            
            if nargin<7
                dodge=-1;
            end
            
            x=shiftdim(x)';
            y=shiftdim(y)';
            

         
%             
%             if size(x,1)>1
%                 x=x';
%             end
%             if size(y,1)>1
%                 y=y';
%                 yci=yci';
%             end           
            %Causes problems when plotting two things
%             if size(yci,1)>2
%                 yci=yci';
%             end
            
            %Hackish but seems to work
            if size(yci,2)~=length(y) || size(yci,2)==2
                yci=yci';
            end
            
            if ~iscellstr(geom)
                geom={geom};
            end
            
            %For area plots we remove NaNs otherwise it looks weird
            if sum(strcmp(geom,{'area','solid_area'}))>0
                selnan=isnan(x) | isnan(y) | isnan(yci(1,:)) | isnan(yci(1,:));
                if sum(selnan)>0
                    warning('NaN elements in area plot were skipped')
                end
                selnan=~selnan;
                x=x(selnan);
                y=y(selnan);
                yci=yci(:,selnan);
            end
            
            if isempty(x) || isempty(y)
                hndl=NaN;
                return;
            end
            
            if length(x)>2
                %x_spacing=x(2)-x(1);
                x_spacing=min(diff(x));
            else
                x_spacing=1;
            end
            
            
            if dodge>=0
                bar_width=(x_spacing-dodge*x_spacing)/(draw_data.n_colors+1);
                dodge_amount=dodge/(draw_data.n_colors-1);
                x=x-x_spacing/2+bar_width+(bar_width+dodge_amount)*(draw_data.color_index-1);
            else
                bar_width=x_spacing/2;
            end
            
            [tmp_xci1,tmp_yci1]=obj.to_polar(x,yci(1,:));
            [tmp_xci2,tmp_yci2]=obj.to_polar(x,yci(2,:));
            yci=[tmp_yci1;tmp_yci2];
            xci=[tmp_xci1;tmp_xci2];
            [x,y]=obj.to_polar(x,y);
            
            
            
            for k=1:length(geom)
                switch geom{k}
                    case 'line'
                        hndl=plot(x,y,'LineStyle',draw_data.line_style,'Color',draw_data.color,'LineWidth',draw_data.size/4);
                    case 'lines'
                        hndl=plot(x,y,'LineStyle',draw_data.line_style,'Color',draw_data.color,'LineWidth',draw_data.size/4);
                        plot(xci',yci','-','Color',draw_data.color+([1 1 1]-draw_data.color)*0.5);
                    case 'area'
                        %Transparent area (This does what we want but prevents a correct eps
                        %export, and weirdly removes axes in older matlab versions)
                        h=fill([xci(2,:) fliplr(xci(1,:))],[yci(2,:) fliplr(yci(1,:))],draw_data.color);
                        set(h,'FaceAlpha',0.2);
                        set(h,'EdgeColor','none')
                        hndl=plot(x,y,'LineStyle',draw_data.line_style,'Color',draw_data.color,'LineWidth',draw_data.size/4);
                    case 'solid_area'
                        %Solid area (no alpha)
                        %h=fill([x fliplr(x)],[yci(2,:) fliplr(yci(1,:))],c+([1 1 1]-c)*0.8);
                        h=fill([xci(2,:) fliplr(xci(1,:))],[yci(2,:) fliplr(yci(1,:))],c);
                        set(h,'EdgeColor','none')%c+([1 1 1]-c)*0.8)
                        hndl=plot(x,y,'LineStyle',draw_data.line_style,'Color',draw_data.color,'LineWidth',draw_data.size/4);
                    case 'errorbar'
                        hndl=errorbar(x,y,y-yci(1,:),yci(2,:)-y,'color',draw_data.color);
                        %hndl=errorbar(x,y,y-yci(:,1),yci(:,2)-y);
                        %hndl=plot(xci,yci,'-','Color',c+([1 1 1]-c)*0.5);
                        set(hndl,'Color',draw_data.color)%[0 0 0]
                        set(hndl,'LineStyle','none')
                    case 'black_errorbar'
                        hndl=errorbar(x,y,y-yci(1,:),yci(2,:)-y,'color','k');
                        
                        %hndl=errorbar(x,y,y-yci(:,1)',yci(:,2)'-y);
                        %hndl=plot(xci,yci,'-');
                        set(hndl,'Color',[0 0 0])
                        set(hndl,'LineStyle','none')
                    case 'bar'
                        barleft=x-bar_width/2;
                        barright=x+bar_width/2;
%                         hndl=patch([barleft ; barright ; barright ; barleft],...
%                         [zeros(1,length(bincounts)) ; zeros(1,length(bincounts)) ; bincounts' ; bincounts'],...
%                         [1 1 1],'FaceColor',face_color,'EdgeColor',edge_color,'FaceAlpha',face_alpha,'EdgeAlpha',edge_alpha);
                        xpatch=[barleft ; barright ; barright ; barleft];
                        ypatch=[zeros(1,length(y)) ; zeros(1,length(y)) ; y ; y];
                        [xpatch,ypatch]=to_polar(obj,xpatch,ypatch);
                        hndl=patch(xpatch,ypatch,[1 1 1],'FaceColor',draw_data.color,'EdgeColor','none');
                        %
                        %hndl=bar(x,y,bar_width,'faceColor',draw_data.color,'EdgeColor','none');
                    case 'point'
                        hndl=plot(x,y,draw_data.marker,'MarkerEdgeColor','none','markerSize',draw_data.size,'MarkerFaceColor',draw_data.color);
                end
                
            end
            
                        %Adjust limits
            obj.plot_lim.maxx(obj.current_row,obj.current_column)=max(max(x),obj.plot_lim.maxx(obj.current_row,obj.current_column));
            obj.plot_lim.minx(obj.current_row,obj.current_column)=min(min(x),obj.plot_lim.minx(obj.current_row,obj.current_column));
            
            
        end

        
    end
    
    
    
end

function ab=fill_abline(ab,varargin)
            ab.on=true;
            
            l=max(cellfun(@length,varargin(1:5)));
            ab.slope(end+1:end+l)=shiftdim(varargin{1});
            ab.intercept(end+1:end+l)=shiftdim(varargin{2});
            ab.xintercept(end+1:end+l)=shiftdim(varargin{3});
            ab.yintercept(end+1:end+l)=shiftdim(varargin{4});
            if ~iscell(varargin{5})
                varargin{5}={varargin{5}};
            end
            ab.fun(end+1:end+l)=shiftdim(varargin{5});
            if iscell(varargin{6})
                ab.style(end+1:end+l)=shiftdim(varargin{6});
            else
                ab.style(end+1:end+l)=repmat({varargin{6}},l,1);
            end
end


function res=comb(dat)
%Combines data in single array if originally in cells
if iscell(dat)
    if size(dat{1},1)==1
        res=horzcat(dat{:});
    else
        res=vertcat(dat{:})';
    end
else
    res=dat;
end
end

function res=tocell(dat)
%If data is not a cell, convert it to one in order to be able to use
%cellfun
if iscell(dat)
    res=dat;
else
    res={dat};
end
end


function sel=multi_sel(to_sel,value)
%Do a selection on the basis of string equality or numerical equality

if ischar(value)
    sel=strcmp(to_sel,value);
else
    sel=to_sel==value;
end

end

function [ymean,yci]=computeci(y,type)

ymean=nanmean(y);
try
    switch type
        case 'bootci'
            yci=bootci(200,@(y)nanmean(y),y);
        case 'ci'
            ci=1.96*nanstd(y)./sqrt(sum(~isnan(y)));
            yci=bsxfun(@plus,ymean,[-ci;ci]);
        case 'std'
            ci=nanstd(y);
            yci=bsxfun(@plus,ymean,[-ci;ci]);
        case 'sem'
            ci=nanstd(y)./sqrt(sum(~isnan(y)));
            yci=bsxfun(@plus,ymean,[-ci;ci]);
        case 'quartile'
            ymean=nanmedian(y);
            yci=prctile(y,[25 75]);
        case '95percentile'
            ymean=nanmedian(y);
            yci=prctile(y,[2.5 97.5]);
        case 'fitnormalci'
            pd=fitdist(y,'Normal');
            ymean=pd.mean();
            ci=pd.paramci();
            yci=ci(:,1)';
        case 'fitpoissonci'
            pd=fitdist(y,'Poisson');
            ymean=pd.mean();
            ci=pd.paramci();
            yci=ci(:,1)';
        case 'fitbinomialci'
            pd=fitdist(y,'Binomial');
            ymean=pd.mean;
            ci=pd.paramci;
            yci=ci(:,2)';
        case 'fit95percentile'
            pd=fitdist(y,'Normal');
            ymean=pd.icdf(0.5);
            yci=pd.icdf([0.025 0.975]);
    end
catch
    disp('Not enough samples for CI computation...skipping')
    yci=repmat([NaN NaN],size(y,2));
end
end

function [z,xs, yfit] = turbotrend(x, y, lambda, n)
% Very fast spline smoothing (Discretize x & compute bin midpoints) found
% at: http://stat.ethz.ch/events/archive/Ascona_04/Slides/eilers.pdf
xmin = min(x);
xmax = max(x);
dx = 1.0001 * (xmax - xmin) / n;
xb = floor(1 + (x - xmin) / dx);
xs = xmin + ((1:n) - 0.5)' * dx;
% Construct equations & solve
s = sparse(xb, 1, y);       % Right-hand side
t = sparse(xb, 1, 1);       % Diagonal W = B?B
D = diff(eye(n), 2);
W = spdiags(t, 0, n, n);
C = chol(W + lambda * D' * D);
z = C \ (C' \ s);           % Solve with Cholesky
yfit = z(xb);
end

function out=parse_aes(varargin)
%Parse input to generate esthetics structure
p=inputParser;

% x and y are mandatory first two arguments
my_addParameter(p,'x',[]);
my_addParameter(p,'y',[]);

% Other aesthetics are string-value pairs
my_addParameter(p,'color',[]);
my_addParameter(p,'lightness',[]);
my_addParameter(p,'group',[]);
my_addParameter(p,'linestyle',[]);
my_addParameter(p,'size',[]);
my_addParameter(p,'marker',[]);
my_addParameter(p,'subset',[]);

parse(p,varargin{:});

%Make everyone column arrays
for pr=1:length(p.Parameters)
    %By doing the test with isrow, we prevent shifting things that could be
    %in 2D such as X and Y
    if isrow(p.Results.(p.Parameters{pr}))
        out.(p.Parameters{pr})=shiftdim(p.Results.(p.Parameters{pr}));
    else
        out.(p.Parameters{pr})=p.Results.(p.Parameters{pr});
    end
end


end

function out=merge_aes(orig_aes,new_aes)
%Merge new_aes in orig_aes (non-empty elements of new_aes will replace the ones of orig_aes)
fields=fieldnames(orig_aes);
out=orig_aes;

for k=1:length(fields)
    if ~isempty(new_aes.(fields{k}))
        out.(fields{k})=new_aes.(fields{k});
    end
end

end

function out=select_aes(aes,sel)
%Extract a logical selection out of an aes structure
fields=fieldnames(aes);

for k=1:length(fields)
    if isempty(aes.(fields{k}))
        out.(fields{k})=[];
    else
        out.(fields{k})=aes.(fields{k})(sel);
    end
    
end

end

function out=validate_aes(aes)
%Generate useable aes structures: empty fields are replaced with arrays of
%ones of the correct size. The size of the other fields are checked for
%consistency. Handle special case of size parameter that can be set by the
%user


out=aes;
fields=fieldnames(aes);


%                 if numel(p_results.size)==1
%                     obj.size=ones(size(obj.x))*p_results.size;
%                 else
%                     obj.size=p_results.size(obj.subset);
%                 end

%Handle special case when Y is a matrix
if ~iscell(out.y)
    if size(out.y,2)>1
        out.y=num2cell(out.y,2); %We convert rows of y to cell elements
        out.y=cellfun(@(c)shiftdim(c),out.y,'uniformOutput',false);
        %out.y=shiftdim(out.y);
    end
end

%Handle special case when Y is a matrix/cell and X is a single vector
if iscell(out.y) && ~iscell(out.x)
    if size(out.x,2)>1 %X is a matrix
        out.x=num2cell(out.x,2);  %We convert rows of x to cell elements
    else %X is a vector
        %We need to duplicate it
        if length(out.x)==length(out.y)
            out.x=num2cell(repmat(shiftdim(out.x),1,length(out.y{1})),2);
        else
            out.x=num2cell(repmat(shiftdim(out.x),1,length(out.y)),1);
        end
    end
    out.x=cellfun(@(c)shiftdim(c),out.x,'uniformOutput',false);
    out.x=shiftdim(out.x);
end



aes_length=-1;
for k=1:length(fields)
    if numel(out.(fields{k}))>0
        if aes_length==-1 && numel(out.(fields{k}))~=1
            aes_length=numel(out.(fields{k}));
        else
            if aes_length~=numel(out.(fields{k})) && numel(out.(fields{k}))~=1 %Handle special case of size
                error('Aesthetics have fields of different lengths !')
            end
        end
    end
end



%Special case for size:
if numel(aes.size)==1
    out.size=ones(size(aes.x))*aes.size;
end


for k=1:length(fields)
    if isempty(aes.(fields{k}))
        out.(fields{k})=ones(aes_length,1);
        
        
        if strcmp(fields{k},'subset')
            out.(fields{k})=true(aes_length,1);
        end
        
    end
end

end

function s=pval_to_star(p)
if p<0.001
    s='***';
elseif p<0.01
    s='**';
elseif p<0.05
    s='*';
else
    s='';
end
end

function [n,ind]=my_histcounts(X,edges,normalization)
persistent old_matlab
if isempty(old_matlab)
    old_matlab=verLessThan('matlab','8.4');
end
if old_matlab
    %We make histc behave like histcounts
    [n,ind]=histc(X,edges);
    ind(ind==length(n))=length(n)-1;
    n(end-1)=n(end-1)+n(end);
    n(end)=[];
    
    switch normalization
        case 'probability'
            n=n./sum(n);
        case 'count'
        otherwise
            warning('Other types of normalization are not supported on older Matlab versions')
    end
else
    [n, ~, ind]=histcounts(X,edges,'Normalization',normalization);
end
end

function my_addParameter(parser,name,value)
%To maintain compatibility with older versions
persistent old_matlab
if isempty(old_matlab)
    old_matlab=verLessThan('matlab','8.3');
end
if old_matlab
    addParamValue(parser,name,value);
else
    addParameter(parser,name,value);
end

end

function [ h ] = point_patch(x,y,s,c,resolution)
%point_patch Create nice looking scatter plot
%Example point_patch(0:pi/19:2*pi,sin(0:pi/19:2*pi),(1:39)/40,[0 0 1],20)

if nargin<5
    resolution=10;
end

persistent circlex
persistent circley
persistent res

if isempty(res) || res~=resolution
    res=resolution;
    circlex=cos(0:pi/(0.5*res):2*pi)/pi;
    circley=sin(0:pi/(0.5*res):2*pi)/pi;
end

x=shiftdim(x);
y=shiftdim(y);
%s=shiftdim(s);
s=sqrt(shiftdim(s)/pi);

trans=@(in,shift,sz)bsxfun(@plus,bsxfun(@times,in,sz),shift);

h=patch(trans(circlex,x,s)',trans(circley,y,s)',c,...
    'EdgeColor',c,'EdgeAlpha',0.8,...
    'FaceColor',c,'FaceAlpha',0.2)

end


function cmap=get_colormap(nc,nl,opts)

if isstr(opts.map)
    if ~strcmp(opts.map,'lch') && nl>1
        error('Lightness not supported for non lch colormaps');
    end
    
    %Brewer colormaps from http://colorbrewer2.org
    switch opts.map
        case 'matlab'
            cmap=colormap('lines');
        case 'brewer1'
            if nc>9
                error('Too many color categories for brewer1 (max=9)')
            end
            cmap=[228    26    28
                55   126   184
                77   175    74
                152    78   163
                255   127     0
                255   255    51
                166    86    40
                247   129   191
                153   153   153]/255;
        case 'brewer2'
            if nc>8
                error('Too many color categories for brewer2 (max=8)')
            end
            cmap=[102	194	165
                252	141	98
                141	160	203
                231	138	195
                166	216	84
                255	217	47
                229	196	148
                179	179	179]/255;
        case 'brewer3'
            if nc>12
                error('Too many color categories for brewer3 (max=12)')
            end
            cmap=[141	211	199
                255	255	179
                190	186	218
                251	128	114
                128	177	211
                253	180	98
                179	222	105
                252	205	229
                217	217	217
                188	128	189
                204	235	197
                255	237	111]/255;
        case 'brewer_pastel'
            if nc>9
                error('Too many color categories for brewer_pastel (max=9)')
            end
            cmap=[251	180	174
                179	205	227
                204	235	197
                222	203	228
                254	217	166
                255	255	204
                229	216	189
                253	218	236
                242	242	242]/255;
        case 'brewer_dark'
            if nc>8
                error('Too many color categories for brewer1 (max=8)')
            end
            cmap=[27	158	119
                217	95	2
                117	112	179
                231	41	138
                102	166	30
                230	171	2
                166	118	29
                102	102	102]/255;
        otherwise
            % Generate colormap using low-level function found on https://code.google.com/p/p-and-a/
            if nl==1
                %Was 65,75
                cmap=pa_LCH2RGB([repmat(linspace(opts.lightness,opts.lightness,nl)',nc+1,1) ...
                    repmat(linspace(opts.chroma,opts.chroma,nl)',nc+1,1)...
                    reshape(repmat(linspace(opts.hue_range(1),opts.hue_range(2),nc+1),nl,1),nl*(nc+1),1)],false);
            else
                cmap=pa_LCH2RGB([repmat(linspace(opts.lightness_range(1),opts.lightness_range(2),nl)',nc+1,1) ...
                    repmat(linspace(opts.chroma_range(1),opts.chroma_range(2),nl)',nc+1,1)...
                    reshape(repmat(linspace(opts.hue_range(1),opts.hue_range(2),nc+1),nl,1),nl*(nc+1),1)],false);
            end
    end
else
    cmap=opts.map;
end
end

function y=unique_and_sort(x,sortopts)
% Unique() function that ignores NaNs in arrays and empty values as well as 'NA' in
% cellstrs, and sorts according to sortopts

persistent old_matlab
if isempty(old_matlab)
    old_matlab=verLessThan('matlab','7.14');
end

%Create unique in original order
if old_matlab
    [y,ia,ic]=unique(x);
    [~,ind]=sort(ia); %Trick to get the original order in older matlab versions
    y=y(ind);
else
    y = unique(x,'stable'); %we keep the original order
end

%Clean up uniques
if ~iscell(x)
    if ~iscategorical(y)
        y(isnan(y)) = []; % remove all nans
    end
else
    y(strcmp(y,'NA'))=[]; %remove all 'NA'
    y(strcmp(y,''))=[]; %remove all ''
end

%Apply sorting options
if numel(sortopts)>1 %Custom ordering
    y=sort(y);%Sort first
    
    sortopts=shiftdim(sortopts);
    %Do checks on sorting array
    if length(sortopts)==length(y) %Correct length ?
        if isnumeric(sortopts) && sum(sort(sortopts)==(1:length(y))')==numel(y) %If we have integers and all numbers from 1 to N are there we probably have indices
            disp('ordering given as indices')
            y=y(sortopts);
        else
            %warning('Improper order array indices: using default order');
            %return
            disp('ordering given as values')
            try
                [present,order]=ismember(sortopts,y);
                if sum(present)==length(y)
                    y=y(order);
                else
                    warning('Improper ordering values')
                end
            catch
                warning('Improper ordering values')
            end

        end
    else
        warning('Improper order array size: using default order');
        return;
    end
    
    
else %Other orderings
    switch sortopts
        case 1
            y=sort(y);
        case -1
            y=flipud(sort(y)); %We use flipud instead of the 'descend' option because somehow it isn't supported for cellstr.
    end
end

end


function h=my_tightplot(m,n,p,gap,marg_h,marg_w,varargin)
%function h=subtightplot(m,n,p,gap,marg_h,marg_w,varargin)
%
% Functional purpose: A wrapper function for Matlab function subplot. Adds the ability to define the gap between
% neighbouring subplots. Unfotrtunately Matlab subplot function lacks this functionality, and the gap between
% subplots can reach 40% of figure area, which is pretty lavish.  
%
% Input arguments (defaults exist):
%   gap- two elements vector [vertical,horizontal] defining the gap between neighbouring axes. Default value
%            is 0.01. Note this vale will cause titles legends and labels to collide with the subplots, while presenting
%            relatively large axis. 
%   marg_h  margins in height in normalized units (0...1)
%            or [lower uppper] for different lower and upper margins 
%   marg_w  margins in width in normalized units (0...1)
%            or [left right] for different left and right margins 
%
% Output arguments: same as subplot- none, or axes handle according to function call.
%
% Issues & Comments: Note that if additional elements are used in order to be passed to subplot, gap parameter must
%       be defined. For default gap value use empty element- [].      
%
% Usage example: h=subtightplot((2,3,1:2,[0.5,0.2])

%note n and m are switched as Matlab indexing is column-wise, while subplot indexing is row-wise :(
[subplot_col,subplot_row]=ind2sub([n,m],p);  


% single subplot dimensions:
%height=(1-(m+1)*gap_vert)/m;
%axh = (1-sum(marg_h)-(Nh-1)*gap(1))/Nh; 
height=(1-(marg_h(2)+marg_h(1))-(m-1)*gap(1))/m;
%width =(1-(n+1)*gap_horz)/n;
%axw = (1-sum(marg_w)-(Nw-1)*gap(2))/Nw;
width =(1-(marg_w(1)+marg_w(2))-(n-1)*gap(2))/n;

% merged subplot position:
bottom=(m-subplot_row)*(height+gap(1)) +marg_h(1);
left=(subplot_col-1)*(width+gap(2)) +marg_w(1);
pos_vec=abs([left bottom width height]);

% h_subplot=subplot(m,n,p,varargin{:},'Position',pos_vec);
% Above line doesn't work as subplot tends to ignore 'position' when same mnp is utilized
h=subplot('Position',pos_vec,varargin{:});

if (nargout < 1),  clear h;  end

end


