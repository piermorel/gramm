function obj=stat_bin(obj,varargin)
% geom_point Displays an histogram of the data in x
%
% Example syntax (default arguments): gramm_object.stat_bin('nbins',30,'geom','bar')
% Options can be given as 'name',value pairs:
% - 'geom' can be 'bar', 'overlaid_bar', 'line', 'stairs', 'point' or 'stacked_bar'
% The 'normalization' argument allows to optionally normalize
% the bin counts (see the doc for Matlab's histcounts() ).
% Default is 'count', for normalization to 1 use 'probability'
% Instead of 'nbins', it is possible to directly specify bin
% edges with 'edges'. If the specified bin widths are not
% equal, it's recommended to use 'countdensity'
% or 'pdf' for normalization. Aspect of the geoms can be
% customized with the 'fill' option
% ('edge','face','all','transparent')

p=inputParser;
my_addParameter(p,'nbins',30);
my_addParameter(p,'edges',[]);
my_addParameter(p,'geom','bar'); %line, bar, overlaid_bar, stacked_bar,stairs, point
my_addParameter(p,'normalization','count');
my_addParameter(p,'fill',[]); %edge,face,all,transparent
my_addParameter(p,'width',[]);
my_addParameter(p,'dodge',[]);
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dd)my_bin(obj,dd,p.Results)});
obj.results.stat_bin={};
end


function hndl=my_bin(obj,draw_data,params)

%Presets for dodge parameter
if isempty(params.dodge)
    if strcmp(params.geom,'bar') && draw_data.n_colors>1  %With 'bar' do we dodge by default if there are several colors
        params.dodge=0.8;
    else
        params.dodge=0; %With all others we put don't dodge
    end
end

%Presets for width parameter
if isempty(params.width)
    if params.dodge>0
        params.width=params.dodge; %If there is a dodge we modify the width accordingly
    else
        params.width=1; %Otherwise we use the full with (histogram).
    end
end


%Set up default fill options for the different geoms
if isempty(params.fill)
    switch params.geom
        case 'bar'
            params.fill='face';
        case 'line'
            params.fill='edge';
        case 'overlaid_bar'
            params.fill='transparent';
        case 'stacked_bar'
            params.fill='face';
        case 'stairs'
            params.fill='edge';
        case 'point'
            params.fill='edge';
    end
end


%Compute bins
if obj.x_factor %For categorical Xs (placed at integer values), we override and make the bins 0.5 1.5 2.5 ...
    binranges=(0:length(obj.x_ticks))+0.5;
    bincenters=1:length(obj.x_ticks);
else
    if obj.polar.is_polar %For polar coordinates we make bin around 0:2pi
        %Make data modulo 2pi
        draw_data.x=mod(comb(draw_data.x),2*pi);
        if isempty(params.edges)
            binranges=linspace(0,2*pi,params.nbins+1);
        else
            if max(params.edges)>2*pi || min(params.edges)<0
                warning('Bin edges exceed the polar ranges (O-2pi)')
            end
            binranges=params.edges;
        end
    else
        if isempty(params.edges)
            binranges=linspace(obj.var_lim.minx,obj.var_lim.maxx,params.nbins+1);
        else
            binranges=params.edges;
        end
    end
    bincenters=(binranges(1:(end-1))+binranges(2:end))/2;
end

%Find actual counts
if iscell(draw_data.x) %If data was provided as Cell/Matrix
    %We do the count individually for each element and average
    %the counts
    bincounts=zeros(1,length(binranges)-1);
    for k=1:length(draw_data.x)
        bincounts=bincounts+my_histcounts(draw_data.x{k},binranges,params.normalization);
    end
    bincounts=bincounts/length(draw_data.x);
else
    %If data was provided as vector we just count
    bincounts = my_histcounts(comb(draw_data.x),binranges,params.normalization);
end

bincounts=shiftdim(bincounts);

obj.results.stat_bin{obj.result_ind,1}.edges=bincenters;
obj.results.stat_bin{obj.result_ind,1}.counts=bincounts;

%Set axis limits
obj.plot_lim.miny(obj.current_row,obj.current_column)=0;
if obj.firstrun(obj.current_row,obj.current_column)
    obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(bincounts);
    
    if ~isempty(params.edges) %If edges are specified we use those for x scale
        obj.plot_lim.minx(obj.current_row,obj.current_column)=binranges(1)-nanmean(diff(binranges));
        obj.plot_lim.maxx(obj.current_row,obj.current_column)=binranges(end)+nanmean(diff(binranges));
    end
    
    %obj.firstrun(obj.current_row,obj.current_column)=0;
    obj.aes_names.y=params.normalization;
    %Initialize stacked bar
    obj.extra.stacked_bar_height=zeros(size(bincenters));
else
    if max(obj.extra.stacked_bar_height+bincounts(1:end)')>obj.plot_lim.maxy(obj.current_row,obj.current_column)
        obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(bincounts(1:end)'+obj.extra.stacked_bar_height);
    end
    if max(bincounts)>obj.plot_lim.maxy(obj.current_row,obj.current_column)
        obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(bincounts);
    end
end



%Set up colors according to fill
face_alpha=1;
edge_alpha=0.8;
switch params.fill
    case 'edge'
        edge_color=draw_data.color;
        face_color=draw_data.color;
        face_alpha=0;
    case 'face'
        edge_color='k';
        edge_alpha=1;
        face_color=draw_data.color;
    case 'all'
        edge_color=draw_data.color;
        edge_alpha=0;
        face_color=draw_data.color;
    case 'transparent'
        edge_color=draw_data.color;
        face_color=draw_data.color;
        face_alpha=0.4;
end



%Set up dodging & width for bars
avl_w=diff(binranges);
dodging=avl_w.*params.dodge./(draw_data.n_colors);
if params.dodge>0
    bar_width=avl_w.*params.width./(draw_data.n_colors);
else
    bar_width=avl_w.*params.width;
end
bar_mid=bincenters-0.5*dodging*draw_data.n_colors+dodging*0.5+(draw_data.color_index-1)*dodging;
bar_left=bar_mid-0.5*bar_width;
bar_right=bar_mid+0.5*bar_width;


spacing=1-params.width;

%overlaid_bar is just a bar without dodging
if strcmp(params.geom,'overlaid_bar')
    params.geom='bar';
end

switch params.geom
    case 'bar'
        xpatch=[bar_right ; bar_left ; bar_left ; bar_right];
        ypatch=[zeros(1,length(bincounts)) ; zeros(1,length(bincounts)) ; bincounts' ; bincounts'];
        [xpatch,ypatch]=to_polar(obj,xpatch,ypatch);
        obj.results.stat_bin{obj.result_ind,1}.bar_handle=patch(xpatch,...
            ypatch,...
            [1 1 1],'FaceColor',face_color,'EdgeColor',edge_color,'FaceAlpha',face_alpha,'EdgeAlpha',edge_alpha);
        
    case 'line'
        xtemp=bar_mid;
        ytemp=bincounts(1:end)';
        [xtemp,ytemp]=to_polar(obj,xtemp,ytemp);
        obj.results.stat_bin{obj.result_ind,1}.line_handle=plot(xtemp,ytemp,'LineStyle',draw_data.line_style,'Color',edge_color,'lineWidth',draw_data.size/4);
        xpatch=[bar_mid(1:end-1) ; bar_mid(2:end) ; bar_mid(2:end);bar_mid(1:end-1)];
        ypatch=[zeros(1,length(bincounts)-1) ; zeros(1,length(bincounts)-1) ; bincounts(2:end)' ; bincounts(1:end-1)'];
        [xpatch,ypatch]=to_polar(obj,xpatch,ypatch);
        obj.results.stat_bin{obj.result_ind,1}.fill_handle=patch(xpatch,ypatch,[1 1 1],'FaceColor',face_color,'EdgeColor','none','FaceAlpha',face_alpha);
        
    case 'stacked_bar'
        xpatch=[binranges(1:end-1)+spacing ; binranges(2:end)-spacing ; binranges(2:end)-spacing ; binranges(1:end-1)+spacing];
        ypatch=[obj.extra.stacked_bar_height ; obj.extra.stacked_bar_height ; obj.extra.stacked_bar_height+bincounts' ; obj.extra.stacked_bar_height+bincounts'];
        [xpatch,ypatch]=to_polar(obj,xpatch,ypatch);
        obj.results.stat_bin{obj.result_ind,1}.bar_handle=patch(xpatch,...
            ypatch,...
            [1 1 1],'FaceColor',face_color,'EdgeColor',edge_color,'FaceAlpha',face_alpha,'EdgeAlpha',edge_alpha);
        obj.extra.stacked_bar_height=obj.extra.stacked_bar_height+bincounts';
    case 'stairs'
        xtemp=[binranges(1:end-1) ; binranges(2:end)];
        ytemp=[bincounts' ; bincounts'];
        [xtemp,ytemp]=to_polar(obj,xtemp(:),ytemp(:));
        obj.results.stat_bin{obj.result_ind,1}.line_handle=plot(xtemp,ytemp,'LineStyle',draw_data.line_style,'Color',edge_color,'lineWidth',draw_data.size/4);
        
        xpatch=[binranges(1:end-1) ; binranges(2:end) ; binranges(2:end) ; binranges(1:end-1)];
        ypatch=[obj.extra.stacked_bar_height ; obj.extra.stacked_bar_height ; obj.extra.stacked_bar_height+bincounts' ; obj.extra.stacked_bar_height+bincounts'];
        [xpatch,ypatch]=to_polar(obj,xpatch,ypatch);
        
        obj.results.stat_bin{obj.result_ind,1}.fill_handle=patch(xpatch,ypatch,[1 1 1],'FaceColor',face_color,'EdgeColor','none','FaceAlpha',face_alpha);
        
    case 'point'
        xtemp=bar_mid;
        ytemp=bincounts(1:end)';
        [xtemp,ytemp]=to_polar(obj,xtemp,ytemp);
        obj.results.stat_bin{obj.result_ind,1}.point_handle=plot(xtemp,ytemp,draw_data.marker,'MarkerEdgeColor','none','markerSize',draw_data.size,'MarkerFaceColor',draw_data.color);
end

end
