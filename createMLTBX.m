function createMLTBX(prjFile, toolboxVersion)
% Package the toolbox as MLTBX.
%   createMLTBX(prjFile, toolboxVersion) builds the MLTBX file and saves it
%   in the working directory. The prjFile is the path to the toolbox packaging
%   PRJ file and toolboxVersion is a string of the form Major.Minor.Bug.Build.
%
%   Example
%       createMLTBX("gramm.prj", "1.0.1.3")

if ~isfile(prjFile)
    error("Unable to find \'%s\'.", prjFile);
end

export("gramm/doc/gramm_landing.mlx","gramm/html/gramm_landing.html",Run=true);
export("gramm/doc/GettingStarted.mlx","gramm/html/GettingStarted.html",Run=true);
export("gramm/doc/Groups.mlx","gramm/html/Groups.html",Run=true);
export("gramm/doc/TimeSeries.mlx","gramm/html/TimeSeries.html",Run=true);
export("gramm/doc/XY.mlx","gramm/html/XY.html",Run=true);
export("gramm/doc/examples.mlx","gramm/html/examples.html",Run=true);

movefile('./gramm/doc/gettingstarted_export.png','./images/gettingstarted_export.png')
movefile('./gramm/doc/groups_export.png','./images/groups_export.png')
movefile('./gramm/doc/timeseries_export.png','./images/timeseries_export.png')
movefile('./gramm/doc/xy_export.png','./images/xy_export.png')
movefile('./gramm/doc/overlaid_export.png','./images/overlaid_export.png')
movefile('./gramm/doc/layout_export.png','./images/layout_export.png')
movefile('./gramm/doc/colorlegend_export.png','./images/colorlegend_export.png')
movefile('./gramm/doc/scaling_export.png','./images/scaling_export.png')

%We need to run it again to have correctly sized figures in the html pages
export("gramm/doc/gramm_landing.mlx","gramm/html/gramm_landing.html");
export("gramm/doc/GettingStarted.mlx","gramm/html/GettingStarted.html");
export("gramm/doc/Groups.mlx","gramm/html/Groups.html");
export("gramm/doc/TimeSeries.mlx","gramm/html/TimeSeries.html");
export("gramm/doc/XY.mlx","gramm/html/XY.html");
export("gramm/doc/examples.mlx","gramm/html/examples.html");

packagingData = matlab.addons.toolbox.ToolboxOptions(prjFile);

% Update the version number
packagingData.ToolboxVersion = toolboxVersion;
outputFileName = packagingData.ToolboxName + "_" + toolboxVersion + ".mltbx";
packagingData.OutputFile =outputFileName;

% Create toolbox MLTBX
matlab.addons.toolbox.packageToolbox(packagingData);

fprintf("Created %s.\n", outputFileName);
end