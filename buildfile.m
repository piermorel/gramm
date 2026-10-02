function plan = buildfile
import matlab.buildtool.tasks.*

plan = buildplan(localfunctions);

plan("clean") = CleanTask;
plan("check") = CodeIssuesTask(Results="issues.mat");

% Local test tasks deliberately have no Inputs/Outputs: always execute.
plan("runExample").Description = "Test all examples, including Vega exports";
plan("runVega").Description = "Test only Vega export examples";
plan("publish").Description = "Publish public and Vega examples and gallery";

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

function runExampleTask(context)
run_examples(context.Plan.RootFolder, 'gramm/examples', 'all');
end

function runVegaTask(context)
run_examples(context.Plan.RootFolder, 'gramm/examples/vega', 'vega');
end

function run_examples(repository_root, example_folder, report_name)
original_path = path;
cleanup_path = onCleanup(@() path(original_path)); %#ok<NASGU>
addpath(fullfile(repository_root, 'buildutils', 'vega'));
run_gramm_examples(repository_root, fullfile(repository_root, example_folder), report_name);
end

function publishTask(context)
% Publish each example once, retaining the exports produced by that execution.
repository_root = context.Plan.RootFolder;
original_path = path;
cleanup_path = onCleanup(@() path(original_path)); %#ok<NASGU>
addpath(fullfile(repository_root, 'buildutils', 'vega'));
publish_examples(repository_root);
end

function publish_examples(repository_root)
% Keep output-state cleanup in an inner scope so it precedes path cleanup.
cleanup_outputs = prepare_vega_outputs(repository_root); %#ok<NASGU>
examples_dir = fullfile(repository_root, 'gramm', 'examples');
html_dir = fullfile(examples_dir, 'html');
vega_html_dir = fullfile(html_dir, 'vega');
if ~isfolder(vega_html_dir)
    mkdir(vega_html_dir);
end
opts.format = 'html';
opts.showCode = true;
opts.figureSnapMethod = 'print';
opts.catchError = false;
folders = {examples_dir, fullfile(examples_dir, 'vega')};
addpath(folders{:});
outputs = {html_dir, vega_html_dir};
for folder_index = 1:numel(folders)
    opts.outputDir = outputs{folder_index};
    files = dir(fullfile(folders{folder_index}, 'example_*.m'));
    assert(~isempty(files), 'gramm:build:NoExamples', 'No examples found in %s.', folders{folder_index});
    for k = 1:numel(files)
        fprintf('Publishing %s\n', files(k).name);
        publish(fullfile(files(k).folder, files(k).name), opts);
    end
end
assemble_vega_gallery(repository_root);
% Generate the Vega index from source names so new examples are discoverable.
index_file = fullfile(repository_root, 'build', 'vega', 'published_index.m');
fid = fopen(index_file, 'w');
assert(fid ~= -1, 'gramm:build:IndexWrite', 'Cannot write Vega example index.');
cleanup_file = onCleanup(@() fclose(fid));
fprintf(fid, '%%%% Vega export examples\n');
for k = 1:numel(files)
    [~, stem] = fileparts(files(k).name);
    fprintf(fid, '%% * <%s.html %s>\n', stem, strrep(stem, '_', ' '));
end
fprintf(fid, '%%\n%% <../../../../build/vega/index.html Interactive comparison gallery>\n');
clear cleanup_file
opts.outputDir = vega_html_dir;
opts.showCode = false;
opts.evalCode = false;
index_output = publish(index_file, opts);
movefile(index_output, fullfile(vega_html_dir, 'index.html'), 'f');
opts.outputDir = html_dir;
publish(fullfile(examples_dir, 'index.m'), opts);
end
