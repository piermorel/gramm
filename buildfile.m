function plan = buildfile
import matlab.buildtool.tasks.*
import matlab.buildtool.Task

plan = buildplan(localfunctions);

plan("clean") = CleanTask;
plan("check") = CodeIssuesTask(Results="issues.mat");

reportFormat = matlab.unittest.plugins.codecoverage.CoverageReport('coverage-report');
covPlugin = matlab.unittest.plugins.CodeCoveragePlugin.forFolder("gramm","Producing",  reportFormat);
plan("runExample") = ExampleDrivenTesterTask("gramm/examples", CodeCoveragePlugin = covPlugin);

plan("publish").Inputs = "gramm/examples/*.m";
plan("publish").Outputs = "gramm/examples/html/**";

plan("package").Dependencies = ["check" "runExample"];

plan.DefaultTasks = ["check" "runExample"];
end

function packageTask(~)
% Create MLTBX package
    prjFile = "gramm.prj";
    packagingData = matlab.addons.toolbox.ToolboxOptions(prjFile);
    tagVersion = getenv("CI_COMMIT_TAG");
    if ~isempty(tagVersion)
        if startsWith(tagVersion, 'v')
            tagVersion = erase(tagVersion, 'v');
        end
        packagingData.ToolboxVersion = tagVersion;
    end
    outputFileName = packagingData.ToolboxName + "_" + packagingData.ToolboxVersion + ".mltbx";
    packagingData.OutputFile = outputFileName;

    matlab.addons.toolbox.packageToolbox(packagingData);

    fprintf("Created %s.\n", outputFileName);
end

function publishTask(~)
% Create HTML pages from examples
examplesDir = fullfile("gramm", "examples");
htmlDir = fullfile(examplesDir, "html");

if ~isfolder(htmlDir)
    mkdir(htmlDir);
end

mFiles = dir(fullfile(examplesDir, "example_*.m"));
if isempty(mFiles)
    error("buildfile:publishTask", "No example_*.m files found in %s.", examplesDir);
end

opts.format = 'html';
opts.outputDir = htmlDir;
opts.showCode = true;
opts.figureSnapMethod = 'print';

fprintf("Publishing %d examples to HTML...\n", numel(mFiles));
for i = 1:numel(mFiles)
    srcFile = fullfile(examplesDir, mFiles(i).name);
    fprintf("  %s\n", mFiles(i).name);
    publish(srcFile, opts);
end

indexOpts.format = 'html';
indexOpts.outputDir = htmlDir;
indexOpts.showCode = false;
publish(fullfile(examplesDir, "index.m"), indexOpts);
fprintf("Published index.html\n");
end
