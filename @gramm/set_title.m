function obj=set_title(obj,title,varargin)
%set_title Add the specified title to the figure
%
% Example syntax: gramm_object.set_title('Title','FontSize',14)
%
% set_title takes as first argument the string to use for the
% title, and cant receive optional 'Name',value pairs to
% specify additional text properties of the title (see Matlab's
% documentation for text properties).
% When called on a single gramm object it will create a title
% above the axes for the gramm object. When called on multiple
% gramm objects it will create a title above all the gramm
% objects. Thus when combining multiple gramm objects it is
% possible to get a general title for the whole figure and
% partial titles for the sub figures. Example:
%
% g(1,1).set_title('Subfigure 1 Title')
% g(1,2).set_title('Subfigure 2 Title')
% g.set_title('Global title')
% g.draw()

if numel(obj)>1
    obj(1).bigtitle=title;
    obj(1).bigtitle_options=varargin;
else
    obj.title=title;
    obj.title_options=varargin;
end
end