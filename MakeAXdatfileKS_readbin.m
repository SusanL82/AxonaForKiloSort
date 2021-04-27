%% make .dat file from axona for kilosort - part 1 (convert bin file)

AXconvert_InList = 'H:\ALZ\PROCESSED\ConvertList_30b.txt'; %textfile listing bin files for conversion
channels =[1:4];%[1:64]; %select all channels

%% convert axona bin files to single channel bin files

% read filenames and paths for raw axona bin files
fid = fopen(AXconvert_InList);
InList = textscan(fid,'%s%s');
fclose(fid);

%make filenames array
for n = 1: numel(InList{1})
    filenames{n} = [InList{1}{n},'\',InList{2}{n}];
    filenames = filenames';
end

convert_raw_bin(filenames,channels,0);
