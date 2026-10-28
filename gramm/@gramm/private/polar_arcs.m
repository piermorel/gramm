function [x,y]=polar_arcs(obj,x,y,closed)
%In polar plots, add points along the edges of patches (vertices along rows,
%one patch per column) or of a line (vector), interpolated in angle and
%radius: edges at constant radius are then drawn as arcs instead of straight
%chords (e.g. bars become wedges). closed (default true) also interpolates
%the edge from the last vertex back to the first. x and y are returned
%unchanged for non-polar plots
if ~obj.polar.is_polar
    return
end
if nargin<4
    closed=true;
end
n=10; %Points per edge
is_row=isrow(x);
if is_row
    x=x';
    y=y';
end
if closed
    x=[x ; x(1,:)];
    y=[y ; y(1,:)];
end
t=(0:n-1)'/n;
x_new=kron(x(1:end-1,:),ones(n,1))+kron(diff(x,1,1),t);
y_new=kron(y(1:end-1,:),ones(n,1))+kron(diff(y,1,1),t);
if ~closed
    x_new=[x_new ; x(end,:)];
    y_new=[y_new ; y(end,:)];
end
x=x_new;
y=y_new;
if is_row
    x=x';
    y=y';
end
end
