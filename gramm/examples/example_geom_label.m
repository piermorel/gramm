% gramm examples and how-tos

% Shared variable
% We stat by loading the sample data (structure created from the carbig
% dataset)
load example_data;

%% Plotting text or labeling with geom_label()



%Create short version of model names by removing manufacturer
cars.ModelShort=cellfun(@(ma,mo)mo(length(ma)+1:end),cars.Manufacturer,cars.Model,'UniformOutput',false);

figure;
clear g
%Provide 'label' as data
g=gramm('x',cars.Horsepower,'y',cars.Acceleration,...
    'label',cars.ModelShort,'color',cars.Manufacturer,'subset',strcmp(cars.Origin_Region,'Japan'));
%geom_label() takes the same arguments as text().
%'BackgroundColor','EdgeColor' and 'Color' can be set to 'auto'
g.geom_label('VerticalAlignment','middle','HorizontalAlignment','center','BackgroundColor','auto','Color','k');
g.set_limit_extra([0.2 0.2],[0.1 0.1]);
g.set_names('color','Manufacturer','x','Horsepower','y','Acceleration');
g.set_color_options('map','brewer2');
g.draw();

% geom_label works when 3D data is provided
figure;
g=gramm('x',cars.Horsepower,'y',cars.Acceleration,'z',cars.MPG,...
    'label',cars.ModelShort,'color',cars.Manufacturer,'subset',strcmp(cars.Origin_Region,'Japan'));
g.geom_label('VerticalAlignment','middle','HorizontalAlignment','center','BackgroundColor','auto','Color','k');
g.set_limit_extra([0.2 0.2],[0.1 0.1]);
g.set_names('color','Manufacturer','x','Horsepower','y','Acceleration','z','MPG');
g.set_color_options('map','brewer2');
g.draw();


figure;
clear g
%Compute number of models outside of gramm so that the output can be used
%as label
temp_table=rowfun(@numel,cars,'OutputVariableNames','N','GroupingVariables',{'Origin_Region','Model_Year'},'InputVariables','MPG');
g=gramm('x',temp_table.Model_Year,'y',temp_table.N,'color',temp_table.Origin_Region,'label',temp_table.N);
g.geom_bar('dodge',0.7,'width',0.6);
g.geom_label('color','k','dodge',0.7,'VerticalAlignment','bottom','HorizontalAlignment','center');
g.set_names('color','Origin','x','Year','y','Number of models');
g.draw();
