function createMLTBX(prjFile, toolboxVersion)
% Package the toolbox as MLTBX file.
% createMLTBX(prjFile, toolboxVersion) builds the MLTBX file and saves
% it in the release folder. Input prjFile is the name of the toolbox
% packaging file and toolboxVersion is a string of the form Major.Minor.Bug.Build.

if ~isfile(prjFile)
    error("Unable to find " + "'" + prjFile+ "'");
end

packagingData = matlab.addons.toolbox.ToolboxOptions(prjFile);

% Update the version number
packagingData.ToolboxVersion = toolboxVersion;

% packagingData.OutputFile = fullfile("release", "fsda.mltbx");
packagingData.OutputFile = strcat(toolboxVersion, ".mltbx");

% Create toolbox MLTBX
matlab.addons.toolbox.packageToolbox(packagingData);

end