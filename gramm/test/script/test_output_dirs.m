function [vega_dir, svg_dir] = test_output_dirs()
%TEST_OUTPUT_DIRS Resolve and create output directories for test exports.
this_dir = fileparts(mfilename('fullpath'));
doc_dir = fileparts(this_dir);
% root_dir = fileparts(doc_dir);

vega_dir = fullfile(doc_dir, 'gramm_vega');
svg_dir = fullfile(doc_dir, 'gramm_svg');

if ~exist(vega_dir, 'dir')
    mkdir(vega_dir);
end
if ~exist(svg_dir, 'dir')
    mkdir(svg_dir);
end
end
