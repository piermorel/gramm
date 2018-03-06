# gramm

Gramm is a powerful plotting toolbox which allows to quickly create complex, publication-quality figures in Matlab, and is inspired by R's [ggplot2](http://ggplot2.org) library by [Hadley Wickham](http://had.co.nz). As a reference to this inspiration, gramm stands for **GRAM**mar of graphics for **M**atlab.


## Table of contents ##

- [Why gramm?](#why-gramm)
- [Citing gramm](#citing-gramm)
- [About gramm](#about-gramm)
- [Using gramm](#using-gramm)
- [Features](#features)
- [Use cases and examples (screenshots)](#use-cases-and-examples)

## Why gramm ##

Gramm is a data visualization toolbox for Matlab that allows to produce publication-quality plots from grouped data easily and flexibly. Matlab can be used for complex data analysis using a high-level interface: it supports mixed-type tabular data via tables, provides statistical functions that accept these tables as arguments, and allows users to adopt a split-apply-combine approach ([Wickham 2011](https://www.jstatsoft.org/article/view/v040i01)) with ```rowfun()```. However, the standard plotting functionality in Matlab is mostly low-level, allowing to create axes in figure windows and draw geometric primitives (lines, points, patches) or simple statistical visualizations (histograms, boxplots) from numerical array data. Producing complex plots from grouped data thus requires iterating over the various groups in order to make successive statistical computations and low-level draw calls, all the while handling axis and color generation in order to visually separate data by groups. The corresponding code is often long, not easily reusable, and makes exploring alternative plot designs tedious.

Inspired by ggplot2 ([Wickham 2009](http://ggplot2.org)), the R implementation of "grammar of graphics" principles ([Wilkinson 1999](http://www.springer.com/de/book/9781475731002)), gramm improves Matlab's plotting functionality, allowing to generate complex figures using high-level object-oriented code.
Gramm has been used in several publications in the field of neuroscience, from human psychophysics ([Morel et al. 2017](https://doi.org/10.1371/journal.pbio.2001323)), to electrophysiology ([Morel et al. 2016](https://doi.org/10.1088/1741-2560/13/1/016002); [Ferrea et al. 2017](https://doi.org/10.1152/jn.00504.2017)), human functional imaging  ([Wan et al. 2017](https://doi.org/10.1002/hbm.23932)) and animal training ([Berger et al. 2017](https://doi.org/10.1152/jn.00614.2017)).

## Citing gramm ##

Gramm has been published in the Journal of Open Source Software. If you use gramm plots in a publication you can thus cite it using the following:

[![DOI](http://joss.theoj.org/papers/10.21105/joss.00568/status.svg)](https://doi.org/10.21105/joss.00568)

Morel, (2018). Gramm: grammar of graphics plotting in Matlab. Journal of Open Source Software, 3(23), 568, https://doi.org/10.21105/joss.00568

## About gramm ##

### Compatibility ###


Tested under Matlab 2014b+ versions. With pre-2014b versions, gramm forces <code>'painters'</code>, renderer to avoid some graphic bugs, which deactivates transparencies (use non-transparent geoms, for example <code>stat_summary('geom','lines')</code>). The statistics toolbox is required for some methods: <code>stat_glm()</code>, some <code>stat_summary()</code> methods, <code>stat_density()</code>. The curve fitting toolbox is required for <code>stat_fit()</code>.

### Installation ###

Download the gramm toolbox from GitHub ("Clone or download" button>download ZIP) or [clone it](https://help.github.com/articles/cloning-a-repository/), and add the folder containing the @gramm class folder to your Matlab path (using the [GUI](https://mathworks.com/help/matlab/matlab_env/add-remove-or-reorder-folders-on-the-search-path.html) or [```addpath()```](https://mathworks.com/help/matlab/ref/addpath.html))

### Documentation ###

- [gramm cheat sheet](https://github.com/piermorel/gramm/blob/master/gramm%20cheat%20sheet.pdf)
- Numerous coding examples and test cases in ```examples.m```, exported for preview in  [html/examples.html](http://htmlpreview.github.io/?https://github.com/piermorel/gramm/blob/master/html/examples.html)
- From MATLAB: <code>doc gramm</code> to find links to the documentation of each method.


## Using gramm ##

### Workflow ###

The typical workflow to generate a figure with gramm is the following:

- In a first step, provide gramm with the relevant data for the figure: X and Y variables, but also grouping variables that will determine color, subplot rows/columns, etc.
- In the next steps, add graphical layers to your figure: raw data layers (directly plot data as points, lines...) or statistical layers (plot fits, histograms, densities, summaries with confidence intervals...). One instruction is enough to add each layer, and all layers offer many customization options.
- In the last step, gramm draws the figure, and takes care of all the annoying parts: no need to loop over colors or subplots, colors and legends are generated automatically, axes limits are taken care of, etc.

For example, with gramm, 7 lines of code are enough to create the figure below from the <code>carbig</code> dataset. Here the figure represents the evolution of fuel economy of new cars in time, with number of cylinders indicated by color, and regions of origin separated across subplot columns:
<img src="/html/examples_01.png" alt="gramm example" width="800">

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
%Set figure title
g.set_title('Fuel economy of new cars between 1970 and 1982')
% Do the actual drawing
g.draw()
```

### Figure export

To export figures in a vector-based format, use the SVG or PDF option rather than EPS. SVG can be read by all vector editing softwares and causes less problems than EPS both for export and import (transparency support, text without cuts, etc.). gramm has a convenient <code>export()</code> method that can be called after <code>draw()</code> and maintains correct dimensions/aspect ratio. The <code>'alpha'</code> option for <code>geom_line()</code> and <code>geom_point()</code> is not supported by Matlab for exports.


## Features
- Accepts X Y and Z data as arrays, matrices or cells of arrays
- Accepts grouping data as arrays or cellstr.


- Multiple ways of separating groups of data:
  - Colors, lightness, point markers, line styles, and point/line size (<code>'color'</code>, <code>'lightness'</code>, <code>'marker'</code>, <code>'linestyle'</code>,  <code>'size'</code>)
  - Subplots by row and/or columns, or wrapping columns (<code>facet_grid()</code> and <code>facet_wrap()</code>). Multiple options for consistent axis limits across facets, rows, columns, etc. (using <code>'scale'</code> and <code>'space'</code>)
  - Separate figures (<code>fig()</code>)

- Multiple ways of directly plotting the data:
  - scatter plots (<code>geom_point()</code>) and jittered scatter plot (<code>geom_jitter()</code>)
  - lines (<code>geom_line()</code>)
  - confidence intervals (<code>geom_interval()</code>)
  - bars plots (<code>geom_bar()</code>)
  - raster plots (<code>geom_raster()</code>)
  - labels (<code>geom_label()</code>)
  - point counts (<code>point_count()</code>)


- Multiple ways of plotting statistics on the data:
  - y data summarized by x values (uniques or binned) with confidence intervals (<code>stat_summary()</code>)
  - histograms and density plots of x values (<code>stat_bin()</code> and <code>stat_density()</code>)
  - box and whisker plots (<code>stat_boxplot()</code>)
  - violin plots (<code>stat_violin()</code>)
  - quantile-quantile plots (<code>stat_qq()</code>) of x data distribution against theoretical distribution or y data distribution.
  - spline-smoothed y data with optional confidence interval (<code>stat_smooth()</code>)
  - 2D binning (<code>stat_bin2d()</code>)
  - GLM fits (<code>stat_glm()</code>, requires statistics toolbox)
  - Custom fits with user-provided anonymous function (<code>stat_fit()</code>)
  - Ellipses of confidence (<code>stat_ellipse()</code>)

- When Z data is provided in the call to <code>gramm()</code>, <code>geom_point()</code> and <code>geom_line()</code> generate 3D plots
- Subplots are created without too much empty space in between (and resize properly !)
- Polar coordinates (<code>set_polar()</code>)
- Color data can also be displayed as a continous variable, not as a grouping factor (<code>set_continuous_color()</code>)
- X and Y axes can be flipped to get horizontal statistics visualizations (<code>coord_flip()</code>)
- Color generation can be customized in the LCH color space, or can use alternative colormaps (Matlab's default, [colorbrewer2](http://colorbrewer2.org)), or provide a custom colormap (<code>set_color_options()</code>)
- Marker shapes and sizes can be customized with <code>set_point_options()</code>
- Line styles and width can be customized with <code>set_line_options()</code>
- Text elements aspect can be customized with <code>set_text_options()</code>
- Parameters of <code>stat_</code> functions (alpha level, N bootstraps) can be modified with <code>set_stat_options()</code>
- The ordering of grouping variables can be changed between native, sorted, or custom (<code>set_order_options</code>)
- Confidence intervals as shaded areas, error bars or thin lines
- Set the width and dodging of graphical elements in <code>geom_</code> functions, <code>stat_bin()</code>, <code>stat_summary()</code>, and <code>stat_boxplot()</code>, with <code>'width'</code> and <code>'dodge'</code> arguments
- The member structure <code>results</code> contains the results of computations from <code>stat_</code> plots as well as graphic handles for all plotted elements
- Figure title (<code>set_title()</code>)
- Multiple gramm plots can be combined in the same figure by creating a matrix of gramm objects and calling the <code>draw()</code> method on the whole matrix. An overarching title can be added by calling <code>set_title()</code> on the whole matrix.
- Different groupings can be used for different <code>stat_</code> and <code>geom_</code> layers with the <code>update()</code> method
- Matlabs axes properties are acessible through the method <code>axe_property()</code>
- Custom legend labels with <code>set_names()</code>
- Plot reference line on the plots with <code>geom_abline()</code>, <code>geom_vline()</code>,<code>geom_hline()</code>
- Plot reference polygons on the plots with <code>geom_polygon()</code>
- Date ticks with <code>set_datetick()</code>
- Gramm works best with table-like data: separate variables / structure fields / table columns for the variables of interest, with each variable having as many elements as observations.


## Use cases and examples

The code for the following figures and many others is in <code>examples.m</code>.

### Mapping groups of data to different visual properties
All the mappings presented below can be combined.

<img src="/html/examples_02.png" alt="" width="800">

### Relationship between categorical and continuous variables

<img src="/html/examples_03.png" alt="" width="800">

### Distribution of a continuous variable
Note that we by using Origin as a faceting variable, we visualize exactly the same quantities as in the figure above.

<img src="/html/examples_05.png" alt="" width="800">

### Relationship between two continous variables

<img src="/html/examples_06.png" alt="" width="800">

### 2D densities

<img src="/html/examples_08.png" alt="2D density" width="800">

### Repeated trajectories
Here the variable given as Y is a Nx1 cell of 1D arrays containing the individual trajectories. Color is given as a Nx1 cellstr.

<img src="/html/examples_09.png" alt="" width="800">

### Spike trains
This example highlights the potential use of gramm for neuroscientific data. Here X is a Nx1 cell containing spike trains collected over N trials. Color is given as a Nx1 cellstr.
Using <code>stat_bin()</code> it is possible to construct peristimulus time histograms.

<img src="/html/examples_10.png" alt="" width="800">

### stat_bin() options ###

<img src="/html/examples_13.png" alt="Histograms example" width="800">

### facet_grid() options ###

<img src="/html/examples_11.png" alt="facet_grid() options" width="800">

### Custom layouts ###

<img src="/html/examples_26.png" alt="Custom layouts" width="550">

### Text labels with geom_label() ###

<img src="/html/examples_21.png" alt="geom_label()" width="800">

### Colormap customization ###
With <code>set_color_options()</code>

<img src="/html/examples_28.png" alt="Colormaps example" width="800">

### Continuous colors

<img src="/html/examples_30.png" alt="Continuous colors" width="800">

### Reordering of categorical variables
With <code>set_order_options()</code>

<img src="/html/examples_31.png" alt="Reordering" width="800">


### Superimposition of gramm objects on the same axes
By making calling the update() method after a first draw, the same axes can be reused for another gramm plot.
Here this allows to plot the whole dataset in the background of each facet.

<img src="/html/examples_25.png" alt="gramm superimposition" width="800">

## Acknowledgements
gramm was inspired and/or used code from:
- [ggplot2](http://ggplot2.org)
- [Panda](http://www.neural-code.com/index.php/panda) for color conversion
- [subtightplot](http://www.mathworks.com/matlabcentral/fileexchange/39664-subtightplot) for subplot creation
- [colorbrewer2](http://colorbrewer2.org)
- [viridis colormap](https://bids.github.io/colormap/)
