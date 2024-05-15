%% Initialize the 

clear; clc;
filePath = uigetdir('', 'Please select the experiment directory');
cd(filePath);

%% Setup Parameters
Sampling_rate = 20000; % Hz, change this according to your setup
conversion_factor = 0.195; % Conversion factor from digital to microvolts

%% Prepare Nex5 File
nexFile = nexCreateFileData(Sampling_rate);

%% Process Each .dat File in the Directory
data_files = dir(fullfile(filePath, '*.dat'));
if length(data_files) ~= 32
    error('There should be exactly 32 amplifier files in the directory.');
end
%numberOfChannels = 32;
%numberofADCBits = ... ;
%voltageResolution = ...;
%fSample = 20e3;

% Read and process each file
for i = 1:length(data_files)
    fileName = fullfile(filePath, data_files(i).name);
    fileinfo = dir(fileName);
    num_samples = fileinfo.bytes/2;
    fid = fopen(fileName, 'r');
    v = fread(fid, num_samples, 'int16'); % Read the entire file as it represents one channel
    fclose(fid);
    
    % Convert to microvolts
    data = v*conversion_factor;
    %data = (metaData.voltageRes*(data - 2^(metaData.numADCBits - 1)))*conversion_factor; % conversion of data to neural data. *1e3 to convert to mV; Confirmed that conversion is correct from Deuteron data.
        
    %v_microvolts = v * conversion_factor;

    % Add channel data to the nexFile
    channel_label = sprintf('Chan_%d', i); % Label channels based on their file order
    nexFile = nexAddContinuous(nexFile, 1/Sampling_rate, Sampling_rate, data, channel_label);
end

%% Save the Nex5 File
outputPath = fullfile(filePath, 'Output_v.nex5');
writeNex5File(nexFile, outputPath);
disp(['Nex5 file saved as: ' outputPath]);
