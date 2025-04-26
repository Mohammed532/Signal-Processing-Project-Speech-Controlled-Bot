% speech_recog.m
% main speech classification script

% setup audio recording object
fs = 16000; % Sample rate
r_dur = 2; % record duration (2 s)
recorder = audiorecorder(fs, 16, 1);

% speech model saved in data/speech_model.mat, generated from
% speech_model_training.m script
load("data/speech_model.mat", "speech_model");


disp('Ready to receive audio!');

while true
    cmd = input("Press enter to record command, or q to quit: ","s");
    switch cmd
        case ""
             disp("Recording...")

             % to ensure that recording is as similar to the audio sample
             % collection used to train the model, code below is copied
             % directly from AudioSampleCollector class
             recordblocking(recorder, r_dur); % record for two seconds
             audio_data = getaudiodata(recorder);

             disp("Processing...")
             % pass through highpass filter (100Hz)
             % (noise-reduction)
             hpIIRFilt = designfilt('highpassiir', ...
                                    'FilterOrder', 8, ...
                                    'HalfPowerFrequency', 100, ... % cutoff freq (100Hz)
                                    'SampleRate', fs);
             filt_audio = filtfilt(hpIIRFilt, audio_data);
            
            

             % normalize data
             normalized_audio = filt_audio / max(abs(filt_audio));

             % extract mfcc spectrum
             coeffs = mfcc(normalized_audio, fs, 'NumCoeffs', 13, "LogEnergy","ignore");
             mfcc_avg = mean(coeffs, 1);

             prediction = predict(speech_model, mfcc_avg);

             fprintf("Got It! Prediction: %s\n", prediction);
             disp("Sending command to bot...");

             % Communication code

        case "q"
            disp("Quiting...")
            break

        otherwise
            disp("Invalid Command. Try again")
    end
end
