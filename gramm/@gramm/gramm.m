classdef gramm < matlab.mixin.Copyable
    %GRAMM Implementation of the features from R's ggplot2 (GRAMmar of graphics plots) in Matlab
    % Pierre Morel 2015
    
    properties (Access=public)
        legend_axe_handle %Store the handle of the legend axis
        facet_axes_handles %Stores the handles of the facet axes
        results %Stores the results of the draw functions and statistics computations (datetime/duration x and y are stored as numbers, see axis_types)
        layout %tiledlayout holding the facets, titles and legend
    end

    properties (SetAccess=protected)
        %How datetime and duration x/y data is converted to the numbers
        %found in results: axis_types.x and axis_types.y have fields type
        %('numeric', 'datetime' or 'duration'), ref (datetime: numbers are
        %days since ref) and unit (duration: 's','m','h' or 'd'; 'deg' for
        %polar x data in degrees, stored in radians)
        axis_types
    end
    
    properties (Access=protected,Hidden=true)
        aes %aesthetics (contains data set by the constructor and used to generate the plots)
        
        %Name of the aesthetics and column/rows for the legend
        aes_names
        
        axe_properties={} %Contains the axes properties to be set to each subplot
        
        geom={} %Cell containing successive plotting function handles
        
        var_lim %Contains the min and max values of variables (minx,maxx,miny,maxy)
        
        %Contains the min and max values of variables in sub plots
        %(minx,maxx,miny,maxy,minc,maxc), c being for the continuous color
        %values. Each of these is a matrix
        %corresponding to the facets, used to set axis limits
        plot_lim
        
        xlim_extra=[0.05 0.05] %extend range of XLim (ratio of original XLim width)
        ylim_extra=[0.05 0.05] %extend range of XLim (ratio of original YLim width)
        zlim_extra=[0.05 0.05]
        
        %Structure containing polar-related parameters: is_polar stores
        %whether to display polar plots, is_polar_closed to  set if the
        %polar lines must close around the circle, max_polar_y to
        %define the limits in radius, and unit the angle unit.
        polar=struct('is_polar',false,...
            'is_polar_closed',false,...
            'max_polar_y',-1,...
            'unit','radians')
        
        axis_scale=struct('x','linear','y','linear','z','linear') %'linear' or 'log' axes (see set_scale())

        is_flipped=false; %Are the axes flipped?
        
        cat_order %Natural order of the values of categorical/datetime/duration grouping data (see validate_aes())

        x_factor %Is X a categorical variable ?
        x_ticks %Store the ticks used for x
        
        %Is the gramm plot part of an array of gramm plots drawn together
        multi=struct('active',false)
        
        %Stores variables relative to gramm updating
        updater=struct('facet_updated',0,...
            'updated',false,...
            'first_draw',true)
        
        firstrun %Is it the first time the plotting function is run
        result_ind %current index in the draw loops
        
        wrap_ncols=-1 %After how many columns do we wrap around subplots
        facet_scale='fixed' %Do we have independent scales between facets ?
        facet_space='fixed' %Do scale axes between facets ?
        force_ticks=false %Do we force ticks on all facets
        row_labels=true;
        column_labels=true;
        
        %structure containing the abline parameters
        abline=struct('on',0,...
            'slope',[],...
            'intercept',[],...
            'xintercept',[],...
            'yintercept',[],...
            'style',[],...
            'fun',[],...
            'linewidth',[],...
            'extent',[],...
            'raw',[])
        
        %structure containing polygon parameters - Nicholas Schaub 2017-Mar-07
        polygon = struct('on',false,...
                         'x',{[]},...
                         'y',{[]},...
                         'color_options',{[]},...
                         'line_style',{[]},...
                         'color',[],...
                         'line_color',[],...
                         'alpha',[],...
                         'extent',[]);
        
        datetick_params={} %cell containng datetick parameters
        current_row %What is the currently drawn row of the subplot
        current_column %What is the currently drawn column of the subplot
        
        continuous_color_options; %Structure holding continuous color options
        
        color_options  %Structure holding color options
        
        order_options %Structure holding order options
        
        text_options %Structure holding text options
        
        line_options %Structure holding line options
        
        point_options %Structure holding point options
        
        stat_options %Structure holding statistics options
        
        layout_options  %Structure holding layout options
        
        legend_y=0 %Current y position of the legend text
        legend_transform %hgtransform scaling the legend vertically (see scale_legend())
        
        
        
        bigtitle=''
        bigtitle_options={}
        title=''
        title_options={}
        
        legend_text_handles=[] %Stores handles of text objects for legend
        facet_text_handles=[] %Stores handles of text objects for facet row and column titles
        facet_row_axes=[] %Stores the overlay axes holding the facet row titles
        title_text_handle=[] %Stores handle of title text object
        
        redraw_fun={}
        
        parent=[]
        parent_tile=struct('tile',1,'span',[1 1]) %Tile used when the parent is a tiledlayout
        
        data_size

        
        extra %Store extra geom-specific info
       
    end
    
    methods (Access=public)
        
        % Constructor
        function obj=gramm(varargin)
            % gramm Constructor for the class: creates a gramm object with the data to plot
            %
            % Example syntax: gramm_object=gramm('x',x_variable,'y',y_variable,'color',color_variable)
            % The data can be given in two layouts:
            %
            % One row per observation: x, y and the grouping variables are 1D arrays
            % of the same length N (like the columns of a table). Points with the same
            % grouping values form a group, e.g. a line for geom_line() or a
            % summary for stat_summary().
            %
            % One row per repeated measurement (trajectories, time series...): y is
            % a N x M matrix, or a N x 1 cell of arrays (possibly of different
            % lengths), each row/cell being one curve. x is then a 1D array of
            % length M shared by all curves, or a matrix/cell with the same size as
            % y. The grouping variables still have one value per row (length N), so
            % each curve gets the color, marker... of its row.
            %
            % Grouping variables (color, lightness, row, column...) represent
            % categories, and can be numerical arrays, cellstr, string, categorical,
            % datetime or duration arrays. Categorical arrays are ordered by their
            % categories, dates and durations chronologically (see
            % set_order_options()). x and y (and ymin, ymax) can also be datetime or
            % duration arrays, which are displayed natively on the axes.
            %
            % Parameters given as 'name',value pairs:
            % - 'x': Data plotted as abscissa, or used for histograms/densities.
            %            1D array or cellstr of length N, or for repeated
            %            measurements a 1D array of length M, or a matrix/cell
            %            with the same size as y
            % - 'y': Data plotted as ordinate. 1D array of length N, or for
            %            repeated measurements a N x M matrix or N x 1 cell of
            %            arrays (one curve per row/cell)
            % - 'ymin': Lower bound of y intervals (absolute), same format as y, see
            %            geom_interval()
            % - 'ymax': Upper bound of y intervals (absolute), same format as y
            % - 'z': Data plotted along z, same format as y
            % - 'label': Label text, cellstr of length N, see geom_label()
            % - 'color': Grouping variable for colors (hue), or continuous color data
            %            (see set_continuous_color())
            % - 'lightness': Grouping variable for color lightness
            % - 'group': Grouping variable without visual change (e.g. one line per
            %            subject)
            % - 'linestyle': Grouping variable for line styles
            % - 'size': Grouping variable for line/point sizes
            % - 'marker': Grouping variable for point shapes
            % - 'subset': Logical array of length N selecting the data to plot
            % - 'row': Grouping variable for rows of subplots, same as facet_grid()
            % - 'column': Grouping variable for columns of subplots, same as
            %            facet_grid()
            % - 'fig': Grouping variable for separate figures, same as fig()
            
            obj.aes=parse_aes(varargin{:});
            obj.axis_types=struct('x',axis_type(),'y',axis_type());
            aes_fields=fieldnames(obj.aes);
            obj.cat_order=cell2struct(repmat({{}},numel(aes_fields),1),aes_fields,1);
            
            %Run the set_xx_options() functions without arguments to set
            %defaults
            set_names(obj);
            set_continuous_color(obj,'active',false);
            set_order_options(obj);
            set_color_options(obj);
            set_text_options(obj);
            set_line_options(obj);
            set_point_options(obj);
            set_stat_options(obj);
            set_layout_options(obj);
        end
        
        obj=update(obj,varargin)
        
        obj=facet_grid(obj,row,col,varargin)
        obj=facet_wrap(obj,col,varargin)
        
        obj=fig(obj,fig)
        
        obj=redraw(obj,src,event)
        obj=draw(obj)
		obj=export(obj,varargin)
           
        % Customization methods
        obj=set_polar(obj,varargin)
        obj=set_color_options(obj,varargin)
        obj=set_text_options(obj,varargin)
        obj=set_line_options(obj,varargin)
        obj=set_point_options(obj,varargin)
        obj=set_order_options(obj,varargin)
        obj=set_stat_options(obj,varargin)
        obj=set_continuous_color(obj,varargin)
        obj=no_legend(obj)
        obj=set_limit_extra(obj,x_extra,y_extra,z_extra)
        obj=axe_property(obj,varargin)
        obj=set_scale(obj,varargin)
        obj=set_datetick(obj,varargin)
        obj=set_title(obj,title,varargin)
        obj=set_parent(obj,parent,varargin)
        obj=set_names(obj,varargin)
        
        % geom  methods
        obj=geom_line(obj,varargin)
        obj=geom_point(obj,varargin)
        obj=geom_count(obj,varargin)
        obj=geom_jitter(obj,varargin)
        obj=geom_abline(obj,varargin)
        obj=geom_polygon(obj,varargin)
        obj=geom_vline(obj,varargin)
        obj=geom_hline(obj,varargin)
        obj=geom_funline(obj,varargin)
        obj=geom_raster(obj,varargin)
        obj=geom_bar(obj,varargin)
        obj=geom_interval(obj,varargin)
        obj=geom_label(obj,varargin)
        obj=geom_swarm(obj,varargin)
        
        % stat methods
        obj=stat_smooth(obj,varargin)
        obj=stat_summary(obj,varargin)
        obj=stat_boxplot(obj,varargin)
        obj=stat_ellipse(obj,varargin)
        obj=stat_glm(obj,varargin)
        obj=stat_fit(obj,varargin)
        obj=stat_bin(obj,varargin)
        obj=stat_bin2d(obj,varargin)
        obj=stat_density(obj,varargin)
        obj=stat_qq(obj,varargin)
        obj=stat_cornerhist(obj,varargin)
        obj=stat_violin(obj,varargin)
        
    end

end





















