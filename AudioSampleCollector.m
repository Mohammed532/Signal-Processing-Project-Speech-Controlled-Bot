classdef AudioSampleCollector
    %AUDIOSAMPLECOLLECTOR Collects audio samples and stores MFCC features
    % and labels
    %
    %
    %   REQUIREMENTS
    %       - Signal Processing Toolbox
    %       - DSP System Toolbox
    %       - Audio Toolbox

    %   TROUBLESHOOTING
    %       - Internal Audio Device Error (M1 Mac): this is a macos
    %       permission issue. Give microphone access in mac settings to
    %       matlab. If matlab isn't visible as an option, close matlab and
    %       run the program in the terminal (run
    %       /Applications/{matlab_version}.app/bin/matlab), run the script,
    %       and click "Accept" to give permission
    
    properties
        % METADATA
        classifiers
        features = [];
        labels = string([]);

        % AUDIO SETUP
        fs = 16000; % sample rate
        bps = 16; % bits per samples
        recorder
    end
    
    methods
        function obj = AudioSampleCollector(classifiers)
            %AUDIOSAMPLECOLLECTOR Constructor
            %   Loads features and labels from existing .mat file
            obj.classifiers = classifiers;
            obj.recorder = audiorecorder(obj.fs, obj.bps, 1);
            if(exist("data/mfcc_features_and_labels.mat", "file") == 2)
                load('data/mfcc_features_and_labels.mat', 'features', 'labels');
                obj.features = features;
                obj.labels = labels;
            end
        end
        
        function startSampling(obj)
            %STARTSAMPLING Collects audio samples for classifiers
            %   IMPORTANT: MUST QUIT PROPERLY FOR DATA TO SAVE CORRECTLY
            disp("Starting audio sampling for following classifiers: ");
            disp(obj.classifiers);
            % recording loop
            quit = false;
            while ~quit
                while true
                    sample_classifier = input("Choose a classifier to record for: ", "s");
                    if is_element(obj.classifiers, sample_classifier)
                        break
                    else
                        disp("Invalid classifier, try again");

                    end
                end
                
%                  disp("Press enter to record a sample, 's' to choose a new classifier, or 'q' to quit recording")
                while true
                    cmd = input("Press enter to record a sample, 's' to choose a new classifier, or 'q' to quit recording: ", "s");
                    switch cmd
                        case ""
                            % record audio
                            disp("Recording...")
                            recordblocking(obj.recorder, 2); % record for two seconds
                            audio_data = getaudiodata(obj.recorder);

                            disp("Playback...");
                            play(obj.recorder);

                            disp("Processing...")
                            % pass through highpass filter (100Hz)
                            % (noise-reduction)
                            hpIIRFilt = designfilt('highpassiir', ...
                                                    'FilterOrder', 8, ...
                                                    'HalfPowerFrequency', 100, ... % cutoff freq (100Hz)
                                                    'SampleRate', obj.fs);
                            filt_audio = filtfilt(hpIIRFilt, audio_data);
                            
                            

                            % normalize data
                            normalized_audio = filt_audio / max(abs(filt_audio));

                            % extract mfcc spectrum
                            % the coeffs returned is a Nx13 matrix, with
                            % N being the frames per audio sample. For
                            % classification training, we'll average the
                            % coeffs across frames to get a 1x13 vector.
                            % LogEnergy is ignored (pertains to audio
                            % volume)
                            coeffs = mfcc(normalized_audio, obj.fs, 'NumCoeffs', 13, "LogEnergy","ignore");
                            sample_feature = mean(coeffs, 1);
                            
                           
                            % store label and feature
                            obj.features = [obj.features; sample_feature];
                            obj.labels(end+1) = sample_classifier;

                        case "s"
                            obj.save();
                            break

                        case "q"
                            disp("Saving Data and Quitting...");
                            quit = true;
                            obj.save();
                            break

                        otherwise
                            disp("Invalid command");
                    end
                end
            end
            
        end

        function save(obj)
            % get path to data folder in project
            proj = currentProject;
            save_path = fullfile(proj.RootFolder, "data", "mfcc_features_and_labels.mat");

            features = obj.features;
            labels = obj.labels;
            save(save_path, 'features', 'labels');
            disp("Features and Labels saved in 'data/mfcc_features_and_labels.mat'")
        end
    end
end

