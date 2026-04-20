function [ h ] = point_patch(x,y,s,c,resolution)
%point_patch Create nice looking scatter plot
%Example point_patch(0:pi/19:2*pi,sin(0:pi/19:2*pi),(1:39)/40,[0 0 1],20)

if nargin<5
    resolution=10;
end


persistent circlex
persistent circley
persistent res

if isempty(res) || res~=resolution
    res=resolution;
    circlex=cos(0:pi/(0.5*res):2*pi)/pi;
    circley=sin(0:pi/(0.5*res):2*pi)/pi;
end

x=shiftdim(x);
y=shiftdim(y);
%s=shiftdim(s);
s=sqrt(shiftdim(s)/pi);

trans=@(in,shift,sz)bsxfun(@plus,bsxfun(@times,in,sz),shift);

h=patch(trans(circlex,x,s)',trans(circley,y,s)',c,...
    'EdgeColor',c,'EdgeAlpha',0.8,...
    'FaceColor',c,'FaceAlpha',0.2);

end
