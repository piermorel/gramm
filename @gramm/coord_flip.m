function obj=coord_flip(obj)
% coord_flip Flips plot axes
%
% Using coord_flip flips the plot axes, i.e. x data will be on the vertical axis and y data on
% the horizontal axis. This is mainly useful to draw stat_ visualisations horizontally,
% such as boxplots, violin plots, etc.

    %CameraUpVector takes in accound 'XDir': when using 'reverse' the
    %CameraUpVector doesn't need to be negative X [-1 0 0]
    obj.axe_property('CameraUpVector',[1 0 0],'XDir','reverse','YAxisLocation','Right');
    for obj_ind=1:numel(obj)
        obj(obj_ind).is_flipped=true;
    end
end