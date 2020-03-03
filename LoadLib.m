function LoadLib()

addpath('..\DSADASK');
    %check x64 or x86
    if strcmp(computer('arch'),'win64')
        DLL = 'DSA-Dask64.dll';
        HEADER = 'DSA-Dask64_forMatlab.h';
        LIB = 'dsadasklib';
    else
        DLL = 'DSA-Dask.dll';
        HEADER = 'DSA-Dask_forMatlab.h';
        LIB = 'dsadasklib';
    end
    %check DLL and HEADER 
    if ~exist(DLL,'file') || ~exist(HEADER,'file')
        fprintf('DLL or HEADER is not found here\n');
        return;
    end
    %check lib loading
    if ~libisloaded(LIB)
        [notfound,warnings] = loadlibrary(DLL,HEADER,'alias',LIB);
        if ~libisloaded(LIB)
            fprintf('Load lib failed\n');
            return;
        end
    end
    
    
    %% save
    savename = 'vars.mat';
    save(savename);
end