function ab=fill_abline(ab,varargin)
ab.on=true;

l=max(cellfun(@length,varargin(1:5)));

%Datetime/duration intercepts, and all x intercepts (polar angles may be in
%degrees), are kept in raw, and converted to numbers in draw() (the
%conversion is only known then). 0 marks them in x/yintercept
raw=cell(l,1);
for k=3:4
    if isdatetime(varargin{k}) || isduration(varargin{k}) || (k==3 && ~all(isnan(varargin{k})))
        raw=num2cell(shiftdim(varargin{k}));
        varargin{k}=zeros(l,1);
    end
end
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
    ab.raw={};
end
ab.raw(end+1:end+l)=raw;

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