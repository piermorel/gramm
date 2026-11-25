function [results] = my_histplot(obj,draw_data,params,setylim)

%Presets for dodge parameter
if isempty(params.dodge)
    if strcmp(params.geom,'bar') && draw_data.n_dodge>1  %With 'bar' do we dodge by default if there are several colors
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
        case 'stacked_bars'
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
if obj.x_factor && obj.polar.is_polar %Categorical Xs evenly spread around the circle
    step=2*pi/length(obj.x_ticks);
    binranges=((0:length(obj.x_ticks))-0.5)*step;
    bincenters=(0:length(obj.x_ticks)-1)*step;
elseif obj.x_factor %For categorical Xs (placed at integer values), we override and make the bins 0.5 1.5 2.5 ...
    binranges=(0:length(obj.x_ticks))+0.5;
    bincenters=1:length(obj.x_ticks);
else
    if obj.polar.is_polar %For polar coordinates we make bin around 0:2pi
        %Make data modulo 2pi
        draw_data.x=mod(comb(draw_data.x),2*pi);
        if isempty(params.edges)
            binranges=linspace(0,2*pi,params.nbins+1);
        else
            binranges=to_num(obj.axis_types.x,params.edges); %Degrees to radians
            if max(binranges)>2*pi || min(binranges)<0
                warning('Bin edges exceed the polar range (0-360 degrees or 0-2pi)')
            end
        end
    else
        binranges=bin_edges(obj,params.edges,params.bin_width,params.nbins);
    end
    bincenters=(binranges(1:(end-1))+binranges(2:end))/2;
end





%Find actual counts
if iscell(draw_data.x) %If data was provided as Cell/Matrix
    %We do the count individually for each element and average
    %the counts
    bincounts=zeros(1,length(binranges)-1);
    for k=1:length(draw_data.x)
        bincounts=bincounts+histcounts(draw_data.x{k},binranges,'Normalization',params.normalization);
    end
    bincounts=bincounts/length(draw_data.x);
else
    %If data was provided as vector we just count
    bincounts = histcounts(comb(draw_data.x),binranges,'Normalization',params.normalization);
end

bincounts=shiftdim(bincounts);

results.edges=binranges;
results.centers=bincenters;
results.counts=bincounts;


if setylim
    %Set axis limits
    obj.plot_lim.miny(obj.current_row,obj.current_column)=0;
    if obj.firstrun(obj.current_row,obj.current_column)
        obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(bincounts);
        
        if ~isempty(params.edges) || ~isempty(params.bin_width) %If edges or bin widths are specified we use the edges for x scale
            obj.plot_lim.minx(obj.current_row,obj.current_column)=binranges(1)-mean(diff(binranges),'omitnan');
            obj.plot_lim.maxx(obj.current_row,obj.current_column)=binranges(end)+mean(diff(binranges),'omitnan');
        end
        
        %obj.firstrun(obj.current_row,obj.current_column)=0;
        if strcmp(obj.aes_names.y,'y')
            obj.aes_names.y=params.normalization;
        end
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
    
end


%Set up colors according to fill
[face_color , face_alpha , edge_color , edge_alpha] = parse_fill (params.fill,draw_data.color,params.fill_alpha);



%Set up dodging & width for bars
avl_w=diff(binranges);
dodging=avl_w.*params.dodge./(draw_data.n_dodge);
if params.dodge>0
    bar_width=avl_w.*params.width./(draw_data.n_dodge);
else
    bar_width=avl_w.*params.width;
end
bar_mid=bincenters-0.5*dodging*draw_data.n_dodge+dodging*0.5+(draw_data.dodge_index-1)*dodging;
bar_left=bar_mid-0.5*bar_width;
bar_right=bar_mid+0.5*bar_width;


spacing=1-params.width;

%overlaid_bar is just a bar without dodging
if strcmp(params.geom,'overlaid_bar')
    params.geom='bar';
end

switch params.geom
    case 'bar'
        [xpatch,ypatch]=bar_patch(obj,bar_left,bar_right,zeros(1,length(bincounts)),bincounts');
        [xpatch,ypatch]=polar_arcs(obj,xpatch,ypatch);
        results.bar_handle=patch(xpatch,...
            ypatch,...
            [1 1 1],'FaceColor',face_color,'EdgeColor',edge_color,'FaceAlpha',face_alpha,'EdgeAlpha',edge_alpha,...
            'LineWidth',draw_data.edge_size,'LineStyle',draw_data.line_style);
        
    case 'line'
        xtemp=bar_mid;
        ytemp=bincounts(1:end)';
        [xtemp,ytemp]=close_polar(obj,xtemp,ytemp);
        results.line_handle=plot(xtemp,ytemp,'LineStyle',draw_data.line_style,'Color',edge_color,'lineWidth',draw_data.line_size);
        xpatch=[bar_mid(1:end-1) ; bar_mid(2:end) ; bar_mid(2:end);bar_mid(1:end-1)];
        ypatch=log_base(obj,[zeros(1,length(bincounts)-1) ; zeros(1,length(bincounts)-1) ; bincounts(2:end)' ; bincounts(1:end-1)']);
        results.fill_handle=patch(xpatch,ypatch,[1 1 1],'FaceColor',face_color,'EdgeColor','none','FaceAlpha',face_alpha);
        
    case 'stacked_bar'
        [xpatch,ypatch]=bar_patch(obj,binranges(1:end-1)+spacing,binranges(2:end)-spacing,obj.extra.stacked_bar_height,obj.extra.stacked_bar_height+bincounts');
        [xpatch,ypatch]=polar_arcs(obj,xpatch,ypatch);
        results.bar_handle=patch(xpatch,...
            ypatch,...
            [1 1 1],'FaceColor',face_color,'EdgeColor',edge_color,'FaceAlpha',face_alpha,'EdgeAlpha',edge_alpha,...
            'LineWidth',draw_data.edge_size,'LineStyle',draw_data.line_style);
        obj.extra.stacked_bar_height=obj.extra.stacked_bar_height+bincounts';
    case 'stairs'
        xtemp=[binranges(1:end-1) ; binranges(2:end)];
        ytemp=[bincounts' ; bincounts'];
        [xtemp,ytemp]=polar_arcs(obj,xtemp(:),ytemp(:),false);
        results.line_handle=plot(xtemp,ytemp,'LineStyle',draw_data.line_style,'Color',edge_color,'lineWidth',draw_data.line_size);
        
        xpatch=[binranges(1:end-1) ; binranges(2:end) ; binranges(2:end) ; binranges(1:end-1)];
        ypatch=log_base(obj,[obj.extra.stacked_bar_height ; obj.extra.stacked_bar_height ; obj.extra.stacked_bar_height+bincounts' ; obj.extra.stacked_bar_height+bincounts']);
        [xpatch,ypatch]=polar_arcs(obj,xpatch,ypatch);
        
        results.fill_handle=patch(xpatch,ypatch,[1 1 1],'FaceColor',face_color,'EdgeColor','none','FaceAlpha',face_alpha);
        
    case 'point'
        xtemp=bar_mid;
        ytemp=bincounts(1:end)';
        point_props=marker_props(obj,draw_data);
        results.point_handle=plot(xtemp,ytemp,point_props{:});
end


end

