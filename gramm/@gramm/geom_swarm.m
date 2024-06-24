function obj = geom_swarm(obj,varargin)

p = inputParser;
addOptional(p,'method','up')
addOptional(p,'corral','none')
addOptional(p,'point_size',3)
addOptional(p,'dodge',0.7);
addOptional(p,'width',0.9);
my_addParameter(p,'alpha',1);
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

xlim([obj.plot_lim.minx obj.plot_lim.maxx]);
ylim([obj.plot_lim.miny obj.plot_lim.maxy]);

uni_x=unique(x);

%Here we need to implement a loose 'unique' because of
%potential numerical errors
uni_x(diff(uni_x)<1e-10)=[];

dodge_uni_x = dodger(uni_x,draw_data,params.dodge);

if params.dodge>0
    params.avl_width=draw_data.dodge_avl_w*params.width./(draw_data.n_colors);
else
    params.avl_width=draw_data.dodge_avl_w*params.width;
end

hndl = gobjects(length(uni_x),1);
for ind_x=1:length(uni_x)

    ysel=y(abs(x-uni_x(ind_x))<1e-10);
    y_orig = ysel;

    [xsel,ysel] = gen_swarm(ysel,params,parent_axe);

    xsel = xsel + dodge_uni_x(ind_x);

    hndl(ind_x) = scatter(xsel,ysel,(params.point_size*2)^2,'filled','MarkerFaceColor',draw_data.color,'MarkerFaceAlpha',params.alpha);
    hndl(ind_x).UserData.x_offset = dodge_uni_x(ind_x);
    hndl(ind_x).UserData.y_orig = y_orig;
end

obj.redraw_fun=vertcat(obj.redraw_fun,{@()swarm_redraw(parent_axe,hndl,params)});

obj.results.geom_swarm{obj.result_ind,1}.scatter_handle = hndl;

end

function swarm_redraw(ax,hndl,params)
for k=1:length(hndl)

    [x,y] = gen_swarm(hndl(k).UserData.y_orig,params,ax) ;

    hndl(k).XData  = x + hndl(k).UserData.x_offset;
    hndl(k).YData  = y ;
end
end


function [x,y] = gen_swarm(y,params,ax)


r = params.point_size;

ax.Units="points";
ptpos = ax.Position;
ax.Units="normalized";
xsz = ptpos(3)/diff(ax.XLim); %Find factor between plotting units and points (unit used by MarkerSize)
ysz = ptpos(4)/diff(ax.YLim);

ypx = y*ysz; %Convert y values to point values

switch params.method
    case 'up'
        [ypx, si]=sort(ypx,1,"ascend");
    case 'down'
        [ypx, si]=sort(ypx,1,"descend");
    case 'fan'
        [~, si]=sort(abs(ypx-nanmean(ypx)),1,"ascend");
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

hex = strcmp(params.method,'hex');
ff=@(k)((-1)^(k+1)) * ceil(k/2); %function to alternate 1 -1 2 -2 3 -3

xpx = zeros(length(y),1);
for k = 1:length(y)

    if hex %Special case of hex packing
        n_placed = sum(ypx(1:k-1)==ypx(k));

        if mod(find(ypx(k)==binc),2)==0
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


            %Sort potential x locations by distance to center
            [~, tmp_i] = sort(abs(x_pot));
            x_pot = x_pot(tmp_i);

            %Compute distances between potential x locations and placed points
            D_pot = pdist2([x_pot repmat(ypx(k),2*length(sel)+1,1)] , [xpx(sel) ypx(sel)]);

            %Pick the first one that doesn't interfere with any previous point
            %(ie has any distance lower than 2*r)
            min_D_pot = min(D_pot,[],2);
            first_good = find(min_D_pot>=2*r-1e-10,1,"first");
            xpx(k)=x_pot(first_good);
        end
    end

end

x = xpx/xsz; %Convert obtained x values in point units back to plot units

switch(params.corral)
    case 'gutter'
        x(x>params.avl_width/2) = params.avl_width/2;
        x(x<-params.avl_width/2) = -params.avl_width/2;
    case 'omit'
        x(abs(x)>params.avl_width/2) = NaN;
    case 'wrap'
        while(any(abs(x)>params.avl_width/2))
            x(x>params.avl_width/2) = params.avl_width/2 - (x(x>params.avl_width/2)-params.avl_width/2);
            x(x<-params.avl_width/2) = -params.avl_width/2 - (x(x<-params.avl_width/2)+params.avl_width/2);
        end
    case 'random'
        x(abs(x)>params.avl_width/2) = rand(sum(abs(x)>params.avl_width/2),1)*params.avl_width-params.avl_width/2;
end

end