function plan = buildfile
import matlab.buildtool.tasks.*
import matlab.buildtool.Task

plan = buildplan(localfunctions);

plan("clean") = CleanTask;
plan("check") = CodeIssuesTask(Results="issues.mat");

plan.DefaultTasks = "check";
end

function runExamplesTask(context)
% Run examples as tests
reportFormat = matlab.unittest.plugins.codecoverage.CoverageReport('coverage-report');
covPlugin = matlab.unittest.plugins.CodeCoveragePlugin.forFolder("gramm","Producing",  reportFormat);
etObj = examplesTester("gramm/examples", CodeCoveragePlugin = covPlugin);
etObj.executeTests();
end

