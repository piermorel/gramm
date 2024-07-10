function [ face_color , face_alpha , edge_color , edge_alpha ] = parse_fill (fill,color)

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

end

