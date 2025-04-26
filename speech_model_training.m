% svm_model_training.m
% script for training and exporting svm model for audio classification

% get path to data folder in project and load sample data
proj = currentProject;
data_path = fullfile(proj.RootFolder, "data", "mfcc_features_and_labels.mat");
load(data_path, 'features', 'labels');

% convert label strings to categorical
labels = categorical(labels);

% kNN classifier

% Ensemble classifier
disp("Training Ensemble Model...");
t = templateTree('MaxNumSplits', 60); % control tree depth
speech_model = fitcensemble(features, labels, ...
                                "Method",'Bag', ...
                                'NumLearningCycles', 200, ...
                                'Learners', t);

% Validate model and test performance
cross = crossval(speech_model);
model_loss = kfoldLoss(cross);
model_accuracy = (1 - model_loss) * 100;
fprintf("Ensemble Model Accuracy: %.4f%%\n", model_accuracy);

predicted_labels = kfoldPredict(en_cross);
confusionchart(labels, predicted_labels);

% Export model
disp("Saving model...")
model_path = fullfile(proj.RootFolder, "data", "speech_model.mat");
save(model_path, 'speech_model');