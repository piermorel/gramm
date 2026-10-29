function out=parse_aes(varargin)
%Parse input to generate esthetics structure
p=inputParser;

% x and y are mandatory first two arguments
addParameter(p,'x',[]);
addParameter(p,'y',[]);
addParameter(p,'ymin',[]);
addParameter(p,'ymax',[]);
addParameter(p,'z',[]);
addParameter(p,'label',[]);

% Other aesthetics are string-value pairs
addParameter(p,'color',[]);
addParameter(p,'lightness',[]);
addParameter(p,'group',[]);
addParameter(p,'linestyle',[]);
addParameter(p,'size',[]);
addParameter(p,'marker',[]);
addParameter(p,'subset',[]);
addParameter(p,'row',[]);
addParameter(p,'column',[]);
addParameter(p,'fig',[]);

parse(p,varargin{:});

%Make everyone column arrays
for pr=1:length(p.Parameters)
    %By doing the test with isrow, we prevent shifting things that could be
    %in 2D such as X and Y
    if isrow(p.Results.(p.Parameters{pr}))
        out.(p.Parameters{pr})=shiftdim(p.Results.(p.Parameters{pr}));
    else
        out.(p.Parameters{pr})=p.Results.(p.Parameters{pr});
    end
end


end