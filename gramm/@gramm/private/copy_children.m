function copies=copy_children(children,parent)
%Copies graphic objects to parent keeping their stacking order: each copy
%goes on top of the previous ones, so we copy from the bottom one
copies=gobjects(size(children));
for k=numel(children):-1:1
    copies(k)=copyobj(children(k),parent);
end

end
