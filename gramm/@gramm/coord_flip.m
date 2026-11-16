function obj=coord_flip(obj)
% coord_flip Exchange the x and y axes, e.g. for horizontal boxplots or violins
%
% Example syntax: gramm_object.coord_flip()
% x data is displayed on the vertical axis and y data on the horizontal
% axis. Sets the axes properties 'CameraUpVector',[1 0 0], 'XDir',
% 'reverse' and 'YAxisLocation','left', and sets things up for correct
% resizing of the figure. These properties can be further modified with
% axe_property() to get the desired orientation and location.

    %CameraUpVector takes in accound 'XDir': when using 'reverse' the
    %CameraUpVector doesn't need to be negative X [-1 0 0]
    obj.axe_property('CameraUpVector',[1 0 0],'XDir','reverse','YAxisLocation','left');
    for obj_ind=1:numel(obj)
        obj(obj_ind).is_flipped=true;
    end
end