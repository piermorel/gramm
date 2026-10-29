function [ face_color , face_alpha , edge_color , edge_alpha ] = parse_fill (fill,color,fill_alpha)
%Colors and transparencies of faces and edges for the 'fill' option. A
%non-empty fill_alpha replaces the face transparency of the fill style

face_alpha=1;
edge_alpha=0.8;
switch fill
    case 'edge'
        edge_color=color;
        face_color=color;
        face_alpha=0;
    case 'face'
        edge_color='k';
        edge_alpha=1;
        face_color=color;
    case 'all'
        edge_color=color;
        edge_alpha=0;
        face_color=color;
    case 'transparent'
        edge_color=color;
        face_color=color;
        face_alpha=0.4;
end
if nargin>2 && ~isempty(fill_alpha)
    face_alpha=fill_alpha;
end

end

