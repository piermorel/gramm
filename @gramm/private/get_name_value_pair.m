function [arg_val,varargin]=get_name_value_pair(varargin)
%GET_NAME_VALUE_PAIR Search for a name-value pair in varargin
%
%   For example:
%   [dodge,varargin] = GET_NAME_VALUE_PAIR(varargin{:},'dodge',0); 
%   Look for the string 'dodge' and assign the subsequent input variable 
%   to dodge. If nothing is found, use 0 as default.

% Adapted for GRAMM by Matthijs Cox
% Credits go mostly to my colleague Edo Hulsebos

arg_str=varargin{end-1};
arg_default=varargin{end};
varargin=varargin(1:end-2);

if ischar(arg_str)
    arg_str={arg_str};
end
na=numel(arg_str);

idx=[];
n=0;
while isempty(idx) && n<na
    n=n+1;
    idx=find(strcmpi(varargin,arg_str{n}));
end

if isempty(idx)
    arg_val=arg_default;
else
    if numel(varargin)<idx+1
        error(['Missing input argument value for ''',arg_str{n},'''.']);
    end
    arg_val=varargin{idx+1};
    varargin(idx:idx+1)=[];
end

if isempty(varargin)
    varargin={};
end