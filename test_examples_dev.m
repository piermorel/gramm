classdef test_examples_dev < matlab.unittest.TestCase
    methods(Test)
        function runAllExamples(testCase)

            examplesDir = fullfile('gramm', 'examples');
            files = dir(fullfile(examplesDir, '*.m'));

            failures = {}; % collect error messages

            for k = 1:numel(files)
                exampleFile = fullfile(files(k).folder, files(k).name);
                [~, name] = fileparts(exampleFile);

                try
                    run(exampleFile);
                catch msg
                    failures{end+1} = sprintf('%s failed:\n%s', ...
                        name, getReport(msg, 'basic'));
                end
                
            end

            % After running all, fail if any example had errors
            if ~isempty(failures)
                testCase.verifyFail(strjoin(failures, newline));
            else
                testCase.verifyTrue(true); % all passed
            end

        end
    end
end