%% make .dat file from axona for kilosort

InPath = 'H:\ALZ\RAW\M30'
RecID = 'M33-2502'; %textfile listing bin files for conversion
DatPath = 'H:\ALZ\PROCESSED\KS_Mat'; %path for storing .dat files
sess=[12:17]; %numbers of separate .bin files from recording day
skippedsamps = [0,0,2,1,2,1]; %samples lost in resampling/merging for sleepscores

%%
Chunk = 10; %chunk length in minutes
fs = 24000; %sampling rate
ChunkLen = Chunk*60*fs; %chunklength in samples

%% convert axona bin files to single channel bin files

% read individual binfiles
skip = 0; 
for s = sess
    disp([RecID,' session ',num2str(s,'%02.f')])
      
    
    %get session length
    binID = fopen([InPath,'\',RecID,'\',RecID,'_',num2str(s,'%02.f'),'\',RecID,'_',num2str(s,'%02.f'),'_ch13','.bin']);
    Sig = fread(binID,'int16'); Sig = int16(Sig); %read signal, convert to int16 (bc double is huge and int16 is original format)
    fclose(binID);
    
    siglen = length(Sig);
    NumChunks = floor(siglen/ChunkLen);
    clear Sig;
    
    %write data to DAT in chunks
    for i = 1:NumChunks
        disp(['chunk ',num2str(i),' of ',num2str(NumChunks+1)])
        
        AllChunks=zeros(64,ChunkLen);AllChunks=int16(AllChunks);
        for ch = 1:64
            % get signal chunk
            binID = fopen([InPath,'\',RecID,'\',RecID,'_',num2str(s,'%02.f'),'\',RecID,'_',num2str(s,'%02.f'),'_ch',num2str(ch),'.bin']); %open single channel bin file
            Sig = fread(binID,'int16'); Sig = int16(Sig); %read signal, convert to int16 (bc double is huge and int16 is original format)
            fclose(binID);
            
            SampChunk = Sig((i*ChunkLen)+1-ChunkLen:i*ChunkLen);
            AllChunks(ch,:)=SampChunk';
            clear Sig
        end
        
        
        %write chunk to .dat file
        if s==min(sess) && i==1 %make file for first chunk of first session
            DATid = fopen([DatPath,'\',RecID,'.dat'], 'w');
            fwrite(DATid, AllChunks, 'int16');
            fclose(DATid);
        else %append to file for next chunks
            DATid = fopen([DatPath,'\',RecID,'.dat'], 'a');
            fwrite(DATid, AllChunks, 'int16');
            fclose(DATid);
        end
        clear AllChunks SampChunk
    end
    
    skip = skip+1; %counter for skipped samples list (samps were lost in downsampling to 6kHz)
    skipped = skippedsamps(skip);
    % write remaining data from bin to .dat
    disp(['chunk ',num2str(NumChunks+1),' of ',num2str(NumChunks+1)])
    
    if  siglen > (NumChunks*ChunkLen)
        RecLeft = siglen-(NumChunks*ChunkLen)-skipped;
        LastChunks = zeros(64,RecLeft); LastChunks = int16(LastChunks);
        for ch = 1:64
            binID = fopen([InPath,'\',RecID,'\',RecID,'_',num2str(s,'%02.f'),'\',RecID,'_',num2str(s,'%02.f'),'_ch',num2str(ch),'.bin']); %open single channel bin file
            Sig = fread(binID,'int16'); Sig = int16(Sig); %read signal, convert to int16 (bc double is huge and int16 is original format)
            fclose(binID);
            SampChunk = Sig((NumChunks*ChunkLen)+1:end-skipped);
            LastChunks(ch,:)=SampChunk';
        end
        
        DATid = fopen([DatPath,'\',RecID,'.dat'], 'a');
        fwrite(DATid, LastChunks, 'int16');
        fclose(DATid);
        
        clear LastChunk LastChunks Sig
    end
end