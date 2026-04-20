function [fallback,dodge_x,dodge_color,dodge_lightness,dodge_ind,dodge_n]=dodge_comp(x,color,lightness,uni_color,uni_lightness)


if iscell(x)
    %If x is given as cell, we don't do the advanced dodging
    fallback=true;
    uni_x=1;
else
    fallback=false;
    uni_x=unique(x);
    %Here we need to implement a loose 'unique' because of
    %potential numerical errors
    uni_x(diff(uni_x)<1e-10)=[];
    
    %Fallback if there are too many unique x values (dodging only makes
    %sense for discrete x values)... 4000 x unique values is already a lot
    %but quick enough to compute below
    if numel(uni_x)>2000
        fallback=true;
        uni_x=1;
    end
end

N=length(uni_x)*length(uni_color)*length(uni_lightness);

%Initialize return values
dodge_x=zeros(N,1);
if iscell(color)
    dodge_color=cell(N,1);
else
    dodge_color=zeros(N,1);
end
if iscell(lightness)
    dodge_lightness=cell(N,1);
else
    dodge_lightness=zeros(N,1);
end
dodge_ind=zeros(N,1);
dodge_n=zeros(N,1);

ind=1;

%Loop over unique X values and count how many lightness and color values
%there are for each (unless we are in fallback in which case we plan for
%all possible lightness and colors).
for ind_x=1:length(uni_x)
    
    
    if ~fallback
        %And here we have a loose selection also because of
        %potential numerical errors
        sel=abs(x-uni_x(ind_x))<1e-10;
    end
    
    temp_ind=1;
    
    for ind_color=1:length(uni_color)
        
        if ~fallback
            sel_color=sel & multi_sel(color,uni_color{ind_color});
        end
        
        %loop over lightness
        for ind_lightness=1:length(uni_lightness)
            
            if ~fallback
                sel_lightness=sel_color & multi_sel(lightness,uni_lightness{ind_lightness});
            end
            
            if fallback || any(sel_lightness)
                dodge_x(ind)=uni_x(ind_x);
                if iscell(color)
                    dodge_color{ind}=uni_color{ind_color};
                else
                    dodge_color(ind)=uni_color{ind_color};
                end
                if iscell(lightness)
                    dodge_lightness{ind}=uni_lightness{ind_lightness};
                else
                    dodge_lightness(ind)=uni_lightness{ind_lightness};
                end
                dodge_ind(ind)=temp_ind;
            
                temp_ind=temp_ind+1;
                ind=ind+1;
            end
        end
    end
    
    dodge_n(ind-(temp_ind-1):ind-1)=temp_ind-1;
    
    
end

dodge_x=dodge_x(1:ind-1);
dodge_color=dodge_color(1:ind-1);
dodge_lightness=dodge_lightness(1:ind-1);
dodge_ind=dodge_ind(1:ind-1);
dodge_n=dodge_n(1:ind-1);

end

