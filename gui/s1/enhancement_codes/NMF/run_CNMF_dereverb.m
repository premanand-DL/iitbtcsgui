clear all;clc;close all;


loc = argv(){1}; 
[deg, fs] = audioread(loc);

out = argv(){2};
out_CNMF = [out '/recording1.wav'];

out1 = argv(){3};
out_CNMF_NMF = [out1 '/recording1.wav'];

disp(out)
disp(out_CNMF)
%% STFT and reverb parameters
parm.analysis = 2048; %window length (1024 corresonds to 64ms when fs = 16000 samples/s)
parm.hop = parm.analysis/4; %hop size
parm.win = sqrt(hamming(parm.analysis)); % window type
parm.Nframe = 40; % number of frames allocated for RIR
parm.Hlate = 2; % number of frames to be considered as early part of RIR


%% Results
%CNMF
sparsity = 1;
[CNMF H_NCTF] = dereverb_kl_divergence_new(deg,sparsity,parm);

disp('CNMF enhanced data is stored at the following location')
disp(out_CNMF);
Write_File(CNMF, fs, out_CNMF);

% CNMF+NMF and CNMF+NMF with retaining early part of RIR
sparsity = 1;
[CNMF_NMF, CNMF_NMF_Hearly, H_speech] = DereverbNMFSpeech_Hlate(deg, sparsity, parm);

disp('CNMF+NMF enhanced data is stored at the following location')
disp(out_CNMF_NMF);
Write_File(CNMF_NMF, fs, out_CNMF_NMF);
