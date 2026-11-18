# gramm

[![Website](https://img.shields.io/badge/website-docs%20%26%20examples-1f5fb8)](https://piermorel.github.io/gramm/) [![View gramm on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://mathworks.com/matlabcentral/fileexchange/54465-gramm-data-visualization-toolbox) [![Paper](https://img.shields.io/badge/paper-10.21105%2Fjoss.00568-4c9a2a)](https://doi.org/10.21105/joss.00568)

Gramm is a MATLAB toolbox that enables the rapid creation of complex, publication-quality figures. Its design philosophy focuses on a *declarative* approach, where users specify the desired end result, as opposed to the traditional *imperative* method involving for loops, if/else statements, etc.

The MATLAB implementation of `gramm` is inspired by the "grammar of graphics" principles ([Wilkinson 1999](http://www.springer.com/de/book/9781475731002)) and the [ggplot2](http://ggplot2.tidyverse.org/) library for R by Hadley Wickham. As a reference to this inspiration, gramm stands for **GRAM**mar of graphics for **M**ATLAB. A similar library called [Seaborn](https://seaborn.pydata.org) also exists for Python.

<a href="https://piermorel.github.io/gramm/docs/GettingStarted.html"><img src="https://piermorel.github.io/gramm/docs/gallery/facets.png" alt="Getting started" title="Getting started" width="195"></a>
<a href="https://piermorel.github.io/gramm/docs/examples/example_advanced_marginal_histograms.html"><img src="https://piermorel.github.io/gramm/docs/gallery/marginal_histograms.png" alt="Custom layouts" title="Custom layouts" width="195"></a>
<a href="https://piermorel.github.io/gramm/docs/examples/example_base_grouping_aesthetics.html"><img src="https://piermorel.github.io/gramm/docs/gallery/color_lightness.png" alt="Groups and subgroups" title="Groups and subgroups" width="195"></a>
<a href="https://piermorel.github.io/gramm/docs/examples/example_base_categorical_x_data.html"><img src="https://piermorel.github.io/gramm/docs/gallery/bars.png" alt="Bar charts" title="Bar charts" width="195"></a>
<a href="https://piermorel.github.io/gramm/docs/OnlineTable.html"><img src="https://piermorel.github.io/gramm/docs/gallery/stacked_bars.png" alt="Stacked bars" title="Stacked bars" width="195"></a>
<a href="https://piermorel.github.io/gramm/docs/examples/example_stat_violin.html"><img src="https://piermorel.github.io/gramm/docs/gallery/violin.png" alt="Violin plots" title="Violin plots" width="195"></a>
<a href="https://piermorel.github.io/gramm/docs/examples/example_geom_swarm.html"><img src="https://piermorel.github.io/gramm/docs/gallery/swarm.png" alt="Swarm plots" title="Swarm plots" width="195"></a>
<a href="https://piermorel.github.io/gramm/docs/examples/example_base_1d_distributions.html"><img src="https://piermorel.github.io/gramm/docs/gallery/density.png" alt="Distributions" title="Distributions" width="195"></a>
<a href="https://piermorel.github.io/gramm/docs/examples/example_base_2d_distributions.html"><img src="https://piermorel.github.io/gramm/docs/gallery/ellipses.png" alt="2D distributions" title="2D distributions" width="195"></a>
<a href="https://piermorel.github.io/gramm/docs/examples/example_base_continuous_xy_data.html"><img src="https://piermorel.github.io/gramm/docs/gallery/psychometric.png" alt="Curve fits" title="Curve fits" width="195"></a>
<a href="https://piermorel.github.io/gramm/docs/TimeSeries.html"><img src="https://piermorel.github.io/gramm/docs/gallery/trajectories.png" alt="Time series" title="Time series" width="195"></a>
<a href="https://piermorel.github.io/gramm/docs/examples/example_base_polar.html"><img src="https://piermorel.github.io/gramm/docs/gallery/wind_rose.png" alt="Polar plots" title="Polar plots" width="195"></a>

More in the [examples gallery](https://piermorel.github.io/gramm/docs/examples/index.html).

## Installation

We recommend installing gramm directly through MATLAB's Add-ons explorer. Search for "gramm" and click Add! You can also install gramm manually by downloading the latest .mltbx file or by adding the gramm folder from the repository to your path.

Gramm 4 requires MATLAB R2022b or later; older releases of gramm work in older MATLAB versions. Some methods require the Statistics and Machine Learning Toolbox or the Curve Fitting Toolbox, see the [cheat sheet](https://piermorel.github.io/gramm/docs/gramm_cheat_sheet.html).

## Usage

This figure, made with the <code>carbig</code> dataset, shows the evolution of fuel economy of new cars with time, depending on the number of cylinders indicated by color, and regions of origin separated across subplot columns:

<img src="https://piermorel.github.io/gramm/docs/gallery/usage.png" alt="Fuel economy of new cars, made with the code below" width="800">

```matlab
load example_data.mat % Load example dataset about cars

% Provide the data: x (year of production) and y (fuel economy), color
% grouping data (number of cylinders), and a subset (even numbers of cylinders)
g=gramm('x',cars.Model_Year,'y',cars.MPG,'color',cars.Cylinders,...
    'subset',~mod(cars.Cylinders,2));
% Subdivide the data in subplots horizontally by region of origin
g.facet_grid([],cars.Origin_Region);
% Add graphical layers: raw data as points, and linear fits
g.geom_point("dodge",0.5);
g.stat_glm();
% Set names for legends and a figure title
g.set_names('column','Origin', 'x','Year of production', 'y','Fuel economy (MPG)',...
    'color','# Cylinders');
g.set_title('Fuel economy of new cars between 1970 and 1982');
% Draw the figure: gramm takes care of colors, subplots, legends and axes limits
g.draw();
```

## Learning gramm

Live scripts going through the analysis of a dataset (open them in MATLAB to benefit from interactive elements; in MATLAB Online, add the gramm folder to the path first):

- **Getting started**: a quick example to understand how gramm works ([View](https://viewer.mathworks.com/addons/54465/latest/files/doc/GettingStarted.mlx), [Open in MATLAB Online](https://matlab.mathworks.com/open/github/v1?repo=piermorel/gramm&file=gramm/doc/GettingStarted.mlx))
- **Grouped data**: visualizations that could accompany an ANOVA ([View](https://viewer.mathworks.com/addons/54465/latest/files/doc/Groups.mlx), [Open in MATLAB Online](https://matlab.mathworks.com/open/github/v1?repo=piermorel/gramm&file=gramm/doc/Groups.mlx))
- **X/Y data**: regressions and fits, grouped 2D data ([View](https://viewer.mathworks.com/addons/54465/latest/files/doc/XY.mlx), [Open in MATLAB Online](https://matlab.mathworks.com/open/github/v1?repo=piermorel/gramm&file=gramm/doc/XY.mlx))
- **Time series**: repeated time series data ([View](https://viewer.mathworks.com/addons/54465/latest/files/doc/TimeSeries.mlx), [Open in MATLAB Online](https://matlab.mathworks.com/open/github/v1?repo=piermorel/gramm&file=gramm/doc/TimeSeries.mlx))
- **Online table**: gramm with MATLAB's table functions, on an open dataset hosted on S3 ([View](https://viewer.mathworks.com/addons/54465/latest/files/doc/OnlineTable.mlx), [Open in MATLAB Online](https://matlab.mathworks.com/open/github/v1?repo=piermorel/gramm&file=gramm/doc/OnlineTable.mlx))

The [examples gallery](https://piermorel.github.io/gramm/docs/examples/index.html) has one page per gramm feature, from basic use to advanced customizations, and the [cheat sheet](https://piermorel.github.io/gramm/docs/gramm_cheat_sheet.html) lists all methods with their options. Once gramm is installed, the same documentation is in MATLAB's help browser (<code>doc gramm</code>).

## Citing gramm

Gramm has been published in the Journal of Open Source Software. If you use gramm plots in a publication you can cite it using the following:

Morel, (2018). Gramm: grammar of graphics plotting in Matlab. Journal of Open Source Software, 3(23), 568, https://doi.org/10.21105/joss.00568

## Acknowledgements
gramm was inspired by [ggplot2](http://ggplot2.org) and uses code or colormaps from [Panda](http://www.neural-code.com/index.php/panda), [colorbrewer2](http://colorbrewer2.org) and [viridis](https://bids.github.io/colormap/).
