% Load the nexFile. this will work with either nex or nex5 format%%
%filePath1 = 'F:\EnclosureProjects\inprep\freemat\ephys_tests\240430_mat5_LFPs_dark\hedy\nex5\Chan_1-30 _hedy_v2.nex5'
%filePath2 = 'F:\EnclosureProjects\inprep\freemat\ephys_tests\240430_mat5_LFPs_dark\hedy\nex5\Chan_31-60 _hedy_v2.nex5'
%filePath3 = 'F:\EnclosureProjects\inprep\freemat\ephys_tests\240430_mat5_LFPs_dark\hedy\nex5\Chan_61-90 _hedy_v2.nex5'
%filePath4 = 'F:\EnclosureProjects\inprep\freemat\ephys_tests\240430_mat5_LFPs_dark\hedy\nex5\Chan_91-128 _hedy_v2.nex5'

% List of nex5 files
filePaths = {
    'F:\EnclosureProjects\inprep\freemat\ephys_tests\240506_mat7_spikesLFPs_desk\logger003\nex5\Chan_1-32_dat_v2.nex5',
    'F:\EnclosureProjects\inprep\freemat\ephys_tests\240506_mat7_spikesLFPs_desk\logger003\nex5\Chan_33-64_dat_v2.nex5',
    'F:\EnclosureProjects\inprep\freemat\ephys_tests\240506_mat7_spikesLFPs_desk\logger003\nex5\Chan_65-96_dat_v2.nex5',
    'F:\EnclosureProjects\inprep\freemat\ephys_tests\240506_mat7_spikesLFPs_desk\logger003\nex5\Chan_97-128_dat_v2.nex5'
};

% Loop over each file
for f = 1:length(filePaths)
    filePath = filePaths{f};
    disp(filePath)
    % Extract parts of the filePath
    [path, name, ~] = fileparts(filePath);
    nexFile = readNexFile(filePath);

    % Check if the file contains continuous data
    if isfield(nexFile, 'contvars') && ~isempty(nexFile.contvars)
        numChannels = length(nexFile.contvars);

        for i = 1:numChannels
            lfpData = nexFile.contvars{i}.data;
            lfpSamplingRate = nexFile.contvars{i}.ADFrequency;

            % Parameters for the spectrogram
            window = round(lfpSamplingRate * 1); % 1-second window
            noverlap = round(window * 0.5); % 50% overlap
            nfft = 2^nextpow2(window);

            % Calculate the spectrogram
            [S, F, T, P] = spectrogram(lfpData, window, noverlap, nfft, lfpSamplingRate);
            P_db = 10*log10(abs(P) + eps);

            % Frequency index up to 300 Hz
            freqIndex300 = F <= 300; 

            % Extract power values for frequencies <= 300 Hz
            P_db_300 = P_db(freqIndex300, :);

            % Create a figure for each channel without displaying it
            figure('Position', [100, 100, 1600, 900], 'Visible', 'off');

            % Plot the spectrogram
            subplot(1, 2, 1);
            surf(T, F(freqIndex300), P_db(freqIndex300, :), 'EdgeColor', 'none');
            axis tight; colormap(parula); view(0, 90);
            title(sprintf('Spectrogram - Channel %d of %s', i, name));
            xlabel('Time (s)');
            ylabel('Frequency (Hz)');
            caxis([prctile(P_db_300(:), 5), prctile(P_db_300(:), 95)]);
            colorbar;

            % Plot the Power Spectral Density
            [Pxx, F_psd] = pwelch(lfpData, window, noverlap, nfft, lfpSamplingRate);
            subplot(1, 2, 2);
            freqIndex_psd300 = F_psd <= 300; % Correct frequency index up to 300 Hz for PSD
            plot(F_psd(freqIndex_psd300), 10*log10(Pxx(freqIndex_psd300)));
            xlim([0 300]);
            title(sprintf('PSD - Channel %d of %s', i, name));
            xlabel('Frequency (Hz)');
            ylabel('Power/Frequency (dB/Hz)');

            % Set the output file path
            outputPath = fullfile(path, sprintf('%s_Channel_%d.png', name, i));

            % Save the figure
            saveas(gcf, outputPath);
            close(gcf);  % Close the figure after saving
        end
    else
        error('No continuous data found in this .nex file.');
    end
end
