% gramm examples and how-tos

% Shared variable
% We stat by loading the sample data (structure created from the carbig
% dataset)
load example_data;

%% Methods for visualizing 2D densities
% The following methods can be used to visualize 2D densities for
% bivariate data

%Create point cloud with two categories
N=10^4;
x=randn(1,N);
y=x+randn(1,N);
test=repmat([0 1 0 0],1,N/4);
y(test==0)=y(test==0)+3;

clear g
% Display points and 95% percentile confidence ellipse
g(1,1)=gramm('x',x,'y',y,'color',test);
g(1,1).set_names('color','grp');
g(1,1).geom_point();
%'patch_opts' can be used to provide more options to the patch() internal
%call
g(1,1).set_point_options('base_size',2);
g(1,1).stat_ellipse('type','95percentile','geom','area','patch_opts',{'FaceAlpha',0.1,'LineWidth',2});
g(1,1).set_title('stat_ellispe()');

%Plot point density as contour plot
g(1,2)=gramm('x',x,'y',y,'color',test);
g(1,2).stat_bin2d('nbins',[10 10],'geom','contour');
g(1,2).set_names('color','grp');
g(1,2).set_title('stat_bin2d(''geom'',''contour'')');

    % %Plot density as point size (looks good only when axes have the same
% %scale, hence the 'DataAspectRatio' option, equivalent to axis equal)
% g(2,1)=gramm('x',x,'y',y,'color',test);
% g(2,1).stat_bin2d('nbins',{-10:0.4:10 ; -10:0.4:10},'geom','point');
% g(2,1).axe_property('DataAspectRatio',[1 1 1]);
% g(2,1).set_names('color','grp');
% g(2,1).set_title('stat_bin2d(''geom'',''point'')');

%Plot density as heatmaps (Heatmaps don't work with multiple colors, so we separate
%the categories with facets). With the heatmap we see better the
%distribution in high-density areas
g(2,1)=gramm('x',x,'y',y);
g(2,1).facet_grid([],test);
g(2,1).stat_bin2d('nbins',[20 20],'geom','image');
%g(2,1).set_continuous_color('LCH_colormap',[0 100 ; 100 20 ;30 20]); %Let's try a custom LCH colormap !
g(2,1).set_names('column','grp','color','count');
g(2,1).set_title('stat_bin2d(''geom'',''image'')');

g(2,2)=gramm('x',x,'y',y,'color',test);
g(2,2).geom_point('alpha',0.05);
g(2,2).set_point_options('base_size',6);
g(2,2).set_title('geom_point(''alpha'',0.05)');

g.set_title('Visualization of 2D densities');

figure
g.draw();