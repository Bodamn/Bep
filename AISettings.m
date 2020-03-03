function AISettings(vars)
%% load
load(vars);
 %% AI SETTINGS
 
    card_type = DSADASK.PCI_9527;%PCI_9527
    card_num = uint16(0);
    SampleRate(1,1) = 64000.0;
    AI_ActualRate(1,1) = 0.0;
    AI_ReadCount = uint32(16000);
    
    
    AI_Channel(1,1) = DSADASK.P9527_AI_CH_0;%P9527_AI_CH_0
    AutoReset= uint8(1);
    AI_AdRange(1,1) = DSADASK.AD_B_10_V;%AD_B_10_V
    AI_ConfigCtrl(1,1) = bitor(DSADASK.P9527_AI_Differential,DSADASK.P9527_AI_Coupling_DC);%P9527_AI_Differential|P9527_AI_Coupling_DC
    TrigTarget(1,1) = DSADASK.P9527_TRG_AI;%P9527_TRG_AI
    TrigCtrl(1,1) = bitor(DSADASK.P9527_TRG_SRC_NOWAIT,DSADASK.P9527_TRG_MODE_POST);%P9527_TRG_SRC_NOWAIT|P9527_TRG_MODE_POST
    ReTriggerCnt(1,1) = uint32(0);
    TriggerDelay(1,1) = uint32(0); 
    AI_buffer0 = zeros(2,AI_ReadCount,'uint32');
    AI_buffer1 = zeros(2,AI_ReadCount,'uint32');
    AI_bufferID0(1,1) = uint16(0);
    AI_bufferID1(1,1) = uint16(0);
    volts = zeros(1,AI_ReadCount,'double');
    SyncMode = DSADASK.ASYNCH_OP;%async
    bEnable = 1;
    AI_HalfReady(1,1) = 0;
    AI_Stopped(1,1) = 0;   
    AI_AccessCnt(1,1) = int32(0);
    
    

    AI_Channel(2,1) = DSADASK.P9527_AI_CH_0;%P9527_AI_CH_0
    AI_AdRange(2,1) = DSADASK.AD_B_10_V;%AD_B_10_V
    AI_ConfigCtrl(2,1) = bitor(DSADASK.P9527_AI_Differential,DSADASK.P9527_AI_Coupling_DC);%P9527_AI_Differential|P9527_AI_Coupling_DC
    
    AI_buffer0 = zeros(2,AI_ReadCount,'uint32');
    AI_buffer1 = zeros(2,AI_ReadCount,'uint32');
    AI_bufferID0(2,1) = uint16(0);
    AI_bufferID1(2,1) = uint16(0);
    volts = zeros(2,AI_ReadCount,'double');
    
    
    % e.genco@tue.nl 
    Analog_Trg=0;
    Analog_Trg_src=DSADASK.P9527_TRG_Analog_CH1;
    Analog_Trg_mode=DSADASK.P9527_TRG_Analog_Above_threshold;
    Analog_Trg_th=0.0;
    ovolts=NaN(1,1);
    
    if Analog_Trg ~= 0   %% in Analog input and output configuration trigger MUST be software!!!
        Analog_Trg= 0;
    end
    
%% save
    save(vars);

end