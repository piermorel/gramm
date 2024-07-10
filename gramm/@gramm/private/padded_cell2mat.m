function matrix_output=padded_cell2mat(cell_input,pad)
    % Convert a ragged cell array of arrays in a padded matrix
    % Pierre Morel 2015.
    
    %With cellfun
%     ticID=tic;
%     maxLength=max(cellfun(@numel,cell_input));
%     tempcell=cellfun(@(x)horzcat(2,x,NaN*zeros(1,maxLength-length(x))),cell_input,'UniformOutput',false);
%     matrix_output=cell2mat(tempcell);
%     disp(['padded matrix (cellfun) created in ' num2str(toc(ticID)) ' s'])
    
    if nargin<2
        pad=NaN;
    end

    %With for loop (faster than cellfun)
    %ticID=tic;
    lengths=cellfun(@numel,cell_input);
    maxLength=max(lengths);
    matrix_output=zeros(length(cell_input),maxLength)+pad;
    for k=1:length(cell_input)
        matrix_output(k,1:lengths(k))=cell_input{k};
    end
    %disp(['padded matrix (for loop)  created in ' num2str(toc(ticID)) ' s'])
end