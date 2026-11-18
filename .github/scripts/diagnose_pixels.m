% One-off diagnostic for the release runner: compares the units of figure
% positions, text extents, GetLayoutInformation() and exportgraphics()

fprintf('ScreenPixelsPerInch: %g\n', get(groot,'ScreenPixelsPerInch'));
fprintf('ScreenSize: %s\n', mat2str(get(groot,'ScreenSize')));

for visible = ["off" "on"]
    fprintf('\n=== Plain tiledlayout, Visible=%s ===\n', visible);
    f = figure('Visible',visible,'Position',[100 100 900 450]);
    t = tiledlayout(f,1,2);
    nexttile(t);
    ax = axes(t);
    ax.Layout.Tile = 'east';
    drawnow;
    report(f, ax);
    probe = text(ax,0,0,'# Cylinders','Units','pixels','FontSize',13,'FontWeight','bold');
    fprintf('Text extent (pixels): %s\n', mat2str(probe.Extent,5));
    probe.Units = 'points';
    fprintf('Text extent (points): %s\n', mat2str(probe.Extent,5));
    export_size(f);
    close(f);
end

fprintf('\n=== gramm figure (README usage), Visible=off ===\n');
load example_data.mat cars
f = figure('Visible','off','Position',[100 100 900 450]);
c = cars(~mod(cars.Cylinders,2),:);
g = gramm('x',c.Model_Year,'y',c.MPG,'color',c.Cylinders);
g.facet_grid([],c.Origin_Region);
g.geom_point();
g.set_names('column','Origin','x','Year of production','y','Fuel economy (MPG)','color','# Cylinders');
g.set_text_options('base_size',12);
g.draw();
drawnow;
report(f, g.legend_axe_handle);
txt = findobj(g.legend_axe_handle,'Type','text');
for k = 1:numel(txt)
    u = txt(k).Units;
    txt(k).Units = 'pixels';
    fprintf('Legend text "%s" extent (pixels, from legend axes): %s\n', ...
        txt(k).String, mat2str(txt(k).Extent,5));
    txt(k).Units = u;
end
export_size(f);
close(f);


function report(f, ax)
fprintf('Figure Position (pixels): %s\n', mat2str(f.Position,5));
li = GetLayoutInformation(ax);
fprintf('Layout PlotBox: %s\n', mat2str(li.PlotBox,5));
fprintf('Layout Position: %s\n', mat2str(li.Position,5));
ax.Units = 'pixels';
fprintf('Axes Position (pixels): %s\n', mat2str(ax.Position,5));
fprintf('getpixelposition: %s\n', mat2str(getpixelposition(ax,true),5));
ax.Units = 'normalized';
fprintf('Axes Position (normalized): %s\n', mat2str(ax.Position,5));
end

function export_size(f)
file = [tempname '.png'];
exportgraphics(f, file, 'Resolution', 150, 'Padding', 'figure');
info = imfinfo(file);
fprintf('exportgraphics at 150 dpi: %d x %d (figure of %.4g x %.4g inches)\n', ...
    info.Width, info.Height, info.Width/150, info.Height/150);
end
