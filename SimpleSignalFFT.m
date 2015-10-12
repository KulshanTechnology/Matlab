% Matlab Signal Analyzing Examples

% generate the test signal
Fs = 16000;
Ts = 1/Fs;
f = 2000;
ph = 0;
% sampling interval in seconds
t = 0.050;

% setup evenly spaced samples over the sampling period
numsamples = t/Ts;
n = linspace(0,numsamples, numsamples);
x = sin(2*pi*(f/Fs).*n + ph);
% This script is available at https://dadorran.wordpress.com search for
% filtering matlab demo
plot(x)

title('Noisy signal')
xlabel('Samples');
ylabel('Amplitude')
 
% plot magnitude spectrum of the signal
X_mags = abs(fft(x));
figure(10)
plot(X_mags)
xlabel('DFT Bins')
ylabel('Magnitude')
 
% plot first half of DFT (normalised frequency)
num_bins = length(X_mags);
plot([0:1/(num_bins/2 -1):1], X_mags(1:num_bins/2))
xlabel('Normalised frequency (\pi rads/sample)')
ylabel('Magnitude')

% plot the spectrogram of the waveform
% Frame the signal into short frames.
% 25 msec frames * 16 kHz sample frequency = 400 samples per frame
% frame step of 10 msec = 160 samples
% For each frame calculate the periodogram estimate of the power spectrum.
% the periodogram is the power spectral estimate, which is the 
% magnitude of the FFT squared using a hamming window
window = 400;
nooverlap = 160;
% number of frequency bins
FFTL = 512;
[S,F,T,P] = spectrogram(x,window,nooverlap,FFTL,Fs);
surf(T,F,10*log10(P),'edgecolor','none');
axis tight; view(0,90);
xlabel('Time (seconds)');
ylabel('Hz');

% convert signal to int16 for transfer to ST32 project
xint = x*2^15;
xint = int16(xint);

% write to text file for easy copying to C project
% this function writes numeric data to ASCII Fie with , delimiter
dlmwrite('sampleaudio.txt',xint);

