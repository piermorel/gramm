function issues = makeCheatSheet(outFile)
% makeCheatSheet Generate the gramm cheat sheet page from the code
%
% issues = makeCheatSheet(outFile) reads the methods in gramm/@gramm and
% writes an HTML cheat sheet to outFile. Each method shows the summary line
% of its help header and a table of its arguments. Names, defaults and
% accepted values come from the inputParser calls (addParameter(),
% valid_choice()), descriptions from the help header, written as:
%
%   % - 'name': Description (default value):
%   %       - 'value': Description of one accepted value
%
% Positional arguments are documented the same way without quotes
% (% - row: Description). The returned issues (string array) list the
% differences between the code and the help headers.

root = fileparts(fileparts(mfilename("fullpath")));
classDir = fullfile(root, "gramm", "@gramm");

files = dir(fullfile(classDir, "*.m"));
names = string(erase({files.name}, ".m"));
issues = strings(0, 1);
methods = cell(1, numel(names));
for k = 1:numel(names)
    [methods{k}, methodIssues] = parseMethod(classDir, names(k));
    issues = [issues; methodIssues]; %#ok<AGROW>
end
methods = [methods{:}];

examples = findExamples(fullfile(root, "gramm", "examples"), names);

% Sections of the page, in order. Methods missing from this list are shown
% in a last section and reported
sections = cheatSheetSections();
listed = [sections.methods];
for name = setdiff(names, listed, "stable")
    issues(end+1, 1) = name + ": not in a cheat sheet section (see cheatSheetSections)"; %#ok<AGROW>
end
for name = setdiff(listed, names, "stable")
    issues(end+1, 1) = name + ": listed in cheatSheetSections but there is no such method"; %#ok<AGROW>
end
other = setdiff(names, listed, "stable");
if ~isempty(other)
    sections(end+1) = struct("id", "other", "title", "Other methods", ...
        "subtitle", "", "hue", 0, "methods", other);
end

html = renderPage(sections, methods, examples);
writelines(html, outFile, Encoding="UTF-8");
end


function sections = cheatSheetSections
% Order of the methods on the page, grouped in sections (hue of the
% section color band)
sections = struct("id", {}, "title", {}, "subtitle", {}, "hue", {}, "methods", {});
sections(end+1) = struct("id", "constructor", "title", "Constructor", ...
    "subtitle", "Object creation, first step", "hue", 0, ...
    "methods", "gramm");
sections(end+1) = struct("id", "facets", "title", "Subplots and figures", ...
    "subtitle", "Method calls, any order", "hue", 40, ...
    "methods", ["facet_grid" "facet_wrap" "fig"]);
sections(end+1) = struct("id", "geoms", "title", "Raw data", ...
    "subtitle", "geom_ method calls, any order", "hue", 205, ...
    "methods", ["geom_point" "geom_jitter" "geom_swarm" "geom_line" "geom_raster" ...
    "geom_bar" "geom_interval" "geom_label" "geom_count"]);
sections(end+1) = struct("id", "stats", "title", "Statistics", ...
    "subtitle", "stat_ method calls, any order", "hue", 230, ...
    "methods", ["stat_summary" "stat_smooth" "stat_glm" "stat_fit" "stat_bin" ...
    "stat_cornerhist" "stat_density" "stat_bin2d" "stat_ellipse" "stat_qq" ...
    "stat_boxplot" "stat_violin"]);
sections(end+1) = struct("id", "elements", "title", "Reference lines and shapes", ...
    "subtitle", "geom_ method calls, any order", "hue", 180, ...
    "methods", ["geom_abline" "geom_vline" "geom_hline" "geom_funline" "geom_polygon"]);
sections(end+1) = struct("id", "options", "title", "Options and customization", ...
    "subtitle", "Method calls, any order", "hue", 120, ...
    "methods", ["set_names" "set_title" "set_order_options" "set_color_options" ...
    "set_continuous_color" "set_point_options" "set_line_options" "set_text_options" ...
    "set_stat_options" "set_layout_options" "set_scale" "set_polar" "set_datetick" ...
    "set_limit_extra" "axe_property" "no_legend" "coord_flip"]);
sections(end+1) = struct("id", "drawing", "title", "Drawing", ...
    "subtitle", "Last method calls", "hue", 350, ...
    "methods", ["set_parent" "draw" "redraw"]);
sections(end+1) = struct("id", "layers", "title", "Superimposing layers", ...
    "subtitle", "After draw(), new layers with new data", "hue", 280, ...
    "methods", "update");
sections(end+1) = struct("id", "export", "title", "Export", ...
    "subtitle", "After draw()", "hue", 300, ...
    "methods", "export");
end


%% Parsing of the methods

function [m, issues] = parseMethod(classDir, name)
% Help header and arguments of a method, merged in rows of the cheat sheet
issues = strings(0, 1);
lines = strtrim(readlines(fullfile(classDir, name + ".m"), Encoding="UTF-8"));

% Function line (the constructor in the classdef file gramm.m)
isFunction = ~cellfun(@isempty, regexp(lines, "^function\s.*\<" + name + "\s*\(", "once"));
fIdx = find(isFunction, 1);
tok = regexp(lines(fIdx), name + "\s*\(([^)]*)\)", "tokens", "once");
signature = strtrim(split(string(tok{1}), ","))';
positional = signature(~ismember(signature, ["obj" "varargin" "~" ""]));

% Help header: comment lines right after the function line
header = strings(0, 1);
k = fIdx + 1;
while k <= numel(lines) && startsWith(lines(k), "%")
    header(end+1, 1) = extractAfter(lines(k), 1); %#ok<AGROW>
    k = k + 1;
end
if isempty(header)
    issues(end+1, 1) = name + ": no help header";
    header = "";
end
[summary, prose, docParams] = parseHeader(header, name);

% Name-value parameters from inputParser. The constructor arguments are
% parsed in private/parse_aes.m
codeFile = fullfile(classDir, name + ".m");
if name == "gramm"
    codeFile = fullfile(classDir, "private", "parse_aes.m");
end
codeParams = parseCode(codeFile);

% Rows: positional arguments, then name-value parameters in code order
docNames = string({docParams.name});
docPositional = logical([docParams.positional]);
codeNames = string({codeParams.name});
rows = struct("name", {}, "positional", {}, "default", {}, "desc", {}, ...
    "values", {}, "valueDescs", {});
for arg = positional
    d = docParams(docPositional & docNames == arg);
    if isempty(d)
        issues(end+1, 1) = name + ": argument " + arg + " not documented"; %#ok<AGROW>
        d = struct("desc", "", "values", strings(1, 0), "valueDescs", strings(1, 0));
    end
    rows(end+1) = struct("name", arg, "positional", true, "default", "", ...
        "desc", d.desc, "values", d.values, "valueDescs", d.valueDescs); %#ok<AGROW>
end
for c = codeParams
    d = docParams(~docPositional & docNames == c.name);
    if isempty(d)
        issues(end+1, 1) = name + ": parameter '" + c.name + "' not documented"; %#ok<AGROW>
        d = struct("desc", "", "values", strings(1, 0), "valueDescs", strings(1, 0));
    end
    % Defaults computed in the code (variables) are only described in the help
    isComputed = ~isempty(regexp(c.default, "^[A-Za-z]\w*$", "once")) && ...
        ~ismember(c.default, ["true" "false" "Inf" "NaN" "pi"]);
    if isComputed
        c.default = "";
        desc = regexprep(strtrim(d.desc), "\s*:$", "");
        defaultIssue = "";
    else
        [desc, defaultIssue] = checkDefault(d.desc, c.default);
    end
    if defaultIssue ~= ""
        issues(end+1, 1) = name + ": '" + c.name + "' " + defaultIssue; %#ok<AGROW>
    end
    % Accepted values: documented ones first, then the ones only in the code
    values = d.values;
    valueDescs = d.valueDescs;
    if ~isempty(c.choices)
        for v = setdiff(values, c.choices, "stable")
            issues(end+1, 1) = name + ": '" + c.name + "' documents " + v + ", not accepted by the code"; %#ok<AGROW>
        end
        for v = setdiff(c.choices, values, "stable")
            if ~isempty(d.values)
                issues(end+1, 1) = name + ": '" + c.name + "' accepts " + v + ", not documented"; %#ok<AGROW>
            end
            values(end+1) = v; %#ok<AGROW>
            valueDescs(end+1) = ""; %#ok<AGROW>
        end
    end
    if name == "gramm"
        default = ""; % Aesthetics are all empty by default
    else
        default = c.default;
    end
    rows(end+1) = struct("name", c.name, "positional", false, "default", default, ...
        "desc", desc, "values", values, "valueDescs", valueDescs); %#ok<AGROW>
end
for d = docParams
    if strtrim(d.desc) == ""
        issues(end+1, 1) = name + ": '" + d.name + "' has an empty description"; %#ok<AGROW>
    end
    if d.positional && ~ismember(d.name, positional)
        issues(end+1, 1) = name + ": documents argument " + d.name + ", not in the function signature"; %#ok<AGROW>
    elseif ~d.positional && ~ismember(d.name, codeNames) && ~isempty(codeParams)
        issues(end+1, 1) = name + ": documents '" + d.name + "', not a parameter in the code"; %#ok<AGROW>
    end
end
% Methods parsing their arguments by hand (set_names, axe_property...):
% the documented parameters are shown as they are
if isempty(codeParams)
    for d = docParams(~docPositional)
        rows(end+1) = struct("name", d.name, "positional", false, "default", "", ...
            "desc", d.desc, "values", d.values, "valueDescs", d.valueDescs); %#ok<AGROW>
    end
end

m = struct("name", name, "summary", summary, "prose", prose, "rows", rows);
end


function [summary, prose, params] = parseHeader(header, name)
% Summary line, other text, and documented arguments of a help header
summary = strtrim(header(1));
if startsWith(summary, name + " ")
    summary = strtrim(extractAfter(summary, strlength(name)));
end

params = struct("name", {}, "positional", {}, "desc", {}, "values", {}, "valueDescs", {});
prose = strings(1, 0);
paragraph = "";
current = 0;      % Index of the argument being described
currentValue = 0; % Index of its value being described
for k = 2:numel(header)
    h = header(k);
    bullet = parseBullet(h);
    if ~isempty(bullet) && strlength(bullet.indent) <= 2
        % New argument: quoted for name-value parameters
        params(end+1) = struct("name", string(bullet.quoted) + string(bullet.word), ...
            "positional", strlength(bullet.quoted) == 0, "desc", string(bullet.desc), ...
            "values", strings(1, 0), "valueDescs", strings(1, 0)); %#ok<AGROW>
        current = numel(params);
        currentValue = 0;
    elseif ~isempty(bullet) && current > 0
        % Indented bullet: one of the accepted values of the argument
        if strlength(bullet.quoted) > 0
            value = "'" + bullet.quoted + "'";
        else
            value = string(bullet.word);
        end
        params(current).values(end+1) = value;
        params(current).valueDescs(end+1) = string(bullet.desc);
        currentValue = numel(params(current).values);
    elseif strtrim(h) == ""
        current = 0;
        currentValue = 0;
        if paragraph ~= ""
            prose(end+1) = paragraph; %#ok<AGROW>
            paragraph = "";
        end
    elseif startsWith(strtrim(h), ["Parameters given as" "Arguments:"])
        % Introduces the list of arguments
    elseif currentValue > 0
        params(current).valueDescs(currentValue) = params(current).valueDescs(currentValue) + " " + strtrim(h);
    elseif current > 0
        params(current).desc = params(current).desc + " " + strtrim(h);
    elseif ~isempty(regexp(h, "^\s{3,}\S", "once"))
        % Indented text (code, diagrams): kept as is, marked with ```
        if paragraph ~= "" && ~startsWith(paragraph, "```")
            prose(end+1) = paragraph; %#ok<AGROW>
            paragraph = "";
        end
        if paragraph == ""
            paragraph = "```" + strip(h, "right");
        else
            paragraph = paragraph + newline + strip(h, "right");
        end
    else
        if startsWith(paragraph, "```")
            prose(end+1) = paragraph; %#ok<AGROW>
            paragraph = "";
        end
        paragraph = strtrim(paragraph + " " + strtrim(h));
    end
end
if paragraph ~= ""
    prose(end+1) = paragraph;
end
end


function bullet = parseBullet(h)
% Bullet of a help header: "- 'name': desc" (quoted, the description is
% optional for values) or "- name: desc". Empty if the line is not a bullet
% (MATLAB doesn't return named tokens in optional groups: two patterns)
bullet = regexp(h, "^(?<indent>\s*)- '(?<quoted>[^']*)':\s*(?<desc>.*)$", "names", "once");
if isempty(bullet)
    bullet = regexp(h, "^(?<indent>\s*)- '(?<quoted>[^']*)'\s*$", "names", "once");
    if ~isempty(bullet)
        bullet.desc = "";
    end
end
if ~isempty(bullet)
    bullet.word = "";
    return
end
% Unquoted: positional argument (a single word), or value of an argument
% (e.g. "- -1: ..." or "- [index1 index2 ...]: ...")
bullet = regexp(h, "^(?<indent>\s*)- (?<word>[^'\s][^:]*?):\s+(?<desc>.*)$", "names", "once");
if ~isempty(bullet)
    bullet.quoted = "";
    if strlength(bullet.indent) <= 2 && isempty(regexp(bullet.word, "^\w+$", "once"))
        bullet = [];
    end
end
end


function params = parseCode(file)
% Name, default value and valid_choice() values of the addParameter() calls
params = struct("name", {}, "default", {}, "choices", {});
lines = strtrim(readlines(file, Encoding="UTF-8"));
lines = lines(contains(lines, "addParameter(") & ~startsWith(lines, "%"));
for k = 1:numel(lines)
    args = splitArgs(extractAfter(lines(k), "addParameter("));
    if numel(args) < 3
        continue
    end
    choices = strings(1, 0);
    if numel(args) > 3
        tok = regexp(args(4), "valid_choice\(\s*v\s*,\s*\{([^}]*)\}", "tokens", "once");
        if ~isempty(tok)
            choices = string(regexp(tok{1}, "'[^']*'", "match"));
        end
    end
    params(end+1) = struct("name", erase(args(2), ["'" """"]), ...
        "default", args(3), "choices", choices); %#ok<AGROW>
end
end


function args = splitArgs(s)
% Comma separated arguments of a call, s starting right after its "("
args = strings(1, 0);
c = char(s);
depth = 0;
inQuote = false;
first = 1;
for k = 1:numel(c)
    if inQuote
        inQuote = c(k) ~= ''''; % Escaped quotes ('') close and reopen
    elseif c(k) == ''''
        inQuote = true;
    elseif any(c(k) == '([{')
        depth = depth + 1;
    elseif any(c(k) == ')]}') && depth > 0
        depth = depth - 1;
    elseif (c(k) == ',' || c(k) == ')') && depth == 0
        args(end+1) = strtrim(string(c(first:k-1))); %#ok<AGROW>
        first = k + 1;
        if c(k) == ')'
            return
        end
    end
end
end


function [desc, issue] = checkDefault(desc, codeDefault)
% Compare the "(default ...)" of a description with the default in the
% code. When they are the same it is removed from the description, as the
% cheat sheet shows the default in its own column (only an explanation
% following the value is kept)
issue = "";
pattern = "\s*\(default ((?:[^()]|\([^()]*\))*)\)";
tok = regexp(desc, pattern, "tokens", "once");
if ~isempty(tok)
    docText = regexprep(string(tok{1}), "^is\s+", "");
    docDefault = normalizeCode(docText);
    codeDefault = normalizeCode(codeDefault);
    % Explanation following the value: "(default [85 15], light to dark)"
    explanation = "";
    separators = regexp(docText, "[,:;]");
    for k = separators
        if normalizeCode(extractBefore(docText, k)) == codeDefault
            explanation = strtrim(extractAfter(docText, k));
            break
        end
    end
    if docDefault == codeDefault
        desc = regexprep(desc, pattern, "", "once");
    elseif explanation ~= ""
        % The value is in its own column, only the explanation stays
        desc = regexprep(desc, pattern, " (" + regexprep(explanation, "[\\$]", "\\$0") + ")", "once");
    elseif codeDefault ~= "[]"
        % An empty default in the code is resolved later: the help says how.
        % Otherwise the help can only add an explanation after the value
        issue = "default is " + docText + " in the help, " + codeDefault + " in the code";
    end
end
desc = regexprep(strtrim(desc), "\s*:$", "");
end


function s = normalizeCode(s)
s = replace(erase(string(s), " "), """", "'");
end


function examples = findExamples(examplesDir, names)
% Examples calling each method: struct with a field per method, holding a
% struct array of example file names and titles
examples = struct();
for name = names
    examples.(name) = struct("file", {}, "title", {});
end
files = dir(fullfile(examplesDir, "example_*.m"));
for k = 1:numel(files)
    code = readlines(fullfile(files(k).folder, files(k).name), Encoding="UTF-8");
    title = strtrim(erase(code(1), "%%"));
    code = code(~startsWith(strtrim(code), "%"));
    tok = regexp(strjoin(code, newline), "\.(\w+)\(", "tokens");
    called = unique(string([tok{:}]));
    file = erase(string(files(k).name), ".m");
    for name = intersect(called, names)
        examples.(name)(end+1) = struct("file", file, "title", title);
    end
    % The constructor is called as a function
    if contains(strjoin(code), "gramm(")
        examples.gramm(end+1) = struct("file", file, "title", title);
    end
end
end


%% HTML rendering

function html = renderPage(sections, methods, examples)
names = [methods.name];
body = strings(0, 1);
nav = strings(0, 1);
for s = sections
    cards = strings(0, 1);
    links = strings(0, 1);
    for name = s.methods(ismember(s.methods, names))
        cards(end+1) = renderMethod(methods(names == name), examples.(name), names); %#ok<AGROW>
        links(end+1) = sprintf('<li><a href="#%s">%s</a></li>', name, name); %#ok<AGROW>
    end
    % Sidebar: sections with the list of their methods
    nav(end+1) = sprintf('<li class="nav-group" style="--hue:%d"><a href="#%s">%s</a>\n<ul>\n%s\n</ul></li>', ...
        s.hue, s.id, s.title, strjoin(links, newline)); %#ok<AGROW>
    body(end+1) = sprintf(['<section class="group" id="%s" style="--hue:%d">\n' ...
        '<h2>%s <span>%s</span></h2>\n<div class="cards">\n%s\n</div>\n</section>'], ...
        s.id, s.hue, s.title, s.subtitle, strjoin(cards, newline)); %#ok<AGROW>
end
html = replace(pageTemplate(), ["{{NAV}}" "{{BODY}}"], ...
    [strjoin(nav, newline) strjoin(body, newline)]);
end


function card = renderMethod(m, examples, names)
if m.name == "gramm"
    call = "g = <b>gramm</b>(";
else
    call = "g.<b>" + m.name + "</b>(";
end

rows = strings(0, 1);
for r = m.rows
    if r.positional
        argName = "<i>" + r.name + "</i>";
    else
        argName = "'" + r.name + "'";
    end
    if r.desc == "" && isempty(r.values)
        desc = "<span class=""todo"">Not documented</span>";
    else
        desc = richText(r.desc, names);
    end
    % The default is starred in the list of accepted values when it is one of them
    default = r.default;
    if ismember(normalizeCode(default), normalizeCode(r.values))
        default = "";
    end
    % Accepted values without descriptions are listed under the description,
    % the others have a row each
    describedValues = any(r.valueDescs ~= "");
    if ~isempty(r.values) && ~describedValues
        cells = strings(1, numel(r.values));
        for v = 1:numel(r.values)
            cells(v) = codeValue(r.values(v));
            if normalizeCode(r.values(v)) == normalizeCode(r.default)
                cells(v) = "<span class=""default"">" + cells(v) + "</span>";
            end
        end
        if desc == "<span class=""todo"">Not documented</span>"
            desc = "";
        end
        desc = desc + "<div class=""values"">" + strjoin(cells, " ") + "</div>";
    end
    rows(end+1) = sprintf('<tr><td class="arg">%s</td><td class="val">%s</td><td>%s</td></tr>', ...
        argName, codeValue(default), desc); %#ok<AGROW>
    if ~describedValues
        continue
    end
    for v = 1:numel(r.values)
        isDefault = normalizeCode(r.values(v)) == normalizeCode(r.default);
        rows(end+1) = sprintf('<tr class="choice%s"><td class="val" colspan="2">%s</td><td>%s</td></tr>', ...
            repmat(' default', 1, double(isDefault)), codeValue(r.values(v)), richText(r.valueDescs(v), names)); %#ok<AGROW>
    end
end
if isempty(rows)
    table = "";
else
    table = "<table>" + strjoin(rows, newline) + "</table>";
end

more = "";
if ~isempty(m.prose)
    more = "<details><summary>More</summary><p>" + ...
        strjoin(arrayfun(@(p) proseHtml(p, names), m.prose), "</p><p>") + "</p></details>";
end

links = "";
if ~isempty(examples)
    n = min(3, numel(examples));
    items = arrayfun(@(e) string(sprintf('<a href="examples/%s.html">%s</a>', e.file, esc(e.title))), examples(1:n));
    links = "<p class=""examples"">Examples: " + strjoin(items, " · ");
    if numel(examples) > n
        links = links + sprintf(" · <a href=""examples/index.html"">+%d</a>", numel(examples) - n);
    end
    links = links + "</p>";
end

search = lower(strjoin([m.name m.summary [m.rows.name] [m.rows.values]], " "));
card = sprintf(['<article class="method" id="%s" data-search="%s">\n' ...
    '<h3><code>%s</code> <span>%s</span></h3>\n%s\n%s\n%s\n</article>'], ...
    m.name, esc(search), call, richText(m.summary, names), table, more, links);
end


function s = proseHtml(p, names)
% Paragraph of the help text, or preformatted block (marked with ```)
if startsWith(p, "```")
    lines = splitlines(extractAfter(p, 3));
    indent = min(strlength(lines) - strlength(strip(lines, "left")));
    s = "</p><pre>" + esc(strjoin(extractAfter(lines, indent), newline)) + "</pre><p>";
else
    s = richText(p, names);
end
end


function s = codeValue(v)
% Default or accepted value, colored by type
if v == ""
    s = "";
    return
end
if startsWith(v, ["'" """"])
    cls = "str";
elseif ismember(v, ["true" "false"])
    cls = "kw";
elseif startsWith(v, "@")
    cls = "fun";
else
    cls = "num";
end
s = "<code class=""" + cls + """>" + esc(v) + "</code>";
end


function t = richText(t, names)
% Description text: quoted options in code font, links to other methods
t = esc(t);
t = regexprep(t, "'([^'\s]+)'", "<code>'$1'</code>");
tok = regexp(t, "(\w+)\(\)", "tokens");
called = unique(string([tok{:}]));
for name = intersect(called, names)
    t = replace(t, name + "()", "<a href=""#" + name + """>" + name + "()</a>");
end
end


function s = esc(s)
s = replace(string(s), ["&" "<" ">" """"], ["&amp;" "&lt;" "&gt;" "&quot;"]);
end


function t = pageTemplate
% Page skeleton (HTML, CSS, filter script) with {{NAV}} and {{BODY}}
% placeholders, kept as a plain HTML file so that it can be edited and
% previewed in a browser
t = fileread(fullfile(fileparts(mfilename("fullpath")), "cheatsheet_template.html"), Encoding="UTF-8");
end
