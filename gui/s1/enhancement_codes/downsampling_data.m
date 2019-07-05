clear;clc;close all;

addpath('utils');

data = 'MVDR';
path = ['../audio/segmented/' data '/'];
fil = dir([path '*.wav']);
fs1 = 8000;

for i = 1 : length(fil)
    %disp(fil(i).name);
    [audio, fs] = audioread([path fil(i).name]);
    audio = resample(audio, fs1, fs);
    
    data_8 = [data '_8k'];
    path_8 = ['../audio/segmented/' data_8 '/' fil(i).name]
    Write_File( audio, fs1, path_8 );
end