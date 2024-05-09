%filePath = 'C:\Users\GENERAL\Desktop\Felipe\hedy_long\Chan_10_spec.nex5';
filePath = 'F:\EnclosureProjects\inprep\freemat\ephys_tests\240506_mat7_spikesLFPs_desk\logger003\nex5\Chan_1-32_dat_v2.nex5'
nexFile = readNexFile(filePath);
% Check if the file contains continuous data and extract the first continuous variable
if isfield(nexFile, 'contvars') && ~isempty(nexFile.contvars)
    lfpData = nexFile.contvars{10}.data; % each index is a channel
    lfpSamplingRate = nexFile.contvars{1}.ADFrequency; % Sampling rate of LFP data
    %disp(lfpSamplingRate)
else
    error('No continuous data found in this .nex file.');
end

% Parameters for the spectrogram
window = round(lfpSamplingRate * 1); % 1-second window
disp(window) % 32000
noverlap = round(window * 0.5); % 50% overlap
disp(noverlap)
nfft = 2^nextpow2(window); % Number of FFT points
disp(nfft) % 32768

% Calculate the spectrogram
[S, F, T, P] = spectrogram(lfpData, window, noverlap, nfft, lfpSamplingRate);

% Calculate dB scale power for plotting
P_db = 10*log10(abs(P) + eps);

% Index for frequencies up to 300 Hz
freqIndex300 = F <= 300; 

% Extract power values for frequencies <= 300 Hz
P_db_300 = P_db(freqIndex300, :);  % Adjust the indices accordingly

% Calculate percentiles for caxis using only the relevant frequency range
perc5 = prctile(P_db_300(:), 5);
perc95 = prctile(P_db_300(:), 95);

% Plot the spectrogram for frequencies up to 300 Hz
figure;
surf(T, F(freqIndex300), P_db(freqIndex300, :), 'EdgeColor', 'none');
axis xy; axis tight; colormap(parula); view(0, 90);
xlabel('Time (Seconds)');
ylabel('Frequency (Hz)');
title('Filtered Spectrogram of LFP Data up to 300 Hz');
colorbar;
caxis([perc5, perc95]);  % Adjusts to cover 90% of data distribution

% Power Spectral Density for up to 300 Hz
%[Pxx, F] = pwelch(lfpData, window, noverlap, nfft, lfpSamplingRate);
%figure;
%plot(F(freqIndex300), 10*log10(Pxx(freqIndex300)));
%xlabel('Frequency (Hz)');
%ylabel('Power/Frequency (dB/Hz)');
%title('Power Spectral Density of LFP Data up to 300 Hz');
%ylim([-75 -25]);
%grid on;
