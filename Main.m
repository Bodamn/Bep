    
%% Start Script
    clc;
    clear all;
    close all;
%% Store savename
vars = 'vars.mat';


%% Load Libraries
 LoadLib();
 load(vars);
%% Declare outputs
F_out = 5;
save(vars);
%% Load IO Settings  
AISettings(vars); 
load(vars);
AOSettings(vars);
load(vars);
%% Load and prepare Analog Input  

AIConfig(vars);
load(vars);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %AI_tpbuffer0 and AI_tpbuffer1 are voidPtr type.
    %And they are useless after returning from calllib.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Set buffer 0
    AI_pbuffer0 = libpointer('uint32Ptr',AI_buffer0(1,:));
    [error,AI_tpbuffer0(1,1),AI_bufferID0(1,1)] = calllib(LIB,'DSA_AI_ContBufferSetup',card,AI_pbuffer0,AI_ReadCount,AI_bufferID0(1,1));
    if error < 0
        calllib(LIB,'DSA_Release_Card',card);
        unloadlibrary(LIB);
        fprintf('1st DSA_AI_ContBufferSetup failed with error code %d\n',error);
        return;
    end
    
    %Set buffer 1
    AI_pbuffer1= libpointer('uint32Ptr',AI_buffer1(1,:));
    [error,AI_tpbuffer1(1,1),AI_bufferID1(1,1)] = calllib(LIB,'DSA_AI_ContBufferSetup',card,AI_pbuffer1,AI_ReadCount,AI_bufferID1(1,1));
    if error < 0
        calllib(LIB,'DSA_AI_ContBufferReset',card);
        calllib(LIB,'DSA_Release_Card',card);
        unloadlibrary(LIB);
        fprintf('2nd DSA_AI_ContBufferSetup failed with error code %d\n',error);
        return;
    end
    
    %The 3rd and 6th parameters are ignored for 9527
    error = calllib(LIB,'DSA_AI_ContReadChannel',card,AI_Channel(1,1),0,AI_bufferID0(1,1),AI_ReadCount,0,SyncMode);
    if error < 0
        calllib(LIB,'DSA_AI_ContBufferReset',card);
        calllib(LIB,'DSA_Release_Card',card);
        unloadlibrary(LIB);
        fprintf('DSA_AI_ContReadChannel failed with error code %d\n',error);
        return;
    end
   


%% Load and prepare Analog Output


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
    
%% MAIN ROUTINE 
    tic;    % Set the Time
    margin = 2; % margin in seconds for the TimeOut
    TimeOut = double(AI_ReadCount)/SampleRate*2.5 + margin; % Acquisition time in seconds (plus margin)
    TimeLeft = TimeOut;
    fprintf('Start AI, press anykey on figure to stop\n');
    index = 0; 
    %Here is like kbhit() in C code , press anykey to exit loop
    figh = figure('keypressfcn',@(obj,ev) set(obj,'userdata',1));
    while isempty(get(figh,'userdata')) && TimeLeft>=0
        [error, AO_HalfReady] = calllib(LIB,'DSA_AO_AsyncDblBufferHalfReady',card,AO_HalfReady);
        if error < 0 
            calllib(LIB,'DSA_AO_AsyncClear',card,AO_AccessCnt,0);
            calllib(LIB,'DSA_AO_ContBufferReset',card);
            calllib(LIB,'DSA_Release_Card',card);
            unloadlibrary(LIB);
            fprintf('DSA_AO_AsyncDblBufferHalfReady failed with error code %d\n',error);
            return;
        end

        if AO_HalfReady == 1
            RdyCnt=RdyCnt+1;         
            if index==0
                index=1;
                fprintf('Buffer 0 AO_HalfReady , press anykey on figure to stop\n');
                Output = (double(AO_tpbuffer0.Value))/ampifier*10;
            else
                index=0;
                fprintf('Buffer 1 AO_HalfReady , press anykey on figure to stop\n');
                Output = (double(AO_tpbuffer1.Value))/ampifier*10;
            end 
            figure(2)
            plot(Output);
            if mod(RdyCnt,4)==1
                AO_tpbuffer0.Value = AO_buffer0;
            elseif mod(RdyCnt,4)==2
                AO_tpbuffer1.Value = AO_buffer0;
            elseif mod(RdyCnt,4)==3
                AO_tpbuffer0.Value = AO_buffer0;
            elseif mod(RdyCnt,4)==0
                AO_tpbuffer1.Value = AO_buffer0;
            end
        end
        
        
        TimeLeft = TimeOut - toc;
        [error, AI_HalfReady, AI_Stopped] = calllib(LIB,'DSA_AI_AsyncDblBufferHalfReady',card,AI_HalfReady,AI_Stopped);
        if error < 0
            calllib(LIB,'DSA_AI_AsyncClear',card,AI_AccessCnt);
            calllib(LIB,'DSA_AI_ContBufferReset',card);
            calllib(LIB,'DSA_Release_Card',card);
            unloadlibrary(LIB);
            fprintf('DSA_AI_AsyncDblBufferHalfReady failed with error code %d\n',error);
            return;
        end
        if AI_HalfReady == 1
            tic;
            TimeLeft = TimeOut;%reset TimeLeft for next buffer     
            
            if index==0
                index=1;
                AI_buffer0 = AI_pbuffer0.Value; 
                [error,AI_buffer0,volts]=calllib(LIB,'DSA_AI_ContVScale',card,AI_AdRange(1,1),AI_buffer0(1,:),volts(1,:),AI_ReadCount);
                fprintf('Buffer 0 AI_HalfReady , press anykey on figure to stop\n');
            else
                index=0;
                AI_buffer1 = AI_pbuffer1.Value;    
                [error,AI_buffer1,volts]=calllib(LIB,'DSA_AI_ContVScale',card,AI_AdRange(1,1),AI_buffer1(1,:),volts(1,:),AI_ReadCount);
                fprintf('Buffer 1 AI_HalfReady , press anykey on figure to stop\n');
            end      
            if error < 0 
                calllib(LIB,'DSA_AI_AsyncClear',card,AI_AccessCnt);
                calllib(LIB,'DSA_AI_ContBufferReset',card);
                calllib(LIB,'DSA_Release_Card',card);
                unloadlibrary(LIB);
                fprintf('DSA_AI_ContVScale failed with error code %d\n',error);
                return;
            end
            figure(1)
            ovolts=[ovolts volts];
            %plot(ovolts); 
        end
        

        
        if AI_Stopped == 1
            break;
        end
        pause(0.001);
    end
    ovolts(1)=[]; 
    fprintf('Stop AI\n');
    t = 0:(1/SampleRate):((length(ovolts)-1)/SampleRate);
    plot(t,ovolts); 
    
    if TimeLeft < 0
        calllib(LIB,'DSA_AI_AsyncClear',card,AI_AccessCnt);
        calllib(LIB,'DSA_AI_ContBufferReset',card);
        calllib(LIB,'DSA_Release_Card', card);
        calllib(LIB,'DSA_AO_AsyncClear',card,AO_AccessCnt,0);
        calllib(LIB,'DSA_AO_ContBufferReset',card);
        calllib(LIB,'DSA_Release_Card', card);
        unloadlibrary(LIB);
        fprintf('DSA_AI_AsyncDblBufferHalfReady time out, please check if all parameters are correct and reboot both PC and 9527\n');
        return;
    end
    
    calllib(LIB,'DSA_AI_AsyncClear',card,AI_AccessCnt);
    
    [error,AccessCnt] = calllib(LIB, 'DSA_AO_AsyncClear',card,AO_AccessCnt,0);
    if error < 0
        calllib(LIB,'DSA_AO_ContBufferReset',card);
        calllib(LIB,'DSA_Release_Card',card);
        unloadlibrary(LIB);
        fprintf('DSA_AO_AsyncClear failed with error code %d\n',error);
        return;
    end
    
    if ~AutoReset
        calllib(LIB,'DSA_AI_ContBufferReset',card);
        calllib(LIB,'DSA_AO_ContBufferReset',card);
    end
    %calllib(LIB,'DSA_Release_Card',card);
    %unloadlibrary(LIB);