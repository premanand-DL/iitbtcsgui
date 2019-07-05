clear; clc;close all;

fpitch = 'fpitch.mat';
fvad = 'fvad';
fout = 'fout.wav';
thre = 0.1;


fil = 'CloseTalking.wav';
%'Reverb_700ms_2m+10dB_stationary_noise.wav';

system('rm fpitch.mat');

vad_seg = vad(fil, 'fpitch.mat', 'fvad', thre, 'fout.wav');

vad_seg

[data, fs] = audioread(fil);
flen=fs/40;
fsh10=fs/100;
nfr10=floor((length(data)-(flen-fsh10))/fsh10);

vad_decision = zeros(length(data),1);
for i = 1 : size(vad_seg, 1)
    vad_decision(vad_seg(i,1) * fsh10 + 1 : vad_seg(i,2) * fsh10 + flen) = 1;
end

plot(0.75*data/max(data)), hold on, plot(vad_decision), hold off