function validate_test_outputs(vega_dir, svg_file)
%VALIDATE_TEST_OUTPUTS Check that one smoke test produced readable outputs.

[~, file_stem] = fileparts(svg_file);
json_file = fullfile(vega_dir, [file_stem '.json']);
html_file = fullfile(vega_dir, [file_stem '.html']);

assert(isfile(json_file), 'gramm:test:MissingVegaJSON', ...
    'Vega JSON output was not created: %s', json_file);
assert(isfile(html_file), 'gramm:test:MissingVegaHTML', ...
    'Vega HTML output was not created: %s', html_file);
assert(isfile(svg_file), 'gramm:test:MissingSVG', ...
    'Reference SVG output was not created: %s', svg_file);

spec = jsondecode(fileread(json_file));
required_fields = {'width', 'height', 'data', 'marks'};
for i = 1:numel(required_fields)
    field_name = required_fields{i};
    assert(isfield(spec, field_name), 'gramm:test:IncompleteVegaSpec', ...
        'Vega JSON %s is missing the required field "%s".', ...
        json_file, field_name);
end

html = fileread(html_file);
assert(contains(html, [file_stem '.json']), ...
    'gramm:test:IncorrectHTMLReference', ...
    'Vega HTML %s does not reference its JSON output.', html_file);
end
