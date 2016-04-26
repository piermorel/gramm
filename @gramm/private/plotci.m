function hndl=plotci(obj,x,y,yci,draw_data,geom,dodge,width)
            
            if nargin<7
                dodge=0;
            end
            if nargin<8
                width=0.5;
            end
            
            x=shiftdim(x)';
            y=shiftdim(y)';
            
            
            %Hackish but seems to work
            if size(yci,2)~=length(y) || size(yci,2)==2
                yci=yci';
            end
            
            if ~iscellstr(geom)
                geom={geom};
            end
            
            if isempty(x) || isempty(y)
                hndl=NaN;
                return;
            end
            
            %The available width is set to the minimum width within the
            %provided data
            if length(x)>2
                avl_w=min(diff(x));
            else
                avl_w=1;
            end
            

            
            %Compute dodging and bar width
            dodging=avl_w*dodge./(draw_data.n_colors);
            if dodge>0
                bar_width=avl_w*width./(draw_data.n_colors);
            else
                bar_width=avl_w*width;
            end
            x=x-0.5*dodging*draw_data.n_colors+dodging*0.5+(draw_data.color_index-1)*dodging;
            
            %Convert CIs to polar coordinates if needed
            [tmp_xci1,tmp_yci1]=to_polar(obj,x,yci(1,:));
            [tmp_xci2,tmp_yci2]=to_polar(obj,x,yci(2,:));
            yci=[tmp_yci1;tmp_yci2];
            xci=[tmp_xci1;tmp_xci2];
            [x,y]=to_polar(obj,x,y);
            
            %Use vertices and faces for patch object construction (has the
            %advantage of properly handling NaN datapoints
            vertices=nan(length(x)*2,2);
            vertices(1:2:end,:)=[tmp_xci1' tmp_yci1'];
            vertices(2:2:end,:)=[tmp_xci2' tmp_yci2'];
            faces=[(1:length(x)*2-2)' (1:length(x)*2-2)'+1 (1:length(x)*2-2)'+2];
            
            %Line plot  doesn't display anything if we have NaNs around, so find
            %out which points are surrounded by NaNs and might not be
            %displayed, we will display those as points
            real_neighbors=zeros(size(y));
            yreals=~isnan(y);
            real_neighbors(2:end)=real_neighbors(2:end)+yreals(1:end-1);
            real_neighbors(1:end-1)=real_neighbors(1:end-1)+yreals(2:end);
            
            
            for k=1:length(geom)
                switch geom{k}
                    case 'line'
                        hndl.line_handle=plot(x,y,'LineStyle',draw_data.line_style,'Color',draw_data.color,'LineWidth',draw_data.size/4);
                        hndl.extra_point_handle=plot(x(real_neighbors==0),y(real_neighbors==0),'o','Color',draw_data.color,'MarkerSize',draw_data.size/3,'MarkerFaceColor',draw_data.color);
                    case 'lines'
                        hndl.line_handle=plot(x,y,'LineStyle',draw_data.line_style,'Color',draw_data.color,'LineWidth',draw_data.size/4);
                        hndl.extra_point_handle=plot(x(real_neighbors==0),y(real_neighbors==0),'o','Color',draw_data.color,'MarkerSize',draw_data.size/3,'MarkerFaceColor',draw_data.color);
                        hndl.lines_handle=plot(xci',yci','-','Color',draw_data.color+([1 1 1]-draw_data.color)*0.5);
                    case 'area'
                        %Transparent area (This does what we want but prevents a correct eps
                        hndl.area_handle=patch('Vertices',vertices,'Faces',faces,'FaceColor',draw_data.color,'FaceAlpha',0.2,'EdgeColor','none');
                        hndl.line_handle=plot(x,y,'LineStyle',draw_data.line_style,'Color',draw_data.color,'LineWidth',draw_data.size/4);
                        hndl.extra_point_handle=plot(x(real_neighbors==0),y(real_neighbors==0),'o','Color',draw_data.color,'MarkerSize',draw_data.size/3,'MarkerFaceColor',draw_data.color);
                        %plot([x(real_neighbors==0) ; x(real_neighbors==0)], [yci(1,real_neighbors==0) ; yci(2,real_neighbors==0)],'Color',draw_data.color)
                        
                    case 'solid_area'
                        %Solid area (no alpha)
                        hndl.area_handle=patch('Vertices',vertices,'Faces',faces,'FaceColor',draw_data.color,'EdgeColor','none');
                        hndl.line_handle=plot(x,y,'LineStyle',draw_data.line_style,'Color',draw_data.color,'LineWidth',draw_data.size/4);
                        hndl.extra_point_handle=plot(x(real_neighbors==0),y(real_neighbors==0),'o','Color',draw_data.color,'MarkerSize',draw_data.size/3,'MarkerFaceColor',draw_data.color);
                        
                    case 'errorbar'
                        hndl.errorbar_handle=my_errorbar(x,yci(1,:),yci(2,:),bar_width/4,draw_data.color);
                        
                    case 'black_errorbar'
                        hndl.errorbar_handle=my_errorbar(x,yci(1,:),yci(2,:),bar_width/4,'k');
                        
                    case 'bar'
                        barleft=x-bar_width/2;
                        barright=x+bar_width/2;
                        xpatch=[barleft ; barright ; barright ; barleft];
                        ypatch=[zeros(1,length(y)) ; zeros(1,length(y)) ; y ; y];
                        [xpatch,ypatch]=to_polar(obj,xpatch,ypatch);
                        hndl.bar_handle=patch(xpatch,ypatch,[1 1 1],'FaceColor',draw_data.color,'EdgeColor','none');
                    case 'point'
                        hndl.point_handle=plot(x,y,draw_data.marker,'MarkerEdgeColor','none','markerSize',draw_data.size,'MarkerFaceColor',draw_data.color);
                end
                
            end
            
            %Adjust limits
            %obj.plot_lim.maxx(obj.current_row,obj.current_column)=max(max(x),obj.plot_lim.maxx(obj.current_row,obj.current_column));
            %obj.plot_lim.minx(obj.current_row,obj.current_column)=min(min(x),obj.plot_lim.minx(obj.current_row,obj.current_column));

        end