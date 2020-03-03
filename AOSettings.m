function AOSettings(vars)
%% Load Variables
load(vars);
%% AO SETTINGS
    
    %UpdateRate(1,1) = 8000.0;  %% MUST be the same as input!!! WHY?
    AO_ActualRate = 0.0;
    AO_WriteCount = AI_ReadCount*0.5;
    AO_Channel = DSADASK.P9527_AO_CH_0;%P9527_AO_CH_0
    AO_AdRange = DSADASK.AD_B_10_V;%AD_B_10_V
    AO_ConfigCtrl = DSADASK.P9527_AO_Differential;%P9527_AO_Differential

    Iterations = uint32(1);
    RepeatInterval = uint32(0);
    definite = uint16(1);
    AO_bufferID0 = uint16(0);
    AO_bufferID1 = uint16(0);

    bEnable = 1;
    AO_Stopped = 0;
    AO_HalfReady = 0;
    AO_AccessCnt = int32(0);
    
    
    pattern1 = zeros(1,AO_WriteCount);
    ampifier = double(hex2dec('7FFFFF'));
    offset = double(hex2dec('800000'));
    %sin
    a = double(1:AO_WriteCount);
    b = double(AO_WriteCount);
    OutputSamples = F_out*AO_WriteCount;
    pattern0 = zeros(1,AO_WriteCount);
    A = double(1:OutputSamples);
    B = double(OutputSamples);
    %pattern0(:) = sin(a/b*pi*2)*ampifier;
    pattern0(:) = sin(double(1:AO_WriteCount)/double(AO_WriteCount)*pi*2)*ampifier;
    %triangle  
    pattern1(1:AO_WriteCount/2) = double((1:AO_WriteCount/2)-1)/double(AO_WriteCount/2-1);
    pattern1(AO_WriteCount/2:AO_WriteCount) = double(AO_WriteCount-(AO_WriteCount/2:AO_WriteCount))/double(AO_WriteCount-AO_WriteCount/2);
    pattern1 = pattern1*ampifier;
    
    pattern2 = zeros(1,AO_WriteCount);
    pattern2(1,:) = double(hex2dec('51eb8'));
    
    pattern3 = swept_sine(SampleRate);
    
    AO_buffer0 = int32(pattern0);
    AO_buffer1 = int32(pattern0);
    
 
%% store variables
save(vars);


end
