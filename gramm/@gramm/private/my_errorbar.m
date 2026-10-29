function hndl=my_errorbar(obj,X,L,U,color,linewidth)
%Errorbars from L to U at X. MATLAB errorbars keep caps of the same size
%on screen whatever the axes size and limits. They can't be drawn on polar
%axes, where the errorbars are lines with caps 1.5% of the x range wide
%(for the default cap size of 6 points)
X=shiftdim(X)';
L=shiftdim(L)';
U=shiftdim(U)';
if obj.polar.is_polar
    width=0.015*obj.line_options.cap_size/6*(obj.var_lim.maxx-obj.var_lim.minx);
    nanarray=nan(1,length(X));
    %Construct the lines of the errorbar by separating all components with
    %NaN points
    xcoords=[X ; X ;  nanarray ; X-width/2 ; X+width/2 ; nanarray ; X-width/2 ; X+width/2 ; nanarray ];
    ycoords=[L ; U ;  nanarray ; U  ; U  ; nanarray ; L ; L ; nanarray];
    hndl=line(xcoords(:),ycoords(:),'Color',color,'LineWidth',linewidth);
else
    hndl=errorbar(X,(L+U)/2,(U-L)/2,'LineStyle','none','Color',color,'LineWidth',linewidth,...
        'CapSize',obj.line_options.cap_size);
end
end
