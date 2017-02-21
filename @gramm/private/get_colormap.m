
function cmap=get_colormap(nc,nl,opts)

if ischar(opts.map)
    if ~strcmp(opts.map,'lch') && nl>1
        error('Lightness not supported for non lch colormaps');
    end
    
    %Brewer colormaps from http://colorbrewer2.org
    switch opts.map
        case 'matlab'
            cmap=colormap('lines');
        case 'brewer1'
            if nc>9
                error('Too many color categories for brewer1 (max=9)')
            end
            cmap=[228    26    28
                55   126   184
                77   175    74
                152    78   163
                255   127     0
                255   255    51
                166    86    40
                247   129   191
                153   153   153]/255;
        case 'brewer2'
            if nc>8
                error('Too many color categories for brewer2 (max=8)')
            end
            cmap=[102	194	165
                252	141	98
                141	160	203
                231	138	195
                166	216	84
                255	217	47
                229	196	148
                179	179	179]/255;
        case 'brewer3'
            if nc>12
                error('Too many color categories for brewer3 (max=12)')
            end
            cmap=[141	211	199
                255	255	179
                190	186	218
                251	128	114
                128	177	211
                253	180	98
                179	222	105
                252	205	229
                217	217	217
                188	128	189
                204	235	197
                255	237	111]/255;
        case 'brewer_pastel'
            if nc>9
                error('Too many color categories for brewer_pastel (max=9)')
            end
            cmap=[251	180	174
                179	205	227
                204	235	197
                222	203	228
                254	217	166
                255	255	204
                229	216	189
                253	218	236
                242	242	242]/255;
        case 'brewer_dark'
            if nc>8
                error('Too many color categories for brewer1 (max=8)')
            end
            cmap=[27	158	119
                217	95	2
                117	112	179
                231	41	138
                102	166	30
                230	171	2
                166	118	29
                102	102	102]/255;
        case 'pm'
            cmap= [255 205 1
                0 108 184
                155 153 59
                109 197 224 %3bis
                187 75 156
                246 143 75
                119 198 150
                245 159 179
                197 164 205
                206 201 43
                224 176 59
                144 96 48
                0 139 90
                135 211 223 %Close to 3bis
                101 44 144
                169 15 50
                236 124 174
                149 191 50]/255;
        otherwise
            % Generate colormap using low-level function found on https://code.google.com/p/p-and-a/
            if nl==1
                %Was 65,75
                cmap=pa_LCH2RGB([repmat(linspace(opts.lightness,opts.lightness,nl)',nc+1,1) ...
                    repmat(linspace(opts.chroma,opts.chroma,nl)',nc+1,1)...
                    reshape(repmat(linspace(opts.hue_range(1),opts.hue_range(2),nc+1),nl,1),nl*(nc+1),1)],false);
            else
                cmap=pa_LCH2RGB([repmat(linspace(opts.lightness_range(1),opts.lightness_range(2),nl)',nc+1,1) ...
                    repmat(linspace(opts.chroma_range(1),opts.chroma_range(2),nl)',nc+1,1)...
                    reshape(repmat(linspace(opts.hue_range(1),opts.hue_range(2),nc+1),nl,1),nl*(nc+1),1)],false);
            end
    end
else
    cmap=opts.map;
end
end