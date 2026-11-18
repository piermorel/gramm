function makeGallery(outDir)
% Draw the gallery figures shown on the website home page and in the README
% as thumbnails: one simple figure per gramm feature, readable when small.
% Each figure is saved as <outDir>/<name>.png
if ~isfolder(outDir)
    mkdir(outDir);
end
load("example_data.mat", "cars");
rng(1);
figures = localfunctions();
figures = figures(startsWith(cellfun(@func2str, figures, UniformOutput=false), "gallery_"));
for k = 1:numel(figures)
    name = erase(func2str(figures{k}), "gallery_");
    fprintf("  %s\n", name);
    fig = figure(Visible="off", Position=[100 100 600 400]);
    g = figures{k}(cars);
    if ~isempty(g)
        g.set_text_options("base_size", 12);
        g.draw();
    end
    drawnow % Lets gramm finish laying out the figure
    % Whole figure, not cropped, so that all thumbnails have the same size
    exportgraphics(fig, fullfile(outDir, name + ".png"), Resolution=150, Padding="figure");
    close(fig);
end
end

% Each function below returns the gramm object to draw in the current
% figure (or [] when it draws itself). Their names give the file names

function g = gallery_color_lightness(~)
% Synthetic growth curves of cultures treated with three drugs at three
% doses (5 replicates each): color and lightness show the two groupings
[day,rep,drug_ind,dose_ind] = ndgrid(0:10,1:5,1:3,1:3);
rate = [0.35 0.3 0.25]';
effect = [0.05 0.1 0.15];
growth = exp((rate(drug_ind)-effect(dose_ind).*drug_ind/2).*day) + 0.3*randn(size(day));
drugs = {'Drug A','Drug B','Drug C'};
doses = {'Low','Medium','High'};
g = gramm('x',day(:),'y',growth(:),'color',drugs(drug_ind(:))','lightness',doses(dose_ind(:))');
g.facet_grid([],drugs(drug_ind(:))');
g.stat_summary('geom',{'area','line'});
g.set_order_options('lightness',doses);
g.set_names('x','Day','y','Growth','color','Drug','lightness','Dose','column','');
end

function g = gallery_facets(cars)
% Same code as the Usage section of README.md (see gallery_usage)
g = gramm('x',cars.Model_Year,'y',cars.MPG,'color',cars.Cylinders,...
    'subset',~mod(cars.Cylinders,2));
g.facet_grid([],cars.Origin_Region);
g.geom_point("dodge",0.5);
g.stat_glm();
g.set_names('column','Origin', 'x','Year of production', 'y','Fuel economy (MPG)',...
    'color','# Cylinders');
g.set_title('Fuel economy of new cars between 1970 and 1982');
end

function g = gallery_usage(cars)
% Figure of the Usage section of README.md: the facets figure, wider than
% the thumbnails
set(gcf, Position=[100 100 900 450]);
g = gallery_facets(cars);
end

function g = gallery_bars(cars)
g = gramm('x',cars.Origin_Region,'y',cars.MPG,'color',cars.Cylinders,'subset',~mod(cars.Cylinders,2));
g.stat_summary('geom',{'bar','black_errorbar'},'dodge',0.8,'width',0.7);
g.set_color_options('map','brewer2');
g.set_names('x','Origin','y','MPG','color','Cyl.');
end

function g = gallery_violin(cars)
period = repmat({'1970-75'},height(cars),1);
period(cars.Model_Year>75) = {'1976-82'};
g = gramm('x',cars.Origin_Region,'y',cars.Horsepower,'color',period);
g.stat_violin('normalization','width','half',true,'width',1,'dodge',0,'fill','transparent');
g.stat_boxplot('width',0.2,'dodge',0.25,'outliers',false);
g.set_color_options('map','brewer1');
g.set_names('x','Origin','y','Horsepower','color','Years');
end

function g = gallery_swarm(cars)
g = gramm('x',cars.Origin_Region,'y',cars.MPG,'color',cars.Origin_Region);
g.geom_swarm('point_size',2.5);
g.set_color_options('map','brewer_pastel');
g.set_names('x','Origin','y','MPG','color','Origin');
g.set_layout_options('legend',false);
end

function g = gallery_density(cars)
g = gramm('x',cars.MPG,'color',cars.Origin_Region);
g.stat_bin('normalization','pdf','geom','overlaid_bar','fill','transparent','nbins',20);
g.stat_density();
g.set_color_options('map','matlab');
g.set_names('x','MPG','y','Density','color','Origin');
end

function g = gallery_stacked_bars(cars)
% After the 1973 oil crisis, 4-cylinder cars replace 8-cylinder ones.
% Percentages of models with each number of cylinders, per year
counts = groupcounts(cars(~mod(cars.Cylinders,2),:),["Model_Year" "Cylinders"]);
counts = grouptransform(counts,"Model_Year",@(n) 100*n/sum(n),"GroupCount");
g = gramm('x',counts.Model_Year,'y',counts.GroupCount,'color',counts.Cylinders);
g.geom_bar('stacked',true,'width',0.8,'EdgeColor','w');
g.set_color_options('map',[0.99 0.75 0.35 ; 0.93 0.42 0.18 ; 0.62 0.12 0.14],'n_color',3,'n_lightness',1);
g.set_names('x','Year','y','% of models','color','Cylinders');
end

function g = gallery_psychometric(~)
% Synthetic proportions of "right" responses of 10 subjects as a function
% of a stimulus intensity, in three conditions
intensity = repmat(-4:4, 30, 1);
condition = repelem({'Easy';'Medium';'Hard'}, 10, 9);
slope = repelem([0.7;1.2;2], 10, 9);
p = 1./(1+exp(-(intensity-0.3)./slope));
response = binornd(20, p)/20;
g = gramm('x',intensity(:),'y',response(:),'color',condition(:));
g.geom_jitter('width',0.3,'height',0,'alpha',0.4);
g.stat_fit('fun',@(b,x)1./(1+exp(-(x-b(1))/b(2))),'StartPoint',[0 1],'stats',true,'intopt','functional');
g.set_order_options('color',{'Easy','Medium','Hard'});
g.set_names('x','Stimulus intensity','y','P(right)','color','');
end

function g = gallery_wind_rose(~)
% Synthetic wind directions (in degrees) and speeds
n = 1000;
wind_direction = mod(250+40*randn(n,1)-150*(rand(n,1)>0.7),360);
speed = categorical(discretize(abs(8+5*randn(n,1)),[0 5 10 15 Inf],...
    'categorical',{'0-5','5-10','10-15','>15'}),{'0-5','5-10','10-15','>15'});
g = gramm('x',wind_direction,'color',speed);
g.set_polar('unit','degrees');
g.stat_bin('edges',0:22.5:360,'geom','stacked_bar','fill','face');
g.axe_property('ThetaZeroLocation','top','ThetaDir','clockwise');
map = parula(7);
g.set_color_options('map',map(3:6,:),'n_color',4,'n_lightness',1);
g.set_names('x','','y','Count','color','Wind (m/s)');
end

function g = gallery_marginal_histograms(cars)
% Custom layout in a tiledlayout: scatter plot with marginal histograms
t = tiledlayout(gcf,4,4,'TileSpacing','compact','Padding','compact');
g_top = gramm('x',cars.Horsepower,'color',cars.Origin_Region);
g_top.set_parent(t,'tile',1,'span',[1 3]);
g_top.stat_bin('geom','stacked_bar','fill','all','nbins',15);
g_top.set_layout_options('legend',false);
g_top.set_names('x','','y','');
g_top.axe_property('XTickLabel','','YTickLabel','');
g_main = gramm('x',cars.Horsepower,'y',cars.MPG,'color',cars.Origin_Region);
g_main.set_parent(t,'tile',5,'span',[3 3]);
g_main.geom_point('alpha',0.6);
g_main.set_names('x','Horsepower','y','MPG','color','Origin');
g_main.set_layout_options('legend_position',[0.8 0.75 0.18 0.2]);
g_right = gramm('x',cars.MPG,'color',cars.Origin_Region);
g_right.set_parent(t,'tile',8,'span',[3 1]);
g_right.stat_bin('geom','stacked_bar','fill','all','nbins',15);
g_right.coord_flip();
g_right.set_layout_options('legend',false);
g_right.set_names('x','','y','');
g_right.axe_property('XTickLabel','','YTickLabel','');
g = [g_top g_main g_right];
g.set_text_options('base_size',12);
for k = 1:numel(g)
    g(k).draw();
end
g = [];
end

function g = gallery_ellipses(~)
load("fisheriris.mat", "meas", "species");
g = gramm('x',meas(:,2),'y',meas(:,1),'color',species);
g.geom_point('alpha',0.7);
g.stat_ellipse('type','95percentile','geom','area');
g.set_names('x','Sepal width','y','Sepal length','color','Species');
end

function g = gallery_trajectories(~)
% Synthetic monthly measurements of 20 subjects in two groups
months = datetime(2024,1,1) + calmonths(0:23);
n = 20;
group = repmat({'Control';'Treated'}, n/2, 1);
treated = strcmp(group,'Treated');
y = 10 + 3*sin(2*pi*(0:23)/12) + treated.*linspace(0,6,24) + randn(n,24) + 2*randn(n,1);
g = gramm('x',months,'y',y,'color',group);
g.geom_line('alpha',0.4);
g.stat_summary('geom','area');
g.set_color_options('map','d3_10');
g.set_names('x','','y','Score','color','Group');
end
