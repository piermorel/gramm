function obj=stat_bin2d(obj,varargin)
% stat_bin2d() Makes 2D bins of X and Y data and displays count
%
% Parameters as 'name',value pairs:
% - 'nbins': Array in the form of [nxbins nybins] to set the
% number of bins in each dimension
% - 'edges': Cell in the form of {[x__edges] [y_edges]} to set
% custom bin edges for each dimension
% - 'geom': Set how results are displayed. 'image' uses a
% heatmap (default), 'contour' uses a contour plot. 'point'
% uses circles of varying size.

p=inputParser;
my_addParameter(p,'nbins',[30 30]);
my_addParameter(p,'edges',{});
my_addParameter(p,'geom','image'); %contour

parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_bin2d(dobj,dd,p.Results)});
obj.results.stat_bin2d={};
end


function hndl=my_bin2d(obj,draw_data,params)

x=comb(draw_data.x);
y=comb(draw_data.y);

if isempty(params.edges)
    [N,C] = hist3([shiftdim(x),shiftdim(y)],params.nbins);
else
    [N,C] = hist3([shiftdim(x),shiftdim(y)],'Edges',params.edges);
    
    obj.plot_lim.minx(obj.current_row,obj.current_column)=params.edges{1}(1);
    obj.plot_lim.maxx(obj.current_row,obj.current_column)=params.edges{1}(end);
    obj.plot_lim.miny(obj.current_row,obj.current_column)=params.edges{2}(1);
    obj.plot_lim.maxy(obj.current_row,obj.current_column)=params.edges{2}(end);
    
    %Put values on the upper edges as if they were in the last
    %bin
    N(:,end-1)=N(:,end-1)+N(:,end);
    N(end-1,:)=N(end-1,:)+N(end,:);
    
    %Remove upper edge
    N(:,end)=[];
    N(end,:)=[];
    
end

obj.results.stat_bin2d{obj.result_ind,1}.edges=C;
obj.results.stat_bin2d{obj.result_ind,1}.counts=N;

switch params.geom
    case 'contour'
        
        [~,hndl]=contour(C{1},C{2},N',5,'Color',draw_data.color);
        
    case 'image'
        
        if ~obj.continuous_color_options.active
            obj.continuous_color_options.active = true;
        end
        
        Nr=reshape(N',1,numel(N));
        sel=Nr>0;
        %sel=true(size(Nr));
        
        if isempty(params.edges)
            %Get polygon half widths
            wx=(C{1}(2)-C{1}(1))/2;
            wy=(C{2}(2)-C{2}(1))/2;
            
            %Generate polygon edges
            [X,Y] = meshgrid(C{1},C{2});
            
            X=reshape(X,1,numel(X));
            Y=reshape(Y,1,numel(Y));
            
            
            patchesx=[X(sel)-wx ; X(sel)-wx ; X(sel)+wx ; X(sel)+wx ];
            patchesy=[Y(sel)-wy ; Y(sel)+wy ; Y(sel)+wy ; Y(sel)-wy ];
            
            
        else
            [Xs, Ys]=meshgrid(params.edges{1}(1:end-1),params.edges{2}(1:end-1));
            [Xe, Ye]=meshgrid(params.edges{1}(2:end),params.edges{2}(2:end));
            
            Xs=reshape(Xs,1,numel(Xs));
            Ys=reshape(Ys,1,numel(Ys));
            Xe=reshape(Xe,1,numel(Xe));
            Ye=reshape(Ye,1,numel(Ye));
            
            patchesx=[Xs(sel) ; Xs(sel) ; Xe(sel) ; Xe(sel)];
            patchesy=[Ys(sel) ; Ye(sel) ; Ye(sel) ; Ys(sel)];
            
            %If we have varied-size patches (we use rounding to
            %get away with numerical issues of unique
            if length(unique(round(diff(params.edges{1})*1e10)))>1 || length(unique(round(diff(params.edges{2})*1e10)))>1
                %Correct values by the area of each patch ?
                Nr=Nr./((Xe-Xs).*(Ye-Ys));
                obj.aes_names.color='Count/area';
            else
                obj.aes_names.color='Count';
            end
            
        end
        
        
        
        
        
        %patchesz=[Nr(sel) ; Nr(sel) ; Nr(sel) ; Nr(sel) ];
        
        %p=patch(patchesx,patchesy,patchesz,Nr(sel));
        hndl=patch(patchesx,patchesy,Nr(sel));
        set(hndl,'edgeColor','none')
        
        %Store color values
        obj.plot_lim.maxc(obj.current_row,obj.current_column)=max(Nr);
        obj.plot_lim.minc(obj.current_row,obj.current_column)=min(Nr);
        
        
    case 'point'
        [X,Y] = meshgrid(C{1},C{2});
        X=reshape(X,1,numel(X));
        Y=reshape(Y,1,numel(Y));
        Nr=reshape(N',1,numel(N));
        sel=Nr>0;
        %hndl=point_patch(X(sel),Y(sel),Nr(sel)*(C{1}(2)-C{1}(1))/30,draw_data.color,20,ratio);
        hndl=scatter(X(sel),Y(sel),Nr(sel)*10,draw_data.marker,'MarkerEdgeColor',draw_data.color,'MarkerFaceColor','none');
end

obj.results.stat_bin2d{obj.result_ind,1}.handle=hndl;

end