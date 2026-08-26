% gramm examples and how-tos

% Shared variable
% We stat by loading the sample data (structure created from the carbig
% dataset)
load example_data;

%% Customize the size and style of graphic elements with set_line_options() and set_point_options()

clear g
x=repmat(1:10,1,5);
y=reshape(bsxfun(@times,1:5,(1:10)'),1,50);
sz=reshape(repmat(1:5,10,1),1,50);

g(1,1)=gramm('x',x,'y',y,'size',sz);
g(1,1).geom_point();
g(1,1).geom_line();
g(1,1).set_title('Default');

g(1,2)=gramm('x',x,'y',y,'color',sz,'size',sz);
g(1,2).geom_point();
g(1,2).set_point_options('border_color','k','border_width',2);
g(1,2).set_color_options('legend','merge');
g(1,2).set_title('Black point border color');

g(1,3)=gramm('x',x,'y',y,'color',sz,'size',sz);
g(1,3).geom_point('alpha',0);
g(1,3).set_color_options('legend','merge');
g(1,3).set_point_options('border_color','auto','border_width',1.5);
g(1,3).set_title('Auto point border color and 0 point alpha');

g(2,1)=gramm('x',x,'y',y,'size',sz);
g(2,1).geom_point();
g(2,1).geom_line();
g(2,1).set_line_options('base_size',1,'step_size',0.2,'style',{':' '-' '--' '-.'});
g(2,1).set_point_options('base_size',4,'step_size',1);
g(2,1).set_title('Modified point/line base & step size + line style');

g(2,2)=gramm('x',x,'y',y,'size',sz,'subset',sz~=3 & sz~=4);
g(2,2).geom_line();
g(2,2).geom_point();
g(2,2).set_title('Default (size according to category)');

g(2,3)=gramm('x',x,'y',y,'size',sz,'subset',sz~=3 & sz~=4);
g(2,3).geom_line();
g(2,3).geom_point();
g(2,3).set_line_options('use_input',true,'input_fun',@(s)1.5+s);
g(2,3).set_point_options('use_input',true,'input_fun',@(s)5+s*2);
g(2,3).set_title('Size according to value');

g.set_title('Customization of line and point options');

figure;
g.draw();
