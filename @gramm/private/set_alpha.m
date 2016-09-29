function [ ] = set_alpha(input_handle,line_alpha,point_alpha)

persistent old_matlab
if isempty(old_matlab)
    old_matlab=verLessThan('matlab','8.4.0');
end

if ~old_matlab
    %Works for continuous color points made with scatter, but alpha goes 
    %back to 1 when CLimMode is set to manual in draw(), line 835
    if point_alpha<1 
        drawnow; %Necessary for handle to be available
        hMarkers = input_handle.MarkerHandle;
        c=hMarkers.FaceColorData;
        hMarkers.FaceColorType = 'truecoloralpha'; %Allows to set alpha
        hMarkers.FaceColorData=[c(1:3,:); repmat(uint8(point_alpha*255),1,size(c,2))];
    end
    
    %Does not work for continuous color lines (which are a hack based on patch)
    if line_alpha<1
        drawnow; %Necessary for handle to be available
        hEdge = input_handle.Edge;
        c=hEdge.ColorData;
        hEdge.ColorType = 'truecoloralpha'; %Allows to set alpha
        hEdge.ColorData=[c(1:3,:); repmat(uint8(line_alpha*255),1,size(c,2))];
    end
end



end

