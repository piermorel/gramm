classdef gramm < matlab.mixin.Copyable
    %GRAMM Implementation of the features from R's ggplot2 (GRAMmar of graphics plots) in Matlab
    % Pierre Morel 2015
    
    properties (Access=public)
        legend_axe_handle %Store the handle of the legend axis
        title_axe_handle %Store the handle of the title axis
        facet_axes_handles %Stores the handles of the facet axes
        results %Stores the results of the draw functions and statistics computations
        
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
        %polar lines must close around the circle, and max_polar_y to
        %define the limits in radius.
        polar=struct('is_polar',false,...
            'is_polar_closed',false)
        
        is_flipped=false; %Are the axes flipped?
        
        x_factor %Is X a categorical variable ?
        x_ticks %Store the ticks used for x
        
        %store variables used when making multiple gramm plots in the same window:
        multi=struct('orig',[0 0],...   origin (x,y) of the current gramm plot in normalized
            'size',[1 1],...   size (w,h) of the current gramm plot in normalized values
            'active',false)
        
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
            'extent',[])
        
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
        
        
        
        bigtitle=''
        bigtitle_options={}
        title=''
        title_options={}
        
        legend_text_handles=[] %Stores handles of text objects for legend
        facet_text_handles=[] %Stores handles of text objects for facet row and column titles
        title_text_handle=[] %Stores handle of title text object
        
        redraw_cache=[] %Cache store for faster redraw() calls
        redraw_fun={}
        
        parent=[]
        
        handle_graphics
        data_size
        
        extra %Store extra geom-specific info
       
    end
    
    methods (Access=public)
        
        % Constructor
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
            %   - 'label' for the label text
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
            %   - label should be a 1D cell array of strings of length N.
            
            obj.aes=parse_aes(varargin{:});
            obj.handle_graphics=~verLessThan('matlab','8.4.0');
            
            %Run the set_xx_options() functions without arguments to set
            %defaults
            set_names(obj);
            set_continuous_color(obj,'active',NaN);
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
        
        obj=redraw(obj,spacing,display)
        obj=draw(obj,do_redraw)
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
        obj=set_datetick(obj,varargin)
        obj=set_title(obj,title,varargin)
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
        
        function obj=set_parent(obj,parent)
            obj.parent=parent;
        end
        
    end

end





















