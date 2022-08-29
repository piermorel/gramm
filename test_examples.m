clc;
clearvars;
load example_data;

%g(1,1)=gramm('x',cars.Model_Year,'y',cars.MPG,'color',cars.Cylinders,'subset',cars.Cylinders~=3 & cars.Cylinders~=5);
%g(1,1).stat_violin();

%cars.Origin = cars.Origin(1:10)
%cars.MPG = cars.MPG(1:10)
%cars.Cylinders = cars.Cylinders(1:10)


clear g
g(1,1)=gramm('x',cars.Origin_Region,'y',cars.Horsepower,'color',cars.Cylinders,'subset',cars.Cylinders~=3 & cars.Cylinders~=5);
g(1,2)=gramm('x',cars.Origin_Region,'y',cars.Horsepower,'color',cars.Cylinders,'subset',cars.Cylinders~=3 & cars.Cylinders~=5);
%g.stat_violin('fill','transparent');
g(1,1).stat_beeswarm('fill','transparent');
g(1,2).stat_violin('fill','transparent');
g.draw();

%{
x = cars.Model_Year;
y = cars.MPG;

uni_x = unique(x);
uni_x(diff(uni_x)<1e-10)=[];

[uni_y,~,idx]=unique(y);
uni_y(diff(uni_y)<1e-10)=[];

n  = accumarray(idx(:),1)

repeatedY = repelem(uni_y,n)
sortedY = sort(y)

ind_x = 1;

ysel=y(abs(x-uni_x(ind_x))<1e-10);

binranges=linspace(min(ysel),max(ysel),100);


x = 1:10;

r = arrayfun(@(a)-a/2+0.5:1:a/2-0.5,1:length(x),'UniformOutput',false);
r = horzcat(r{:})

%r = -a/2+0.5:1:-a/2+0.5
%}