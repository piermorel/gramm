reportFormat = matlab.unittest.plugins.codecoverage.CoverageReport('coverage-report'); 
covPlugin = matlab.unittest.plugins.CodeCoveragePlugin.forFolder("gramm", "Producing", reportFormat); 
% obj = examplesTester("gramm/generate_all_outputs.m", CodeCoveragePlugin = covPlugin); 
obj = examplesTester("gramm/export_vega_test.m", CodeCoveragePlugin = covPlugin); 
obj.executeTests; 