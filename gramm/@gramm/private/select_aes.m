function out=select_aes(aes,sel)
%Extract a logical selection out of an aes structure
fields=fieldnames(aes);

for k=1:length(fields)
    if isempty(aes.(fields{k}))
        out.(fields{k})=[];
    else
        out.(fields{k})=aes.(fields{k})(sel);
    end
    
end

end
