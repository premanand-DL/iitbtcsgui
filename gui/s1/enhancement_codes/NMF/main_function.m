clear all;clc;close all;


%% STFT and reverb parameters
parm.analysis = 1024; %window length (1024 corresonds to 64ms when fs = 16000 samples/s)
parm.hop = parm.analysis/4; %hop size
parm.win = sqrt(hamming(parm.analysis)); % window type
parm.Nframe = 20; % number of frames allocated for RIR
parm.Hlate = 2; % number of frames to be considered as early part of RIR

%% things to be changed
clean = wavread('sa1.wav');
ch = 8;
[rir fs] = wavread('RIR_SimRoom3_near_AnglA.wav');


%% RIR parameters
rir = rir(:,ch);
l = find(rir == max(rir));


%% Simulate Reverb Speech
reverb = conv(clean,rir);
reverb = reverb(l:end);
reverb = reverb - mean(reverb); reverb = norm_wav(reverb,16);


%% Results

%CNMF
sparsity = 1;
[CNMF H_NCTF] = dereverb_kl_divergence_new(reverb,sparsity,parm);

%CNMF with Sparsity on RIR
sparsity = 2;
[NCTF_Hspr H_spr] = dereverb_kl_divergence_new(reverb,sparsity,parm);

%CNMF with frequency envelope on RIR
sparsity = 1;
[NCTF_Henv H_env] = DereverbKLdivFrequencyEnvelope(reverb,sparsity,rir,parm);

%CNMF with retaining early part of RIR
sparsity = 1;
[CNMF_Hearly H_CNMF_early] = DereverbNMF_Hlate(reverb,sparsity,parm);

% CNMF+NMF and CNMF+NMF with retaining early part of RIR
sparsity = 1;
[CNMF_NMF CNMF_NMF_Hearly H_speech] = DereverbNMFSpeech_Hlate(reverb,sparsity,parm);

% CNMF+NMF with sparsity on RIR
sparsity = 2;
[CNMF_NMF_Hspr CNMF_NMF_Hspr_Hearly H_speechSpr] = DereverbNMFSpeech_Hlate(reverb,sparsity,parm);

% CNMF+NMF with frequency Envelope
sparsity = 1;
[CNMF_NMF_Henv H_NMF_env] = DereverbKLdivSpeechModelFrequencyEnvelope(reverb,1,rir,parm);

%% Plotting RIR estimates
k = 190; % frequency band
% Obtaining STFT of RIR for a particular freqency band
RIR = abs(stft(rir, parm.analysis, parm.hop, 0, parm.win));
l1 = sum(RIR);
l2 = find(l1==max(l1));
RIR = RIR(:,l2:l2 + parm.Nframe - 1);

%% plots for methods without speech model
set(0, 'DefaultAxesFontSize', 14);
fig=figure,ax=axes;box on;
plot(RIR(k,:)/sum(RIR(k,:)),'k', 'linewidth', 3),hold on
plot(H_NCTF(k,:)/sum(H_NCTF(k,:)),'b-','linewidth', 1),
plot(H_spr(k,:)/sum(H_spr(k,:)),'gx-.','linewidth', 1,'Markersize', 10)
plot(H_env(k,:)/sum(H_env(k,:)),'ro-.','linewidth', 1, 'Markersize', 10),
legend('RIR H_k','N-CTF','N-CTF + H_{sparse}','N-CTF + H_{gain}')
title(sprintf('RIR for k = %d',k))
xlabel('Frame number', 'FontWeight','demi')
ylabel('Magnitude of H ({|H_k|})','FontWeight','demi')
set(ax, 'FontWeight','demi')
axis tight

%% plots for methods with speech model
fig2=figure,ax=axes;box on;
plot(RIR(k,:)/sum(RIR(k,:)),'k', 'linewidth', 3),hold on
plot(H_NCTF(k,:)/sum(H_NCTF(k,:)),'b-','linewidth', 1),
plot(H_speech(k,:)/sum(H_speech(k,:)),'rx-','linewidth', 2, 'Markersize', 8),
plot(H_NMF_env(k,:)/sum(H_NMF_env(k,:)),'co-','linewidth', 2, 'Markersize', 8),
plot(H_speechSpr(k,:)/sum(H_speechSpr(k,:)),'go-','linewidth', 2, 'Markersize', 8),hold off
legend('RIR H_k','N-CTF','N-CTF+NMF','N-CTF+NMF+H_{gain}','N-CTF+NMF+H_{sparse}')
title(sprintf('RIR for k = %d',k))
xlabel('Frame number', 'FontWeight','demi')
ylabel('Magnitude of H ({|H_k|})','FontWeight','demi')
set(ax, 'FontWeight','demi')
axis tight