function export_vega(g, varargin)
%EXPORT_VEGA Export gramm plot to Vega interactive visualization
%   EXPORT_VEGA(g, ...) exports the gramm plot g to an interactive Vega visualization
%   with the following optional parameters:
%       'file_name' - Name of the output files (default: 'untitled')
%       'export_path' - Path where to save the files (default: './')
%       'x' - X-axis label (default: 'x-axis')
%       'y' - Y-axis label (default: 'y-axis')
%       'title' - Plot title (default: 'Untitled')
%       'width' - Width of the plot in pixels (default: figure width)
%       'height' - Height of the plot in pixels (default: figure height)
%       'interactive' - Enable interactive legend ('true' or 'false', default: 'false')
%       'tooltip' - Enable tooltips on hover ('true' or 'false', default: 'true')
%
%   Example:
%       g = gramm('x', x, 'y', y);
%       g.geom_line();
%       g.draw();
%       export_vega(g, 'file_name', 'my_plot', 'export_path', './output');

% Parse input parameters
params = parseInputParameters(g, varargin);

% Analyze gramm object
gramm_analysis = analyzeGrammObject(g);

% Detect chart types and layers
chart_spec = detectAllChartTypes(gramm_analysis, params);

% Extract and process data
vega_data = extractVegaData(gramm_analysis);

% Generate Vega specification
vega_spec = generateVegaSpecification(chart_spec, vega_data, params);

% Write output files
writeVegaFiles(vega_spec, params);

end

%% ===== CORE ANALYSIS FUNCTIONS =====

function params = parseInputParameters(g, varargin)
    % Get figure dimensions
    h_fig = g(1).parent;
    fig_pos = getpixelposition(h_fig);
    if fig_pos(3) == 0
        width_fig = '500';
    else
        width_fig = num2str(fig_pos(3));
    end
    if fig_pos(4) == 0
        height_fig = '500';
    else
        height_fig = num2str(fig_pos(4));
    end
    
    % Extract axis names from gramm object if available
    default_x_label = 'x-axis';
    default_y_label = 'y-axis';
    
    % Handle gramm arrays - use first element
    gramm_obj = g(1);
    
    % Try to get axis labels from facet_axes_handles
    try
        if ~isempty(gramm_obj.facet_axes_handles)
            default_x_label = gramm_obj.facet_axes_handles(1).XLabel.String;
            default_y_label = gramm_obj.facet_axes_handles(1).YLabel.String;
        end
    catch
        % Keep defaults if extraction fails
    end
    
    % Default parameters
    params = struct();
    params.file_name = 'untitled';
    params.export_path = './';
    params.x_label = default_x_label;
    params.y_label = default_y_label;
    params.title = 'Untitled';
    params.width = width_fig;
    params.height = height_fig;
    params.interactive = 'false';
    params.tooltip = 'true';
    
    % Parse input arguments
    args = varargin{1}; % varargin is a cell containing the arguments
    for i = 1:2:length(args)
        if i <= length(args)
            param_name = args{i};
            
            
            % Ensure parameter name is a string/char and convert to char
            if ischar(param_name)
                param_str = param_name;
            elseif isstring(param_name)
                param_str = char(param_name);
            else
                error('Parameter name at position %d must be a string or char array, got %s', i, class(param_name));
            end
            
            switch param_str
                case 'file_name'
                    params.file_name = args{i+1};
                case 'export_path'
                    params.export_path = args{i+1};
                case 'x'
                    params.x_label = args{i+1};
                case 'y'
                    params.y_label = args{i+1};
                case 'title'
                    params.title = args{i+1};
                case 'width'
                    params.width = args{i+1};
                case 'height'
                    params.height = args{i+1};
                case 'interactive'
                    params.interactive = args{i+1};
                case 'tooltip'
                    params.tooltip = args{i+1};
            end
        end
    end
    
end

function analysis = analyzeGrammObject(g)
    analysis = struct();
    
    % Extract aesthetic mappings
    analysis.aes = extractAesthetics(g);
    
    % Analyze g.results to detect all geom_* and stat_* handles
    analysis.geoms = detectGeomHandles(g.results);
    analysis.stats = detectStatHandles(g); % Now uses new implementation
    
    % Extract data and handle complex formats
    analysis.data = extractComplexData(g);
    
    % Detect grouping variables and color scales
    analysis.grouping = extractGroupingInfo(g);
    
    % Extract continuous color options for heatmaps/2D plots
    analysis.continuous_color = extractContinuousColorInfo(g);
end

function aes = extractAesthetics(g)
    aes = struct();
    aes.x = g.aes.x;
    aes.y = g.aes.y;
    
    % Extract additional aesthetics if present
    if isfield(g.aes, 'color')
        aes.color = g.aes.color;
    end
    if isfield(g.aes, 'size')
        aes.size = g.aes.size;
    end
    if isfield(g.aes, 'shape')
        aes.shape = g.aes.shape;
    end
end

function geoms = detectGeomHandles(results)
    geoms = struct();
    
    % Check for all possible geom handles - both _handle and direct field names
    geom_types = {'geom_point_handle', 'geom_line_handle', 'geom_bar_handle', ...
                  'geom_jitter_handle', 'geom_swarm_handle', 'geom_raster_handle', ...
                  'geom_interval_handle', 'geom_abline_handle', 'geom_vline_handle', ...
                  'geom_hline_handle', 'geom_polygon_handle'};
    
    % Also check for direct geom field names (without _handle suffix)
    geom_types_direct = {'geom_point', 'geom_line', 'geom_bar', ...
                        'geom_jitter', 'geom_swarm', 'geom_raster', ...
                        'geom_interval', 'geom_abline', 'geom_vline', ...
                        'geom_hline', 'geom_polygon'};
    
    % Check for _handle versions first
    for i = 1:length(geom_types)
        if isfield(results, geom_types{i})
            geoms.(geom_types{i}) = results.(geom_types{i});
        end
    end
    
    % Check for direct field names and convert to _handle format
    for i = 1:length(geom_types_direct)
        if isfield(results, geom_types_direct{i}) && ~isempty(results.(geom_types_direct{i}))
            handle_name = [geom_types_direct{i} '_handle'];
            geoms.(handle_name) = results.(geom_types_direct{i});
        end
    end
end


function data = extractComplexData(g)
    data = struct();
    data.x = g.aes.x;
    data.y = g.aes.y;
    
    % Handle complex data formats (2D arrays, cell arrays) - placeholder for now
    % This will be expanded in later phases
end

function grouping = extractGroupingInfo(g)
    grouping = struct();
    grouping.hasColorGroup = false;
    grouping.colorData = [];
    
    % Check for color grouping - more comprehensive detection
    if isfield(g.aes, 'color') && ~isempty(g.aes.color)
        % Check if color data has multiple unique values
        unique_colors = unique(g.aes.color);
        if length(unique_colors) > 1
            grouping.hasColorGroup = true;
            grouping.colorData = g.aes.color;
        else
            grouping.colorData = g.aes.color;
        end
    elseif isfield(g.results, 'color') && ~isempty(g.results.color) && length(g.results.color) > 1
        grouping.hasColorGroup = true;
        grouping.colorData = g.aes.color;
    else
        % No color grouping, use default color
        grouping.colorData = repmat('#ff4565', length(g.aes.x), 1);
    end
end

function continuous_color = extractContinuousColorInfo(g)
    continuous_color = struct();
    continuous_color.active = false;
    continuous_color.colormap = [];
    continuous_color.CLim = [];
    
    % Check if continuous color is active in gramm object
    if isfield(g, 'continuous_color_options') && ~isempty(g.continuous_color_options)
        if isfield(g.continuous_color_options, 'active') && g.continuous_color_options.active
            continuous_color.active = true;
            
            % Extract colormap if available
            if isfield(g.continuous_color_options, 'colormap') && ~isempty(g.continuous_color_options.colormap)
                continuous_color.colormap = g.continuous_color_options.colormap;
            end
            
            % Extract color limits if available
            if isfield(g.continuous_color_options, 'CLim') && ~isempty(g.continuous_color_options.CLim)
                continuous_color.CLim = g.continuous_color_options.CLim;
            end
        end
    end
end

function hex_colors = convertColormapToHex(colormap_matrix, num_colors)
    % Convert MATLAB colormap matrix to array of hex color strings
    % colormap_matrix: Nx3 matrix of RGB values (0-1)
    % num_colors: number of colors to sample from the colormap
    
    if isempty(colormap_matrix)
        % Default viridis-like gradient (blue-green-yellow) to match gramm default
        hex_colors = {'#440154', '#482777', '#3f4a8a', '#31678e', '#26838f', '#1f9d8a', '#6cce5a', '#b6de2b', '#fee825'};
        return;
    end
    
    % Sample colors evenly from the colormap
    colormap_size = size(colormap_matrix, 1);
    if num_colors > colormap_size
        num_colors = colormap_size;
    end
    
    indices = round(linspace(1, colormap_size, num_colors));
    sampled_colors = colormap_matrix(indices, :);
    
    % Convert RGB to hex
    hex_colors = cell(num_colors, 1);
    for i = 1:num_colors
        r = round(sampled_colors(i, 1) * 255);
        g = round(sampled_colors(i, 2) * 255);
        b = round(sampled_colors(i, 3) * 255);
        hex_colors{i} = sprintf('#%02x%02x%02x', r, g, b);
    end
end

%% ===== CHART TYPE DETECTION =====

function chart_spec = detectAllChartTypes(analysis, params)
    chart_spec = struct();
    chart_spec.layers = {};
    
    % Get geom field names and handle empty case
    if isempty(analysis.geoms) || ~isstruct(analysis.geoms)
        geom_fields = {};
    else
        geom_fields = fieldnames(analysis.geoms);
    end
    
    % Get stat field names and handle empty case
    if isempty(analysis.stats) || ~isstruct(analysis.stats)
        stat_fields = {};
    else
        stat_fields = fieldnames(analysis.stats);
    end
    
    % Process each geom type
    for i = 1:length(geom_fields)
        geom_type = geom_fields{i};
        switch geom_type
            case 'geom_point_handle'
                chart_spec.layers{end+1} = createPointLayer(analysis, params);
            case 'geom_line_handle'
                chart_spec.layers{end+1} = createLineLayer(analysis, params);
            case 'geom_bar_handle'
                chart_spec.layers{end+1} = createBarLayer(analysis, params);
            case 'geom_jitter_handle'
                chart_spec.layers{end+1} = createJitterLayer(analysis, params);
            case 'geom_swarm_handle'
                chart_spec.layers{end+1} = createSwarmLayer(analysis, params);
            case 'geom_raster_handle'
                chart_spec.layers{end+1} = createRasterLayer(analysis, params);
            case 'geom_interval_handle'
                chart_spec.layers{end+1} = createIntervalLayer(analysis, params);
            case 'geom_abline_handle'
                chart_spec.layers{end+1} = createAblineLayer(analysis, params);
            case 'geom_vline_handle'
                chart_spec.layers{end+1} = createVlineLayer(analysis, params);
            case 'geom_hline_handle'
                chart_spec.layers{end+1} = createHlineLayer(analysis, params);
            case 'geom_polygon_handle'
                chart_spec.layers{end+1} = createPolygonLayer(analysis, params);
        end
    end
    
    % Process each stat type - NEW IMPLEMENTATION
    for i = 1:length(stat_fields)
        stat_type = stat_fields{i};
        switch stat_type
            case 'stat_glm_handle'
                chart_spec.layers{end+1} = createStatGlmLayer(analysis, params);
            case 'stat_smooth_handle'
                chart_spec.layers{end+1} = createStatSmoothLayer(analysis, params);
            case 'stat_bin_handle'
                chart_spec.layers{end+1} = createStatBinLayer(analysis, params);
            case 'stat_summary_handle'
                chart_spec.layers{end+1} = createStatSummaryLayer(analysis, params);
            case 'stat_boxplot_handle'
                chart_spec.layers{end+1} = createStatBoxplotLayer(analysis, params);
            case 'stat_density_handle'
                chart_spec.layers{end+1} = createStatDensityLayer(analysis, params);
            case 'stat_violin_handle'
                chart_spec.layers{end+1} = createStatViolinLayer(analysis, params);
            case 'stat_qq_handle'
                chart_spec.layers{end+1} = createStatQqLayer(analysis, params);
            % TODO: Re-implement other stat types with new approach
            % case 'stat_fit_handle'
            %     chart_spec.layers{end+1} = createStatFitLayer(analysis, params);
            case 'stat_bin2d_handle'
                chart_spec.layers{end+1} = createStatBin2dLayer(analysis, params);
            % case 'stat_ellipse_handle'
            %     chart_spec.layers{end+1} = createStatEllipseLayer(analysis, params);
            % case 'stat_cornerhist_handle'
            %     chart_spec.layers{end+1} = createStatCornerhist(analysis, params);
        end
    end
    
    % If no geom or stat detected, default to point
    if isempty(chart_spec.layers)
        chart_spec.layers{1} = createPointLayer(analysis, params);
        disp('No geom or stat type detected, defaulting to point chart');
    end
end

%% ===== GEOMETRIC OBJECT IMPLEMENTATIONS =====

function layer = createPointLayer(analysis, params)
    layer = struct();
    layer.isVegaChart = true;
    
    % Create Vega specification for points
    layer.vegaSpec = createBaseVegaSpec();
    
    % Add scales
    layer.vegaSpec.scales = createVegaScales(analysis);
    
    % Add axes
    layer.vegaSpec.axes = createVegaAxes(analysis, params);
    
    % Create marks
    marks = struct();
    marks.name = 'points';
    marks.type = 'symbol';
    marks.from = struct('data', 'table');
    
    marks.encode = struct();
    marks.encode.enter = struct();
    marks.encode.enter.x = struct('scale', 'xscale', 'field', 'x');
    marks.encode.enter.y = struct('scale', 'yscale', 'field', 'y');
    marks.encode.enter.size = struct('value', 60);
    marks.encode.enter.stroke = struct('value', 'white');
    marks.encode.enter.strokeWidth = struct('value', 1);
    
    if analysis.grouping.hasColorGroup
        marks.encode.enter.fill = struct('scale', 'color', 'field', 'color');
    else
        marks.encode.enter.fill = struct('value', '#ff4565');
    end
    
    % Add tooltip support
    marks = addTooltipToMark(marks, params, analysis);
    
    layer.vegaSpec.marks = {marks};
end

function layer = createLineLayer(analysis, params)
    layer = struct();
    layer.isVegaChart = true;
    
    % Create Vega specification for lines
    layer.vegaSpec = createBaseVegaSpec();
    
    % Add scales
    layer.vegaSpec.scales = createVegaScales(analysis);
    
    % Add axes
    layer.vegaSpec.axes = createVegaAxes(analysis, params);
    
    % Create marks with proper grouping for multiple lines
    if analysis.grouping.hasColorGroup
        % For multi-color lines, use group with facet
        marks = struct();
        marks.name = 'lines';
        marks.type = 'group';
        marks.from = struct('facet', struct('name', 'series', 'data', 'table', 'groupby', 'color'));
        
        % Define the line mark within the group
        line_mark = struct();
        line_mark.type = 'line';
        line_mark.from = struct('data', 'series');
        line_mark.sort = struct('field', 'x'); % Sort by x-value within each color group
        line_mark.encode = struct();
        line_mark.encode.enter = struct();
        line_mark.encode.enter.x = struct('scale', 'xscale', 'field', 'x');
        line_mark.encode.enter.y = struct('scale', 'yscale', 'field', 'y');
        line_mark.encode.enter.strokeWidth = struct('value', 2);
        line_mark.encode.enter.stroke = struct('scale', 'color', 'field', 'color');
        
        % Add tooltip support to nested line mark
        line_mark = addTooltipToMark(line_mark, params, analysis);
        
        marks.marks = {line_mark};
    else
        % For single-color lines, use simple line mark directly
        marks = struct();
        marks.name = 'lines';
        marks.type = 'line';
        marks.from = struct('data', 'table');
        marks.encode = struct();
        marks.encode.enter = struct();
        marks.encode.enter.x = struct('scale', 'xscale', 'field', 'x');
        marks.encode.enter.y = struct('scale', 'yscale', 'field', 'y');
        marks.encode.enter.strokeWidth = struct('value', 2);
        marks.encode.enter.stroke = struct('value', '#ff4565');
        
        % Add tooltip support to simple line mark
        marks = addTooltipToMark(marks, params, analysis);
    end
    
    layer.vegaSpec.marks = {marks};
end

function layer = createBarLayer(analysis, params)
    layer = struct();
    layer.isVegaChart = true;
    
    % Create Vega specification for bars following official grouped bar pattern
    layer.vegaSpec = createBaseVegaSpec();
    
    % Create scales following the official example pattern (adapted for vertical bars)
    layer.vegaSpec.scales = {};
    
    % X scale (categorical - for bar groups)
    xscale = struct();
    xscale.name = 'xscale';
    xscale.type = 'band';
    xscale.domain = struct('data', 'table', 'field', 'x', 'sort', true);
    xscale.range = 'width';
    xscale.padding = 0.2;
    layer.vegaSpec.scales{end+1} = xscale;
    
    % Y scale (quantitative - for bar heights)
    yscale = struct();
    yscale.name = 'yscale';
    yscale.type = 'linear';
    yscale.domain = struct('data', 'table', 'field', 'y');
    yscale.range = 'height';
    yscale.round = true;
    yscale.zero = true;
    yscale.nice = true;
    layer.vegaSpec.scales{end+1} = yscale;
    
    % Color scale if grouping exists
    if analysis.grouping.hasColorGroup
        colorscale = struct();
        colorscale.name = 'color';
        colorscale.type = 'ordinal';
        colorscale.domain = struct('data', 'table', 'field', 'color');
        colorscale.range = {'#fc4464', '#08bc4d', '#04b0fc', '#ff9500', '#9b59b6', '#e74c3c', '#2ecc71', '#3498db'};
        layer.vegaSpec.scales{end+1} = colorscale;
    end
    
    % Add axes
    layer.vegaSpec.axes = {
        struct('orient', 'bottom', 'scale', 'xscale', 'tickSize', 0, 'labelPadding', 4, 'zindex', 1);
        struct('orient', 'left', 'scale', 'yscale')
    };
    
    if analysis.grouping.hasColorGroup
        % For grouped bars, use the official nested group structure
        marks = struct();
        marks.type = 'group';
        marks.from = struct('facet', struct('data', 'table', 'name', 'facet', 'groupby', 'x'));
        
        % Positioning for each group
        marks.encode = struct();
        marks.encode.enter = struct();
        marks.encode.enter.x = struct('scale', 'xscale', 'field', 'x');
        
        % Add signal for width calculation
        marks.signals = {struct('name', 'width', 'update', 'bandwidth(''xscale'')')};
        
        % Add inner scale for positioning bars within each group
        pos_scale = struct();
        pos_scale.name = 'pos';
        pos_scale.type = 'band';
        pos_scale.range = 'width';
        pos_scale.domain = struct('data', 'facet', 'field', 'color');
        marks.scales = {pos_scale};
        
        % Create the individual bar mark within each group
        bar_mark = struct();
        bar_mark.name = 'bars';
        bar_mark.from = struct('data', 'facet');
        bar_mark.type = 'rect';
        bar_mark.encode = struct();
        bar_mark.encode.enter = struct();
        bar_mark.encode.enter.x = struct('scale', 'pos', 'field', 'color');
        bar_mark.encode.enter.width = struct('scale', 'pos', 'band', 1);
        bar_mark.encode.enter.y = struct('scale', 'yscale', 'field', 'y');
        bar_mark.encode.enter.y2 = struct('scale', 'yscale', 'value', 0);
        bar_mark.encode.enter.fill = struct('scale', 'color', 'field', 'color');
        
        % Add tooltip support to nested bar mark
        bar_mark = addTooltipToMark(bar_mark, params, analysis);
        
        marks.marks = {bar_mark};
    else
        % Single bars can use simple rect mark
        marks = struct();
        marks.name = 'bars';
        marks.type = 'rect';
        marks.from = struct('data', 'table');
        
        marks.encode = struct();
        marks.encode.enter = struct();
        marks.encode.enter.x = struct('scale', 'xscale', 'field', 'x');
        marks.encode.enter.width = struct('scale', 'xscale', 'band', 1);
        marks.encode.enter.y = struct('scale', 'yscale', 'field', 'y');
        marks.encode.enter.y2 = struct('scale', 'yscale', 'value', 0);
        marks.encode.enter.fill = struct('value', '#ff4565');
        
        % Add tooltip support to simple bar mark
        marks = addTooltipToMark(marks, params, analysis);
    end
    
    layer.vegaSpec.marks = {marks};
end

function layer = createJitterLayer(analysis, params)
    layer = struct();
    layer.isVegaChart = true;
    
    % Create Vega specification for jittered points
    layer.vegaSpec = createBaseVegaSpec();
    
    % Add scales
    layer.vegaSpec.scales = createVegaScales(analysis);
    
    % Add axes
    layer.vegaSpec.axes = createVegaAxes(analysis, params);
    
    % Create marks with jitter transform
    marks = struct();
    marks.name = 'jitteredPoints';
    marks.type = 'symbol';
    marks.from = struct('data', 'table');
    
    marks.encode = struct();
    marks.encode.enter = struct();
    marks.encode.update = struct();
    marks.encode.update.x = struct('signal', 'scale(''xscale'', datum.x) + bandwidth(''xscale'')/2 + (random() - 0.5) * bandwidth(''xscale'') * 0.8');
    marks.encode.enter.y = struct('scale', 'yscale', 'field', 'y');
    marks.encode.enter.size = struct('value', 60);
    marks.encode.enter.stroke = struct('value', 'white');
    marks.encode.enter.strokeWidth = struct('value', 1);
    
    if analysis.grouping.hasColorGroup
        marks.encode.enter.fill = struct('scale', 'color', 'field', 'color');
    else
        marks.encode.enter.fill = struct('value', '#ff4565');
    end
    
    % Add tooltip support
    marks = addTooltipToMark(marks, params, analysis);
    
    layer.vegaSpec.marks = {marks};
end

function layer = createSwarmLayer(analysis, params)
    layer = struct();
    layer.isVegaChart = true;
    
    % Create Vega specification for beeswarm plot using jitter-based approach
    % This preserves Y-value accuracy while creating swarm visual effect
    layer.vegaSpec = createBaseVegaSpec();
    
    % Create scales - force band scale for swarm plots
    scales = {};
    
    % X scale - always use band scale for swarm plots to create discrete groups
    xscale = struct();
    xscale.name = 'xscale';
    xscale.type = 'band';
    xscale.domain = struct('data', 'table', 'field', 'x', 'sort', true);
    xscale.range = 'width';
    scales{end+1} = xscale;
    
    % Y scale - preserves exact Y values from data
    yscale = struct();
    yscale.name = 'yscale';
    yscale.type = 'linear';
    yscale.domain = struct('data', 'table', 'field', 'y');
    yscale.range = 'height';
    yscale.nice = true;
    yscale.zero = true;
    scales{end+1} = yscale;
    
    % Color scale if grouping exists
    if analysis.grouping.hasColorGroup
        colorscale = struct();
        colorscale.name = 'color';
        colorscale.type = 'ordinal';
        colorscale.domain = struct('data', 'table', 'field', 'color');
        colorscale.range = {'#fc4464', '#08bc4d', '#04b0fc', '#ff9500', '#9b59b6', '#e74c3c', '#2ecc71', '#3498db'};
        scales{end+1} = colorscale;
    end
    
    layer.vegaSpec.scales = scales;
    
    % Add axes - both X and Y for proper scaling
    layer.vegaSpec.axes = {
        struct('orient', 'bottom', 'scale', 'xscale', 'labelAngle', 0, 'labelFontSize', 12);
        struct('orient', 'left', 'scale', 'yscale')
    };
    
    % Create swarm marks using jitter-based approach that preserves Y values
    marks = struct();
    marks.name = 'swarmPoints';
    marks.type = 'symbol';
    marks.from = struct('data', 'table');
    
    % Encode properties
    marks.encode = struct();
    marks.encode.enter = struct();
    marks.encode.enter.stroke = struct('value', 'white');
    marks.encode.enter.strokeWidth = struct('value', 1);
    marks.encode.enter.size = struct('value', 80);
    
    % CRITICAL: Preserve exact Y values from data - no transformation applied
    marks.encode.enter.y = struct('scale', 'yscale', 'field', 'y');
    
    % Set color based on grouping
    if analysis.grouping.hasColorGroup
        marks.encode.enter.fill = struct('scale', 'color', 'field', 'color');
    else
        marks.encode.enter.fill = struct('value', '#ff4565');
    end
    
    % X positioning with simple jitter calculation (same as jitter implementation)
    marks.encode.update = struct();
    marks.encode.update.x = struct('signal', 'scale(''xscale'', datum.x) + bandwidth(''xscale'')/2 + (random() - 0.5) * bandwidth(''xscale'') * 0.8');
    
    % Add tooltip support
    marks = addTooltipToMark(marks, params, analysis);
    
    layer.vegaSpec.marks = {marks};
end

function layer = createRasterLayer(analysis, params)
    layer = struct();
    layer.isVegaChart = true;
    
    % Create Vega specification for raster/tick plots
    layer.vegaSpec = createBaseVegaSpec();
    
    % Add scales (only x-scale needed for raster)
    scales = createVegaScales(analysis);
    layer.vegaSpec.scales = scales(1); % Only keep x-scale
    
    % Add axes (only x-axis)
    layer.vegaSpec.axes = {struct('orient', 'bottom', 'scale', 'xscale')};
    
    % Create marks
    marks = struct();
    marks.name = 'ticks';
    marks.type = 'rect';
    marks.from = struct('data', 'table');
    
    marks.encode = struct();
    marks.encode.enter = struct();
    marks.encode.enter.x = struct('scale', 'xscale', 'field', 'x');
    marks.encode.enter.width = struct('value', 2);
    marks.encode.enter.y = struct('value', 0);
    marks.encode.enter.height = struct('signal', 'height');
    
    if analysis.grouping.hasColorGroup
        marks.encode.enter.fill = struct('scale', 'color', 'field', 'color');
    else
        marks.encode.enter.fill = struct('value', '#ff4565');
    end
    
    layer.vegaSpec.marks = {marks};
end

function layer = createIntervalLayer(analysis, params)
    layer = struct();
    layer.isVegaChart = true;
    
    % Create Vega specification for error bars/intervals
    layer.vegaSpec = createBaseVegaSpec();
    
    % Add scales
    layer.vegaSpec.scales = createVegaScales(analysis);
    
    % Add axes
    layer.vegaSpec.axes = createVegaAxes(analysis, params);
    
    % Create marks for error bars
    marks = struct();
    marks.name = 'errorbars';
    marks.type = 'rule';
    marks.from = struct('data', 'table');
    
    marks.encode = struct();
    marks.encode.enter = struct();
    marks.encode.enter.x = struct('scale', 'xscale', 'field', 'x');
    marks.encode.enter.y = struct('scale', 'yscale', 'field', 'ymin');
    marks.encode.enter.y2 = struct('scale', 'yscale', 'field', 'ymax');
    marks.encode.enter.strokeWidth = struct('value', 2);
    
    if analysis.grouping.hasColorGroup
        marks.encode.enter.stroke = struct('scale', 'color', 'field', 'color');
    else
        marks.encode.enter.stroke = struct('value', '#ff4565');
    end
    
    layer.vegaSpec.marks = {marks};
end

function layer = createAblineLayer(analysis, params)
    layer = struct();
    layer.isVegaChart = true;
    
    % Create Vega specification for diagonal reference lines
    layer.vegaSpec = createBaseVegaSpec();
    
    % Add scales
    layer.vegaSpec.scales = createVegaScales(analysis);
    
    % Add axes
    layer.vegaSpec.axes = createVegaAxes(analysis, params);
    
    % Create marks for diagonal line
    marks = struct();
    marks.name = 'abline';
    marks.type = 'line';
    marks.from = struct('data', 'table');
    
    marks.encode = struct();
    marks.encode.enter = struct();
    marks.encode.enter.x = struct('scale', 'xscale', 'field', 'x');
    marks.encode.enter.y = struct('scale', 'yscale', 'field', 'y');
    marks.encode.enter.stroke = struct('value', '#808080');
    marks.encode.enter.strokeWidth = struct('value', 2);
    marks.encode.enter.strokeDash = struct('value', [5, 5]);
    
    layer.vegaSpec.marks = {marks};
end

function layer = createVlineLayer(analysis, params)
    layer = struct();
    layer.isVegaChart = true;
    
    % Create Vega specification for vertical reference lines
    layer.vegaSpec = createBaseVegaSpec();
    
    % Add scales
    layer.vegaSpec.scales = createVegaScales(analysis);
    
    % Add axes
    layer.vegaSpec.axes = createVegaAxes(analysis, params);
    
    % Create marks for vertical lines
    marks = struct();
    marks.name = 'vlines';
    marks.type = 'rule';
    marks.from = struct('data', 'table');
    
    marks.encode = struct();
    marks.encode.enter = struct();
    marks.encode.enter.x = struct('scale', 'xscale', 'field', 'x');
    marks.encode.enter.y = struct('value', 0);
    marks.encode.enter.y2 = struct('signal', 'height');
    marks.encode.enter.stroke = struct('value', '#808080');
    marks.encode.enter.strokeWidth = struct('value', 1);
    marks.encode.enter.strokeDash = struct('value', [3, 3]);
    
    layer.vegaSpec.marks = {marks};
end

function layer = createHlineLayer(analysis, params)
    layer = struct();
    layer.isVegaChart = true;
    
    % Create Vega specification for horizontal reference lines
    layer.vegaSpec = createBaseVegaSpec();
    
    % Add scales
    layer.vegaSpec.scales = createVegaScales(analysis);
    
    % Add axes
    layer.vegaSpec.axes = createVegaAxes(analysis, params);
    
    % Create marks for horizontal lines
    marks = struct();
    marks.name = 'hlines';
    marks.type = 'rule';
    marks.from = struct('data', 'table');
    
    marks.encode = struct();
    marks.encode.enter = struct();
    marks.encode.enter.x = struct('value', 0);
    marks.encode.enter.x2 = struct('signal', 'width');
    marks.encode.enter.y = struct('scale', 'yscale', 'field', 'y');
    marks.encode.enter.stroke = struct('value', '#808080');
    marks.encode.enter.strokeWidth = struct('value', 1);
    marks.encode.enter.strokeDash = struct('value', [3, 3]);
    
    layer.vegaSpec.marks = {marks};
end

function layer = createPolygonLayer(analysis, params)
    layer = struct();
    layer.isVegaChart = true;
    
    % Create Vega specification for polygon/area plots
    layer.vegaSpec = createBaseVegaSpec();
    
    % Add scales
    layer.vegaSpec.scales = createVegaScales(analysis);
    
    % Add axes
    layer.vegaSpec.axes = createVegaAxes(analysis, params);
    
    % Create marks for polygon
    marks = struct();
    marks.name = 'polygons';
    marks.type = 'area';
    marks.from = struct('data', 'table');
    
    marks.encode = struct();
    marks.encode.enter = struct();
    marks.encode.enter.x = struct('scale', 'xscale', 'field', 'x');
    marks.encode.enter.y = struct('scale', 'yscale', 'field', 'y');
    marks.encode.enter.y2 = struct('scale', 'yscale', 'value', 0);
    marks.encode.enter.fill = struct('value', '#cccccc');
    marks.encode.enter.fillOpacity = struct('value', 0.3);
    
    layer.vegaSpec.marks = {marks};
end

%% ===== STATISTICAL TRANSFORMATION IMPLEMENTATIONS =====

function stats = extractStatisticsData(g)
    % Extract computed statistical data from gramm object results
    % This function replaces the old detectStatHandles approach by extracting
    % actual computed statistics instead of just checking for handle existence
    
    stats = struct();
    
    % Check for stat_glm results and extract regression data
    if isfield(g.results, 'stat_glm') && ~isempty(g.results.stat_glm)
        stats.stat_glm = extractGlmData(g.results.stat_glm);
    end
    
    % Extract stat_smooth data if present
    if isfield(g.results, 'stat_smooth') && ~isempty(g.results.stat_smooth)
        stats.stat_smooth = extractSmoothData(g.results.stat_smooth);
    end
    
    % Extract stat_bin data if present
    if isfield(g.results, 'stat_bin') && ~isempty(g.results.stat_bin)
        stats.stat_bin = extractBinData(g.results.stat_bin);
        if ~isempty(stats.stat_bin)
        end
    end
    
    % Extract stat_summary data if present
    if isfield(g.results, 'stat_summary') && ~isempty(g.results.stat_summary)
        stats.stat_summary = extractSummaryData(g.results.stat_summary);
    end
    
    % Extract stat_boxplot data if present
    if isfield(g.results, 'stat_boxplot') && ~isempty(g.results.stat_boxplot)
        stats.stat_boxplot = extractBoxplotData(g.results.stat_boxplot);
    end
    
    % Extract stat_density data if present
    if isfield(g.results, 'stat_density') && ~isempty(g.results.stat_density)
        stats.stat_density = extractDensityData(g.results.stat_density);
    end
    
    % Extract stat_violin data if present
    if isfield(g.results, 'stat_violin') && ~isempty(g.results.stat_violin)
        stats.stat_violin = extractViolinData(g.results.stat_violin);
    end
    
    % Extract stat_qq data if present
    if isfield(g.results, 'stat_qq') && ~isempty(g.results.stat_qq)
        stats.stat_qq = extractQqData(g.results.stat_qq);
    end
    
    % Extract stat_bin2d data if present
    if isfield(g.results, 'stat_bin2d') && ~isempty(g.results.stat_bin2d)
        stats.stat_bin2d = extractBin2dData(g.results.stat_bin2d);
    end
    
end

function glm_data = extractGlmData(stat_glm_results)
    % Extract GLM regression data from gramm's computed results
    % This includes regression line coordinates, confidence intervals, and handles
    
    glm_data = [];
    
    % Handle different formats - struct array, single struct, or cell array
    if isstruct(stat_glm_results) && ~iscell(stat_glm_results)
        if numel(stat_glm_results) > 1
            % Multi-group: struct array with multiple elements
            results_to_process = cell(numel(stat_glm_results), 1);
            for k = 1:numel(stat_glm_results)
                results_to_process{k} = stat_glm_results(k);
            end
        else
            % Single group: wrap single struct in cell for uniform processing
            results_to_process = {stat_glm_results};
        end
    elseif iscell(stat_glm_results)
        results_to_process = stat_glm_results;
    else
        return;
    end
    
    for i = 1:numel(results_to_process)
        result = results_to_process{i};
        
        if isempty(result)
            continue;
        end
        
        % Create data structure for this GLM result
        glm_entry = struct();
        
        % Extract basic regression data
        if isfield(result, 'x') && isfield(result, 'y')
            % For grouped GLM, directly use the provided regression data without checking length
            % This avoids issues with special object types that don't support standard functions
            try
                glm_entry.reg_x = result.x;  % Regression line x coordinates
                glm_entry.reg_y = result.y;  % Regression line y coordinates
            catch ME
                % Skip this entry if we can't access the data
                continue;
            end
        end
        
        % Extract confidence interval data - prioritize yci over area handle for reliability
        ci_extracted = false;
        
        % First try to extract CI from yci (more reliable)
        if isfield(result, 'yci')
            % Skip isempty check as it may fail with special objects
            % Normalize yci to a numeric matrix with rows [lower, upper]
            yci = result.yci;
            if istable(yci)
                yci = yci{:,:}; % extract numeric data from table
            elseif iscell(yci)
                try
                    yci = cell2mat(yci);
                catch
                    try
                        yci = vertcat(yci{:});
                    catch
                        yci = [];
                    end
                end
            end

            original_ci_lower = [];
            original_ci_upper = [];

            if ~isempty(yci)
                [r,c] = size(yci);
                if c == 2
                    % Expected format: two columns, each row is [lower upper]
                    original_ci_lower = yci(:,1);
                    original_ci_upper = yci(:,2);
                elseif r == 2
                    % Handle legacy 2xN format: first row lower, second row upper
                    original_ci_lower = yci(1,:).';
                    original_ci_upper = yci(2,:).';
                elseif mod(numel(yci),2) == 0
                    % As a last resort, reshape to Nx2
                    yci = reshape(yci, [], 2);
                    original_ci_lower = yci(:,1);
                    original_ci_upper = yci(:,2);
                else
                end

                % Sanity check: enforce lower ≤ upper per row
                if ~isempty(original_ci_lower) && ~isempty(original_ci_upper)
                    swap_idx = original_ci_lower > original_ci_upper;
                    if any(swap_idx)
                        tmp = original_ci_lower(swap_idx);
                        original_ci_lower(swap_idx) = original_ci_upper(swap_idx);
                        original_ci_upper(swap_idx) = tmp;
                    end

                    % Use original x coordinates for interpolation base
                    % Handle special object types that don't support standard indexing
                    try
                        ci_x_coords = result.x(:);
                    catch
                        % Fallback: use the regression x coordinates we already extracted
                        ci_x_coords = glm_entry.reg_x(:);
                    end

                    % Interpolate to match regression x values if needed
                    if isfield(glm_entry, 'reg_x') && numel(glm_entry.reg_x) > numel(original_ci_lower)
                        glm_entry.ci_lower = interp1(ci_x_coords, original_ci_lower, glm_entry.reg_x, 'linear', 'extrap');
                        glm_entry.ci_upper = interp1(ci_x_coords, original_ci_upper, glm_entry.reg_x, 'linear', 'extrap');
                    else
                        glm_entry.ci_lower = original_ci_lower(:);
                        glm_entry.ci_upper = original_ci_upper(:);
                    end

                    
                    ci_extracted = true;
                end
            end
        end
        
        % Fallback to area handle extraction if yci failed
        if ~ci_extracted && isfield(result, 'area_handle')
            try
                if isprop(result.area_handle, 'Vertices') || isfield(result.area_handle, 'Vertices')
                    vertices = get(result.area_handle, 'Vertices');
                    if size(vertices, 1) > 0
                        % Area vertices are typically [x1,y1; x2,y2; ...] for lower bound
                        % followed by reverse order for upper bound
                        n_points = size(vertices, 1) / 2;
                        if n_points == floor(n_points) && n_points > 1
                            % Split vertices into two halves
                            first_half = vertices(1:n_points, :);
                            second_half = vertices(n_points+1:end, :);
                            % Reverse second half to match x order
                            second_half = flipud(second_half);
                            
                            area_x = first_half(:, 1);
                            first_y = first_half(:, 2);
                            second_y = second_half(:, 2);
                            
                            % Determine which is upper and which is lower by comparing y values
                            first_mean = mean(first_y);
                            second_mean = mean(second_y);
                            
                            if first_mean < second_mean
                                area_lower = first_y;
                                area_upper = second_y;
                            else
                                area_lower = second_y;
                                area_upper = first_y;
                            end
                            
                            
                            % Interpolate to match regression x values
                            if isfield(glm_entry, 'reg_x')
                                try
                                    % Remove duplicate x values before interpolation
                                    [unique_x, unique_idx] = unique(area_x);
                                    unique_lower = area_lower(unique_idx);
                                    unique_upper = area_upper(unique_idx);
                                    
                                    glm_entry.ci_lower = interp1(unique_x, unique_lower, glm_entry.reg_x, 'linear', 'extrap');
                                    glm_entry.ci_upper = interp1(unique_x, unique_upper, glm_entry.reg_x, 'linear', 'extrap');
                                    ci_extracted = true;
                                catch interp_error
                                end
                            end
                        end
                    end
                end
            catch ME
            end
        end
        
        % Extract handle information for coordinate data
        if isfield(result, 'line_handle')
            glm_entry.line_handle = result.line_handle;
        end
        
        if isfield(result, 'area_handle')
            glm_entry.area_handle = result.area_handle;
            
            % Extract vertices from area patch for confidence interval coordinates
            try
                if isprop(result.area_handle, 'Vertices') || isfield(result.area_handle, 'Vertices')
                    vertices = get(result.area_handle, 'Vertices');
                    glm_entry.area_vertices = vertices;
                elseif isprop(result.area_handle, 'XData') || isfield(result.area_handle, 'XData')
                    % Alternative: Extract XData and YData
                    xdata = get(result.area_handle, 'XData');
                    ydata = get(result.area_handle, 'YData');
                    glm_entry.area_xdata = xdata;
                    glm_entry.area_ydata = ydata;
                end
            catch ME
            end
        end
        
        % Extract model information if available
        if isfield(result, 'model')
            glm_entry.model = result.model;
        end
        
        % Store the index for grouping
        glm_entry.result_index = i;
        
        if ~isempty(fieldnames(glm_entry))
            glm_data = [glm_data; glm_entry];
        end
    end
    
end

function smooth_data = extractSmoothData(stat_smooth_results)
    % Extract smooth regression data from gramm's computed results
    % This includes smooth regression line coordinates, confidence intervals, and handles
    % Similar structure to extractGlmData but for stat_smooth
    
    if isempty(stat_smooth_results)
        smooth_data = [];
        return;
    end
    
    smooth_data = {};
    
    % Handle struct arrays (stat_smooth uses struct arrays, not cell arrays like stat_glm)
    if numel(stat_smooth_results) > 1
        % Multi-group: struct array with multiple elements
        results_to_process = cell(numel(stat_smooth_results), 1);
        for k = 1:numel(stat_smooth_results)
            results_to_process{k} = stat_smooth_results(k);
        end
    else
        % Single group
        results_to_process = {stat_smooth_results};
    end
    
    for i = 1:length(results_to_process)
        result = results_to_process{i};
        
        if ~isempty(result) && isfield(result, 'x') && isfield(result, 'y')
            data_entry = struct();
            
            % Extract x and y coordinates for the smooth line
            data_entry.x = result.x;
            data_entry.y = result.y;
            data_entry.group = i; % Assign group number
            
            % Extract confidence intervals from yci if available
            if isfield(result, 'yci') && ~isempty(result.yci)
                yci = result.yci;
                
                % For stat_smooth, yci is a [2 x N] matrix where row 1 is lower bounds, row 2 is upper bounds
                if size(yci, 1) == 2
                    data_entry.ci_lower = yci(1, :)';  % First row is lower bounds (transpose to column)
                    data_entry.ci_upper = yci(2, :)';  % Second row is upper bounds (transpose to column)
                    
                elseif size(yci, 2) == 2
                    % Fallback for GLM-style format [N x 2]
                    data_entry.ci_lower = yci(:, 1);  % First column is lower bounds
                    data_entry.ci_upper = yci(:, 2);  % Second column is upper bounds
                    
                else
                end
            end
            
            % Extract handles for reference
            if isfield(result, 'line_handle')
                    data_entry.line_handle = result.line_handle;
            end
            
            if isfield(result, 'area_handle')
                    data_entry.area_handle = result.area_handle;
                
                % Extract vertices for debugging if needed
                if ~isempty(result.area_handle) && isvalid(result.area_handle) && isprop(result.area_handle, 'Vertices')
                    vertices = result.area_handle.Vertices;
                end
            end
            
            smooth_data{end+1} = data_entry;
        end
    end
    
end

function bin_data = extractBinData(stat_bin_results)
    % Extract histogram/bin data from gramm's computed results
    % This includes bin edges, centers, counts for histogram visualization
    
    if isempty(stat_bin_results)
        bin_data = [];
        return;
    end
    
    % Handle both single-group and multi-group stat_bin structures
    if numel(stat_bin_results) > 1
        % Multi-group: struct array with multiple elements
        bin_data = {};
        
        for k = 1:numel(stat_bin_results)
            result = stat_bin_results(k);
            
            if isfield(result, 'edges') && isfield(result, 'centers') && isfield(result, 'counts')
                group_data = struct();
                group_data.edges = result.edges;      % Bin edges
                group_data.centers = result.centers;  % Bin centers  
                group_data.counts = result.counts;    % Count values
                group_data.group = k;                 % Group identifier
                
                % Ensure counts is a column vector for consistency
                if size(group_data.counts, 2) > size(group_data.counts, 1)
                    group_data.counts = group_data.counts';
                end
                
                % Ensure centers is a column vector for consistency  
                if size(group_data.centers, 2) > size(group_data.centers, 1)
                    group_data.centers = group_data.centers';
                end
                
                
                % Extract handles for reference
                if isfield(result, 'bar_handle')
                    group_data.bar_handle = result.bar_handle;
                end
                
                bin_data{end+1} = group_data;
            else
            end
        end
    else
        % Single group
        
        if isfield(stat_bin_results, 'edges') && isfield(stat_bin_results, 'centers') && isfield(stat_bin_results, 'counts')
            bin_data = struct();
            bin_data.edges = stat_bin_results.edges;      % Bin edges
            bin_data.centers = stat_bin_results.centers;  % Bin centers  
            bin_data.counts = stat_bin_results.counts;    % Count values
            bin_data.group = 1;                           % Single group identifier
            
            % Ensure counts is a column vector for consistency
            if size(bin_data.counts, 2) > size(bin_data.counts, 1)
                bin_data.counts = bin_data.counts';
            end
            
            % Ensure centers is a column vector for consistency  
            if size(bin_data.centers, 2) > size(bin_data.centers, 1)
                bin_data.centers = bin_data.centers';
            end
            
            
            % Extract handles for reference
            if isfield(stat_bin_results, 'bar_handle')
                bin_data.bar_handle = stat_bin_results.bar_handle;
            end
        else
            bin_data = [];
        end
    end
    
end

function summary_data = extractSummaryData(stat_summary_results)
    % Extract summary statistics data from gramm's computed results
    % This includes summary statistics per category with confidence intervals
    % Similar structure to extractGlmData but for categorical summaries
    
    if isempty(stat_summary_results)
        summary_data = [];
        return;
    end
    
    summary_data = {};
    
    % Handle struct arrays (similar to stat_smooth)
    if numel(stat_summary_results) > 1
        % Multi-group: struct array with multiple elements
        results_to_process = cell(numel(stat_summary_results), 1);
        for k = 1:numel(stat_summary_results)
            results_to_process{k} = stat_summary_results(k);
        end
    else
        % Single group
        results_to_process = {stat_summary_results};
    end
    
    for i = 1:length(results_to_process)
        result = results_to_process{i};
        
        if isfield(result, 'x') && isfield(result, 'y')
            data_entry = struct();
            data_entry.x = result.x(:);  % Ensure column vector
            data_entry.y = result.y(:);  % Ensure column vector
            data_entry.group = i;        % Group identifier
            
            
            % Extract confidence intervals from yci if available
            if isfield(result, 'yci') && ~isempty(result.yci)
                yci = result.yci;
                
                % Handle yci format (need to check if it's [N x 2] like GLM or [2 x N] like smooth)
                if size(yci, 2) == 2 && size(yci, 1) == length(data_entry.y)
                    % [N x 2] format like GLM
                    data_entry.ci_lower = yci(:, 1);
                    data_entry.ci_upper = yci(:, 2);
                elseif size(yci, 1) == 2 && size(yci, 2) == length(data_entry.y)
                    % [2 x N] format like smooth
                    data_entry.ci_lower = yci(1, :)';  % First row is lower bounds
                    data_entry.ci_upper = yci(2, :)';  % Second row is upper bounds
                else
                    % Set default confidence intervals
                    data_entry.ci_lower = data_entry.y;
                    data_entry.ci_upper = data_entry.y;
                end
            else
                % No confidence intervals available
                data_entry.ci_lower = data_entry.y;
                data_entry.ci_upper = data_entry.y;
            end
            
            % Extract handles for reference
            if isfield(result, 'line_handle')
                data_entry.line_handle = result.line_handle;
                end
            if isfield(result, 'area_handle')
                data_entry.area_handle = result.area_handle;
                end
            
            summary_data{end+1} = data_entry;
        else
        end
    end
    
end

function boxplot_data = extractBoxplotData(stat_boxplot_results)
    % Extract boxplot data from gramm's computed results
    % boxplot_data is a 4x5 double array where:
    % - Each row represents a category
    % - Each column is: [bottom whisker, Q1, median, Q3, top whisker]
    
    if isempty(stat_boxplot_results)
        boxplot_data = [];
        return;
    end
    
    % Extract the boxplot_data field
    if isfield(stat_boxplot_results, 'boxplot_data')
        raw_data = stat_boxplot_results.boxplot_data;
        
        % Verify it's the expected 5-number summary format
        if size(raw_data, 2) ~= 5
        end
        
        % Create structured data for each category
        boxplot_data = {};
        num_categories = size(raw_data, 1);
        
        for i = 1:num_categories
            category_data = struct();
            category_data.category = i;  % Category index (will be mapped to labels later)
            
            % Extract 5-number summary: [bottom whisker, Q1, median, Q3, top whisker]
            if size(raw_data, 2) >= 5
                category_data.whisker_low = raw_data(i, 1);   % Bottom whisker
                category_data.q1 = raw_data(i, 2);           % First quartile
                category_data.median = raw_data(i, 3);       % Median
                category_data.q3 = raw_data(i, 4);           % Third quartile  
                category_data.whisker_high = raw_data(i, 5); % Top whisker
                
                
                boxplot_data{end+1} = category_data;
            else
            end
        end
        
    else
        boxplot_data = [];
    end
    
end

function density_data = extractDensityData(stat_density_results)
    % Extract kernel density estimation data from gramm's computed results
    % This includes density curves coordinates for each group
    
    if isempty(stat_density_results)
        density_data = [];
        return;
    end
    
    density_data = {};
    
    % Handle struct arrays (stat_density uses struct arrays)
    if numel(stat_density_results) > 1
        % Multi-group: struct array with multiple elements
        results_to_process = cell(numel(stat_density_results), 1);
        for k = 1:numel(stat_density_results)
            results_to_process{k} = stat_density_results(k);
        end
    else
        % Single group
        results_to_process = {stat_density_results};
    end
    
    for i = 1:length(results_to_process)
        result = results_to_process{i};
        
        if ~isempty(result) && isfield(result, 'x') && isfield(result, 'y')
            data_entry = struct();
            
            % Extract x and y coordinates for the density curve
            data_entry.x = result.x(:);  % Ensure column vector - density evaluation points
            data_entry.y = result.y(:);  % Ensure column vector - density values
            data_entry.group = i;        % Assign group number
            
            
            % Extract handles for reference
            if isfield(result, 'handle')
                data_entry.handle = result.handle;
            end
            
            density_data{end+1} = data_entry;
        else
        end
    end
    
end

function violin_data = extractViolinData(stat_violin_results)
    % Extract violin plot data from gramm's computed results
    % stat_violin_results contains densities, densities_y, and unique_x
    
    violin_data = {};
    
    
    for i = 1:size(stat_violin_results, 1)
        result = stat_violin_results(i, 1);
        
        % Validate required fields
        if isfield(result, 'densities') && isfield(result, 'densities_y') && isfield(result, 'unique_x')
            % Extract violin data for each category
            for j = 1:length(result.unique_x)
                data_entry = struct();
                data_entry.group = i;
                data_entry.category_index = result.unique_x(j);
                data_entry.x_density = result.densities{j};     % Density values (x-coordinates for violin shape)
                data_entry.y_values = result.densities_y{j};   % Y-values corresponding to density points
                
                % Store handle information if available
                if isfield(result, 'line_handle')
                    data_entry.line_handle = result.line_handle;
                end
                if isfield(result, 'fill_handle')
                    data_entry.fill_handle = result.fill_handle;
                end
                
                
                violin_data{end+1} = data_entry;
            end
        else
        end
    end
    
end

function qq_data = extractQqData(stat_qq_results)
    % Extract Q-Q plot data from gramm's computed results
    % stat_qq_results contains x (theoretical quantiles) and y (sample quantiles)
    
    qq_data = {};
    
    
    for i = 1:size(stat_qq_results, 1)
        result = stat_qq_results(i, 1);
        
        % Validate required fields
        if isfield(result, 'x') && isfield(result, 'y')
            data_entry = struct();
            data_entry.group = i;
            data_entry.x_theoretical = result.x(:);  % Theoretical quantiles
            data_entry.y_sample = result.y(:);       % Sample quantiles
            
            % Store handle information if available
            if isfield(result, 'point_handle')
                data_entry.point_handle = result.point_handle;
            end
            
            
            qq_data{end+1} = data_entry;
        else
        end
    end
    
end

function stats = detectStatHandles(g)
    % New implementation that extracts actual statistical data from gramm objects
    % This replaces the old handle-only detection approach
    
    
    % Use the new extractStatisticsData function
    stats = extractStatisticsData(g);
    
    % Create handle-style entries for compatibility with existing switch statements
    % This allows us to trigger the stat layer creation logic
    if isfield(stats, 'stat_glm') && ~isempty(stats.stat_glm)
        stats.stat_glm_handle = true;  % Flag to indicate GLM data exists
    end
    
    % Add stat_smooth_handle flag if stat_smooth data exists
    if isfield(stats, 'stat_smooth') && ~isempty(stats.stat_smooth)
        stats.stat_smooth_handle = true;  % Flag to indicate smooth data exists
    end
    
    % Add stat_bin_handle flag if stat_bin data exists
    if isfield(stats, 'stat_bin') && ~isempty(stats.stat_bin)
        stats.stat_bin_handle = true;  % Flag to indicate bin data exists
    end
    
    % Add stat_summary_handle flag if stat_summary data exists
    if isfield(stats, 'stat_summary') && ~isempty(stats.stat_summary)
        stats.stat_summary_handle = true;  % Flag to indicate summary data exists
    end
    
    % Add stat_boxplot_handle flag if stat_boxplot data exists
    if isfield(stats, 'stat_boxplot') && ~isempty(stats.stat_boxplot)
        stats.stat_boxplot_handle = true;  % Flag to indicate boxplot data exists
    end
    
    % Add stat_density_handle flag if stat_density data exists
    if isfield(stats, 'stat_density') && ~isempty(stats.stat_density)
        stats.stat_density_handle = true;  % Flag to indicate density data exists
    end
    
    % Add stat_violin_handle flag if stat_violin data exists
    if isfield(stats, 'stat_violin') && ~isempty(stats.stat_violin)
        stats.stat_violin_handle = true;  % Flag to indicate violin data exists
    end
    
    % Add stat_qq_handle flag if stat_qq data exists
    if isfield(stats, 'stat_qq') && ~isempty(stats.stat_qq)
        stats.stat_qq_handle = true;  % Flag to indicate QQ data exists
    end
    
    % Add stat_bin2d_handle flag if stat_bin2d data exists
    if isfield(stats, 'stat_bin2d') && ~isempty(stats.stat_bin2d)
        stats.stat_bin2d_handle = true;  % Flag to indicate bin2d data exists
    end
    
end

function layer = createStatGlmLayer(analysis, params)
    % Create Vega specification for GLM fits using actual gramm regression data
    % This version uses pre-computed regression data instead of Vega transforms
    
    layer = struct();
    layer.isVegaChart = true;
    
    % Create base Vega specification
    layer.vegaSpec = createBaseVegaSpec();
    
    % Check if we have GLM data in the analysis
    if ~isfield(analysis, 'stats') || ~isfield(analysis.stats, 'stat_glm') || isempty(analysis.stats.stat_glm)
        % Create empty layer
        layer.vegaSpec.data = {struct('name', 'table', 'values', [])};
        layer.vegaSpec.scales = createVegaScales(analysis);
        layer.vegaSpec.axes = createVegaAxes(analysis, params);
        layer.vegaSpec.marks = {};
        return;
    end
    
    glm_data = analysis.stats.stat_glm;
    
    % Prepare data sources
    data_sources = {};
    
    % 1. Original data points (will be handled by main table in generateVegaSpecification)
    % We don't add original data here to avoid duplication
    
    % 2. Unified stats data containing regression and confidence interval information
    stats_data = struct();
    stats_data.name = 'stats';
    stats_data.values = [];
    
    % Process each GLM result and combine into unified stats structure
    for i = 1:length(glm_data)
        glm_entry = glm_data(i);
        
        % Combine regression and confidence interval data into unified stats points
        if isfield(glm_entry, 'reg_x') && isfield(glm_entry, 'reg_y')
            x_len = length(glm_entry.reg_x);
            
            % Determine confidence interval data availability
            has_ci = isfield(glm_entry, 'ci_lower') && isfield(glm_entry, 'ci_upper');
            
            % Create unified stats points for full regression line
            for j = 1:x_len
                stats_point = struct();
                stats_point.x = glm_entry.reg_x(j);
                stats_point.regression_y = glm_entry.reg_y(j);
                stats_point.group = i;  % Group index for color separation
                
                % Always include confidence interval fields for consistent structure
                if has_ci && j <= length(glm_entry.ci_lower) && j <= length(glm_entry.ci_upper)
                    stats_point.ci_lower = glm_entry.ci_lower(j);
                    stats_point.ci_upper = glm_entry.ci_upper(j);
                else
                    % Set to NaN when confidence intervals are not available
                    % This ensures all stats_point structures have the same fields
                    stats_point.ci_lower = NaN;
                    stats_point.ci_upper = NaN;
                end
                
                stats_data.values = [stats_data.values; stats_point];
            end
        end
    end
    
    data_sources{end+1} = stats_data;
    layer.vegaSpec.data = data_sources;
    
    % Create scales
    layer.vegaSpec.scales = createVegaScales(analysis);
    
    % Add group color scale if multiple GLM results (different colors/groups)
    if length(glm_data) > 1 || analysis.grouping.hasColorGroup
        group_scale = struct();
        group_scale.name = 'groupColor';
        group_scale.type = 'ordinal';
        group_scale.domain = struct('data', 'stats', 'field', 'group');
        group_scale.range = {'#fc4464', '#08bc4d', '#04b0fc', '#ff9500', '#9b59b6', '#e74c3c', '#2ecc71', '#3498db'};
        layer.vegaSpec.scales{end+1} = group_scale;
    end
    
    % Create axes
    layer.vegaSpec.axes = createVegaAxes(analysis, params);
    
    % Create marks
    marks = {};
    
    % Check if we have stats data for regression and confidence intervals
    has_stats = ~isempty(stats_data.values);
    has_ci = false;
    if has_stats
        % Check if any stats points have confidence interval data
        for i = 1:length(stats_data.values)
            if isfield(stats_data.values(i), 'ci_lower') && isfield(stats_data.values(i), 'ci_upper')
                has_ci = true;
                break;
            end
        end
    end
    
    % 1. Confidence interval areas (render first, behind other elements)
    if has_stats && has_ci
        % Create a filtered data source for confidence intervals to exclude NaN values
        ci_data_source = struct();
        ci_data_source.name = 'confidence_filtered';
        ci_data_source.source = 'stats';
        ci_data_source.transform = {struct('type', 'filter', 'expr', 'isValid(datum.ci_lower) && isValid(datum.ci_upper)')};
        
        % Add the filtered confidence data source
        layer.vegaSpec.data{end+1} = ci_data_source;
        
        if length(glm_data) > 1 || analysis.grouping.hasColorGroup
            % Multiple groups - use grouped approach for confidence areas
            ci_marks = struct();
            ci_marks.name = 'confidence_areas';
            ci_marks.type = 'group';
            ci_marks.from = struct('facet', struct('name', 'ci_group_data', 'data', 'confidence_filtered', 'groupby', 'group'));
            
            % Inner area mark for each group
            inner_area = struct();
            inner_area.type = 'area';
            inner_area.from = struct('data', 'ci_group_data');
            inner_area.sort = struct('field', 'x');
            inner_area.encode = struct();
            inner_area.encode.enter = struct();
            inner_area.encode.enter.x = struct('scale', 'xscale', 'field', 'x');
            inner_area.encode.enter.y = struct('scale', 'yscale', 'field', 'ci_lower');
            inner_area.encode.enter.y2 = struct('scale', 'yscale', 'field', 'ci_upper');
            inner_area.encode.enter.fillOpacity = struct('value', 0.2);
            inner_area.encode.enter.strokeWidth = struct('value', 0);
            inner_area.encode.enter.fill = struct('scale', 'groupColor', 'field', 'group');
            
            ci_marks.marks = {inner_area};
        else
            % Single group - use simple area
            ci_marks = struct();
            ci_marks.name = 'confidence_areas';
            ci_marks.type = 'area';
            ci_marks.from = struct('data', 'confidence_filtered');
            ci_marks.sort = struct('field', 'x');  % Sort by x for proper area rendering
            
            ci_marks.encode = struct();
            ci_marks.encode.enter = struct();
            ci_marks.encode.enter.x = struct('scale', 'xscale', 'field', 'x');
            ci_marks.encode.enter.y = struct('scale', 'yscale', 'field', 'ci_lower');
            ci_marks.encode.enter.y2 = struct('scale', 'yscale', 'field', 'ci_upper');
            ci_marks.encode.enter.fillOpacity = struct('value', 0.2);
            ci_marks.encode.enter.strokeWidth = struct('value', 0);
            ci_marks.encode.enter.fill = struct('value', '#ff4565');
        end
        
        marks{end+1} = ci_marks;
    end
    
    % 2. Regression lines
    if has_stats
        if length(glm_data) > 1 || analysis.grouping.hasColorGroup
            % Multiple groups - use faceted approach
            reg_marks = struct();
            reg_marks.name = 'regression_lines';
            reg_marks.type = 'group';
            reg_marks.from = struct('facet', struct('name', 'group_data', 'data', 'stats', 'groupby', 'group'));
            
            % Inner line mark
            inner_line = struct();
            inner_line.type = 'line';
            inner_line.from = struct('data', 'group_data');
            inner_line.sort = struct('field', 'x');
            inner_line.encode = struct();
            inner_line.encode.enter = struct();
            inner_line.encode.enter.x = struct('scale', 'xscale', 'field', 'x');
            inner_line.encode.enter.y = struct('scale', 'yscale', 'field', 'regression_y');
            inner_line.encode.enter.strokeWidth = struct('value', 2);
            inner_line.encode.enter.stroke = struct('scale', 'groupColor', 'field', 'group');
            
            reg_marks.marks = {inner_line};
            marks{end+1} = reg_marks;
        else
            % Single group - simple line
            reg_marks = struct();
            reg_marks.name = 'regression_line';
            reg_marks.type = 'line';
            reg_marks.from = struct('data', 'stats');
            reg_marks.sort = struct('field', 'x');
            reg_marks.encode = struct();
            reg_marks.encode.enter = struct();
            reg_marks.encode.enter.x = struct('scale', 'xscale', 'field', 'x');
            reg_marks.encode.enter.y = struct('scale', 'yscale', 'field', 'regression_y');
            reg_marks.encode.enter.strokeWidth = struct('value', 2);
            reg_marks.encode.enter.stroke = struct('value', '#ff4565');
            
            marks{end+1} = reg_marks;
        end
    end
    
    % 3. Data points (render on top) - will use main "table" data source
    points_marks = struct();
    points_marks.name = 'data_points';
    points_marks.type = 'symbol';
    points_marks.from = struct('data', 'table');  % Use main data source
    points_marks.encode = struct();
    points_marks.encode.enter = struct();
    points_marks.encode.enter.x = struct('scale', 'xscale', 'field', 'x');
    points_marks.encode.enter.y = struct('scale', 'yscale', 'field', 'y');
    points_marks.encode.enter.size = struct('value', 50);
    points_marks.encode.enter.stroke = struct('value', 'white');
    points_marks.encode.enter.strokeWidth = struct('value', 1);
    
    if analysis.grouping.hasColorGroup
        points_marks.encode.enter.fill = struct('scale', 'color', 'field', 'color');
    else
        points_marks.encode.enter.fill = struct('value', 'steelblue');
    end
    
    % Add tooltip support
    points_marks = addTooltipToMark(points_marks, params, analysis);
    marks{end+1} = points_marks;
    
    layer.vegaSpec.marks = marks;
end

function layer = createStatSmoothLayer(analysis, params)
    % Create a stat_smooth layer with smooth regression lines and confidence intervals
    % Similar to createStatGlmLayer but for smooth regression
    
    % Get smooth data from analysis
    smooth_data = analysis.stats.stat_smooth;
    
    % Create base Vega specification for this layer
    layer = struct();
    layer.vegaSpec = createBaseVegaSpec();
    layer.vegaSpec.width = str2double(params.width);
    layer.vegaSpec.height = str2double(params.height);
    
    % Set up scales (same as GLM)
    layer.vegaSpec.scales = createVegaScales(analysis, false, 'table');
    
    % Add groupColor scale for multiple groups
    if length(smooth_data) > 1 || analysis.grouping.hasColorGroup
        groupScale = struct();
        groupScale.name = 'groupColor';
        groupScale.type = 'ordinal';
        groupScale.domain = struct('data', 'stats', 'field', 'group');
        groupScale.range = {'#fc4464', '#08bc4d', '#04b0fc', '#ff9500', '#9b59b6', '#e74c3c', '#2ecc71', '#3498db'};
        layer.vegaSpec.scales{end+1} = groupScale;
    end
    
    % Set up axes
    layer.vegaSpec.axes = createVegaAxes(analysis, params);
    
    % Convert smooth data to Vega stats format
    stats_data = [];
    for i = 1:length(smooth_data)
        entry = smooth_data{i};
        for j = 1:length(entry.x)
            data_point = struct();
            data_point.x = entry.x(j);
            data_point.regression_y = entry.y(j);
            data_point.group = entry.group;
            
            % Add confidence intervals if available
            if isfield(entry, 'ci_lower') && isfield(entry, 'ci_upper')
                data_point.ci_lower = entry.ci_lower(j);
                data_point.ci_upper = entry.ci_upper(j);
            end
            
            stats_data = [stats_data; data_point];
        end
    end
    
    % Add stats data source
    stats_data_source = struct();
    stats_data_source.name = 'stats';
    stats_data_source.values = stats_data;
    layer.vegaSpec.data{end+1} = stats_data_source;
    
    % Set up marks array
    marks = {};
    has_stats = ~isempty(stats_data);
    
    % 1. Confidence intervals (if available)
    if has_stats && ~isempty(stats_data) && isfield(stats_data(1), 'ci_lower')
        % Add filtered confidence data source
        ci_data_source = struct();
        ci_data_source.name = 'confidence_filtered';
        ci_data_source.source = 'stats';
        ci_data_source.transform = {struct('type', 'filter', 'expr', 'isValid(datum.ci_lower) && isValid(datum.ci_upper)')};
        
        % Add the filtered confidence data source
        layer.vegaSpec.data{end+1} = ci_data_source;
        
        if length(smooth_data) > 1 || analysis.grouping.hasColorGroup
            % Multiple groups - use grouped approach for confidence areas
            ci_marks = struct();
            ci_marks.name = 'confidence_areas';
            ci_marks.type = 'group';
            ci_marks.from = struct('facet', struct('name', 'ci_group_data', 'data', 'confidence_filtered', 'groupby', 'group'));
            
            % Inner area mark for each group
            inner_area = struct();
            inner_area.type = 'area';
            inner_area.from = struct('data', 'ci_group_data');
            inner_area.sort = struct('field', 'x');
            inner_area.encode = struct();
            inner_area.encode.enter = struct();
            inner_area.encode.enter.x = struct('scale', 'xscale', 'field', 'x');
            inner_area.encode.enter.y = struct('scale', 'yscale', 'field', 'ci_lower');
            inner_area.encode.enter.y2 = struct('scale', 'yscale', 'field', 'ci_upper');
            inner_area.encode.enter.fillOpacity = struct('value', 0.2);
            inner_area.encode.enter.strokeWidth = struct('value', 0);
            inner_area.encode.enter.fill = struct('scale', 'groupColor', 'field', 'group');
            
            ci_marks.marks = {inner_area};
        else
            % Single group - use simple area
            ci_marks = struct();
            ci_marks.name = 'confidence_areas';
            ci_marks.type = 'area';
            ci_marks.from = struct('data', 'confidence_filtered');
            ci_marks.sort = struct('field', 'x');
            
            ci_marks.encode = struct();
            ci_marks.encode.enter = struct();
            ci_marks.encode.enter.x = struct('scale', 'xscale', 'field', 'x');
            ci_marks.encode.enter.y = struct('scale', 'yscale', 'field', 'ci_lower');
            ci_marks.encode.enter.y2 = struct('scale', 'yscale', 'field', 'ci_upper');
            ci_marks.encode.enter.fillOpacity = struct('value', 0.2);
            ci_marks.encode.enter.strokeWidth = struct('value', 0);
            ci_marks.encode.enter.fill = struct('value', '#ff4565');
        end
        
        marks{end+1} = ci_marks;
    end
    
    % 2. Smooth regression lines
    if has_stats
        if length(smooth_data) > 1 || analysis.grouping.hasColorGroup
            % Multiple groups - use faceted approach
            reg_marks = struct();
            reg_marks.name = 'smooth_lines';
            reg_marks.type = 'group';
            reg_marks.from = struct('facet', struct('name', 'group_data', 'data', 'stats', 'groupby', 'group'));
            
            % Inner line mark
            inner_line = struct();
            inner_line.type = 'line';
            inner_line.from = struct('data', 'group_data');
            inner_line.sort = struct('field', 'x');
            inner_line.encode = struct();
            inner_line.encode.enter = struct();
            inner_line.encode.enter.x = struct('scale', 'xscale', 'field', 'x');
            inner_line.encode.enter.y = struct('scale', 'yscale', 'field', 'regression_y');
            inner_line.encode.enter.strokeWidth = struct('value', 2);
            inner_line.encode.enter.stroke = struct('scale', 'groupColor', 'field', 'group');
            
            reg_marks.marks = {inner_line};
        else
            % Single group
            reg_marks = struct();
            reg_marks.name = 'smooth_lines';
            reg_marks.type = 'line';
            reg_marks.from = struct('data', 'stats');
            reg_marks.sort = struct('field', 'x');
            
            reg_marks.encode = struct();
            reg_marks.encode.enter = struct();
            reg_marks.encode.enter.x = struct('scale', 'xscale', 'field', 'x');
            reg_marks.encode.enter.y = struct('scale', 'yscale', 'field', 'regression_y');
            reg_marks.encode.enter.strokeWidth = struct('value', 2);
            reg_marks.encode.enter.stroke = struct('value', '#ff4565');
        end
        
        marks{end+1} = reg_marks;
    end
    
    % 3. Data points (similar to GLM layer)
    points_marks = struct();
    points_marks.name = 'data_points';
    points_marks.type = 'symbol';
    points_marks.from = struct('data', 'table');
    
    points_marks.encode = struct();
    points_marks.encode.enter = struct();
    points_marks.encode.enter.x = struct('scale', 'xscale', 'field', 'x');
    points_marks.encode.enter.y = struct('scale', 'yscale', 'field', 'y');
    points_marks.encode.enter.size = struct('value', 50);
    points_marks.encode.enter.stroke = struct('value', 'white');
    points_marks.encode.enter.strokeWidth = struct('value', 1);
    
    % Color encoding for points
    if analysis.grouping.hasColorGroup
        points_marks.encode.enter.fill = struct('scale', 'color', 'field', 'color');
    else
        points_marks.encode.enter.fill = struct('value', '#ff4565');
    end
    
    % Add tooltip for points
    points_marks = addTooltipToMark(points_marks, params, analysis);
    
    marks{end+1} = points_marks;
    
    layer.vegaSpec.marks = marks;
end

function layer = createStatBinLayer(analysis, params)
    % Create a stat_bin layer with histogram bars
    % This creates proper bar charts instead of scatter plots for histograms
    
    % Get bin data from analysis
    bin_data = analysis.stats.stat_bin;
    
    % Create base Vega specification for this layer
    layer = struct();
    layer.vegaSpec = createBaseVegaSpec();
    layer.vegaSpec.width = str2double(params.width);
    layer.vegaSpec.height = str2double(params.height);
    
    % Set up scales for histogram - custom scales needed for proper y-domain
    layer.vegaSpec.scales = createHistogramScales(analysis);
    
    % Set up axes
    layer.vegaSpec.axes = createVegaAxes(analysis, params);
    
    % Handle both single-group and multi-group bin data
    bin_vega_data = [];
    
    if iscell(bin_data)
        % Multi-group: process each group separately
        for g = 1:length(bin_data)
            group_bin = bin_data{g};
            for i = 1:length(group_bin.centers)
                data_point = struct();
                data_point.x = group_bin.centers(i);      % Bin center for x position
                data_point.count = group_bin.counts(i);   % Count for height
                data_point.group = group_bin.group;       % Group identifier
                
                % Calculate bin width from edges for proper bar width
                if i == 1
                    % First bin
                    bin_width = group_bin.edges(2) - group_bin.edges(1);
                else
                    % Use previous bin width (should be consistent)
                    bin_width = group_bin.edges(i+1) - group_bin.edges(i);
                end
                data_point.bin_width = bin_width;
                
                % Add bin boundaries for reference
                data_point.x_left = group_bin.edges(i);
                data_point.x_right = group_bin.edges(i+1);
                
                bin_vega_data = [bin_vega_data; data_point];
            end
        end
    else
        % Single group
        for i = 1:length(bin_data.centers)
            data_point = struct();
            data_point.x = bin_data.centers(i);      % Bin center for x position
            data_point.count = bin_data.counts(i);   % Count for height
            data_point.group = bin_data.group;       % Group identifier (always 1 for single)
            
            % Calculate bin width from edges for proper bar width
            if i == 1
                % First bin
                bin_width = bin_data.edges(2) - bin_data.edges(1);
            else
                % Use previous bin width (should be consistent)
                bin_width = bin_data.edges(i+1) - bin_data.edges(i);
            end
            data_point.bin_width = bin_width;
            
            % Add bin boundaries for reference
            data_point.x_left = bin_data.edges(i);
            data_point.x_right = bin_data.edges(i+1);
            
            bin_vega_data = [bin_vega_data; data_point];
        end
    end
    
    % Add bin data source
    bin_data_source = struct();
    bin_data_source.name = 'bins';
    bin_data_source.values = bin_vega_data;
    layer.vegaSpec.data{end+1} = bin_data_source;
    
    % Create histogram bars mark with multi-group support
    if iscell(bin_data) && length(bin_data) > 1
        % Multi-group: use grouped approach like other multi-group visualizations
        bars_mark = struct();
        bars_mark.name = 'histogram_bars';
        bars_mark.type = 'group';
        bars_mark.from = struct('facet', struct('name', 'bin_group_data', 'data', 'bins', 'groupby', 'group'));
        
        % Inner rect mark for each group
        inner_rect = struct();
        inner_rect.type = 'rect';
        inner_rect.from = struct('data', 'bin_group_data');
        
        inner_rect.encode = struct();
        inner_rect.encode.enter = struct();
        
        % Position bars using bin edges for precise alignment
        inner_rect.encode.enter.x = struct('scale', 'xscale', 'field', 'x_left');
        inner_rect.encode.enter.x2 = struct('scale', 'xscale', 'field', 'x_right');
        inner_rect.encode.enter.y = struct('scale', 'yscale', 'value', 0);      % Base at y=0
        inner_rect.encode.enter.y2 = struct('scale', 'yscale', 'field', 'count'); % Height from count
        
        % Multi-group bar styling with color scale
        inner_rect.encode.enter.fill = struct('scale', 'groupColor', 'field', 'group');
        inner_rect.encode.enter.stroke = struct('value', 'white');
        inner_rect.encode.enter.strokeWidth = struct('value', 1);
        
        % Add tooltip showing bin and group info
        inner_rect.encode.update = struct();
        inner_rect.encode.update.tooltip = struct('signal', ...
            "'Group: ' + datum.group + ', Bin: [' + format(datum.x_left, '.2f') + ', ' + format(datum.x_right, '.2f') + '], Count: ' + datum.count");
        
        bars_mark.marks = {inner_rect};
    else
        % Single group: use simple rect marks
        bars_mark = struct();
        bars_mark.name = 'histogram_bars';
        bars_mark.type = 'rect';
        bars_mark.from = struct('data', 'bins');
        
        bars_mark.encode = struct();
        bars_mark.encode.enter = struct();
        
        % Position bars using bin edges for precise alignment
        bars_mark.encode.enter.x = struct('scale', 'xscale', 'field', 'x_left');
        bars_mark.encode.enter.x2 = struct('scale', 'xscale', 'field', 'x_right');
        bars_mark.encode.enter.y = struct('scale', 'yscale', 'value', 0);      % Base at y=0
        bars_mark.encode.enter.y2 = struct('scale', 'yscale', 'field', 'count'); % Height from count
        
        % Single group bar styling
        bars_mark.encode.enter.fill = struct('value', '#fc4464');  % Red color like gramm default
        bars_mark.encode.enter.stroke = struct('value', 'white');
        bars_mark.encode.enter.strokeWidth = struct('value', 1);
        
        % Add tooltip showing bin info
        bars_mark.encode.update = struct();
        bars_mark.encode.update.tooltip = struct('signal', ...
            "'Bin: [' + format(datum.x_left, '.2f') + ', ' + format(datum.x_right, '.2f') + '], Count: ' + datum.count");
    end
    
    % Set up marks array with just the bars (no scatter points for histograms)
    marks = {bars_mark};
    
    layer.vegaSpec.marks = marks;
end

function layer = createStatSummaryLayer(analysis, params)
    % Create a stat_summary layer with line chart and confidence intervals
    % This creates line charts showing summary statistics per category with CI bands
    
    % Get summary data from analysis
    summary_data = analysis.stats.stat_summary;
    
    % Create base Vega specification for this layer
    layer = struct();
    layer.vegaSpec = createBaseVegaSpec();
    layer.vegaSpec.width = str2double(params.width);
    layer.vegaSpec.height = str2double(params.height);
    
    % Check if we have summary data
    if isempty(summary_data)
        layer.vegaSpec.data = {struct('name', 'table', 'values', [])};
        layer.vegaSpec.scales = createVegaScales(analysis);
        layer.vegaSpec.axes = createVegaAxes(analysis, params);
        layer.vegaSpec.marks = {};
        return;
    end
    
    % Prepare data sources for summary lines and confidence intervals
    line_data = [];
    ci_data = [];
    
    % Process each group's summary data
    for i = 1:length(summary_data)
        group_data = summary_data{i};
        group_id = group_data.group;
        
        % Map x values to categorical data - need to convert from numeric to categorical  
        % For stat_summary, x typically represents category indices (1,2,3...) 
        % but we need the actual category labels from the original data
        x_categories = analysis.aes.x;  % Get original categorical data
        unique_categories = unique(x_categories, 'stable');
        
        % Add line data points
        for j = 1:length(group_data.x)
            line_point = struct();
            x_index = group_data.x(j);
            if x_index <= length(unique_categories)
                line_point.x = unique_categories{x_index};  % Use category label instead of index
            else
                line_point.x = group_data.x(j);  % Fallback to numeric if can't map
            end
            line_point.y = group_data.y(j);
            line_point.group = group_id;
            line_data = [line_data; line_point];
        end
        
        % Add confidence interval data (area band)
        for j = 1:length(group_data.x)
            x_index = group_data.x(j);
            if x_index <= length(unique_categories)
                x_label = unique_categories{x_index};
            else
                x_label = group_data.x(j);
            end
            
            % Lower bound point
            ci_lower = struct();
            ci_lower.x = x_label;
            ci_lower.y = group_data.ci_lower(j);
            ci_lower.ci_type = 'lower';
            ci_lower.group = group_id;
            ci_data = [ci_data; ci_lower];
            
            % Upper bound point
            ci_upper = struct();
            ci_upper.x = x_label;
            ci_upper.y = group_data.ci_upper(j);
            ci_upper.ci_type = 'upper';
            ci_upper.group = group_id;
            ci_data = [ci_data; ci_upper];
        end
    end
    
    
    % Create data sources
    data_sources = {};
    
    % Main line data source
    line_datasource = struct();
    line_datasource.name = 'summary_lines';
    line_datasource.values = line_data;
    data_sources{end+1} = line_datasource;
    
    % Confidence interval data source with transforms
    ci_datasource = struct();
    ci_datasource.name = 'summary_ci';
    ci_datasource.values = ci_data;
    
    % Add pivot transform to create lower/upper fields and sorting
    ci_datasource.transform = {};
    ci_datasource.transform{end+1} = struct('type', 'pivot', 'field', 'ci_type', 'value', 'y', 'groupby', {{'x'}});
    ci_datasource.transform{end+1} = struct('type', 'collect', 'sort', struct('field', 'x', 'order', 'ascending'));
    
    data_sources{end+1} = ci_datasource;
    
    layer.vegaSpec.data = data_sources;
    
    % Create scales for summary chart with CI bounds included in y-domain
    scales = createVegaScales(analysis);
    
    % Update y-scale to include confidence interval bounds
    for i = 1:length(scales)
        if strcmp(scales{i}.name, 'yscale')
            % Replace y-scale domain to include CI data
            scales{i}.domain = struct();
            scales{i}.domain.fields = {};
            scales{i}.domain.fields{end+1} = struct('data', 'table', 'field', 'y');
            scales{i}.domain.fields{end+1} = struct('data', 'summary_ci', 'field', 'lower');
            scales{i}.domain.fields{end+1} = struct('data', 'summary_ci', 'field', 'upper');
            break;
        end
    end
    
    % Add color scale for groups if we have multiple groups
    if length(summary_data) > 1
        color_scale = struct();
        color_scale.name = 'color';
        color_scale.type = 'ordinal';
        color_scale.domain = struct('data', 'summary_lines', 'field', 'group');
        color_scale.range = {'#fc4464', '#08bc4d', '#04b0fc', '#ff9500', '#9b59b6', '#e74c3c', '#2ecc71', '#3498db'};
        scales{end+1} = color_scale;
    else
        % Single group: use fixed color
        color_scale = struct();
        color_scale.name = 'color';
        color_scale.type = 'ordinal';
        color_scale.domain = {1};
        color_scale.range = {'#fc4464'};
        scales{end+1} = color_scale;
    end
    
    layer.vegaSpec.scales = scales;
    
    % Create axes
    layer.vegaSpec.axes = createVegaAxes(analysis, params);
    
    % Create marks for line chart and confidence intervals
    marks = {};
    
    % 1. Confidence interval area (behind the line)
    ci_area = struct();
    ci_area.type = 'area';
    ci_area.from = struct('data', 'summary_ci');
    ci_area.encode = struct();
    ci_area.encode.update = struct();
    ci_area.encode.update.x = struct('scale', 'xscale', 'field', 'x', 'band', 0.5);
    ci_area.encode.update.y = struct('scale', 'yscale', 'field', 'lower');
    ci_area.encode.update.y2 = struct('scale', 'yscale', 'field', 'upper');
    ci_area.encode.update.fill = struct('value', '#fc4464');
    ci_area.encode.update.fillOpacity = struct('value', 0.2);
    ci_area.zindex = 0;
    
    marks{end+1} = ci_area;
    
    % 2. Summary line (on top of confidence interval)
    line_mark = struct();
    line_mark.type = 'line';
    line_mark.from = struct('data', 'summary_lines');
    line_mark.encode = struct();
    line_mark.encode.update = struct();
    line_mark.encode.update.x = struct('scale', 'xscale', 'field', 'x', 'band', 0.5);
    line_mark.encode.update.y = struct('scale', 'yscale', 'field', 'y');
    line_mark.encode.update.stroke = struct('scale', 'color', 'field', 'group');
    line_mark.encode.update.strokeWidth = struct('value', 2);
    line_mark.encode.update.tooltip = struct('signal', '''Categories: '' + datum.x + '', Values: '' + format(datum.y, ''.3f'')');
    line_mark.zindex = 1;
    
    marks{end+1} = line_mark;
    
    
    layer.vegaSpec.marks = marks;
end

function layer = createStatBoxplotLayer(analysis, params)
    % Create a stat_boxplot layer with box and whisker plots
    % Uses boxplot_data from results.stat_boxplot which contains the 5-number summary
    
    % Get boxplot data from analysis
    boxplot_data = analysis.stats.stat_boxplot;
    
    % Create base Vega specification for this layer
    layer = struct();
    layer.vegaSpec = createBaseVegaSpec();
    layer.vegaSpec.width = str2double(params.width);
    layer.vegaSpec.height = str2double(params.height);
    
    % Check if we have boxplot data
    if isempty(boxplot_data)
        layer.vegaSpec.data = {struct('name', 'table', 'values', [])};
        layer.vegaSpec.scales = createVegaScales(analysis);
        layer.vegaSpec.axes = createVegaAxes(analysis, params);
        layer.vegaSpec.marks = {};
        return;
    end
    
    % Prepare data sources for boxplot components
    box_data = [];
    whisker_data = [];
    median_data = [];
    
    % Get original categorical data for mapping
    x_categories = analysis.aes.x;
    unique_categories = unique(x_categories, 'stable');
    
    % Process each category's boxplot data
    for i = 1:length(boxplot_data)
        category_stats = boxplot_data{i};
        category_index = category_stats.category;
        
        % Map category index to label
        if category_index <= length(unique_categories)
            category_label = unique_categories{category_index};
        else
            category_label = sprintf('Category%d', category_index);
        end
        
        % Create box data (rectangle for IQR)
        box_entry = struct();
        box_entry.x = category_label;
        box_entry.q1 = category_stats.q1;
        box_entry.q3 = category_stats.q3;
        box_entry.category = category_index;
        box_data = [box_data; box_entry];
        
        % Create whisker data (lines from box to whiskers)
        % Lower whisker
        whisker_lower = struct();
        whisker_lower.x = category_label;
        whisker_lower.y_start = category_stats.q1;
        whisker_lower.y_end = category_stats.whisker_low;
        whisker_lower.type = 'lower';
        whisker_lower.category = category_index;
        whisker_data = [whisker_data; whisker_lower];
        
        % Upper whisker
        whisker_upper = struct();
        whisker_upper.x = category_label;
        whisker_upper.y_start = category_stats.q3;
        whisker_upper.y_end = category_stats.whisker_high;
        whisker_upper.type = 'upper';
        whisker_upper.category = category_index;
        whisker_data = [whisker_data; whisker_upper];
        
        % Create median data (line across the box)
        median_entry = struct();
        median_entry.x = category_label;
        median_entry.median = category_stats.median;
        median_entry.category = category_index;
        median_data = [median_data; median_entry];
    end
    
    
    % Create data sources
    data_sources = {};
    
    % Box data source (for rectangles)
    box_datasource = struct();
    box_datasource.name = 'boxplot_boxes';
    box_datasource.values = box_data;
    data_sources{end+1} = box_datasource;
    
    % Whisker data source (for lines)
    whisker_datasource = struct();
    whisker_datasource.name = 'boxplot_whiskers';
    whisker_datasource.values = whisker_data;
    data_sources{end+1} = whisker_datasource;
    
    % Median data source (for median lines)
    median_datasource = struct();
    median_datasource.name = 'boxplot_medians';
    median_datasource.values = median_data;
    data_sources{end+1} = median_datasource;
    
    layer.vegaSpec.data = data_sources;
    
    % Create scales for boxplot
    scales = createVegaScales(analysis);
    
    % Update y-scale to include boxplot bounds
    for i = 1:length(scales)
        if strcmp(scales{i}.name, 'yscale')
            % Replace y-scale domain to include all boxplot components
            scales{i}.domain = struct();
            scales{i}.domain.fields = {};
            scales{i}.domain.fields{end+1} = struct('data', 'table', 'field', 'y');
            scales{i}.domain.fields{end+1} = struct('data', 'boxplot_boxes', 'field', 'q1');
            scales{i}.domain.fields{end+1} = struct('data', 'boxplot_boxes', 'field', 'q3');
            scales{i}.domain.fields{end+1} = struct('data', 'boxplot_whiskers', 'field', 'y_start');
            scales{i}.domain.fields{end+1} = struct('data', 'boxplot_whiskers', 'field', 'y_end');
            scales{i}.domain.fields{end+1} = struct('data', 'boxplot_medians', 'field', 'median');
            break;
        end
    end
    
    % Add color scale
    color_scale = struct();
    color_scale.name = 'color';
    color_scale.type = 'ordinal';
    color_scale.domain = struct('data', 'boxplot_boxes', 'field', 'category');
    color_scale.range = {'#fc4464', '#08bc4d', '#04b0fc', '#ff9500', '#9b59b6', '#e74c3c', '#2ecc71', '#3498db'};
    scales{end+1} = color_scale;
    
    layer.vegaSpec.scales = scales;
    
    % Create axes
    layer.vegaSpec.axes = createVegaAxes(analysis, params);
    
    % Create marks for boxplot components
    marks = {};
    
    % 1. Box rectangles (IQR)
    box_mark = struct();
    box_mark.type = 'rect';
    box_mark.from = struct('data', 'boxplot_boxes');
    box_mark.encode = struct();
    box_mark.encode.update = struct();
    box_mark.encode.update.x = struct('scale', 'xscale', 'field', 'x', 'band', 0.5, 'offset', -15);  % Center box by offsetting half width
    box_mark.encode.update.width = struct('value', 30);  % Fixed width for boxes
    box_mark.encode.update.y = struct('scale', 'yscale', 'field', 'q3');
    box_mark.encode.update.y2 = struct('scale', 'yscale', 'field', 'q1');
    box_mark.encode.update.fill = struct('scale', 'color', 'field', 'category');
    box_mark.encode.update.fillOpacity = struct('value', 0.7);
    box_mark.encode.update.stroke = struct('value', '#333');
    box_mark.encode.update.strokeWidth = struct('value', 1);
    box_mark.zindex = 1;
    
    marks{end+1} = box_mark;
    
    % 2. Whisker lines
    whisker_mark = struct();
    whisker_mark.type = 'rule';
    whisker_mark.from = struct('data', 'boxplot_whiskers');
    whisker_mark.encode = struct();
    whisker_mark.encode.update = struct();
    whisker_mark.encode.update.x = struct('scale', 'xscale', 'field', 'x', 'band', 0.5);
    whisker_mark.encode.update.y = struct('scale', 'yscale', 'field', 'y_start');
    whisker_mark.encode.update.y2 = struct('scale', 'yscale', 'field', 'y_end');
    whisker_mark.encode.update.stroke = struct('value', '#333');
    whisker_mark.encode.update.strokeWidth = struct('value', 1);
    whisker_mark.zindex = 0;
    
    marks{end+1} = whisker_mark;
    
    % 3. Median lines
    median_mark = struct();
    median_mark.type = 'rule';
    median_mark.from = struct('data', 'boxplot_medians');
    median_mark.encode = struct();
    median_mark.encode.update = struct();
    median_mark.encode.update.x = struct('scale', 'xscale', 'field', 'x', 'band', 0.5, 'offset', -15);  % Start at left edge of box
    median_mark.encode.update.y = struct('scale', 'yscale', 'field', 'median');
    median_mark.encode.update.x2 = struct('scale', 'xscale', 'field', 'x', 'band', 0.5, 'offset', 15);  % End at right edge of box
    median_mark.encode.update.stroke = struct('value', '#000');
    median_mark.encode.update.strokeWidth = struct('value', 2);
    median_mark.encode.update.tooltip = struct('signal', '''Category: '' + datum.x + '', Median: '' + format(datum.median, ''.3f'')');
    median_mark.zindex = 2;
    
    marks{end+1} = median_mark;
    
    
    layer.vegaSpec.marks = marks;
end

function layer = createStatDensityLayer(analysis, params)
    % Create a stat_density layer with kernel density estimation curves
    % This creates line charts showing density curves for each group
    
    % Get density data from analysis
    density_data = analysis.stats.stat_density;
    
    % Create base Vega specification for this layer
    layer = struct();
    layer.vegaSpec = createBaseVegaSpec();
    layer.vegaSpec.width = str2double(params.width);
    layer.vegaSpec.height = str2double(params.height);
    
    % Check if we have density data
    if isempty(density_data)
        layer.vegaSpec.data = {struct('name', 'table', 'values', [])};
        layer.vegaSpec.scales = createVegaScales(analysis);
        layer.vegaSpec.axes = createVegaAxes(analysis, params);
        layer.vegaSpec.marks = {};
        return;
    end
    
    % Convert density data to Vega format with proper group mapping
    density_vega_data = [];
    
    % Get unique group labels from analysis.aes.color for proper mapping
    if analysis.grouping.hasColorGroup && isfield(analysis, 'aes') && isfield(analysis.aes, 'color')
        unique_groups = unique(analysis.aes.color, 'stable');
    else
        unique_groups = {};
    end
    
    for i = 1:length(density_data)
        entry = density_data{i};
        
        % Map numeric group ID to actual group label
        if ~isempty(unique_groups) && entry.group <= length(unique_groups)
            group_label = unique_groups{entry.group};
        else
            group_label = entry.group;  % Fallback to numeric if mapping fails
        end
        
        for j = 1:length(entry.x)
            data_point = struct();
            data_point.x = entry.x(j);      % Density evaluation point
            data_point.y = entry.y(j);      % Density value (PDF)
            data_point.group = group_label; % Mapped group identifier
            
            density_vega_data = [density_vega_data; data_point];
        end
        
    end
    
    % Add density data source
    density_data_source = struct();
    density_data_source.name = 'density';
    density_data_source.values = density_vega_data;
    layer.vegaSpec.data = {density_data_source};
    
    % Create scales optimized for density plots
    scales = {};
    
    % X scale - continuous, covers the range of evaluation points
    xscale = struct();
    xscale.name = 'xscale';
    xscale.type = 'linear';
    xscale.domain = struct('data', 'density', 'field', 'x');
    xscale.range = 'width';
    xscale.nice = true;
    scales{end+1} = xscale;
    
    % Y scale - continuous, covers the range of density values
    yscale = struct();
    yscale.name = 'yscale';
    yscale.type = 'linear';
    yscale.domain = struct('data', 'density', 'field', 'y');
    yscale.range = 'height';
    yscale.nice = true;
    yscale.zero = true;  % Start from 0 for density plots
    scales{end+1} = yscale;
    
    % Add group color scale if multiple groups
    if length(density_data) > 1 || analysis.grouping.hasColorGroup
        groupScale = struct();
        groupScale.name = 'groupColor';
        groupScale.type = 'ordinal';
        % Use the same domain as the main color scale to ensure consistent mapping
        groupScale.domain = struct('data', 'table', 'field', 'color');
        groupScale.range = {'#fc4464', '#08bc4d', '#04b0fc', '#ff9500', '#9b59b6', '#e74c3c', '#2ecc71', '#3498db'};
        scales{end+1} = groupScale;
    end
    
    layer.vegaSpec.scales = scales;
    
    % Set up axes
    layer.vegaSpec.axes = createVegaAxes(analysis, params);
    
    % Create density curve marks
    marks = {};
    
    if length(density_data) > 1 || analysis.grouping.hasColorGroup
        % Multiple groups - use faceted approach for separate density curves
        density_marks = struct();
        density_marks.name = 'density_curves';
        density_marks.type = 'group';
        density_marks.from = struct('facet', struct('name', 'group_data', 'data', 'density', 'groupby', 'group'));
        
        % Inner line mark for each group's density curve
        inner_line = struct();
        inner_line.type = 'line';
        inner_line.from = struct('data', 'group_data');
        inner_line.sort = struct('field', 'x');  % Sort by x for proper line rendering
        
        inner_line.encode = struct();
        inner_line.encode.enter = struct();
        inner_line.encode.enter.x = struct('scale', 'xscale', 'field', 'x');
        inner_line.encode.enter.y = struct('scale', 'yscale', 'field', 'y');
        inner_line.encode.enter.strokeWidth = struct('value', 2);
        inner_line.encode.enter.stroke = struct('scale', 'groupColor', 'field', 'group');
        inner_line.encode.enter.fill = struct('value', 'transparent');
        
        % Add tooltip showing density information
        inner_line.encode.update = struct();
        inner_line.encode.update.tooltip = struct('signal', ...
            "'Group: ' + datum.group + ', Value: ' + format(datum.x, '.3f') + ', Density: ' + format(datum.y, '.6f')");
        
        density_marks.marks = {inner_line};
    else
        % Single group - simple line
        density_marks = struct();
        density_marks.name = 'density_curve';
        density_marks.type = 'line';
        density_marks.from = struct('data', 'density');
        density_marks.sort = struct('field', 'x');
        
        density_marks.encode = struct();
        density_marks.encode.enter = struct();
        density_marks.encode.enter.x = struct('scale', 'xscale', 'field', 'x');
        density_marks.encode.enter.y = struct('scale', 'yscale', 'field', 'y');
        density_marks.encode.enter.strokeWidth = struct('value', 2);
        density_marks.encode.enter.stroke = struct('value', '#fc4464');
        density_marks.encode.enter.fill = struct('value', 'transparent');
        
        % Add tooltip
        density_marks.encode.update = struct();
        density_marks.encode.update.tooltip = struct('signal', ...
            "'Value: ' + format(datum.x, '.3f') + ', Density: ' + format(datum.y, '.6f')");
    end
    
    marks{end+1} = density_marks;
    
    
    layer.vegaSpec.marks = marks;
end

function layer = createStatViolinLayer(analysis, params)
    % Create a stat_violin layer with violin plots showing density distribution
    % This creates area charts showing density curves mirrored on both sides
    
    layer = struct();
    layer.isVegaChart = true;
    
    % Get violin data from analysis
    if ~isfield(analysis, 'stats') || ~isfield(analysis.stats, 'stat_violin')
        layer.marks = {struct('type', 'symbol', 'from', struct('data', 'table'))};
        return;
    end
    
    violin_data = analysis.stats.stat_violin;
    
    % Create violin data table for Vega
    vega_violin_data = [];
    
    % Get category labels from analysis (similar to density implementation)
    if analysis.grouping.hasColorGroup && isfield(analysis, 'aes') && isfield(analysis.aes, 'color')
        unique_groups = unique(analysis.aes.color, 'stable');
    else
        unique_groups = {};
    end
    
    for i = 1:length(violin_data)
        entry = violin_data{i};
        x_density = entry.x_density(:);      % Density values (width from center)
        y_values = entry.y_values(:);        % Y positions
        
        % Map category index to actual category label
        if ~isempty(unique_groups) && entry.category_index <= length(unique_groups)
            category_label = unique_groups{entry.category_index};
        else
            category_label = sprintf('Category_%d', entry.category_index);
        end
        
        
        % Create violin shape data (mirror density on both sides)
        for j = 1:length(y_values)
            % Normalize density to a reasonable width (e.g., max 0.4 band width)
            normalized_density = x_density(j) / max(x_density) * 0.4;
            
            % Left side of violin (negative density)
            left_point = struct();
            left_point.category = category_label;
            left_point.y = y_values(j);
            left_point.x_offset = -normalized_density;
            left_point.density = x_density(j);
            left_point.group = entry.group;
            vega_violin_data = [vega_violin_data; left_point];
            
            % Right side of violin (positive density) 
            right_point = struct();
            right_point.category = category_label;
            right_point.y = y_values(j);
            right_point.x_offset = normalized_density;
            right_point.density = x_density(j);
            right_point.group = entry.group;
            vega_violin_data = [vega_violin_data; right_point];
        end
    end
    
    % Create violin marks using area
    violin_mark = struct();
    violin_mark.name = 'violin_plots';
    violin_mark.type = 'group';
    violin_mark.from = struct('facet', struct('name', 'violin_category', 'data', 'violin', 'groupby', 'category'));
    
    % Create area mark for each violin
    area_mark = struct();
    area_mark.type = 'area';
    area_mark.from = struct('data', 'violin_category');
    area_mark.sort = struct('field', 'y');
    
    % Encoding for violin shape
    area_encoding = struct();
    area_encoding.enter = struct();
    area_encoding.enter.x = struct('scale', 'xscale', 'field', 'category', 'band', 0.5);
    area_encoding.enter.x.offset = struct('field', 'x_offset', 'scale', 'violin_width');
    area_encoding.enter.y = struct('scale', 'yscale', 'field', 'y');
    area_encoding.enter.fill = struct('value', '#ff4565');
    area_encoding.enter.fillOpacity = struct('value', 0.7);
    area_encoding.enter.stroke = struct('value', '#ff4565');
    area_encoding.enter.strokeWidth = struct('value', 1);
    
    area_encoding.update = struct();
    area_encoding.update.tooltip = struct('signal', ...
        '''Category: '' + datum.category + '', Y: '' + format(datum.y, ''.3f'') + '', Density: '' + format(datum.density, ''.6f'')');
    
    area_mark.encode = area_encoding;
    violin_mark.marks = {area_mark};
    
    % Initialize vegaSpec structure to match other stat layers
    layer.vegaSpec = struct();
    layer.vegaSpec.data = {struct('name', 'violin', 'values', vega_violin_data)};
    layer.vegaSpec.marks = {violin_mark};
    
    % Create scales for violin plots
    scales = {};
    
    % X scale - band scale for categories
    xscale = struct();
    xscale.name = 'xscale';
    xscale.type = 'band';
    xscale.domain = struct('data', 'violin', 'field', 'category', 'sort', true);
    xscale.padding = 0.1;
    xscale.range = 'width';
    scales{end+1} = xscale;
    
    % Y scale - continuous for violin data values
    yscale = struct();
    yscale.name = 'yscale';
    yscale.type = 'linear';
    yscale.domain = struct('data', 'violin', 'field', 'y');
    yscale.range = 'height';
    yscale.nice = true;
    yscale.zero = true;
    scales{end+1} = yscale;
    
    % Custom scale for violin width
    violin_width_scale = struct();
    violin_width_scale.name = 'violin_width';
    violin_width_scale.type = 'linear';
    violin_width_scale.domain = {-0.4, 0.4};
    violin_width_scale.range = {-50, 50};  % Pixel offset range
    scales{end+1} = violin_width_scale;
    
    layer.vegaSpec.scales = scales;
    
    % Set up axes
    layer.vegaSpec.axes = createVegaAxes(analysis, params);
    
end

function layer = createStatQqLayer(analysis, params)
    % Create a stat_qq layer with Q-Q plots showing quantile comparison
    % This creates scatter plots comparing theoretical vs sample quantiles
    
    layer = struct();
    layer.isVegaChart = true;
    
    % Get QQ data from analysis
    if ~isfield(analysis, 'stats') || ~isfield(analysis.stats, 'stat_qq')
        layer.marks = {struct('type', 'symbol', 'from', struct('data', 'table'))};
        return;
    end
    
    qq_data = analysis.stats.stat_qq;
    
    % Create QQ data table for Vega
    vega_qq_data = [];
    
    % Get group labels from analysis (similar to other stat implementations)
    if analysis.grouping.hasColorGroup && isfield(analysis, 'aes') && isfield(analysis.aes, 'color')
        unique_groups = unique(analysis.aes.color, 'stable');
    else
        unique_groups = {};
    end
    
    for i = 1:length(qq_data)
        entry = qq_data{i};
        x_theoretical = entry.x_theoretical(:);  % Theoretical quantiles
        y_sample = entry.y_sample(:);            % Sample quantiles
        
        % Map group index to actual group label
        if ~isempty(unique_groups) && entry.group <= length(unique_groups)
            group_label = unique_groups{entry.group};
        else
            group_label = sprintf('Group_%d', entry.group);
        end
        
        
        % Create QQ scatter plot data
        for j = 1:length(y_sample)
            data_point = struct();
            data_point.x = x_theoretical(j);
            data_point.y = y_sample(j);
            data_point.color = group_label;
            data_point.group = entry.group;
            vega_qq_data = [vega_qq_data; data_point];
        end
    end
    
    % Initialize vegaSpec structure to match other stat layers
    layer.vegaSpec = struct();
    layer.vegaSpec.data = {struct('name', 'qq', 'values', vega_qq_data)};
    
    % Create scales for QQ plots
    scales = {};
    
    % X scale - continuous for theoretical quantiles
    xscale = struct();
    xscale.name = 'xscale';
    xscale.type = 'linear';
    xscale.domain = struct('data', 'qq', 'field', 'x');
    xscale.range = 'width';
    xscale.nice = true;
    scales{end+1} = xscale;
    
    % Y scale - continuous for sample quantiles
    yscale = struct();
    yscale.name = 'yscale';
    yscale.type = 'linear';
    yscale.domain = struct('data', 'qq', 'field', 'y');
    yscale.range = 'height';
    yscale.nice = true;
    scales{end+1} = yscale;
    
    % Color scale for groups
    if analysis.grouping.hasColorGroup
        color_scale = struct();
        color_scale.name = 'color';
        color_scale.type = 'ordinal';
        color_scale.domain = struct('data', 'qq', 'field', 'color');
        color_scale.range = {'#fc4464', '#08bc4d', '#04b0fc', '#ff9500', '#9b59b6', '#e74c3c', '#2ecc71', '#3498db'};
        scales{end+1} = color_scale;
    end
    
    layer.vegaSpec.scales = scales;
    
    % Set up axes
    layer.vegaSpec.axes = createVegaAxes(analysis, params);
    
    % Create QQ scatter plot marks
    qq_mark = struct();
    qq_mark.name = 'qq_points';
    qq_mark.type = 'symbol';
    qq_mark.from = struct('data', 'qq');
    
    % Encoding for QQ scatter plot
    qq_encoding = struct();
    qq_encoding.enter = struct();
    qq_encoding.enter.x = struct('scale', 'xscale', 'field', 'x');
    qq_encoding.enter.y = struct('scale', 'yscale', 'field', 'y');
    qq_encoding.enter.size = struct('value', 60);
    qq_encoding.enter.stroke = struct('value', 'white');
    qq_encoding.enter.strokeWidth = struct('value', 1);
    
    if analysis.grouping.hasColorGroup
        qq_encoding.enter.fill = struct('scale', 'color', 'field', 'color');
    else
        qq_encoding.enter.fill = struct('value', '#fc4464');
    end
    
    qq_encoding.update = struct();
    qq_encoding.update.tooltip = struct('signal', ...
        '''Theoretical: '' + format(datum.x, ''.3f'') + '', Sample: '' + format(datum.y, ''.3f'') + '', Group: '' + datum.color');
    
    qq_mark.encode = qq_encoding;
    
    layer.vegaSpec.marks = {qq_mark};
    
end

function scales = createHistogramScales(analysis)
    % Create custom scales for histograms with proper y-domain from count data
    % This ensures the y-axis shows the actual count range instead of 0-1
    
    scales = {};
    bin_data = analysis.stats.stat_bin;
    
    % Handle both single-group and multi-group data
    if iscell(bin_data)
        % Multi-group: get ranges from all groups
        all_edges = [];
        all_counts = [];
        
        for g = 1:length(bin_data)
            group_bin = bin_data{g};
            all_edges = [all_edges, group_bin.edges];
            all_counts = [all_counts; group_bin.counts];
        end
        
        x_min = min(all_edges);
        x_max = max(all_edges);
        y_max = max(all_counts);
        
    else
        % Single group
        x_min = min(bin_data.edges);
        x_max = max(bin_data.edges);
        y_max = max(bin_data.counts);
        
    end
    
    % X-scale: use bin edges range
    xscale = struct();
    xscale.name = 'xscale';
    xscale.type = 'linear';
    xscale.domain = [x_min, x_max];
    xscale.range = 'width';
    scales{end+1} = xscale;
    
    % Y-scale: use count range from bins data
    yscale = struct();
    yscale.name = 'yscale';
    yscale.type = 'linear';
    yscale.domain = [0, y_max];  % Always start from 0 for histograms
    yscale.range = 'height';
    yscale.nice = true;
    yscale.zero = true;
    scales{end+1} = yscale;
    
    % Add groupColor scale for multi-group histograms
    if iscell(bin_data) && length(bin_data) > 1
        groupScale = struct();
        groupScale.name = 'groupColor';
        groupScale.type = 'ordinal';
        groupScale.domain = struct('data', 'bins', 'field', 'group');
        groupScale.range = {'#fc4464', '#08bc4d', '#04b0fc', '#ff9500', '#9b59b6', '#e74c3c', '#2ecc71', '#3498db'};
        scales{end+1} = groupScale;
        
    end
end

%% ===== VEGA HELPER FUNCTIONS =====

function baseSpec = createBaseVegaSpec()
    baseSpec = struct();
    baseSpec.schema = 'https://vega.github.io/schema/vega/v6.json';
    baseSpec.width = 600;
    baseSpec.height = 400;
    baseSpec.padding = struct('left', 60, 'right', 20, 'top', 20, 'bottom', 60);
    baseSpec.autosize = 'none';
    baseSpec.data = {struct('name', 'table')};
end

function scales = createVegaScales(analysis, forceBandScale, dataSource)
    if nargin < 2
        forceBandScale = false;
    end
    if nargin < 3
        dataSource = 'table';  % Default to 'table' for backward compatibility
    end
    
    scales = {};
    
    % X scale
    xscale = struct();
    xscale.name = 'xscale';
    if forceBandScale || ~isnumeric(analysis.data.x)
        xscale.type = 'band';
        xscale.domain = struct('data', dataSource, 'field', 'x', 'sort', true);
        xscale.padding = 0.1;
    else
        xscale.type = 'linear';
        xscale.domain = struct('data', dataSource, 'field', 'x');
    end
    xscale.range = 'width';
    scales{end+1} = xscale;
    
    % Y scale
    yscale = struct();
    yscale.name = 'yscale';
    if isnumeric(analysis.data.y)
        yscale.type = 'linear';
        yscale.domain = struct('data', dataSource, 'field', 'y');
    else
        yscale.type = 'band';
        yscale.domain = struct('data', dataSource, 'field', 'y', 'sort', true);
        yscale.padding = 0.1;
    end
    yscale.range = 'height';
    yscale.nice = true;
    yscale.zero = true;
    scales{end+1} = yscale;
    
    % Color scale if grouping exists
    if analysis.grouping.hasColorGroup
        colorscale = struct();
        colorscale.name = 'color';
        colorscale.type = 'ordinal';
        colorscale.domain = struct('data', dataSource, 'field', 'color');
        colorscale.range = {'#fc4464', '#08bc4d', '#04b0fc', '#ff9500', '#9b59b6', '#e74c3c', '#2ecc71', '#3498db'};
        scales{end+1} = colorscale;
    end
end

function axes = createVegaAxes(analysis, params)
    axes = {};
    
    % X axis
    xaxis = struct();
    xaxis.orient = 'bottom';
    xaxis.scale = 'xscale';
    xaxis.title = params.x_label;
    axes{end+1} = xaxis;
    
    % Y axis
    yaxis = struct();
    yaxis.orient = 'left';
    yaxis.scale = 'yscale';
    yaxis.title = params.y_label;
    axes{end+1} = yaxis;
end

%% ===== ENCODING HELPERS =====

function mark = addTooltipToMark(mark, params, analysis)
    % Add tooltip encoding to a mark if tooltips are enabled
    if ~strcmpi(params.tooltip, 'true')
        return; % Skip if tooltips are disabled
    end
    
    % Ensure mark has update encoding section
    if ~isfield(mark, 'encode')
        mark.encode = struct();
    end
    if ~isfield(mark.encode, 'update')
        mark.encode.update = struct();
    end
    
    % Build tooltip signal expression following tooltip.json pattern
    if analysis.grouping.hasColorGroup
        tooltip_signal = sprintf('''%s: '' + (isNumber(datum.x) ? format(datum.x, ''.3f'') : datum.x) + '', %s: '' + (isNumber(datum.y) ? format(datum.y, ''.3f'') : datum.y) + '', Color: '' + datum.color', ...
                                params.x_label, params.y_label);
    else
        tooltip_signal = sprintf('''%s: '' + (isNumber(datum.x) ? format(datum.x, ''.3f'') : datum.x) + '', %s: '' + (isNumber(datum.y) ? format(datum.y, ''.3f'') : datum.y)', ...
                                params.x_label, params.y_label);
    end
    
    % Add tooltip to update encoding
    mark.encode.update.tooltip = struct('signal', tooltip_signal);
end

function encoding = createBasicEncoding(analysis)
    encoding = struct();
    
    % X encoding
    encoding.x = struct();
    encoding.x.field = 'x';
    if isnumeric(analysis.data.x)
        encoding.x.type = 'quantitative';
    else
        encoding.x.type = 'nominal';
    end
    
    % Y encoding
    encoding.y = struct();
    encoding.y.field = 'y';
    if isnumeric(analysis.data.y)
        encoding.y.type = 'quantitative';
    else
        encoding.y.type = 'nominal';
    end
end

function color_encoding = createColorEncoding(grouping)
    color_encoding = struct();
    color_encoding.field = 'color';
    color_encoding.type = 'nominal';
    
    % Create color scale based on actual data
    color_encoding.scale = struct();
    
    % Get unique color values and convert to strings
    if isnumeric(grouping.colorData)
        unique_colors = unique(grouping.colorData);
        color_encoding.scale.domain = arrayfun(@num2str, unique_colors, 'UniformOutput', false);
    else
        unique_colors = unique(grouping.colorData);
        color_encoding.scale.domain = cellstr(unique_colors);
    end
    
    % Default color palette - extend if needed
    default_colors = {'#fc4464', '#08bc4d', '#04b0fc', '#ff9500', '#9b59b6', '#e74c3c', '#2ecc71', '#3498db'};
    num_colors = length(color_encoding.scale.domain);
    color_encoding.scale.range = default_colors(1:min(num_colors, length(default_colors)));
end

%% ===== DATA PROCESSING =====

function vega_data = extractVegaData(analysis)
    x = analysis.data.x;
    y = analysis.data.y;
    colorData = analysis.grouping.colorData;
    hasColorGroup = analysis.grouping.hasColorGroup;
    
    % Handle different data types and clean data
    [x, y, colorData] = cleanAndProcessData(x, y, colorData, hasColorGroup);
    
    % Convert to Vega data format
    vega_data = [];
    for i = 1:length(x)
        dataPoint = struct();
        
        % Handle x values
        if isnumeric(x(i))
            dataPoint.x = x(i);
        else
            dataPoint.x = char(x(i));
        end
        
        % Handle y values
        if isnumeric(y(i))
            dataPoint.y = y(i);
        else
            dataPoint.y = char(y(i));
        end
        
        % Handle color grouping
        if hasColorGroup
            if isnumeric(colorData(i))
                dataPoint.color = num2str(colorData(i));
            else
                dataPoint.color = char(colorData(i));
            end
        end
        
        vega_data = [vega_data; dataPoint];
    end
end

function [x_clean, y_clean, color_clean] = cleanAndProcessData(x, y, colorData, hasColorGroup)
    % Handle different data types
    
    % Convert cell arrays to numeric if they contain numeric data
    if iscell(x) && all(cellfun(@isnumeric, x))
        x = cell2mat(x);
    end
    if iscell(y) && all(cellfun(@isnumeric, y))
        y = cell2mat(y);
    end
    
    if isnumeric(x) && isnumeric(y)
        % Remove NaN and infinite values for numeric data
        validIndices = ~isnan(x) & ~isnan(y) & isfinite(x) & isfinite(y);
        
        % Check if any data was filtered out and warn user
        originalCount = length(x);
        filteredCount = sum(validIndices);
        if filteredCount < originalCount
            warning('gramm:VegaExport:InvalidData', ...
                'Removed %d data points containing NaN or infinite values (%d remaining)', ...
                originalCount - filteredCount, filteredCount);
        end
        
        x_clean = x(validIndices);
        y_clean = y(validIndices);
        if hasColorGroup
            color_clean = colorData(validIndices);
        else
            color_clean = colorData;
        end
    else
        % Convert non-numeric data to strings
        if ~isnumeric(x)
            x = string(x);
        end
        if ~isnumeric(y)
            y = string(y);
        end
        
        % Remove missing values
        validIndices = ~ismissing(x) & ~ismissing(y);
        x_clean = x(validIndices);
        y_clean = y(validIndices);
        if hasColorGroup
            color_clean = colorData(validIndices);
        else
            color_clean = colorData;
        end
    end
end

%% ===== VEGA SPECIFICATION GENERATION =====

function vega_spec = generateVegaSpecification(chart_spec, vega_data, params)
    % All chart layers now use Vega format
    if isempty(chart_spec.layers)
        error('No chart layers found');
    end
    
    % Use the first layer's Vega specification as base
    vega_spec = chart_spec.layers{1}.vegaSpec;
    
    % Update dimensions from params
    vega_spec.width = str2double(params.width);
    vega_spec.height = str2double(params.height);
    
    % Set up main data table with raw data points
    % First ensure we have a "table" data source for the main data
    table_data_index = -1;
    for i = 1:length(vega_spec.data)
        if strcmp(vega_spec.data{i}.name, 'table')
            table_data_index = i;
            break;
        end
    end
    
    if table_data_index == -1
        % No table data source exists, add it at the beginning
        table_data_source = struct('name', 'table', 'values', vega_data);
        vega_spec.data = [{table_data_source}, vega_spec.data];
    else
        % Table data source exists, update its values
        vega_spec.data{table_data_index}.values = vega_data;
    end
    
    % Add title if specified
    if ~strcmp(params.title, 'Untitled')
        vega_spec.title = params.title;
    end
    
    % Update axis titles
    for i = 1:length(vega_spec.axes)
        if strcmp(vega_spec.axes{i}.orient, 'bottom')
            vega_spec.axes{i}.title = params.x_label;
        elseif strcmp(vega_spec.axes{i}.orient, 'left')
            vega_spec.axes{i}.title = params.y_label;
        end
    end
    
    % Handle multi-layer visualizations by combining marks, scales, and data sources
    if length(chart_spec.layers) > 1
        combined_marks = {};
        combined_scales = {};
        combined_data = {vega_spec.data{1}};  % Start with main table data
        
        for i = 1:length(chart_spec.layers)
            layer_spec = chart_spec.layers{i}.vegaSpec;
            
            % Combine marks from all layers
            if isfield(layer_spec, 'marks')
                for j = 1:length(layer_spec.marks)
                    combined_marks{end+1} = layer_spec.marks{j};
                end
            end
            
            % Combine scales (avoiding duplicates)
            if isfield(layer_spec, 'scales')
                for j = 1:length(layer_spec.scales)
                    scale_name = layer_spec.scales{j}.name;
                    exists = false;
                    for k = 1:length(combined_scales)
                        if strcmp(combined_scales{k}.name, scale_name)
                            exists = true;
                            break;
                        end
                    end
                    if ~exists
                        combined_scales{end+1} = layer_spec.scales{j};
                    end
                end
            end
            
            % Combine data sources (avoiding duplicates and main table)
            if isfield(layer_spec, 'data')
                for j = 1:length(layer_spec.data)
                    data_name = layer_spec.data{j}.name;
                    % Skip main table data (already added)
                    if strcmp(data_name, 'table')
                        continue;
                    end
                    
                    % Check if this data source already exists
                    exists = false;
                    for k = 1:length(combined_data)
                        if strcmp(combined_data{k}.name, data_name)
                            exists = true;
                            break;
                        end
                    end
                    if ~exists
                        combined_data{end+1} = layer_spec.data{j};
                    end
                end
            end
        end
        
        vega_spec.marks = combined_marks;
        vega_spec.scales = combined_scales;
        vega_spec.data = combined_data;
    end
    
    % Add legend if color scale exists (multiple colors in data)
    vega_spec = addLegendIfNeeded(vega_spec, vega_data, params);
    
    % Store flag to indicate this is a Vega chart
    vega_spec.isVegaChart = true;
end


function vega_spec = addLegendIfNeeded(vega_spec, vega_data, params)
    % Check if there are multiple colors in the data
    hasMultipleColors = false;
    hasColorScale = false;
    
    % Check if there's a color scale defined
    if isfield(vega_spec, 'scales')
        for i = 1:length(vega_spec.scales)
            if strcmp(vega_spec.scales{i}.name, 'color')
                hasColorScale = true;
                break;
            end
        end
    end
    
    % Check if there are multiple unique color values in the data
    if ~isempty(vega_data) && isstruct(vega_data)
        if length(vega_data) > 1 && isfield(vega_data, 'color')
            % Extract all color values from struct array
            color_values = {vega_data.color};
            % Remove empty values
            color_values = color_values(~cellfun(@isempty, color_values));
            unique_colors = unique(color_values);
            hasMultipleColors = length(unique_colors) > 1;
        elseif isfield(vega_data, 'color') && iscell(vega_data.color)
            % Handle case where color is a cell array
            unique_colors = unique(vega_data.color);
            hasMultipleColors = length(unique_colors) > 1;
        end
    end
    
    % Add legend if we have both a color scale and multiple colors
    if hasColorScale && hasMultipleColors
        % Check if interactive legend is requested
        isInteractive = strcmpi(params.interactive, 'true');
        
        if isInteractive
            % Add interactive legend with signals and data
            vega_spec = addInteractiveLegend(vega_spec);
        else
            % Create standard legend specification
            legend = struct();
            legend.fill = 'color';
            legend.orient = 'right';
            legend.padding = 10;
            legend.cornerRadius = 5;
            legend.strokeColor = '#ddd';
            legend.fillColor = '#fff';
            legend.title = 'Color';
            legend.titlePadding = 5;
            legend.titleFontSize = 12;
            legend.titleFontWeight = 'bold';
            legend.labelFontSize = 11;
            legend.symbolSize = 100;
            legend.symbolType = 'circle';
            
            % Add legend to specification
            vega_spec.legends = {legend};
        end
        
        % Adjust padding to accommodate legend
        if isfield(vega_spec, 'padding')
            vega_spec.padding.right = 120; % Increase right padding for legend
        else
            vega_spec.padding = struct('left', 60, 'right', 120, 'top', 20, 'bottom', 60);
        end
    end
end

function vega_spec = addInteractiveLegend(vega_spec)
    % Add interactive legend functionality based on official Vega pattern
    
    % Add signals for interactive legend
    if ~isfield(vega_spec, 'signals')
        vega_spec.signals = {};
    end
    
    % Clear signal - resets selection when clicking empty space
    clear_signal = struct();
    clear_signal.name = 'clear';
    clear_signal.value = true;
    clear_signal.on = {struct('events', 'pointerup[!event.item]', 'update', 'true', 'force', true)};
    vega_spec.signals{end+1} = clear_signal;
    
    % Shift signal - detects if shift key is held during click
    shift_signal = struct();
    shift_signal.name = 'shift';
    shift_signal.value = false;
    shift_signal.on = {struct('events', '@legendSymbol:click, @legendLabel:click', 'update', 'event.shiftKey', 'force', true)};
    vega_spec.signals{end+1} = shift_signal;
    
    % Clicked signal - captures clicked legend item
    clicked_signal = struct();
    clicked_signal.name = 'clicked';
    clicked_signal.value = [];
    clicked_signal.on = {struct('events', '@legendSymbol:click, @legendLabel:click', 'update', '{value: datum.value}', 'force', true)};
    vega_spec.signals{end+1} = clicked_signal;
    
    % Add selected data for tracking clicked items
    if ~isfield(vega_spec, 'data')
        vega_spec.data = {};
    end
    
    selected_data = struct();
    selected_data.name = 'selected';
    selected_data.on = {
        struct('trigger', 'clear', 'remove', true);
        struct('trigger', '!shift', 'remove', true);
        struct('trigger', '!shift && clicked', 'insert', 'clicked');
        struct('trigger', 'shift && clicked', 'toggle', 'clicked')
    };
    vega_spec.data{end+1} = selected_data;
    
    % Create interactive legend
    legend = struct();
    legend.fill = 'color';
    legend.title = 'Color';
    legend.orient = 'right';
    legend.padding = 10;
    
    % Interactive legend encoding
    legend.encode = struct();
    
    % Interactive symbols
    legend.encode.symbols = struct();
    legend.encode.symbols.name = 'legendSymbol';
    legend.encode.symbols.interactive = true;
    legend.encode.symbols.update = struct();
    legend.encode.symbols.update.fill = struct('value', 'transparent');
    legend.encode.symbols.update.strokeWidth = struct('value', 2);
    legend.encode.symbols.update.opacity = {
        struct('test', '!length(data(''selected'')) || indata(''selected'', ''value'', datum.value)', 'value', 0.7);
        struct('value', 0.15)
    };
    legend.encode.symbols.update.size = struct('value', 64);
    
    % Interactive labels
    legend.encode.labels = struct();
    legend.encode.labels.name = 'legendLabel';
    legend.encode.labels.interactive = true;
    legend.encode.labels.update = struct();
    legend.encode.labels.update.opacity = {
        struct('test', '!length(data(''selected'')) || indata(''selected'', ''value'', datum.value)', 'value', 1);
        struct('value', 0.25)
    };
    
    vega_spec.legends = {legend};
    
    % Update marks to be interactive - modify existing marks
    if isfield(vega_spec, 'marks')
        for i = 1:length(vega_spec.marks)
            mark = vega_spec.marks{i};
            
            % Add interactivity to marks that use color encoding
            if isfield(mark, 'encode') && isfield(mark.encode, 'enter')
                if isfield(mark.encode.enter, 'fill') && isfield(mark.encode.enter.fill, 'scale') && strcmp(mark.encode.enter.fill.scale, 'color')
                    % Update fill encoding for interactivity
                    if ~isfield(mark.encode, 'update')
                        mark.encode.update = struct();
                    end
                    
                    mark.encode.update.opacity = {
                        struct('test', '!length(data(''selected'')) || indata(''selected'', ''value'', datum.color)', 'value', 0.7);
                        struct('value', 0.15)
                    };
                    
                    mark.encode.update.fill = {
                        struct('test', '!length(data(''selected'')) || indata(''selected'', ''value'', datum.color)', 'scale', 'color', 'field', 'color');
                        struct('value', '#ccc')
                    };
                    
                elseif isfield(mark.encode.enter, 'stroke') && isfield(mark.encode.enter.stroke, 'scale') && strcmp(mark.encode.enter.stroke.scale, 'color')
                    % Update stroke encoding for interactivity
                    if ~isfield(mark.encode, 'update')
                        mark.encode.update = struct();
                    end
                    
                    mark.encode.update.opacity = {
                        struct('test', '!length(data(''selected'')) || indata(''selected'', ''value'', datum.color)', 'value', 0.7);
                        struct('value', 0.15)
                    };
                    
                    mark.encode.update.stroke = {
                        struct('test', '!length(data(''selected'')) || indata(''selected'', ''value'', datum.color)', 'scale', 'color', 'field', 'color');
                        struct('value', '#ccc')
                    };
                end
            end
            
            % Handle nested marks (for grouped charts like bars and lines)
            if isfield(mark, 'marks')
                for j = 1:length(mark.marks)
                    nested_mark = mark.marks{j};
                    if isfield(nested_mark, 'encode') && isfield(nested_mark.encode, 'enter')
                        if ~isfield(nested_mark.encode, 'update')
                            nested_mark.encode.update = struct();
                        end
                        
                        % Handle fill encoding (for bars)
                        if isfield(nested_mark.encode.enter, 'fill') && isfield(nested_mark.encode.enter.fill, 'scale') && strcmp(nested_mark.encode.enter.fill.scale, 'color')
                            nested_mark.encode.update.opacity = {
                                struct('test', '!length(data(''selected'')) || indata(''selected'', ''value'', datum.color)', 'value', 0.7);
                                struct('value', 0.15)
                            };
                            
                            nested_mark.encode.update.fill = {
                                struct('test', '!length(data(''selected'')) || indata(''selected'', ''value'', datum.color)', 'scale', 'color', 'field', 'color');
                                struct('value', '#ccc')
                            };
                        end
                        
                        % Handle stroke encoding (for lines)
                        if isfield(nested_mark.encode.enter, 'stroke') && isfield(nested_mark.encode.enter.stroke, 'scale') && strcmp(nested_mark.encode.enter.stroke.scale, 'color')
                            nested_mark.encode.update.opacity = {
                                struct('test', '!length(data(''selected'')) || indata(''selected'', ''value'', datum.color)', 'value', 0.7);
                                struct('value', 0.15)
                            };
                            
                            nested_mark.encode.update.stroke = {
                                struct('test', '!length(data(''selected'')) || indata(''selected'', ''value'', datum.color)', 'scale', 'color', 'field', 'color');
                                struct('value', '#ccc')
                            };
                        end
                        
                        mark.marks{j} = nested_mark;
                    end
                end
            end
            
            vega_spec.marks{i} = mark;
        end
    end
end

%% ===== FILE OUTPUT =====

function writeVegaFiles(vega_spec, params)
    % Create export directory if it doesn't exist
    if ~isempty(params.export_path) && ~exist(params.export_path, 'dir')
        mkdir(params.export_path);
    end
    
    % Remove the flag before writing JSON (all specs are now Vega)
    if isfield(vega_spec, 'isVegaChart')
        vega_spec = rmfield(vega_spec, 'isVegaChart');
    end
    
    % Convert specification to JSON
    vegaSpecJson = jsonencode(vega_spec);
    
    % Write JSON file
    jsonFile = fullfile(params.export_path, sprintf('%s.json', params.file_name));
    fileID = fopen(jsonFile, 'w+');
    fprintf(fileID, '%s', vegaSpecJson);
    fclose(fileID);
    
    % Write HTML file (always use Vega template now)
    htmlFile = fullfile(params.export_path, sprintf('%s.html', params.file_name));
    htmlContent = createVegaHTMLTemplate(params.file_name);
    
    fileID = fopen(htmlFile, 'w+');
    fprintf(fileID, '%s', htmlContent);
    fclose(fileID);
    
    fprintf('Vega specification successfully written to %s\n', jsonFile);
    fprintf('HTML file successfully written to %s\n', htmlFile);
end

function htmlContent = createVegaHTMLTemplate(file_name)
    % Vega HTML template for all chart types
    htmlContent = sprintf([ ...
        '<!DOCTYPE html>\n', ...
        '<html lang="en">\n', ...
        '<head>\n', ...
        '    <meta charset="UTF-8">\n', ...
        '    <meta name="viewport" content="width=device-width, initial-scale=1.0">\n', ...
        '    <title>Vega Chart</title>\n', ...
        '    <script src="https://cdn.jsdelivr.net/npm/vega@5"></script>\n', ...
        '    <script src="https://cdn.jsdelivr.net/npm/vega-embed@6"></script>\n', ...
        '</head>\n', ...
        '<body>\n', ...
        '    <div id="%s_chart"></div>\n', ...
        '    <script>\n', ...
        '        fetch("%s.json")\n', ...
        '            .then(response => response.json())\n', ...
        '            .then(spec => {\n', ...
        '                console.log("DEBUG: Loaded Vega spec:", spec);\n', ...
        '                console.log("DEBUG: Axes found:", spec.axes);\n', ...
        '                if (spec.axes) {\n', ...
        '                    spec.axes.forEach((axis, i) => {\n', ...
        '                        console.log(`DEBUG: Axis ${i} - Orient: ${axis.orient}, Title: "${axis.title}"`);\n', ...
        '                    });\n', ...
        '                }\n', ...
        '                if (spec.marks) {\n', ...
        '                    spec.marks.forEach((mark, i) => {\n', ...
        '                        if (mark.encode && mark.encode.update && mark.encode.update.tooltip) {\n', ...
        '                            console.log(`DEBUG: Mark ${i} tooltip signal: ${mark.encode.update.tooltip.signal}`);\n', ...
        '                        }\n', ...
        '                    });\n', ...
        '                }\n', ...
        '                vegaEmbed("#%s_chart", spec, {\n', ...
        '                    actions: true,\n', ...
        '                    theme: "default",\n', ...
        '                    renderer: "canvas"\n', ...
        '                });\n', ...
        '            })\n', ...
        '            .catch(error => console.error("Error loading chart:", error));\n', ...
        '    </script>\n', ...
        '</body>\n', ...
        '</html>\n' ...
    ], file_name, file_name, file_name);
end

function bin2d_data = extractBin2dData(stat_bin2d_results)
    % Extract 2D binning data from gramm's computed results
    % This includes bin edges and 2D histogram counts for heatmap visualization
    
    bin2d_data = [];
    
    if isstruct(stat_bin2d_results) && isfield(stat_bin2d_results, 'counts') && isfield(stat_bin2d_results, 'edges')
        
        % Extract the 2D histogram data
        bin2d_data = struct();
        bin2d_data.counts = stat_bin2d_results.counts;  % 2D matrix of counts
        bin2d_data.x_edges = stat_bin2d_results.edges{1};  % X bin edges
        bin2d_data.y_edges = stat_bin2d_results.edges{2};  % Y bin edges
        
    else
    end
end

function layer = createStatBin2dLayer(analysis, params)
    % Create a stat_bin2d layer with heatmap visualization
    % Uses 2D histogram data from results.stat_bin2d
    
    % Get bin2d data from analysis
    bin2d_data = analysis.stats.stat_bin2d;
    
    % Create base Vega specification for this layer
    layer = struct();
    layer.vegaSpec = createBaseVegaSpec();
    layer.vegaSpec.width = str2double(params.width);
    layer.vegaSpec.height = str2double(params.height);
    
    % Check if we have bin2d data
    if isempty(bin2d_data)
        layer.vegaSpec.data = {struct('name', 'table', 'values', [])};
        layer.vegaSpec.scales = createVegaScales(analysis);
        layer.vegaSpec.axes = createVegaAxes(analysis, params);
        layer.vegaSpec.marks = {};
        return;
    end
    
    % Convert 2D histogram to heatmap data format
    heatmap_data = {};
    counts = bin2d_data.counts;
    x_edges = bin2d_data.x_edges;
    y_edges = bin2d_data.y_edges;
    
    % Calculate bin centers for positioning
    x_centers = (x_edges(1:end-1) + x_edges(2:end)) / 2;
    y_centers = (y_edges(1:end-1) + y_edges(2:end)) / 2;
    
    % Calculate bin widths for sizing
    x_width = x_edges(2) - x_edges(1);  % Assuming uniform spacing
    y_width = y_edges(2) - y_edges(1);  % Assuming uniform spacing
    
    
    % Convert matrix to list of rectangles for heatmap
    cell_idx = 1;
    for i = 1:length(x_centers)
        for j = 1:length(y_centers)
            if counts(j, i) > 0  % Only include non-zero bins
                heatmap_entry = struct();
                heatmap_entry.x = x_centers(i);
                heatmap_entry.y = y_centers(j);
                heatmap_entry.count = counts(j, i);
                heatmap_entry.x_width = x_width;
                heatmap_entry.y_width = y_width;
                heatmap_data{cell_idx} = heatmap_entry;
                cell_idx = cell_idx + 1;
            end
        end
    end
    
    % Convert cell array to struct array for Vega
    if ~isempty(heatmap_data)
        heatmap_data = [heatmap_data{:}];
    else
        heatmap_data = [];
    end
    
    
    % Create data source for heatmap
    data_source = struct();
    data_source.name = 'heatmap_data';
    data_source.values = heatmap_data;
    
    layer.vegaSpec.data = {data_source};
    
    % Create scales for heatmap
    scales = {};
    
    % X scale (linear for continuous data)
    x_scale = struct();
    x_scale.name = 'xscale';
    x_scale.type = 'linear';
    x_scale.domain = struct('data', 'heatmap_data', 'field', 'x');
    x_scale.range = 'width';
    scales{end+1} = x_scale;
    
    % Y scale (linear for continuous data)
    y_scale = struct();
    y_scale.name = 'yscale';
    y_scale.type = 'linear';
    y_scale.domain = struct('data', 'heatmap_data', 'field', 'y');
    y_scale.range = 'height';
    y_scale.nice = true;
    y_scale.zero = true;
    scales{end+1} = y_scale;
    
    % Color scale for count values (heatmap intensity)
    % Use gramm's colormap if available, otherwise default to dark blue to yellow
    color_scale = struct();
    color_scale.name = 'color';
    color_scale.type = 'linear';
    
    % Set domain based on actual data range or gramm's CLim
    if isfield(analysis, 'continuous_color') && analysis.continuous_color.active && ~isempty(analysis.continuous_color.CLim)
        % Use gramm's color limits
        color_scale.domain = analysis.continuous_color.CLim;
    else
        % Use data-driven domain
        color_scale.domain = struct('data', 'heatmap_data', 'field', 'count');
    end
    
    % Set color range based on gramm's colormap or default
    if isfield(analysis, 'continuous_color') && analysis.continuous_color.active && ~isempty(analysis.continuous_color.colormap)
        % Convert gramm's colormap to hex colors (sample 9 colors for good gradient)
        hex_colors = convertColormapToHex(analysis.continuous_color.colormap, 9);
        color_scale.range = hex_colors;
    else
        % Default viridis-like gradient (blue-green-yellow) to match gramm default
        color_scale.range = {'#440154', '#482777', '#3f4a8a', '#31678e', '#26838f', '#1f9d8a', '#6cce5a', '#b6de2b', '#fee825'};
    end
    scales{end+1} = color_scale;
    
    layer.vegaSpec.scales = scales;
    
    % Create axes
    layer.vegaSpec.axes = createVegaAxes(analysis, params);
    
    % Create heatmap marks
    marks = {};
    
    % Heatmap rectangles
    heatmap_mark = struct();
    heatmap_mark.type = 'rect';
    heatmap_mark.from = struct('data', 'heatmap_data');
    heatmap_mark.encode = struct();
    heatmap_mark.encode.update = struct();
    
    % Position and size rectangles
    heatmap_mark.encode.update.x = struct('scale', 'xscale', 'field', 'x', 'offset', struct('signal', '-datum.x_width/2 * width / (domain("xscale")[1] - domain("xscale")[0])'));
    heatmap_mark.encode.update.y = struct('scale', 'yscale', 'field', 'y', 'offset', struct('signal', '-datum.y_width/2 * height / (domain("yscale")[1] - domain("yscale")[0])'));
    heatmap_mark.encode.update.width = struct('signal', 'datum.x_width * width / (domain("xscale")[1] - domain("xscale")[0])');
    heatmap_mark.encode.update.height = struct('signal', 'datum.y_width * height / (domain("yscale")[1] - domain("yscale")[0])');
    
    % Color based on count
    heatmap_mark.encode.update.fill = struct('scale', 'color', 'field', 'count');
    heatmap_mark.encode.update.stroke = struct('value', '#ffffff');
    heatmap_mark.encode.update.strokeWidth = struct('value', 0.5);
    
    % Tooltip
    heatmap_mark.encode.update.tooltip = struct('signal', '''X: '' + format(datum.x, ''.3f'') + '', Y: '' + format(datum.y, ''.3f'') + '', Count: '' + datum.count');
    
    marks{end+1} = heatmap_mark;
    
    
    layer.vegaSpec.marks = marks;
end

