function obj = geom_swarm(obj,varargin)
% geom_swarm Display data as swarms of non-overlapping points
%
% Example syntax: gramm_object.geom_swarm('type','fan','point_size',2)
% Points with the same x value are spread horizontally so that they don't
% overlap (beeswarm plot). The layout depends on the size of the axes and
% is computed again when the figure is resized.
%
% Parameters given as 'name',value pairs:
% - 'type': How points are spread (default 'up'):
%       - 'up': points placed from the lowest to the highest y value
%       - 'down': points placed from the highest to the lowest y value
%       - 'fan': points placed from the mean outwards
%       - 'hex': y values rounded to rows of points on a hexagonal grid
%       - 'square': y values rounded to rows of points on a square grid
% - 'corral': What to do with points spreading beyond 'width' (default
%            'none'):
%       - 'none': points are left where they are
%       - 'gutter': points are stacked at the edges of the width
%       - 'omit': points are not displayed
%       - 'wrap': points are folded back inside the width
%       - 'random': points are placed randomly inside the width
% - 'point_size': Radius of the points, in points (default 3). The swarm
%            layout uses it, so set_point_options() and the size aesthetic
%            don't change the size of swarm points
% - 'dodge': Spacing between swarms of different colors within an unique
%            x value (default 0.7), see stat_summary()
% - 'nudge': Fixed horizontal shift of the swarms, in the same units as
%            'width', e.g. to place them next to a half violin, see
%            stat_violin() (default 0)
% - 'half': Draw half swarms, same choices as in stat_violin() (default
%            'none'):
%       - 'none' (or false): points spread on both sides of the x value
%       - 'left' or 'right': points spread on that side only, their edges
%            touching the x value, e.g. next to the flat side of a half
%            violin. 'corral' then uses half of 'width'
%       - 'color' (or true): left or right depending on the color index,
%            with two colors sharing the same x ('dodge' is ignored)
% - 'width': Width available to each swarm, used by 'corral' (default 0.9)
% - 'alpha': Transparency of the points, from 0 (transparent) to 1
%            (opaque) (default 1)

p = inputParser;
addParameter(p,'type','up',@(v) valid_choice(v,{'up','down','fan','hex','square'}));
addParameter(p,'corral','none',@(v) valid_choice(v,{'none','gutter','omit','wrap','random'}));
addParameter(p,'point_size',3,@(v) valid_range(v,0,Inf));
addParameter(p,'dodge',0.7,@(v) valid_range(v,0,Inf));
addParameter(p,'nudge',0,@(v) valid_range(v,-Inf,Inf));
addParameter(p,'half','none',@(v) (isscalar(v) && (islogical(v) || isnumeric(v))) || valid_choice(v,{'none','left','right','color'}));
addParameter(p,'width',0.9,@(v) valid_range(v,0,Inf));
addParameter(p,'alpha',1,@(v) valid_range(v,0,1));
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_swarm(dobj,dd,p.Results)});
obj.results.geom_swarm={};

end

function hndl=my_swarm(obj,draw_data,params)

x=comb(draw_data.x);
y=comb(draw_data.y);


parent_axe=obj.facet_axes_handles(obj.current_row,obj.current_column);


xl = [obj.var_lim.minx-0.5 obj.var_lim.maxx+0.5];
yl = [obj.var_lim.miny obj.var_lim.maxy];
params.all_ux = unique_no_nan(obj.aes.x);

obj.plot_lim.minx(obj.current_row,obj.current_column)=xl(1);
obj.plot_lim.maxx(obj.current_row,obj.current_column)=xl(2);
obj.plot_lim.miny(obj.current_row,obj.current_column)=yl(1);
obj.plot_lim.maxy(obj.current_row,obj.current_column)=yl(2);

set_num_lim(gca,'X',[obj.plot_lim.minx(obj.current_row,obj.current_column) obj.plot_lim.maxx(obj.current_row,obj.current_column)]);
set_num_lim(gca,'Y',[obj.plot_lim.miny(obj.current_row,obj.current_column) obj.plot_lim.maxy(obj.current_row,obj.current_column)]);

uni_x=unique(x);

%Here we need to implement a loose 'unique' because of
%potential numerical errors
uni_x(diff(uni_x)<1e-10)=[];

%Side on which points are spread (no dodging in 'color' mode)
[params.side,params.dodge]=half_side(params.half,draw_data.color_index,params.dodge);

dodge_uni_x = dodger(uni_x,draw_data,params.dodge,params.nudge);

if params.dodge>0
    params.avl_width=draw_data.dodge_avl_w*params.width./(draw_data.n_colors);
else
    params.avl_width=draw_data.dodge_avl_w*params.width;
end

hndl = gobjects(length(uni_x),1);
y_orig = cell(length(uni_x),1);
for ind_x=1:length(uni_x)

    ysel=y(abs(x-uni_x(ind_x))<1e-10);
    y_orig{ind_x} = ysel;

    [xsel,ysel] = gen_swarm(ysel,params,parent_axe);

    xsel = xsel + dodge_uni_x(ind_x);

    hndl(ind_x) = scatter(xsel,ysel,(params.point_size*2)^2,'filled','MarkerFaceColor',draw_data.color,'MarkerFaceAlpha',params.alpha);
end

obj.redraw_fun=vertcat(obj.redraw_fun,{@()swarm_redraw(parent_axe,hndl,y_orig,dodge_uni_x,params)});

obj.results.geom_swarm{obj.result_ind,1}.scatter_handle = hndl;

end

function swarm_redraw(ax,hndl,y_orig,x_offset,params)
for k=1:length(hndl)

    [x,y] = gen_swarm(y_orig{k},params,ax) ;

    hndl(k).XData  = x + x_offset(k);
    hndl(k).YData  = y ;
end
end


function [x,y] = gen_swarm(y,params,ax)


r = params.point_size;

%Size of the axes in points (unit used by MarkerSize), from the layout:
%changing the axes units instead takes axes out of their tiledlayout when
%the layout is not computed yet
box = getfield(GetLayoutInformation(ax),'PlotBox'); %In pixels
ptsz = box(3:4)*72/get(groot,'ScreenPixelsPerInch');
xsz = ptsz(1)/diff(ruler2num(ax.XLim,ax.XAxis)); %Find factor between plotting units and points
ysz = ptsz(2)/diff(ruler2num(ax.YLim,ax.YAxis));

ypx = y*ysz; %Convert y values to point values

switch params.type
    case 'up'
        [ypx, si]=sort(ypx,1,"ascend");
    case 'down'
        [ypx, si]=sort(ypx,1,"descend");
    case 'fan'
        [~, si]=sort(abs(ypx-mean(ypx,'omitnan')),1,"ascend");
        ypx=ypx(si);
    otherwise %hex and square
        [ypx, si]=sort(ypx,1,"ascend");
        bins = min(ypx)-r:r*2:max(ypx)+r;
        binc = bins(1:end-1)+r;
        ypx = discretize(ypx,bins,binc);
end

y = ypx/ysz;


%Store in a logical matrix points that are less than two radius away from
%other points (ie could possibly be in contact)
D = squareform(pdist(ypx)) < r*2;

hex = strcmp(params.type,'hex');
one_sided = ~strcmp(params.side,'none');
ff=@(k)((-1)^(k+1)) * ceil(k/2); %function to alternate 1 -1 2 -2 3 -3

xpx = zeros(length(y),1);
for k = 1:length(y)

    if hex %Special case of hex packing
        n_placed = sum(ypx(1:k-1)==ypx(k));

        if one_sided
            %Points placed side by side from the center, every other row
            %shifted by the hexagonal offset
            if mod(find(ypx(k)==binc),2)==0
                xpx(k) = 2*r*n_placed;
            else
                xpx(k) = r * sqrt(3) / 2 + 2*r*n_placed;
            end
        elseif mod(find(ypx(k)==binc),2)==0
            xpx(k) = -r * sqrt(3) / 4 + 2*r*ff(n_placed);
        else
            xpx(k) = r * sqrt(3) / 4 + 2*r*ff(n_placed);
        end

    else

        sel = find(D(k,1:k-1)); %Select already placed points that could be in contact


        if ~isempty(sel) %If we are far away from placed points we keep the x = 0 value

            %Find potential x locations
            x_pot = zeros(2*length(sel)+1,1);

            for l = 1:length(sel)
                side = (rand>0.5)*2-1; %We randomize order of left and right
                x_pot((l-1)*2+2) = side*sqrt(4*r^2 -(ypx(k)-ypx(sel(l)))^2)+xpx(sel(l)); %Place potential point on the right or the left of previous points
                x_pot((l-1)*2+3) = -side*sqrt(4*r^2 -(ypx(k)-ypx(sel(l)))^2)+xpx(sel(l));
            end


            %For half swarms we only keep locations on the positive side
            %(flipped at the end for the left side). One of them is always
            %free: the right of the rightmost point in contact
            if one_sided
                x_pot = x_pot(x_pot>=-1e-10);
            end

            %Sort potential x locations by distance to center
            [~, tmp_i] = sort(abs(x_pot));
            x_pot = x_pot(tmp_i);

            %Compute distances between potential x locations and placed points
            D_pot = pdist2([x_pot repmat(ypx(k),length(x_pot),1)] , [xpx(sel) ypx(sel)]);

            %Pick the first one that doesn't interfere with any previous point
            %(ie has any distance lower than 2*r)
            min_D_pot = min(D_pot,[],2);
            first_good = find(min_D_pot>=2*r-1e-10,1,"first");
            xpx(k)=x_pot(first_good);
        end
    end

end

%Half swarms are shifted by one radius so that the edges of the first
%points touch the x value
if one_sided
    xpx = xpx + r;
end

x = xpx/xsz; %Convert obtained x values in point units back to plot units

%Limits of the corral: half swarms use half of the width, on one side
if one_sided
    lo = 0;
else
    lo = -params.avl_width/2;
end
hi = params.avl_width/2;

switch(params.corral)
    case 'gutter'
        x(x>hi) = hi;
        x(x<lo) = lo;
    case 'omit'
        x(x>hi | x<lo) = NaN;
    case 'wrap'
        while(any(x>hi | x<lo))
            x(x>hi) = hi - (x(x>hi)-hi);
            x(x<lo) = lo - (x(x<lo)-lo);
        end
    case 'random'
        sel_out = x>hi | x<lo;
        x(sel_out) = lo + rand(sum(sel_out),1)*(hi-lo);
end

%Left half swarms are mirrored
if strcmp(params.side,'left')
    x = -x;
end

end