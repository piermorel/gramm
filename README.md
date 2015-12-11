# gramm
## Introduction
Gramm allows to easily plot grouped data in Matlab, and is inspired by R's [ggplot2](http://ggplot2.org) library by [Hadley Wickham](http://had.co.nz)

With gramm, 6 lines of code are enough to create such a figure:
<img src="/img/carbig_example.png" alt="gramm example" width="800">
```matlab
load carbig.mat %Load example dataset about cars
origin_region=num2cell(org,2); %Convert origin data to a cellstr
%Create a gramm object, provide x (year) and y (mpg) data
%color data (region of origin) and select a subset of the data
g=gramm('x',Model_Year,'y',MPG,'color',origin_region,'subset',Cylinders~=3 & Cylinders~=5,'size',5)
%Set appropriate names for legends
g.set_names('color','Origin','x','Year of production','y','MPG','column','# Cylinders')
%Subdivide the data in subplots horizontally by number of cylinders
g.facet_grid([],Cylinders)
%Plot raw data points
g.geom_point()
%Plot summarized data: 5 bins over x are created and for each
%bin the mean and confidence interval is displayed as a shaded area
g.stat_summary('geom','area','type','bootci','bin_in',5)
g.draw() %Draw method
```

## Features
- Accepts x and y data as arrays, matrices or cells of arrays
- Accepts grouping data as arrays or cellstr
- Multiple ways of separating data by groups: 
  - Color, point size and line type
  - Subplots by row and/or columns, or wrapping columns (<code>facet_grid()</code> and <code>facet_wrap()</code>)
- Multiple ways of directly plotting the data: 
  - scatter plots (<code>geom_point()</code>) and jittered scatter plot (<code>geom_jitter()</code>)
  - lines (<code>geom_line()</code>)
  - bars plots (<code>geom_bar()</code>)
  - raster plots (<code>geom_raster()</code>)
- Multiple ways of plotting transformed data:
  - y data summarized by unique x values with confidence intervals (<code>stat_summary()</code>)
  - spline-smoothed y data with optional confidence interval (<code>stat_smooth()</code>)
  - histograms and density plots of x values (<code>stat_bin()</code> and <code>stat_density()</code>)
  - 2D binning (<code>stat_bin2d()</code>)
  - GLM fits (<code>stat_glm()</code>, requires statistics toolbox)
- Subplots are created without too much empty space in between (and resize properly !)
- Polar plots (<code>set_polar()</code>)
- Confidence intervals as shaded areas, error bars or thin lines
- Multiple gramm plots can be combined in the same figure by creatin a matrix of gramm objects and calling the <code>draw()</code> method on the whole matrix.
- Matlabs axes properties are acessible through the method <code>axe_property()</code>
- Custom legend labels with <code>set_names()</code>

## Examples

### Multiple gramm objects in a single figure 
Also shows histograms, categorical x values
<img src="/img/multiple_gramm_example.png" alt="Multiple gramm" width="800">

### Fits (carbig data) ###
<img src="/img/carbig_glm_example.png" alt="GLM fits" width="500">

### Continuous colors
<img src="/img/continuous_color_example.png" alt="Continuous colors" width="500">

## Acknowledgements
gramm was inspired and/or used code from:
- [ggplot2](http://ggplot2.org)
- [Panda](http://www.neural-code.com/index.php/panda) for color conversion
- [subtightplot](http://www.mathworks.com/matlabcentral/fileexchange/39664-subtightplot) for subplot creation
