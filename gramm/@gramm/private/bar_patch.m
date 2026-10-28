function [x,y]=bar_patch(left,right,bottom,top)
%Patch coordinates of bars, one bar per column. The outline starts in the
%middle of the top edge: when it starts at a corner, MATLAB draws a stray
%line out of the axes from bars that are less than a pixel high
x=[(left+right)/2 ; right ; right ; left ; left];
y=[top ; top ; bottom ; bottom ; top];
end
