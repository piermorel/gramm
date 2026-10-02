% gramm examples and how-tos

% Shared variable
% We stat by loading the sample data (structure created from the carbig
% dataset)
load example_data;


%% Example from the readme
% Here we plot the evolution of fuel economy of new cars bewteen 1970 and 1980 (carbig
% dataset). Gramm is used to easily separate groups on the basis of the number of
% cylinders of the cars (color), and on the basis of the region of origin of
% the cars (subplot columns). Both the raw data (points) and a glm fit with
% 95% confidence interval (line+shaded area) are plotted.
%

%%%
% Create a gramm object, provide x (year of production) and y (fuel economy) data,
% color grouping data (number of cylinders) and select a subset of the data
g=gramm('x',cars.Model_Year,'y',cars.MPG,'color',cars.Cylinders,'subset',cars.Cylinders~=3 & cars.Cylinders~=5);
%%%
% Subdivide the data in subplots horizontally by region of origin using
% facet_grid()
g.facet_grid([],cars.Origin_Region);
%%%
% Plot raw data as points
g.geom_point();
%%%
% Plot linear fits of the data with associated confidence intervals
g.stat_glm();
%%%
% Set appropriate names for legends
g.set_names('column','Origin','x','Year of production','y','Fuel economy (MPG)','color','# Cylinders');
%%%
% Set figure title
g.set_title('Fuel economy of new cars between 1970 and 1982');
%%%
% Do the actual drawing
figure;
g.draw();


%% Raw MATLAB equivalent of the figure above
% The following code produces a similar figure using raw MATLAB, to
% illustrate how gramm simplifies the process

figure('Color',[1 1 1]);

% Define groups
cyl = [4 6 8]; % Manually
orig = unique(cars.Origin_Region); % Based on data

% Loop over groups
for oi = 1:length(orig) % External loop on the axes

    % Axes creation
    ax = subplot(1,length(orig),oi);
    hold on

    for ci = 1:length(cyl) %Internal loop on the colors

        % Data selection
        sel = strcmp(cars.Origin_Region,orig{oi}) & ...
            cars.Cylinders==cyl(ci) & ...
            ~isnan(cars.Model_Year) & ~isnan(cars.MPG);

        % Plotting of raw data
        plot(cars.Model_Year(sel),cars.MPG(sel),'.', ...
            'MarkerSize',15);

        % Keep the same color for the statistics
        ax.ColorOrderIndex = ax.ColorOrderIndex - 1;

        % Statistics (linear fit and plotting)
        b = [ones(sum(sel),1) cars.Model_Year(sel)] \ ...
			cars.MPG(sel);
        x_fit = [min(cars.Model_Year(sel)) ...
			max(cars.Model_Year(sel))];
        plot(x_fit, x_fit * b(2) + b(1),'LineWidth',1.5);
    end

    % Axes legends
    title(['Origin: ' orig{oi}]);
    xlabel('Year');
    ylabel('Fuel Economy (MPG)');
end
% Ugly color legend
l = legend('4','','6','','8','','Location','southeast');
title(l,'#Cyl');
