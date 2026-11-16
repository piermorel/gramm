function obj=set_title(obj,title,varargin)
% set_title Add a title to the gramm plot, or to the whole figure when called on an array
%
% Example syntax: gramm_object.set_title('Title','FontSize',14)
% When called on a single gramm object, the title is placed above its
% axes. When called on an array of gramm objects, the title is placed above
% all of them. A figure can thus have a general title and titles for each
% gramm plot:
%   g(1,1).set_title('Subfigure 1 Title')
%   g(1,2).set_title('Subfigure 2 Title')
%   g.set_title('Global title')
%   g.draw()
%
% Arguments:
% - title: Text of the title. Can be followed by any text() property as
%            'name',value pairs ('FontSize', 'Color'...)

if numel(obj)>1
    obj(1).bigtitle=title;
    obj(1).bigtitle_options=varargin;
else
    obj.title=title;
    obj.title_options=varargin;
end
end