function plan = buildfile
import matlab.buildtool.tasks.*
import matlab.buildtool.Task

plan = buildplan(localfunctions);

plan("clean") = CleanTask;
plan("check") = CodeIssuesTask(Results="issues.mat");

reportFormat = matlab.unittest.plugins.codecoverage.CoverageReport('coverage-report');
covPlugin = matlab.unittest.plugins.CodeCoveragePlugin.forFolder("gramm","Producing",  reportFormat);
plan("runExample") = ExampleDrivenTesterTask("gramm/examples", CodeCoveragePlugin = covPlugin);

plan("test") = TestTask("test_examples_dev.m",SourceFiles=["gramm/@gramm/*.m" "gramm/@gramm/private/*.m"], ...
    TestResults = "testresults.html").addCodeCoverage("coverageresults.html");

plan.DefaultTasks = ["check" "test"];
end

