% sample_collector.m
% collects audio samples

classifiers = ["left", "right", "forward", "backward", "180", "dance"];

asc = AudioSampleCollector(classifiers);

asc.startSampling();