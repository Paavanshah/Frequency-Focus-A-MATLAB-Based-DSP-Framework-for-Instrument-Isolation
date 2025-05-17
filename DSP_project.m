% Step 1: Load the Audio File
[audioData, Fs] = audioread('song5.mp3');

% Play the original audio
sound(audioData, Fs);
pause(length(audioData)/Fs + 1);  % Wait until playback finishes

% Display basic info    
disp(['Sample Rate: ', num2str(Fs), ' Hz']);
disp(['Number of Samples: ', num2str(length(audioData))]);

% Step 2: Analyze Frequency Content (FFT)
N = length(audioData);
f = (-N/2:N/2-1)*(Fs/N);  % Frequency axis
Y = fft(audioData);
Y = fftshift(Y);          % Shift zero frequency to the center

% Plot Frequency Spectrum
figure;
plot(f, abs(Y));
title('Frequency Spectrum of Original Audio');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
grid on;

% Step 3: Apply Band-Pass Filter to Isolate 585.544 Hz
f0 = 585.544;       % Center frequency to keep
bw = 100;           % Bandwidth (e.g., ±50 Hz) - Adjust as needed

% Design Band-Pass Filter
d = designfilt('bandpassiir', ...
               'FilterOrder', 4, ...
               'HalfPowerFrequency1', (f0 - bw/2)/(Fs/2), ...
               'HalfPowerFrequency2', (f0 + bw/2)/(Fs/2), ...
               'DesignMethod', 'butter');

% Apply the Band-Pass Filter
filteredAudio = filtfilt(d, audioData);

% Plot Filtered Audio Signal
figure;
plot(filteredAudio);
title('Filtered Audio Signal (After Band-Pass Filter)');
xlabel('Sample Number');
ylabel('Amplitude');
grid on;

% Step 4: Apply Moving Average Filter (MAF) for Low-Frequency Noise
windowSize = 500;  % Window size for the moving average (adjust as needed)

% Convert to mono if the audio is stereo
if size(filteredAudio, 2) == 2
    filteredAudio = mean(filteredAudio, 2);  % Convert to mono
end

% Apply Moving Average Filter
mafAudio = conv(filteredAudio, ones(windowSize, 1)/windowSize, 'same');

% Step 5: Amplitude Adjustment (Gain)
gainFactor = 60;  % Amplify by 5 times

% Apply gain to the filtered audio
amplifiedAudio = gainFactor * mafAudio;

% Ensure values are within the range [-1, 1] to avoid clipping
amplifiedAudio = max(min(amplifiedAudio, 1), -1);

% Play the amplified audio
sound(amplifiedAudio, Fs);
pause(length(amplifiedAudio)/Fs + 1);

% Step 6: Save Processed Audio
audiowrite('filtered_audio_bandpass.wav', filteredAudio, Fs);
audiowrite('amplified_audio_bandpass.wav', amplifiedAudio, Fs);

% Step 7: Compare Original, Filtered, and Amplified Audio
figure;

% Waveform Comparison
subplot(3,1,1);
plot(audioData);
title('Original Audio Signal');
xlabel('Sample Number');
ylabel('Amplitude');

subplot(3,1,2);
plot(filteredAudio);
title('Filtered Audio Signal (After Band-Pass Filter)');
xlabel('Sample Number');
ylabel('Amplitude');

subplot(3,1,3);
plot(amplifiedAudio);
title('Amplified Audio Signal (After MAF and Gain)');
xlabel('Sample Number');
ylabel('Amplitude');

% Step 8: Spectrograms for Comparison
% Check if the audio is stereo and convert to mono if needed
if size(audioData, 2) == 2
    audioData = mean(audioData, 2);  % Convert to mono
end

% Spectrogram for comparison
figure;
subplot(3,1,1);
spectrogram(audioData, 256, 250, 256, Fs, 'yaxis');
title('Spectrogram of Original Audio');

subplot(3,1,2);
spectrogram(filteredAudio, 256, 250, 256, Fs, 'yaxis');
title('Spectrogram of Filtered Audio (Band-Pass)');

subplot(3,1,3);
spectrogram(amplifiedAudio, 256, 250, 256, Fs, 'yaxis');
title('Spectrogram of Amplified Audio');

% Step 9: Frequency Spectrum of Amplified Audio
N_amp = length(amplifiedAudio);
f_amp = (-N_amp/2:N_amp/2-1)*(Fs/N_amp);  % Frequency axis for amplified audio
Y_amp = fft(amplifiedAudio);
Y_amp = fftshift(Y_amp);                  % Shift zero frequency to the center

% Plot Frequency Spectrum of Amplified Audio
figure;
plot(f_amp, abs(Y_amp));
title('Frequency Spectrum of Amplified Audio (Band-Pass Applied)');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
grid on;