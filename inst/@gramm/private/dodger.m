function x = dodger(x,draw_data,dodge)

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

end

