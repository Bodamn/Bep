function AIConfig(vars)
%% Load variables
    loadname ='vars.mat';
    load(loadname);
%% AI CONFIGURATION
    card = calllib(LIB,'DSA_Register_Card',card_type,card_num);
    if card < 0 
        unloadlibrary(LIB);
        error = card;
        fprintf('DSA_Register_Card failed with error code %d\n',error);
        return;
    end
    
    
    [error,AI_ActualRate] = calllib(LIB,'DSA_AI_9527_ConfigSampleRate',card,SampleRate,AI_ActualRate);
    if error < 0 && error~=-81
        calllib(LIB,'DSA_Release_Card', card);
        unloadlibrary(LIB);
        fprintf('DSA_AI_9527_ConfigSampleRate failed with error code %d\n',error);
        return;
    end
    
    error = calllib(LIB,'DSA_AI_9527_ConfigChannel',card,AI_Channel(1,1),AI_AdRange(1,1),AI_ConfigCtrl(1,1),AutoReset);
    if error < 0
        calllib(LIB,'DSA_Release_Card', card);
        unloadlibrary(LIB);
        fprintf('DSA_AI_9527_ConfigChannel failed with error code %d\n',error);
        return;
    end 
    
    if Analog_Trg > 0
        TrigCtrl = bitor(DSADASK.P9527_TRG_SRC_ANALOG,DSADASK.P9527_TRG_MODE_POST);%P9527_TRG_SRC_NOWAIT|P9527_TRG_MODE_POST

        error = calllib(LIB,'DSA_TRG_Config',card,TrigTarget,TrigCtrl,ReTriggerCnt,TriggerDelay);
        if error < 0
            calllib(LIB,'DSA_Release_Card',card);
            unloadlibrary(LIB);
            fprintf('DSA_TRG_Config failed with error code %d\n',error);
            return;
        end
        
        error = calllib(LIB,'DSA_TRG_ConfigAnalogTrigger',card,Analog_Trg_src,Analog_Trg_mode,Analog_Trg_th);
        fprintf(strcat('Trigger Ai',num2str(Analog_Trg_src),'\n'));
        if error < 0
            calllib(LIB,'DSA_Release_Card',card);
            unloadlibrary(LIB);
            fprintf('DSA_ANALGO_TRG_Config failed with error code %d\n',error);
            return;
        end
        
    else
        error = calllib(LIB,'DSA_TRG_Config',card,TrigTarget,TrigCtrl,ReTriggerCnt,TriggerDelay);
        if error < 0
            calllib(LIB,'DSA_Release_Card',card);
            unloadlibrary(LIB);
            fprintf('DSA_TRG_Config failed with error code %d\n',error);
            return;
        end
    end 
        
    error = calllib(LIB,'DSA_AI_AsyncDblBufferMode',card,bEnable);
    if error < 0
        calllib(LIB,'DSA_Release_Card',card);
        unloadlibrary(LIB);
        fprintf('DSA_AI_AsyncDblBufferMode failed with error code %d\n',error);
        return;
    end

%% Save Variables
    save(vars);
end