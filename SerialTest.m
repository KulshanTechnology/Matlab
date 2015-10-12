% simple test script for communicating over a Serial Port

% Create the serial object, ST board enumarates as COM14 on my PC

s = serial('COM12');
set(s,'BaudRate',115200);
fopen(s);

% notify the user we have opened the COM port
disp('Com Port opened')
% display any data that is stored in the buffer
if s.BytesAvailable>1
    disp(fscanf(s));
end

Loop = true;
ch = '';
% get an input from the console
% for test ST project 2 toggles orange and 3 toggles red
% enter q to exit the loop

while(Loop)
    ch = input('Input a command >> ', 's');
    % if the user presses 'q' we exit
    if ch == 'q'
        Loop = false;
        break
    end
    % send the command
    fprintf(s, ch);
    % if ch == 5, we are going to receive an audio sample
    if ch == '5'
        numsamples = 800;
        audio = zeros(1,numsamples,'int16');
        jLoop = 1;
        desired16BitValue = 0;

        % wait for the micro to start sending the audio sample
        while (s.BytesAvailable == 0)
            disp('waiting for response')
        end 

        disp('gathering audio data')
        while jLoop<numsamples % Change the loop logic as required
            
            % wait for the next sample
            while (s.BytesAvailable < 2)
            end
            disp('sample received')
            disp(jLoop)
            
            singleByte(1) = fread(s,1,'uint8'); %Typecasting to 'uint8'
            singleByte(2) = fread(s,1,'uint8');

            desired16BitValue = (bitshift(int16(singleByte(1)),8) + int16(singleByte(2))); %Assuming singleByte(1) to be MSB

            audio(jLoop) = desired16BitValue;
            
            jLoop = jLoop+1;
        end
    elseif strcmp(ch,'fft')
        % if we have an audio sample, run frequency analyses on it
        if(~isempty(audio))
            % convert array to double
            audiosignal = double(audio);
            audiosignal = audiosignal/2^15;

            figure()

            % plot magnitude spectrum of the signal
            Audio_mags = abs(fft(audiosignal));
            figure(10)
            plot(Audio_mags)
            xlabel('DFT Bins')
            ylabel('Magnitude')

            figure()

            % plot first half of DFT (normalised frequency)
            num_bins = length(Audio_mags);
            plot([0:1/(num_bins/2 -1):1], Audio_mags(1:num_bins/2))
            xlabel('Normalised frequency (\pi rads/sample)')
            ylabel('Magnitude')

            figure()

            % plot the spectrogram of the waveform
            % Frame the signal into short frames.
            % 25 msec frames * 16 kHz sample frequency = 400 samples per frame
            % frame step of 10 msec = 160 samples
            % For each frame calculate the periodogram estimate of the power spectrum.
            % the periodogram is the power spectral estimate, which is the 
            % magnitude of the FFT squared using a hamming window
            Fs = 16000;
            window = 400;
            nooverlap = 160;
            % number of frequency bins
            FFTL = 512;
            [S,F,T,P] = spectrogram(audiosignal,window,nooverlap,FFTL,Fs);
            surf(T,F,10*log10(P),'edgecolor','none');
            axis tight; view(0,90);
            xlabel('Time (seconds)');
            ylabel('Hz');        
        end
    else
        % wait for data to be available
        disp(s.BytesAvailable)
        while (s.BytesAvailable == 0)
            disp('waiting for response')
        end 
        % display the response
        disp(fscanf(s));
    end
        
end

% close out the COM port and clear the object
% this must be here! otherwise the script will stay connected
% to the com port after it ends
fclose(s);
delete(s);
clear s

disp('Done')
