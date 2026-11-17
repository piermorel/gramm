function obj = geom_label(obj,varargin)
% geom_label Display the label data as text
%
% Example syntax: gramm_object.geom_label('Color','auto','dodge',0.6)
% Displays the text given as 'label' to gramm(), at the x and y locations.
% Appearance of the text can be customized with any text() property given
% as 'name',value pair.
%
% Parameters given as 'name',value pairs:
% - 'dodge': Spacing between labels of different colors within an unique
%            x value (default 0)
% - 'Color': Color of the text, or 'auto' for the gramm color (default
%            'auto')
% - 'EdgeColor': Color of the text box edge, can be 'auto' for the gramm
%            color
% - 'BackgroundColor': Color of the text box, can be 'auto' for the gramm
%            color



%Look in varargin
if mod(numel(varargin),2)~=0
    error('Improper number of ''name'',value argument pairs')
end


obj.geom=vertcat(obj.geom,{@(dobj,dd)my_label(dobj,dd,varargin)});
obj.results.geom_label_handle={};

end

function hndl=my_label(obj,draw_data,params)

if isnumeric(draw_data.label)
    draw_data.label=cellfun(@(c)num2str(c),num2cell(draw_data.label),'UniformOutput',false);
end

if iscell(draw_data.x)
    disp('Unsupported cell X/Y for geom_text')
    hndl=[];
else
    
    
    if isempty(params)
        x=draw_data.x;
        y=draw_data.y;
        if isempty(draw_data.z)
            hndl=text(x,y,draw_data.label,'Color',draw_data.color);
        else
            hndl=text(x,y,draw_data.z,draw_data.label,'Color',draw_data.color);
        end

    else
        
        %If one of the colors is 'auto' we replace with the data-driven
        %color
        for k=1:2:numel(params)
            if any(strcmp(params{k},{'Color','EdgeColor','BackgroundColor'})) && strcmp(params{k+1},'auto')
                params{k+1}=draw_data.color;
            end
        end
        
        %Find dodge option
        dodge_ind=find(strcmp(params,'dodge'));
        if ~isempty(dodge_ind)
            dodge=params{dodge_ind+1};
            params(dodge_ind:dodge_ind+1)=[];
        else
            dodge=0;
        end
        x=dodger(draw_data.x,draw_data,dodge);
        y=draw_data.y;
        if isempty(draw_data.z)
            hndl=text(x,y,draw_data.label,'Color',draw_data.color,params{:});
        else
            hndl=text(x,y,draw_data.z,draw_data.label,'Color',draw_data.color,params{:});
        end
    end
        
end

obj.results.geom_label_handle{obj.result_ind,1}={hndl};

end


