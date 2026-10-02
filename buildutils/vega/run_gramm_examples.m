function results = run_gramm_examples(repository_root, example_folder, report_name)
%RUN_GRAMM_EXAMPLES Run ExamplesDrivenTester and propagate unsuccessful tests.
% The folder argument also permits an isolated fixture for runner validation.
cleanup_outputs = prepare_vega_outputs(repository_root); %#ok<NASGU>
report_root = fullfile(repository_root, 'test-report', report_name);
coverage_root = fullfile(repository_root, 'coverage-report', report_name);
report_format = matlab.unittest.plugins.codecoverage.CoverageReport(coverage_root);
coverage_plugin = matlab.unittest.plugins.CodeCoveragePlugin.forFolder( ...
    fullfile(repository_root, 'gramm', '@gramm'), 'Producing', report_format);
runner = examplesTester(example_folder, CodeCoveragePlugin=coverage_plugin, ...
    OutputPath=report_root);
runner.executeTests;
results = runner.TestResults;
assemble_vega_gallery(repository_root);
assert(~isempty(results), 'gramm:build:NoTests', 'No examples were executed.');
assertSuccess(results);
end
