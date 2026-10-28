function obj=set_scale(obj,varargin)
% set_scale Set linear or logarithmic axes
%
% Example syntax: gramm_object.set_scale('x','log','y','log')
% Arguments are given as name,value pairs, the names being the axes
% ('x', 'y' or 'z') and the values 'linear' (default) or 'log'.
% On log axes, the limits extend proportionally beyond the data, and
% exclude values at or below 0, which can't be displayed. Bars (geom_bar,
% stat_bin, stat_summary bars) start from the bottom of the axis.
% Statistics are still computed on the linear values: give
% logarithmically spaced bins to stat_bin() with 'edges', e.g.
% 'edges',logspace(0,3,20). Not supported in polar plots.
% axe_property('XScale','log') (and 'YScale', 'ZScale') has the same
% effect.

if mod(numel(varargin),2)~=0
    error('Arguments of set_scale() must be given as ''name'',value pairs')
end
for k=1:2:numel(varargin)
    ax=validatestring(varargin{k},{'x','y','z'});
    scale=validatestring(varargin{k+1},{'linear','log'});
    for obj_ind=1:numel(obj)
        obj(obj_ind).axis_scale.(ax)=scale;
    end
end
end
