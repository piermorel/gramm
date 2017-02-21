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
            
            if dodge>0
                bar_width=draw_data.dodge_avl_w*width./(draw_data.n_colors);
            else
                bar_width=draw_data.dodge_avl_w*width;
            end
            
            x=dodger(x',draw_data,dodge)';
            
            %Convert CIs to polar coordinates if needed
            [tmp_xci1,tmp_yci1]=to_polar(obj,x,yci(1,:));
            [tmp_xci2,tmp_yci2]=to_polar(obj,x,yci(2,:));
            yci=[tmp_yci1;tmp_yci2];
            xci=[tmp_xci1;tmp_xci2];
            [x,y]=to_polar(obj,x,y);
            
            
            if 1 %any(isnan(tmp_yci1)) || any(isnan(tmp_yci2))
                %Use vertices and faces for patch object construction with triangles (has the
                %advantage of properly handling NaN datapoints
                vertices=nan(length(x)*2,2);
                vertices(1:2:end,:)=[tmp_xci1' tmp_yci1'];
                vertices(2:2:end,:)=[tmp_xci2' tmp_yci2'];
                faces=[(1:length(x)*2-2)' (1:length(x)*2-2)'+1 (1:length(x)*2-2)'+2];
            else
                %We create patches as one single polygon (looks much better when exporting with plot2svg)
                vertices=horzcat([tmp_xci1' ; flipud(tmp_xci2')],[tmp_yci1' ; flipud(tmp_yci2')]);
                faces=1:2*length(x);
            end
            
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
                        hndl.line_handle=plot(x,y,...
                            'LineStyle',draw_data.line_style,...
                            'Color',draw_data.color,...
                            'LineWidth',draw_data.line_size);
                        
                        hndl.extra_point_handle=plot(x(real_neighbors==0),y(real_neighbors==0),'o',...
                            'Color',draw_data.color,...
                            'MarkerSize',draw_data.point_size,...
                            'MarkerFaceColor',draw_data.color);
                        
                    case 'lines'
                        hndl.line_handle=plot(x,y,...
                            'LineStyle',draw_data.line_style,...
                            'Color',draw_data.color,...
                            'LineWidth',draw_data.line_size);
                        
                        hndl.extra_point_handle=plot(x(real_neighbors==0),y(real_neighbors==0),'o',...
                            'Color',draw_data.color,...
                            'MarkerSize',draw_data.point_size,...
                            'MarkerFaceColor',draw_data.color);
                        
                        %hndl.lines_handle=plot(xci',yci','-','Color',draw_data.color+([1 1 1]-draw_data.color)*0.5);
                        hndl.lines_handle=plot(xci',yci','LineStyle',draw_data.line_style,...
                            'Color',draw_data.color,...
                            'LineWidth',draw_data.line_size/3);
                        
                    case 'area'
                        %Transparent area (This does what we want but prevents a correct eps
                        hndl.area_handle=patch('Vertices',vertices,...
                            'Faces',faces,...
                            'FaceColor',draw_data.color,...
                            'FaceAlpha',0.2,...
                            'EdgeColor','none');
                        
                        hndl.line_handle=plot(x,y,...
                            'LineStyle',draw_data.line_style,...
                            'Color',draw_data.color,...
                            'LineWidth',draw_data.line_size);
                        
                        hndl.extra_point_handle=plot(x(real_neighbors==0),y(real_neighbors==0),'o',...
                            'Color',draw_data.color,...
                            'MarkerSize',draw_data.point_size,...
                            'MarkerFaceColor',draw_data.color);
                        
                    case 'area_only'
                        hndl.area_handle=patch('Vertices',vertices,'Faces',faces,'FaceColor',draw_data.color,'FaceAlpha',0.2,'EdgeColor','none');
                        
                    case 'solid_area'
                        %Solid area (no alpha)
                        hndl.area_handle=patch('Vertices',vertices,...
                            'Faces',faces,...
                            'FaceColor',draw_data.color,...
                            'EdgeColor','none');
                        
                        hndl.line_handle=plot(x,y,...
                            'LineStyle',draw_data.line_style,...
                            'Color',draw_data.color,...
                            'LineWidth',draw_data.line_size);
                        
                        hndl.extra_point_handle=plot(x(real_neighbors==0),y(real_neighbors==0),'o',...
                            'Color',draw_data.color,...
                            'MarkerSize',draw_data.point_size,...
                            'MarkerFaceColor',draw_data.color);
                        
                    case 'errorbar'
                        hndl.errorbar_handle=my_errorbar(x,yci(1,:),yci(2,:),bar_width/4,draw_data.color,draw_data.line_size);
                        
                    case 'black_errorbar'
                        hndl.errorbar_handle=my_errorbar(x,yci(1,:),yci(2,:),bar_width/4,'k',draw_data.line_size);
                        
                    case 'bar'
                        barleft=x-bar_width/2;
                        barright=x+bar_width/2;
                        xpatch=[barleft ; barright ; barright ; barleft];
                        ypatch=[zeros(1,length(y)) ; zeros(1,length(y)) ; y ; y];
                        [xpatch,ypatch]=to_polar(obj,xpatch,ypatch);
                        hndl.bar_handle=patch(xpatch,ypatch,[1 1 1],'FaceColor',draw_data.color,'EdgeColor','none');
                   case 'edge_bar'
                        barleft=x-bar_width/2;
                        barright=x+bar_width/2;
                        xpatch=[barleft ; barright ; barright ; barleft];
                        ypatch=[zeros(1,length(y)) ; zeros(1,length(y)) ; y ; y];
                        [xpatch,ypatch]=to_polar(obj,xpatch,ypatch);
                        hndl.bar_handle=patch(xpatch,ypatch,[1 1 1],'FaceColor',draw_data.color,'EdgeColor','k');
                    case 'point'
                        hndl.point_handle=plot(x,y,draw_data.marker,'MarkerEdgeColor','none','markerSize',draw_data.point_size,'MarkerFaceColor',draw_data.color);
                end
                
            end
            
            %Adjust limits
            %obj.plot_lim.maxx(obj.current_row,obj.current_column)=max(max(x),obj.plot_lim.maxx(obj.current_row,obj.current_column));
            %obj.plot_lim.minx(obj.current_row,obj.current_column)=min(min(x),obj.plot_lim.minx(obj.current_row,obj.current_column));

        end