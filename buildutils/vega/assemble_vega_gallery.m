function assemble_vega_gallery(repository_root)
%ASSEMBLE_VEGA_GALLERY Package existing outputs without rerunning examples.
output_root = fullfile(repository_root, 'build', 'vega');
templates = fullfile(repository_root, 'buildutils', 'vega', 'gallery');
code_dir = fullfile(output_root, 'code');
if ~isfolder(code_dir)
    mkdir(code_dir);
end
copyfile(fullfile(templates, 'vega_export_docs.html'), fullfile(output_root, 'index.html'));
copyfile(fullfile(templates, 'vega_export_docs.js'), output_root);
copyfile(fullfile(repository_root, 'gramm', 'examples', 'vega', 'example_*.m'), code_dir);
fprintf('Vega comparison gallery: %s\n', fullfile(output_root, 'index.html'));
end
