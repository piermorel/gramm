function obj=geom_line(obj,varargin)
% geom_line Display data as lines
%
% Example syntax: gramm_object.geom_line('ordered',false,'alpha',1)
% Supports color, lightness, linestyle and size groups. If x and y are 1D
% arrays, all the points within a group are connected: if the data is not
% properly grouped/ordered things can look weird.
%
% Parameters given as 'name',value pairs:
% - 'dodge': Spacing between lines of different colors within an
%            unique x value (default 0)
% - 'alpha': Transparency of lines, from 0 (transparent) to 1 (opaque)
%            (default 1)
% - 'stacked': Stack the lines of the different groups and shade the
%            areas between them (only with 1D arrays for x and y)
%            (default false)
% - 'fill_to': If set to a y value, shade the area between the lines and
%            this value (default [])
% - 'fill': Former name of 'fill_to' (default [])
% - 'fill_alpha': Transparency of the shaded areas, from 0 to 1
%            (default 0.4)
% - 'ordered': Order the points of each line along x, so that the line
%            doesn't go back on itself (only with 1D arrays for x and y)
%            (default false)

p=inputParser;
addParameter(p,'dodge',0,@(v) valid_range(v,0,Inf));
addParameter(p,'alpha',1,@(v) valid_range(v,0,1));
addParameter(p,'stacked',false);
addParameter(p,'fill_to',[]);
addParameter(p,'fill',[]); %Former name of 'fill_to'
addParameter(p,'fill_alpha',0.4,@(v) valid_range(v,0,1));
addParameter(p,'ordered',false);
parse(p,varargin{:});

params=p.Results;
if isempty(params.fill_to)
    params.fill_to=params.fill;
end

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_line(dobj,dd,params)});
obj.results.geom_line_handle={};
end


function hndl=my_line(obj,draw_data,params)



if obj.continuous_color_options.active
    
    obj.plot_lim.maxc(obj.current_row,obj.current_column)=max(obj.plot_lim.maxc(obj.current_row,obj.current_column),max(comb(draw_data.continuous_color)));
    obj.plot_lim.minc(obj.current_row,obj.current_column)=min(obj.plot_lim.minc(obj.current_row,obj.current_column),min(comb(draw_data.continuous_color)));
    
    if isempty(draw_data.z)
        [x,y]=close_polar(obj,draw_data.x,draw_data.y);

        %We fake continuous colors lines by creating patch objects
        %without fill. Since they need to be closed we draw the
        %line twice
        if iscell(x)
            for k=1:length(x)
                if iscell(draw_data.continuous_color) %Within-line continuous color given
                    hndl=patch([shiftdim(x{k}) ; flipud(shiftdim(x{k}))],...
                        [shiftdim(y{k}) ; flipud(shiftdim(y{k}))],...
                        [shiftdim(draw_data.continuous_color{k}) ; flipud(shiftdim(draw_data.continuous_color{k}))],...
                        'faceColor','none','EdgeColor','interp','lineWidth',draw_data.line_size,'LineStyle',draw_data.line_style);
                else %Per-line continuous color given
                    hndl=patch([shiftdim(x{k}) ; flipud(shiftdim(x{k}))],...
                        [shiftdim(y{k}) ; flipud(shiftdim(y{k}))],...
                        repmat(draw_data.continuous_color(k),length(x{k})*2,1),...
                        'faceColor','none','EdgeColor','interp','lineWidth',draw_data.line_size,'LineStyle',draw_data.line_style);
                end
            end
        else
            hndl=patch([shiftdim(x) ; flipud(shiftdim(x))],...
                [shiftdim(y) ; flipud(shiftdim(y))],...
                [shiftdim(draw_data.continuous_color) ; flipud(shiftdim(draw_data.continuous_color))],...
                'faceColor','none','EdgeColor','interp','lineWidth',draw_data.line_size,'LineStyle',draw_data.line_style);
        end
    else
        if iscell(draw_data.x)
            for k=1:length(draw_data.x)
                if iscell(draw_data.continuous_color) %Within-line continuous color given
                    hndl=patch([shiftdim(draw_data.x{k}) ; flipud(shiftdim(draw_data.x{k}))],...
                        [shiftdim(draw_data.y{k}) ; flipud(shiftdim(draw_data.y{k}))],...
                        [shiftdim(draw_data.z{k}) ; flipud(shiftdim(draw_data.z{k}))],...
                        [shiftdim(draw_data.continuous_color{k}) ; flipud(shiftdim(draw_data.continuous_color{k}))],...
                        'faceColor','none','EdgeColor','interp','lineWidth',draw_data.line_size,'LineStyle',draw_data.line_style);
                else %Per-line continuous color given
                    hndl=patch([shiftdim(draw_data.x{k}) ; flipud(shiftdim(draw_data.x{k}))],...
                        [shiftdim(draw_data.y{k}) ; flipud(shiftdim(draw_data.y{k}))],...
                        [shiftdim(draw_data.z{k}) ; flipud(shiftdim(draw_data.z{k}))],...
                        repmat(draw_data.continuous_color(k),length(draw_data.x{k})*2,1),...
                        'faceColor','none','EdgeColor','interp','lineWidth',draw_data.line_size,'LineStyle',draw_data.line_style);
                end
            end
        else
            hndl=patch([shiftdim(draw_data.x) ; flipud(shiftdim(draw_data.x))],...
                [shiftdim(draw_data.y) ; flipud(shiftdim(draw_data.y))],...
                [shiftdim(draw_data.z) ; flipud(shiftdim(draw_data.z))],...
                [shiftdim(draw_data.continuous_color) ; flipud(shiftdim(draw_data.continuous_color))],...
                'faceColor','none','EdgeColor','interp','lineWidth',draw_data.line_size,'LineStyle',draw_data.line_style);
        end
    end
    
    
else
    %Combnan allows for drawing multiple lines without loops
    %(it adds a NaN between lines that have to be separated)
    if isempty(draw_data.z)
        

        

        if params.stacked || ~isempty(params.fill_to)
            
            if iscell(draw_data.x) || iscell(draw_data.y)
                warning('''stacked'' or ''fill_to'' options require simple array input for x and y');
                obj.results.geom_line_handle{obj.result_ind,1}=[];
                return;
            end
            
            if length(unique(draw_data.x))<length(draw_data.x)
                warning('''stacked'' or ''fill_to'' options will produce unexpected results with non unique x values');
            end

            [x,i]=sort(draw_data.x);
            y=draw_data.y(i);


            if params.stacked
                [xline, bottom, top] = stacker(obj,x,y,draw_data.facet_x,params.fill_to,'line');
            else
                xline = x(:)';
                bottom = zeros(1,length(x))+params.fill_to;
                top = y(:)';
            end

            xpatch = [xline(1:end-1) ; xline(2:end) ; xline(2:end) ; xline(1:end-1)];
            ypatch = log_base(obj,[top(1:end-1); top(2:end) ; bottom(2:end) ; bottom(1:end-1)]);

            obj.results.geom_line_fill_handle{obj.result_ind,1}=patch(xpatch,ypatch,[1 1 1],...
                'FaceColor',draw_data.color,...
                'EdgeColor','none',...
                'FaceAlpha',params.fill_alpha,...
                'EdgeAlpha', params.alpha);

            hndl=patch('XData',combnan(xline),'YData',combnan(top),...
                'LineStyle',draw_data.line_style,'LineWidth',draw_data.line_size,'EdgeColor',draw_data.color);

            if obj.plot_lim.maxy(obj.current_row,obj.current_column)<max(top)
                obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(top);
            end

        else
            
            x=combnan(draw_data.x);
            y=combnan(draw_data.y);
            x=dodger(x,draw_data,params.dodge);
            if params.ordered 
                [x,i]=sort(x);
                y=y(i);
            end

            [x,y]=close_polar(obj,x,y);
            hndl=patch('XData',combnan(x),'YData',combnan(y),...
                'LineStyle',draw_data.line_style,'LineWidth',draw_data.line_size,'EdgeColor',draw_data.color);
        end


    else
        hndl=patch('XData',combnan(draw_data.x),'YData',combnan(draw_data.y),'ZData',combnan(draw_data.z),...
            'LineStyle',draw_data.line_style,'LineWidth',draw_data.line_size,'EdgeColor',draw_data.color);
    end
end

if ~isempty(hndl)
    hndl.EdgeAlpha = params.alpha;
end

obj.results.geom_line_handle{obj.result_ind,1}=hndl;

end