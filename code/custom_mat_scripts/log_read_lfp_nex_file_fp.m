%% log_Read_LFP_NEX_file
% This script reads in a NEX file that contains LFP data collected from the Deuteron logger system.
% It will output LFP data into a MATLAB structure.
% Created by [Your Name] on [Creation Date]

%% Initialize data
cd('F:\EnclosureProjects\inprep\freemat\ephys_tests')
filePath = uigetdir('', 'Please select the experiment directory');

%cd('F:\EnclosureProjects\inprep\freemat\ephys_tests\240424_mat2_spikesLFPs\hooke_1to7khz\nex5\spikedata')
outputPath = uigetdir('', 'Please select the output directory');
cd(filePath);
neural_dir = dir('*.nex*');

%% Process each file
for neural_file = 1:length(neural_dir)
    
    fileName = neural_dir(neural_file).name;
    disp(fileName)
    
    % Read in NEX file
    nex = readNexFile([filePath '/' fileName]);
    
    % Extract continuous data
    if isfield(nex, 'contvars') && ~isempty(nex.contvars)
        for j = 1:length(nex.contvars)
            contData = nex.contvars{j}.data;
            contName = nex.contvars{j}.name;
            LFPData.(['Channel_' contName]) = contData;
        end
    else
        error('No continuous data found in this .nex file.');
    end
    
    clearvars -except LFPData filePath neural_dir outputPath
    
end

%% Save variables
[~, basename, ~] = fileparts(outputPath);
save(fullfile(outputPath, ['LFP_data_' basename '.mat']), 'LFPData', '-v7.3');

% Optionally, you might want to add some checks or visualizations here to confirm the data looks as expected.
