function [x,y]=bar_patch(obj,left,right,bottom,top)
%Patch coordinates of bars, one bar per column, ready for log y axes (see
%log_base()). The outline starts in the middle of the top edge: when it
%starts at a corner, MATLAB draws a stray line out of the axes from bars
%that are less than a pixel high.
%Bars that are too flat to be drawn are hidden (NaN faces are not drawn):
%their degenerate faces are rendered as a horizontal line across the whole
%figure. Graphics are drawn in single precision, so this includes bars too
%small to be told apart from their bottom in single precision (e.g. a tiny
%value stacked on top of large ones), and on linear axes bars far below a
%pixel high compared to the largest values (MATLAB maps them to the axes in
%single precision too)
x=[(left+right)/2 ; right ; right ; left ; left];
y=[top ; top ; bottom ; bottom ; top];
flat=single(top)==single(bottom);
if ~strcmp(obj.axis_scale.y,'log') && ~isempty(top)
    flat=flat | abs(top-bottom)<1e-6*max(abs([top(:) ; bottom(:)]));
end
y(:,flat)=NaN;
y=log_base(obj,y);
end
