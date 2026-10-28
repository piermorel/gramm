function y=log_base(obj,y)
%Bars and filled areas start from 0, and confidence areas can extend below
%0, which can't be displayed on a log y axis: they start from a tiny
%positive value instead (below the axis)
if strcmp(obj.axis_scale.y,'log')
    y(y<=0)=realmin;
end
end
