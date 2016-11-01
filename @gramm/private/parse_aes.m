function out=parse_aes(varargin)
%Parse input to generate esthetics structure
p=inputParser;

% x and y are mandatory first two arguments
my_addParameter(p,'x',[]);
my_addParameter(p,'y',[]);
my_addParameter(p,'ymin',[]);
my_addParameter(p,'ymax',[]);
my_addParameter(p,'z',[]);
my_addParameter(p,'label',[]);

% Other aesthetics are string-value pairs
my_addParameter(p,'color',[]);
my_addParameter(p,'lightness',[]);
my_addParameter(p,'group',[]);
my_addParameter(p,'linestyle',[]);
my_addParameter(p,'size',[]);
my_addParameter(p,'marker',[]);
my_addParameter(p,'subset',[]);
my_addParameter(p,'row',[]);
my_addParameter(p,'column',[]);
my_addParameter(p,'fig',[]);

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