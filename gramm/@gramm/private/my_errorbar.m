function hndl=my_errorbar(X,L,U,width,color,linewidth)
    %Make all sizes work
    X=shiftdim(X)';
    L=shiftdim(L)';
    U=shiftdim(U)';
    nanarray=nan(1,length(X));
    %Construct the lines of the errorbar by separating all components with
    %NaN points
    xcoords=[X ; X ;  nanarray ; X-width/2 ; X+width/2 ; nanarray ; X-width/2 ; X+width/2 ; nanarray ];
    ycoords=[L ; U ;  nanarray ; U  ; U  ; nanarray ; L ; L ; nanarray];
    hndl=line(xcoords(:),ycoords(:),'Color',color,'LineWidth',linewidth);
end
