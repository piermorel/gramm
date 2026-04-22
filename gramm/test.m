project_root = fileparts(mfilename('fullpath'));
script_test_dir = fullfile(project_root, 'test', 'script');
original_path = path;
cleanup_path = onCleanup(@() path(original_path)); %#ok<NASGU>
addpath(project_root);

reportFormat = matlab.unittest.plugins.codecoverage.CoverageReport(fullfile(project_root, 'coverage-report'));
covPlugin = matlab.unittest.plugins.CodeCoveragePlugin.forFolder(fullfile(project_root, '@gramm'), "Producing", reportFormat);

obj = examplesTester(script_test_dir, CodeCoveragePlugin = covPlugin);
obj.executeTests;
