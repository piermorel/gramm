function plan = buildfile
import matlab.buildtool.tasks.*

plan = buildplan(localfunctions);

plan("clean") = CleanTask;
plan("check") = CodeIssuesTask(Results="issues.mat");

reportFormat = matlab.unittest.plugins.codecoverage.CoverageReport('coverage-report');
covPlugin = matlab.unittest.plugins.CodeCoveragePlugin.forFolder("gramm","Producing",  reportFormat);
plan("runExample") = ExampleDrivenTesterTask("gramm/examples", CodeCoveragePlugin = covPlugin);

plan("docs").Inputs = "gramm/doc/" + liveScripts() + ".mlx";
plan("docs").Outputs = "gramm/html/" + liveScripts() + ".html";

plan("publish").Inputs = "gramm/examples/*.m";
plan("publish").Outputs = "gramm/html/examples/**";

plan("cheatsheet").Inputs = ["gramm/@gramm/**/*.m" "gramm/examples/example_*.m" "buildutils/makeCheatSheet.m" "buildutils/cheatsheet_template.html"];
plan("cheatsheet").Outputs = "gramm/html/gramm_cheat_sheet.html";

plan("readmeImages").Dependencies = "publish";

plan("package").Dependencies = ["check" "runExample" "docs" "publish" "cheatsheet"];

plan.DefaultTasks = ["check" "runExample"];
end

function names = liveScripts
% Live scripts in gramm/doc, exported as HTML pages for the help browser:
% the landing page (no code) and the tutorials
names = ["gramm_landing" tutorials()];
end

function names = tutorials
names = ["GettingStarted" "Groups" "XY" "TimeSeries" "OnlineTable"];
end

function docsTask(~)
% Export the tutorial live scripts to HTML, running them so that the pages
% show what the current code draws. Figure sizes are set in the live scripts
restoreTheme = onCleanup(lightFigures());
cleanup = onCleanup(@removeLiveScriptFiles);
for name = liveScripts()
    fprintf("  %s\n", name);
    htmlFile = fullfile("gramm", "html", name + ".html");
    if ismember(name, tutorials())
        runTutorial(name, htmlFile);
    else
        export(fullfile("gramm", "doc", name + ".mlx"), htmlFile); % No code to run
    end
    % export() stretches figures to the page width: show them at their own
    % size instead (narrower in narrow windows)
    html = replace(fileread(htmlFile, Encoding="UTF-8"), ...
        "style=""width: 100%;""", "style=""max-width: 100%;""");
    writelines(html, htmlFile, Encoding="UTF-8");
end
end

function publishTask(~)
% Publish the examples as HTML pages. Figure sizes are set in the examples
examplesDir = fullfile("gramm", "examples");
htmlDir = fullfile("gramm", "html", "examples");
if ~isfolder(htmlDir)
    mkdir(htmlDir);
end
restoreTheme = onCleanup(lightFigures());

opts.format = 'html';
opts.outputDir = htmlDir;
opts.showCode = true;
opts.figureSnapMethod = 'print';
opts.useNewFigure = false; % The examples open their own figures
mFiles = dir(fullfile(examplesDir, "example_*.m"));
for i = 1:numel(mFiles)
    fprintf("  %s\n", mFiles(i).name);
    htmlFile = publish(fullfile(examplesDir, mFiles(i).name), opts);
    close all
    % Images narrower in narrow windows
    html = replace(fileread(htmlFile, Encoding="UTF-8"), "<style type=""text/css"">", ...
        "<style type=""text/css"">" + newline + "img { max-width: 100%; height: auto; }");
    writelines(html, htmlFile, Encoding="UTF-8");
end

opts.showCode = false;
publish(fullfile(examplesDir, "index.m"), opts);
end

function cheatsheetTask(~)
% Generate the cheat sheet from the help headers and inputParser options of
% the methods. Differences between the code and the help headers are
% reported as warnings
addpath("buildutils");
cleanup = onCleanup(@() rmpath("buildutils"));
issues = makeCheatSheet(fullfile("gramm", "html", "gramm_cheat_sheet.html"));
if ~isempty(issues)
    warning("buildfile:cheatsheet", "%d differences between the code and the help headers:\n%s", ...
        numel(issues), strjoin("  " + issues, newline));
end
end

function readmeImagesTask(~)
% Update the images of README.md (run locally, then commit the images)
% The tutorials save their README image with gramm's export() when they run
restoreTheme = onCleanup(lightFigures());
cleanup = onCleanup(@removeLiveScriptFiles);
for name = tutorials()
    runTutorial(name, fullfile(tempdir, name + ".html"));
end
movefile(fullfile("gramm", "doc", "*_export.png"), "images");

% The other images come from the published examples
galleryImages = [
    "overlaid_export"    "example_advanced_superimposed_plots_01"
    "layout_export"      "example_advanced_marginal_histograms_01"
    "scaling_export"     "example_facet_grid_scale_options_01"
    "colorlegend_export" "example_color_palette_customization_02"];
for k = 1:height(galleryImages)
    copyfile(fullfile("gramm", "html", "examples", galleryImages(k,2) + ".png"), ...
        fullfile("images", galleryImages(k,1) + ".png"));
end
end

function runTutorial(name, htmlFile)
% Run a tutorial live script and export it as HTML. export() shows errors
% in the page instead of throwing them (CatchError=false would also stop
% on errors caught by the code), so the page is checked for them
export(fullfile("gramm", "doc", name + ".mlx"), htmlFile, Run=true);
if contains(fileread(htmlFile), "embeddedOutputsErrorElement")
    error("buildfile:tutorialError", "%s.mlx has errors, see %s", name, htmlFile);
end
end

function removeLiveScriptFiles
% Remove the files written by the live scripts when they run (downloaded
% data, images saved with export()): everything in gramm/ is packaged
files = [dir(fullfile("gramm", "doc", "*.mat")); dir(fullfile("gramm", "doc", "*_export.png"))];
for k = 1:numel(files)
    delete(fullfile(files(k).folder, files(k).name));
end
end

function restore = lightFigures
% Draw the documentation figures with the light theme, whatever the desktop
% theme. Returns the function restoring the theme, for onCleanup()
s = settings;
s.matlab.appearance.figure.GraphicsTheme.TemporaryValue = "light";
restore = @() clearTemporaryValue(s.matlab.appearance.figure.GraphicsTheme);
end

function packageTask(~)
% Create MLTBX package
    prjFile = "gramm.prj";
    packagingData = matlab.addons.toolbox.ToolboxOptions(prjFile);
    % tiledlayout features used by gramm (tilenum) need R2022b
    packagingData.MinimumMatlabRelease = "R2022b";
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
