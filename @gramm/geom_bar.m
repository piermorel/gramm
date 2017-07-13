function obj=geom_bar(obj,varargin)
% geom_point Display data as bars
%
% Example syntax (default arguments): gramm_object.geom_bar(0.8)
% This will add a layer that will display data as bars. When
% data in several colors has to be displayed, the bars of
% different colors are dodged. The function can receive an
% optional argument specifying the width of the bar

if mod(numel(varargin),2)~=0
    error('Improper number of ''name'',value argument pairs')
end

% Alternative input parsing (not using Matlab's inputParser), 
% to allow the final varargin to be non-empty 
params=struct();
[params.width,varargin] = get_name_value_pair(varargin{:},'width',0.8);
[params.stacked,varargin] = get_name_value_pair(varargin{:},'stacked',false);
[params.dodge,varargin] = get_name_value_pair(varargin{:},'dodge',0);
[params.FaceColor,varargin] = get_name_value_pair(varargin{:},'FaceColor','auto');
[params.EdgeColor,varargin] = get_name_value_pair(varargin{:},'EdgeColor','k');
[params.LineWidth,varargin] = get_name_value_pair(varargin{:},'LineWidth',[]);

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_bar(dobj,dd,params,varargin{:})});
obj.results.geom_bar_handle={};
end



function hndl=my_bar(obj,draw_data,params,varargin)
width=params.width;
dodge=params.dodge;

% combine cell data into single array
x=comb(draw_data.x);
y=comb(draw_data.y);

if min(y)>0
    obj.plot_lim.miny(obj.current_row,obj.current_column)=0;
end
if max(y)<0
    obj.plot_lim.maxy(obj.current_row,obj.current_column)=0;
end
    
% Convert to a row vector, the same as x(:).'
x=shiftdim(x)';
y=shiftdim(y)';
          
% Check for automatic Face- and EdgeColor options
if strcmp(params.FaceColor,'auto')
    FaceColor=draw_data.color;
else
    FaceColor=params.FaceColor;
end
if strcmp(params.EdgeColor,'auto')
    EdgeColor=draw_data.color;
else
    EdgeColor=params.EdgeColor;
end
if isempty(params.LineWidth)
    % Note: default used to be 0.5, but taking it from draw_data seems
    % nice, then users can set it via set_line_options.
    LineWidth=draw_data.line_size;
else
    %overloaded LineWidth via input arguments
    LineWidth=params.LineWidth;
end


if params.stacked
    
    %Problem with stacked bar when different x values are used
    if obj.firstrun(obj.current_row,obj.current_column)
        %Store heights at the level of dodge x
        obj.extra.stacked_bar_height=zeros(1,length(draw_data.dodge_x));
        obj.plot_lim.minx(obj.current_row,obj.current_column)=min(x)-width;
        obj.plot_lim.maxx(obj.current_row,obj.current_column)=max(x)+width;
        %obj.firstrun(obj.current_row,obj.current_column)=0;
    end
    
    % Stack index is used to keep track of the stacks
    x_stack_ind=arrayfun(@(xin)find(abs(draw_data.dodge_x-xin)<1e-10,1),x);
    
    % Calculate bar patch coordinates
    barleft=x-width/2;
    barright=x+width/2;
    barbottom=obj.extra.stacked_bar_height(x_stack_ind);
    bartop=obj.extra.stacked_bar_height(x_stack_ind)+y;
    xpatch=[barleft ; barright ; barright ; barleft];
    ypatch=[barbottom ; barbottom ; bartop ; bartop];
    [xpatch,ypatch]=to_polar(obj,xpatch,ypatch);       
    
    obj.extra.stacked_bar_height(x_stack_ind)=obj.extra.stacked_bar_height(x_stack_ind)+y;
    if obj.plot_lim.maxy(obj.current_row,obj.current_column)<max(obj.extra.stacked_bar_height)
        obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(obj.extra.stacked_bar_height);
    end
    
else
    
    % Calculate dodged positions
    if dodge>0
        bar_width=draw_data.dodge_avl_w*width./(draw_data.n_colors);
    else
        bar_width=draw_data.dodge_avl_w*width;
    end
    x=dodger(x',draw_data,dodge)';
            
    % Calculate bar patch coordinates
    barleft=x-bar_width/2;
    barright=x+bar_width/2;
    xpatch=[barleft ; barright ; barright ; barleft];
    ypatch=[zeros(1,length(y)) ; zeros(1,length(y)) ; y ; y];
    [xpatch,ypatch]=to_polar(obj,xpatch,ypatch);
    
end

% Draw the bars
hndl=patch(xpatch,ypatch,[1 1 1],...
    'FaceColor',FaceColor,...
    'EdgeColor',EdgeColor,...
    'LineWidth',LineWidth, varargin{:});
    
% Assign bar handle to obj
obj.results.geom_bar_handle{obj.result_ind,1}=hndl;


end