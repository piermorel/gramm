function plan = buildfile
import matlab.buildtool.tasks.*

plan = buildplan(localfunctions);

plan("clean") = CleanTask;
plan("check") = CodeIssuesTask(Results="issues.mat");

reportFormat = matlab.unittest.plugins.codecoverage.CoverageReport('coverage-report');
covPlugin = matlab.unittest.plugins.CodeCoveragePlugin.forFolder("gramm","Producing",  reportFormat);
plan("runExample") = ExampleDrivenTesterTask("gramm/examples", CodeCoveragePlugin = covPlugin);

plan("docs").Inputs = ["gramm/doc/" + liveScripts() + ".mlx" "buildutils/gramm_doc.css"];
plan("docs").Outputs = "gramm/html/" + liveScripts() + ".html";

plan("publish").Inputs = ["gramm/examples/*.m" "buildutils/gramm_doc.css"];
plan("publish").Outputs = "gramm/html/examples/**";

plan("cheatsheet").Inputs = ["gramm/@gramm/**/*.m" "gramm/examples/example_*.m" "buildutils/makeCheatSheet.m" "buildutils/cheatsheet_template.html"];
plan("cheatsheet").Outputs = "gramm/html/gramm_cheat_sheet.html";

plan("gallery").Inputs = ["gramm/@gramm/**/*.m" "buildutils/makeGallery.m"];
plan("gallery").Outputs = "gramm/html/gallery/*.png";

plan("package").Dependencies = ["check" "runExample" "docs" "publish" "cheatsheet" "gallery"];

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
    writelines(addDocStyle(html), htmlFile, Encoding="UTF-8");
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
    addDocStyleToFile(htmlFile);
end

opts.showCode = false;
addDocStyleToFile(publish(fullfile(examplesDir, "index.m"), opts));
end

function html = addDocStyle(html)
% Add the style of the documentation pages (buildutils/gramm_doc.css) after
% the styles written by MATLAB, so that it overrides them. The style is
% inline so that each page works on its own (help browser, website). The
% viewport tag makes phones show the pages at their width
css = fileread(fullfile("buildutils", "gramm_doc.css"), Encoding="UTF-8");
html = replace(html, "</head>", ...
    "<meta name=""viewport"" content=""width=device-width, initial-scale=1"">" + newline + ...
    "<style type=""text/css"">" + newline + css + "</style>" + newline + "</head>");
end

function addDocStyleToFile(htmlFile)
writelines(addDocStyle(fileread(htmlFile, Encoding="UTF-8")), htmlFile, Encoding="UTF-8");
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

function galleryTask(~)
% Draw the gallery figures of the website home page and of README.md
restoreTheme = onCleanup(lightFigures());
addpath("buildutils");
cleanup = onCleanup(@() rmpath("buildutils"));
makeGallery(fullfile("gramm", "html", "gallery"));
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
