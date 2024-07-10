function h=my_tightplot(m,n,p,gap,marg_h,marg_w,varargin)
%function h=subtightplot(m,n,p,gap,marg_h,marg_w,varargin)
%
% Functional purpose: A wrapper function for Matlab function subplot. Adds the ability to define the gap between
% neighbouring subplots. Unfotrtunately Matlab subplot function lacks this functionality, and the gap between
% subplots can reach 40% of figure area, which is pretty lavish.  
%
% Input arguments (defaults exist):
%   gap- two elements vector [vertical,horizontal] defining the gap between neighbouring axes. Default value
%            is 0.01. Note this vale will cause titles legends and labels to collide with the subplots, while presenting
%            relatively large axis. 
%   marg_h  margins in height in normalized units (0...1)
%            or [lower uppper] for different lower and upper margins 
%   marg_w  margins in width in normalized units (0...1)
%            or [left right] for different left and right margins 
%
% Output arguments: same as subplot- none, or axes handle according to function call.
%
% Issues & Comments: Note that if additional elements are used in order to be passed to subplot, gap parameter must
%       be defined. For default gap value use empty element- [].      
%
% Usage example: h=subtightplot((2,3,1:2,[0.5,0.2])

%note n and m are switched as Matlab indexing is column-wise, while subplot indexing is row-wise :(
[subplot_col,subplot_row]=ind2sub([n,m],p);  


% single subplot dimensions:
%height=(1-(m+1)*gap_vert)/m;
%axh = (1-sum(marg_h)-(Nh-1)*gap(1))/Nh; 
height=(1-(marg_h(2)+marg_h(1))-(m-1)*gap(1))/m;
%width =(1-(n+1)*gap_horz)/n;
%axw = (1-sum(marg_w)-(Nw-1)*gap(2))/Nw;
width =(1-(marg_w(1)+marg_w(2))-(n-1)*gap(2))/n;

% merged subplot position:
bottom=(m-subplot_row)*(height+gap(1)) +marg_h(1);
left=(subplot_col-1)*(width+gap(2)) +marg_w(1);
pos_vec=abs([left bottom width height]);

h=axes('Position',pos_vec,varargin{:});

end