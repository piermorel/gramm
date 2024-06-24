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


p=inputParser;
p.KeepUnmatched=true;
my_addParameter(p,'width',0.6);
my_addParameter(p,'stacked',false);
my_addParameter(p,'dodge',0);
my_addParameter(p,'FaceColor','auto');
my_addParameter(p,'EdgeColor','k');
my_addParameter(p,'LineWidth',[]);
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
    LineWidth=draw_data.line_size;
else
    % overloaded LineWidth via input arguments
    LineWidth=params.LineWidth;
end

if params.stacked
    
    %Problem with stacked bar when different x values are used
    if obj.firstrun(obj.current_row,obj.current_column)
        %Store heights at the level of dodge x
        obj.extra.stacked_bar_height=zeros(1,length(draw_data.facet_x));
        %obj.plot_lim.minx(obj.current_row,obj.current_column)=min(x)-width;
        %obj.plot_lim.maxx(obj.current_row,obj.current_column)=max(x)+width;
    end
    
    % Stack index is used to keep track of the stacks
    x_stack_ind=arrayfun(@(xin)find(abs(draw_data.facet_x-xin)<1e-10,1),x);
    
    % Calculate bar patch left/right coordinates
    barleft=x-width/2;
    barright=x+width/2;
    
    % Calculate bar patch top/bottom coordinates
    barbottom=zeros(size(x));
    bartop=zeros(size(x));
    for k=1:length(x) %Loop in order to make stacked bar height cumulative even when plotted at the same x/color
        barbottom(k)=obj.extra.stacked_bar_height(x_stack_ind(k));
        bartop(k)=obj.extra.stacked_bar_height(x_stack_ind(k))+y(k);
        obj.extra.stacked_bar_height(x_stack_ind(k))=obj.extra.stacked_bar_height(x_stack_ind(k))+y(k);
    end

    xpatch=[barleft ; barright ; barright ; barleft];
    ypatch=[barbottom ; barbottom ; bartop ; bartop];
    [xpatch,ypatch]=to_polar(obj,xpatch,ypatch);
     
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

% Convert unmatched structure to cell array of name-value pairs
args=my_struct2cell(unmatched);

% Draw the bars
hndl=patch(xpatch,ypatch,[1 1 1],...
    'FaceColor',FaceColor,...
    'EdgeColor',EdgeColor,...
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