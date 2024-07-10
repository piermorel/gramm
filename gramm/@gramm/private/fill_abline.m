function ab=fill_abline(ab,varargin)
ab.on=true;

l=max(cellfun(@length,varargin(1:5)));
ab.slope(end+1:end+l)=shiftdim(varargin{1});
ab.intercept(end+1:end+l)=shiftdim(varargin{2});
ab.xintercept(end+1:end+l)=shiftdim(varargin{3});
ab.yintercept(end+1:end+l)=shiftdim(varargin{4});
ab.extent(end+1:end+l)=shiftdim(varargin{7});
ab.linewidth(end+1:end+l)=shiftdim(varargin{8});

%Because of the constructor these are initialized as empty
%arrays
if isempty(ab.fun)
    ab.fun={};
    ab.style={};
end

if ~iscell(varargin{5})
    varargin{5}={varargin{5}};
end
ab.fun(end+1:end+l)=shiftdim(varargin{5});
if iscell(varargin{6})
    ab.style(end+1:end+l)=shiftdim(varargin{6});
else
    ab.style(end+1:end+l)=repmat({varargin{6}},l,1);
end
end