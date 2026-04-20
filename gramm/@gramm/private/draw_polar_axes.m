function hpol = draw_polar_axes(cax,maxrho)
%Modified version of Matlab's internal polar axis creation function
%that draws the polar axes at the back of an existing figure

% get hold state
%cax = newplot;

next = lower(get(cax, 'NextPlot'));
%hold_state = ishold(cax);

% get x-axis text color so grid is in same color
if ~isprop(cax, 'GridAlpha') || ~isprop(cax, 'GridColor') ~isprop(cax, 'Color')
    tc = get(cax, 'XColor');
else
    % get the axis gridColor
    axColor = get(cax, 'Color');
    gridAlpha = get(cax, 'GridAlpha');
    axGridColor = get(cax,'GridColor').*gridAlpha + axColor.*(1-gridAlpha);
    tc = axGridColor;
end
ls = get(cax, 'GridLineStyle');

% Hold on to current Text defaults, reset them to the
% Axes' font attributes so tick marks use them.
fAngle = get(cax, 'DefaultTextFontAngle');
fName = get(cax, 'DefaultTextFontName');
fSize = get(cax, 'DefaultTextFontSize');
fWeight = get(cax, 'DefaultTextFontWeight');
fUnits = get(cax, 'DefaultTextUnits');
set(cax, ...
    'DefaultTextFontAngle', get(cax, 'FontAngle'), ...
    'DefaultTextFontName', get(cax, 'FontName'), ...
    'DefaultTextFontSize', get(cax, 'FontSize'), ...
    'DefaultTextFontWeight', get(cax, 'FontWeight'), ...
    'DefaultTextUnits', 'data');

pol_handles=[];



% make a radial grid
hold(cax, 'on');

% ensure that Inf values don't enter into the limit calculation.
%         arho = abs(rho(:));
%         maxrho = max(arho(arho ~= Inf));
hhh = line([-maxrho, -maxrho, maxrho, maxrho], [-maxrho, maxrho, maxrho, -maxrho], 'Parent', cax);
set(cax, 'DataAspectRatio', [1, 1, 1], 'PlotBoxAspectRatioMode', 'auto');
v = [get(cax, 'XLim') get(cax, 'YLim')];
ticks = sum(get(cax, 'YTick') >= 0);
delete(hhh);

% check radial limits and ticks
rmin = 0;
%rmax = v(4);
rmax=maxrho;
rticks = max(ticks - 1, 2);
if rticks > 5   % see if we can reduce the number
    if rem(rticks, 2) == 0
        rticks = rticks / 2;
    elseif rem(rticks, 3) == 0
        rticks = rticks / 3;
    end
end

% define a circle
th = 0 : pi / 50 : 2 * pi;
xunit = cos(th);
yunit = sin(th);
% now really force points on x/y axes to lie on them exactly
inds = 1 : (length(th) - 1) / 4 : length(th);
xunit(inds(2 : 2 : 4)) = zeros(2, 1);
yunit(inds(1 : 2 : 5)) = zeros(3, 1);
% plot background if necessary
%         if ~ischar(get(cax, 'Color'))
%             patch('XData', xunit * rmax, 'YData', yunit * rmax, ...
%                 'EdgeColor', tc, 'FaceColor', get(cax, 'Color'), ...
%                 'HandleVisibility', 'off', 'Parent', cax);
%         end

% draw radial circles
c82 = cos(82 * pi / 180);
s82 = sin(82 * pi / 180);
rinc = (rmax - rmin) / rticks;
for i = (rmin + rinc) : rinc : rmax
    pol_handles(end+1) = line(xunit * i, yunit * i, 'LineStyle', ls, 'Color', tc, 'LineWidth', 1, ...
        'HandleVisibility', 'off', 'Parent', cax);
    pol_handles(end+1) = text((i + rinc / 20) * c82, (i + rinc / 20) * s82, ...
        ['  ' num2str(i)], 'VerticalAlignment', 'bottom', ...
        'HandleVisibility', 'off', 'Parent', cax);
end
set(pol_handles(end-1), 'LineStyle', '-'); % Make outer circle solid

% plot spokes
th = (1 : 6) * 2 * pi / 12;
cst = cos(th);
snt = sin(th);
cs = [-cst; cst];
sn = [-snt; snt];
pol_handles(end+1:end+6) = line(rmax * cs, rmax * sn, 'LineStyle', ls, 'Color', tc, 'LineWidth', 1, ...
    'HandleVisibility', 'off', 'Parent', cax);

% annotate spokes in degrees
rt = 1.1 * rmax;
for i = 3 :3: length(th)
    pol_handles(end+1) = text(rt * cst(i), rt * snt(i), int2str(i * 30),...
        'HorizontalAlignment', 'center', ...
        'HandleVisibility', 'off', 'Parent', cax);
    if i == length(th)
        loc = int2str(0);
    else
        loc = int2str(180 + i * 30);
    end
    pol_handles(end+1) = text(-rt * cst(i), -rt * snt(i), loc, 'HorizontalAlignment', 'center', ...
        'HandleVisibility', 'off', 'Parent', cax);
end

% set view to 2-D
view(cax, 2);
% set axis limits
axis(cax, rmax * [-1, 1, -1.15, 1.15]);




%Put all in the back
uistack(pol_handles,'bottom')

% Reset defaults.
set(cax, ...
    'DefaultTextFontAngle', fAngle , ...
    'DefaultTextFontName', fName , ...
    'DefaultTextFontSize', fSize, ...
    'DefaultTextFontWeight', fWeight, ...
    'DefaultTextUnits', fUnits );


set(cax, 'DataAspectRatio', [1, 1, 1]), axis(cax, 'off');
set(cax, 'NextPlot', next);

set(get(cax, 'XLabel'), 'Visible', 'on');
set(get(cax, 'YLabel'), 'Visible', 'on');

end
