function [vega_dir, svg_dir] = test_output_dirs()
%TEST_OUTPUT_DIRS Resolve isolated output directories for smoke tests.
% Set GRAMM_TEST_OUTPUT_ROOT to retain artifacts in a chosen directory.

output_root = getenv('GRAMM_TEST_OUTPUT_ROOT');
if isempty(output_root)
    output_root = tempname;
end

fprintf('Vega example output: %s\n', output_root);

vega_dir = fullfile(output_root, 'vega');
svg_dir = fullfile(output_root, 'svg');

if ~isfolder(vega_dir)
    mkdir(vega_dir);
end
if ~isfolder(svg_dir)
    mkdir(svg_dir);
end
end
