function plan = buildfile
import matlab.buildtool.tasks.*
import matlab.buildtool.Task

plan = buildplan(localfunctions);

plan("clean") = CleanTask;
plan("check") = CodeIssuesTask(Results="issues.mat");

reportFormat = matlab.unittest.plugins.codecoverage.CoverageReport('coverage-report');
covPlugin = matlab.unittest.plugins.CodeCoveragePlugin.forFolder("gramm","Producing",  reportFormat);
plan("runExample") = ExampleDrivenTesterTask("gramm/examples", CodeCoveragePlugin = covPlugin);

plan("package").Dependencies = ["check" "runExample"];
plan("package").Inputs = "gramm.prj";
plan("publish").Dependencies = [];

plan.DefaultTasks = ["check" "runExample"];
end

function packageTask(context)

    prjFile = context.Task.Inputs.Path;
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
%publishTask Publish edited examples to HTML with an index page.
%   Looks for .m files in gramm/examples/edited/, publishes each to HTML
%   in gramm/examples/html/, then generates a categorized index page.

editedDir = fullfile("gramm", "examples", "edited");
htmlDir = fullfile("gramm", "examples", "html");

if ~isfolder(editedDir)
    error("buildfile:publishTask", ...
        "Edited examples folder not found: %s\nAdd .m files to this folder to publish.", editedDir);
end

if ~isfolder(htmlDir)
    mkdir(htmlDir);
end

mFiles = dir(fullfile(editedDir, "*.m"));
if isempty(mFiles)
    error("buildfile:publishTask", ...
        "No .m files found in %s.\nAdd edited .m files to publish.", editedDir);
end

addpath gramm/
addpath(editedDir);

opts.format = 'html';
opts.outputDir = htmlDir;
opts.showCode = true;

fprintf("Publishing %d examples to HTML...\n", numel(mFiles));
for i = 1:numel(mFiles)
    srcFile = fullfile(editedDir, mFiles(i).name);
    fprintf("  %s\n", mFiles(i).name);
    publish(srcFile, opts);
end

addpath buildutils/
generateExamplesIndex(htmlDir);
end
