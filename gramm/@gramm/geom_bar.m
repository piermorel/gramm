function obj=geom_bar(obj,varargin)
% geom_bar Display data as bars
%
% Example syntax (default arguments): gramm_object.geom_bar('width',0.6)
% This will add a layer that will display data as bars. When
% data in several colors has to be displayed, the bars of
% different colors are dodged.
%
% Parameters given as 'name',value pairs:
% - 'width': Width of the bars (default 0.6)
% - 'stacked': Set to true to stack bars instead of dodging them (default false)
% - 'dodge': Spacing between bars of different colors within an unique x value (default 0)
% - 'FaceColor': Face color of bars, can be 'auto' to use data color (default 'auto')
% - 'EdgeColor': Edge color of bars, can be 'auto' to use data color (default 'k')
% - 'fill': Fill style, can be 'edge', 'face', 'all', or 'transparent' (default [])
% - 'fill_alpha': Transparency of the bar faces, from 0 (transparent) to
%   1 (opaque). If empty, set by the fill style (default [])
% - 'LineWidth': Width of bar edges (default uses line_size from data)

if mod(numel(varargin),2)~=0
    error('Improper number of ''name'',value argument pairs')
end


p=inputParser;
p.KeepUnmatched=true;
addParameter(p,'width',0.6,@(v) valid_range(v,0,Inf));
addParameter(p,'stacked',false);
addParameter(p,'dodge',0,@(v) valid_range(v,0,Inf));
addParameter(p,'FaceColor','auto');
addParameter(p,'EdgeColor','k');
addParameter(p,'fill',[],@(v) isempty(v) || valid_choice(v,{'edge','face','all','transparent'}));
addParameter(p,'fill_alpha',[],@(v) valid_range(v,0,1,true));
addParameter(p,'LineWidth',[]);
parse(p,varargin{:});

obj.geom=vertcat(obj.geom,{@(dobj,dd)my_bar(dobj,dd,p.Results,p.Unmatched)});
obj.results.geom_bar_handle={};
end



function hndl=my_bar(obj,draw_data,params,unmatched)
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
if ~isempty(params.fill)
    %Set up colors according to fill
    [FaceColor , FaceAlpha , EdgeColor , EdgeAlpha] = parse_fill (params.fill,draw_data.color,params.fill_alpha);
else
    FaceAlpha = 1;
    if ~isempty(params.fill_alpha)
        FaceAlpha = params.fill_alpha;
    end
    EdgeAlpha = 1;
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
end

if isempty(params.LineWidth)
    LineWidth=draw_data.line_size;
else
    % overloaded LineWidth via input arguments
    LineWidth=params.LineWidth;
end

if params.stacked

    [bar_x,barbottom, bartop] = stacker(obj,x,y,draw_data.facet_x,0,'bar');

    barleft=bar_x-width/2;
    barright=bar_x+width/2;

    [xpatch,ypatch]=bar_patch(barleft,barright,barbottom,bartop);

    if obj.plot_lim.maxy(obj.current_row,obj.current_column)<max(bartop)
        obj.plot_lim.maxy(obj.current_row,obj.current_column)=max(bartop);
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
    [xpatch,ypatch]=bar_patch(barleft,barright,zeros(1,length(y)),y);

end

% Hide zero-height bars (NaN faces are not drawn): their degenerate faces
% can be rendered as a stray horizontal line extending out of the axes
ypatch(:,ypatch(1,:)==ypatch(3,:))=NaN;
ypatch=log_base(obj,ypatch);
[xpatch,ypatch]=polar_arcs(obj,xpatch,ypatch);

% Convert unmatched structure to cell array of name-value pairs
args=my_struct2cell(unmatched);


hndl=patch(xpatch,ypatch,[1 1 1],...
    'FaceColor',FaceColor,...
    'EdgeColor',EdgeColor,...
    'FaceAlpha',FaceAlpha,...
    'EdgeAlpha',EdgeAlpha,...
    'LineWidth',LineWidth, args{:});

% Assign bar handle to obj
obj.results.geom_bar_handle{obj.result_ind,1}=hndl;

end

function c=my_struct2cell(s)
% Convert structure cell array with name-value pairs

fn=fieldnames(s);
nf=length(fn);
c=cell(1,2*nf);
c(1:2:end)=fn;
for n=1:nf
    c{2*n}=s.(fn{n});
end

end