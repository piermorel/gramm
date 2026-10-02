function cleanup = prepare_vega_outputs(repository_root)
%PREPARE_VEGA_OUTPUTS Reset only build-owned output and restore caller state.
output_root = fullfile(repository_root, 'build', 'vega');
original_output_root = getenv('GRAMM_TEST_OUTPUT_ROOT');
original_path = path;
cleanup = onCleanup(@() restore_state(original_path, original_output_root));
if isfolder(output_root)
    rmdir(output_root, 's');
end
mkdir(output_root);
setenv('GRAMM_TEST_OUTPUT_ROOT', output_root);
addpath(fullfile(repository_root, 'gramm'), ...
    fullfile(repository_root, 'buildutils', 'vega'));
end

function restore_state(original_path, original_output_root)
path(original_path);
setenv('GRAMM_TEST_OUTPUT_ROOT', original_output_root);
end
