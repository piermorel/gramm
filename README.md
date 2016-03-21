# gramm

Gramm is a powerful plotting toolbox which allows to quickly create complex, publication-quality figures in Matlab, and is inspired by R's [ggplot2](http://ggplot2.org) library by [Hadley Wickham](http://had.co.nz). As a reference to this inspiration, gramm stands for **GRAM**mar of graphics for **M**atlab.

## Using gramm ##

### Principle ###

The typical workflow to generate a figure with gramm is the following:

- In a first step, provide gramm with the relevant data for the figure: X and Y variables, but also grouping variables that will determine color, subplot rows/columns, etc.
- In the next steps, add graphical layers to your figure: raw data layers (directly plot data as points, lines...) or statistical layers (plot fits, histograms, densities, summaries with confidence intervals...). One instruction is enough to add each layer, and all layers offer many customization options.
- In the last step, gramm draws the figure, and takes care of all the annoying parts: no need to loop over colors or subplots, colors and legends are generated automatically, axes limits are taken care of, etc.

For example, with gramm, 6 lines of code are enough to create the figure below from the <code>carbig</code> dataset. Here the figure represents the evolution of fuel economy of new cars in time, with number of cylinders indicated by color, and regions of origin separated across subplot columns:
<img src="/img/carbig_example.png" alt="gramm example" width="830">
```matlab
load carbig.mat %Load example dataset about cars
origin_region=num2cell(org,2); %Convert origin data to a cellstr

% Create a gramm object, provide x (year of production) and y (fuel economy) data,
% color grouping data (number of cylinders) and select a subset of the data
g=gramm('x',Model_Year,'y',MPG,'color',Cylinders,'subset',Cylinders~=3 & Cylinders~=5)
% Subdivide the data in subplots horizontally by region of origin
g.facet_grid([],origin_region)
% Plot raw data as points
g.geom_point()
% Plot linear fits of the data with associated confidence intervals
g.stat_glm()
% Set appropriate names for legends
g.set_names('column','Origin','x','Year of production','y','Fuel economy (MPG)','color','# Cylinders')
% Do the actual drawing
g.draw()
```

### Installation
Add the folder containing gramm.m to your path
### Compatibility
Tested under Matlab 2014b+ versions. With pre-2014b versions, gramm forces <code>'painters'</code>, renderer to avoid some graphic bugs, which deactivates transparencies (use non-transparent geoms, for example <code>stat_summary('geom','lines')</code>). The statistics toolbox is required for some methods: <code>stat_glm()</code>, some <code>stat_summary()</code> methods, <code>stat_density()</code>. The curve fitting toolbox is required for <code>stat_fit()</code/>.
#### Documentation
Look at the [gramm cheat sheet](https://github.com/piermorel/gramm/blob/master/gramm%20cheat%20sheet.pdf)

Type <code>doc gramm</code> to find links to the documentation of each method.


## Features
- Accepts x and y data as arrays, matrices or cells of arrays
- Accepts grouping data as arrays or cellstr.


- Multiple ways of separating groups of data: 
  - Colors, lightness, point markers, line styles, and point/line size (<code>'color'</code>, <code>'lightness'</code>, <code>'marker'</code>, <code>'linestyle'</code>,  <code>'size'</code>)
  - Subplots by row and/or columns, or wrapping columns (<code>facet_grid()</code> and <code>facet_wrap()</code>). Multiple <code>'scale'</code> options for consistent axis limits across facets, rows, columns, etc.

- Multiple ways of directly plotting the data: 
  - scatter plots (<code>geom_point()</code>) and jittered scatter plot (<code>geom_jitter()</code>)
  - lines (<code>geom_line()</code>)
  - bars plots (<code>geom_bar()</code>)
  - raster plots (<code>geom_raster()</code>)
  - point counts (<code>point_count()</code>)

- Multiple ways of plotting statistics on the data:
  - y data summarized by x values (uniques or binned) with confidence intervals (<code>stat_summary()</code>)
  - histograms and density plots of x values (<code>stat_bin()</code> and <code>stat_density()</code>)
  - box and whisker plots (<code>stat_boxplot</code>)
  - quantile-quantile plots (<code>stat_qq()</code>) of x data distribution against theoretical distribution or y data distribution.
  - spline-smoothed y data with optional confidence interval (<code>stat_smooth()</code>)
  - 2D binning (<code>stat_bin2d()</code>)
  - GLM fits (<code>stat_glm()</code>, requires statistics toolbox)
  - Custom fits with user-provided anonymous function (<code>stat_fit()</code>)
  - Ellipses of confidence (<code>stat_ellipse()</code>)

- Subplots are created without too much empty space in between (and resize properly !)
- Polar coordinates (<code>set_polar()</code>)
- Color data can also be displayed as a continous variable, not as a grouping factor (<code>set_continuous_color()</code>)
- Possibility to customize color generations in the LCH color space, chose alternative colormaps (Matlab's default, [colorbrewer2](http://colorbrewer2.org)), or provide a custom colormap (<code>set_color_options()</code>)
- Possibility to change ordering of grouping variables between native, sorted, or custom (<code>set_order_options</code>)
- Confidence intervals as shaded areas, error bars or thin lines
- Results of computations from <code>stat_</code> plots are returned in the member structure <code>results</code>
- Multiple gramm plots can be combined in the same figure by creating a matrix of gramm objects and calling the <code>draw()</code> method on the whole matrix.
- Matlabs axes properties are acessible through the method <code>axe_property()</code>
- Custom legend labels with <code>set_names()</code>
- Plot reference line on the plots with <code>geom_abline()</code>, <code>geom_vline()</code>,<code>geom_hline()</code>
- Date ticks with set_datetick()
- Gramm works best with table-like data: separate variables / structure fields / table columns for the variables of interest, with each variable having as many elements as observations.

## Examples


### Custom fits ###
<code>stat_fit()</code>

<img src="/img/fit_example.png" alt="Custom fits" width="558">

### GLM fits (carbig data) ###
<code>stat_glm()</code>

<img src="/img/carbig_glm_example.png" alt="GLM fits" width="559">

### Multiple gramm objects in a single figure 
Also shows histograms, categorical x values

<img src="/img/multiple_gramm_example.png" alt="Multiple gramm" width="800">

### Histograms ###
<code>stat_bin()</code> with different <code>'geom'</code> options: <code>'bar'</code>, <code>'stacked_bar'</code>,<code>'point'</code>,<code>'line'</code>, <code>'overlaid_bar'</code>,<code>'stairs'</code>

<img src="/img/histograms_example.png" alt="Histograms example" width="733">

### Colormap customization ###
<code>set_color_options()</code> with <code>'map'</code> set as <code>'lch'</code> with various customization on the first row. <code>'map'</code> set to <code>matlab</code>,
 <code>brewer1</code>, and <code>brewer2</code> on the second line

<img src="/img/colormaps_example.png" alt="Colormaps example" width="788">

### 2D density visualizations ###
<code>stat_ellipse()</code> and <code>stat_bin2d()</code> with <code>'geom'</code> set to <code>'contour'</code>,<code>'point'</code>,<code>'image'</code>

<img src="/img/2D_densities_example.png" alt="2D density" width="653">

### Continuous colors

<img src="/img/continuous_color_example.png" alt="Continuous colors" width="556">

## Acknowledgements
gramm was inspired and/or used code from:
- [ggplot2](http://ggplot2.org)
- [Panda](http://www.neural-code.com/index.php/panda) for color conversion
- [subtightplot](http://www.mathworks.com/matlabcentral/fileexchange/39664-subtightplot) for subplot creation
- [colorbrewer2](http://colorbrewer2.org)
