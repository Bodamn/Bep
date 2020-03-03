function AOConfig(LIB)
%% load vars
loadname='AOSettings_vars.mat';
load(loadname);

%% AO CONFIGURATION
    disp('Setting AR');
    [error,AO_ActualRate] = calllib(LIB,'DSA_AO_9527_ConfigSampleRate',card,UpdateRate,AO_ActualRate);
    if error < 0
        calllib(LIB,'DSA_Release_Card', card);
        unloadlibrary(LIB);
        fprintf('DSA_AO_9527_ConfigSampleRate failed with error code %d\n',error);
        return;
    end
    
    error = calllib(LIB,'DSA_AO_9527_ConfigChannel',card,AO_Channel,AO_AdRange,AO_ConfigCtrl,AutoReset);
    if error < 0
        calllib(LIB,'DSA_Release_Card', card);
        unloadlibrary(LIB);
        fprintf('DSA_AO_9527_ConfigChannel failed with error code %d\n',error);
        return;
    end
    

    
    error = calllib(LIB,'DSA_AO_AsyncDblBufferMode',card,bEnable);
    if error < 0
        calllib(LIB,'DSA_Release_Card', card);
        unloadlibrary(LIB);
        fprintf('DSA_AO_AsyncDblBufferMode failed with error code %d\n',error);
        return;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %tpbuffer0 and tpbuffer1 are voidPtr type.
    %We need change type later.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Set buffer0
    AO_pbuffer0 = libpointer('int32Ptr',AO_buffer0);
    [error,AO_tpbuffer0,AO_bufferID0] = calllib(LIB,'DSA_AO_ContBufferSetup',card,AO_pbuffer0,AO_WriteCount,AO_bufferID0);
    if error < 0
        calllib(LIB,'DSA_Release_Card',card);
        unloadlibrary(LIB);
        fprintf('1st DSA_AO_ContBufferSetup failed with error code %d\n',error);
        return;
    end 
    
    %Set buffer1
    AO_pbuffer1 = libpointer('int32Ptr',AO_buffer1);
    [error,AO_tpbuffer1,bufferID1] = calllib(LIB,'DSA_AO_ContBufferSetup',card,AO_pbuffer1,AO_WriteCount,AO_bufferID1);
    if error < 0
        calllib(LIB,'DSA_AO_ContBufferReset',card);
        calllib(LIB,'DSA_Release_Card',card);
        unloadlibrary(LIB);
        fprintf('2nd DSA_AO_ContBufferSetup failed with error code %d\n',error);
        return;
    end 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Use setdatatype to change tpbuffer pointer type 
    % and to set its size (1,AO_WriteCount) 
    %Use tpbuffer to change buffer pattern later , don't use pbuffer
    %Or we will make some problems in Matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    setdatatype(AO_tpbuffer0,'int32Ptr',1,AO_WriteCount);
    setdatatype(AO_tpbuffer1,'int32Ptr',1,AO_WriteCount);
    
    %The 3rd parameter is ignored for 9527
    error = calllib(LIB,'DSA_AO_ContWriteChannel',card,AO_Channel,AO_bufferID0,AO_WriteCount,Iterations,RepeatInterval,definite,SyncMode);
    if error < 0
        calllib(LIB,'DSA_AO_ContBufferReset',card);
        calllib(LIB,'DSA_Release_Card', card);
        unloadlibrary(LIB);
        fprintf('DSA_AO_ContWriteChannel failed with error code %d\n',error);
        return;
    end
    
   
    
        
    RdyCnt = uint32(0);
    
%% save vars
savename = 'AOConfig_vars.mat';
save(savename);

end
