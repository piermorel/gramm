function [x,y]=to_polar(obj,theta,rho)
%If the graph is set as polar, x and y are interpreted as rho and
%theta respectively, and data is converted in cartesian x and
%y. Passthrough if is_polar is false

if obj.polar.is_polar
    if iscell(theta)
        x=cell(size(theta));
        y=cell(size(theta));
        for k=1:length(theta)
            [x{k},y{k}]=pol2cart(theta{k},rho{k});
            
            %We close the plot by repeating the first point at
            %the end
            if obj.polar.is_polar_closed
                x{k}(end+1)=x{k}(1);
                y{k}(end+1)=y{k}(1);
            end
            
        end
    else
        [x,y]=pol2cart(theta,rho);
        if obj.polar.is_polar_closed && size(shiftdim(x),2)==1 && size(shiftdim(y),2)==1
            x(end+1)=x(1);
            y(end+1)=y(1);
        end
    end
else
    x=theta;
    y=rho;
end
end