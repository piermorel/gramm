function installAddOn(FXID,version)
    fileExchangeId = FXID;
    addonReleaseVersion = version;
    
    urlGen = matlab.addons.repositories.FileExchangeRepositoryUrlGenerator;
    url = urlGen.addonPackagesUrl(fileExchangeId, addonReleaseVersion);
    pkgMetadata = webread(url);
    
    isMltbx = arrayfun(@(p) strcmp(p.type,'mltbx'), pkgMetadata.packages);
    mltbxMetadata = pkgMetadata.packages(find(isMltbx,1));
    
    if isempty(mltbxMetadata)
        error("No mltbx package found.");
    end
    
    outFile = fullfile(tempdir, mltbxMetadata.filename);
    websave(outFile, mltbxMetadata.url);
    
    matlab.addons.install(outFile);
    rehash toolboxcache;
    
    disp("Installed toolbox from " + mltbxMetadata.url);
end