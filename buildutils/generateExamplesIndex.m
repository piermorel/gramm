function generateExamplesIndex(htmlDir)
%generateExamplesIndex Generate an index page by publishing a temporary .m script.
%   generateExamplesIndex(htmlDir) scans htmlDir for example HTML files,
%   groups them by category (from filename prefix), builds a .m script with
%   %% sections and publish-style links, and publishes it to index.html.
%
%   File naming convention: example_<category>_<name>.html
%   Categories are auto-discovered. No configuration needed.

htmlFiles = dir(fullfile(htmlDir, "example_*.html"));
if isempty(htmlFiles)
    warning("generateExamplesIndex:noFiles", "No example_*.html files in %s", htmlDir);
    return
end

categorized = containers.Map('KeyType','char','ValueType','any');
for i = 1:numel(htmlFiles)
    [~, name] = fileparts(htmlFiles(i).name);
    tokens = regexp(name, '^example_([^_]+)_(.+)$', 'tokens');
    if ~isempty(tokens)
        cat = tokens{1}{1};
        displayName = strrep(tokens{1}{2}, '_', ' ');
    else
        cat = "general";
        displayName = name;
    end
    entry.file = htmlFiles(i).name;
    entry.displayName = displayName;
    if categorized.isKey(cat)
        categorized(cat) = [categorized(cat), {entry}];
    else
        categorized(cat) = {entry};
    end
end

categories = sort(string(categorized.keys));

% Build a .m script using MATLAB publish markup
lines = [
    "% gramm Examples"
    "% Auto-generated index of published examples."
    ""
];
for i = 1:numel(categories)
    cat = categories(i);
    sectionTitle = upper(extractBefore(cat,2)) + extractAfter(cat,1);
    lines = [lines; "%% " + sectionTitle]; %#ok<AGROW>
    entries = categorized(char(cat));
    for j = 1:numel(entries)
        e = entries{j};
        lines = [lines; "% * <" + e.file + " " + e.displayName + ">"]; %#ok<AGROW>
    end
    lines = [lines; ""]; %#ok<AGROW>
end

scriptFile = fullfile(htmlDir, "index_generator.m");
writelines(lines, scriptFile);
publish(scriptFile, struct('format','html','outputDir',htmlDir,'showCode',false));
delete(scriptFile);

% Rename published output to index.html
movefile(fullfile(htmlDir, "index_generator.html"), fullfile(htmlDir, "index.html"));
fprintf("Generated index.html with %d examples in %s\n", numel(htmlFiles), htmlDir);
end
