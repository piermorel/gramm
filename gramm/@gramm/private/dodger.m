function x = dodger(x,draw_data,dodge,nudge)
%Shifts x positions of the current color for dodging, then by a fixed
%nudge (optional). The nudge is in the same units as the 'width' options
%of the geoms: a fraction of the space available for each x value, divided
%by the number of colors when dodging

if nargin<4
    nudge=0;
end

%dodging
avl_w=draw_data.dodge_avl_w;
%Compute dodging and bar width
dodging=avl_w*dodge./(draw_data.n_colors);
%NEW DODGING
if dodge
    if draw_data.dodge_fallback %No advanced dodging
        x=x-0.5*dodging*draw_data.dodge_n+dodging*0.5+(draw_data.dodge_ind-1)*dodging;
    else
        x_dodge_indices=arrayfun(@(xin)find(abs(draw_data.dodge_x-xin)<1e-10,1),x);
        x=x-0.5*dodging*draw_data.dodge_n(x_dodge_indices)+dodging*0.5+(draw_data.dodge_ind(x_dodge_indices)-1)*dodging;
    end
end

%Nudging is applied after dodging so that layers with the same 'dodge'
%stay aligned with each other
if nudge
    if dodge>0
        x=x+avl_w*nudge./(draw_data.n_colors);
    else
        x=x+avl_w*nudge;
    end
end

end
