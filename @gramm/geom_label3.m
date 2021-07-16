function obj = geom_label3(obj,varargin)
% geom_label3 Display data as labels for 3D plots
%
% Example syntax: gramm_object.geom_label3'Color','auto','dodge',0.6)
% Geom label displays text (provided as 'label' in the constructor call
% gramm()). At the X, Y and, Z locations provided in the constructor call.
% Appearance of the text can be customized with any text property given as
% 'name',value pair in the arguments. The color-related arguments
% ('Color','EdgeColor','BackgroundColor') can also be set to 'auto' in
% order for the corresponding element to be colored according the the
% color groups provided in the constructor. geom_label3() also accepts a
% 'dodge' argument.



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
        [x,y,z]=to_polar3(obj,draw_data.x,draw_data.y,draw_data.z);
        
        hndl=text(x,y,z,draw_data.label,'Color',draw_data.color);
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
        [x,y,z]=to_polar3(obj,x,draw_data.y,draw_data.z);
        
    
        
        hndl=text(x,y,z,draw_data.label,'Color',draw_data.color,params{:});
    end
        
end

obj.results.geom_label_handle{obj.result_ind,1}={hndl};

end


