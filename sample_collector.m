% sample_collector.m
% script for collecting audio samples

classifiers = ["left", "right", "forward", "backward", "180", "dance"];

asc = AudioSampleCollector(classifiers);

asc.startSampling();