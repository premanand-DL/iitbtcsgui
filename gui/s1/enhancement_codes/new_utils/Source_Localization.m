clc;
clear;
close all;

addpath(genpath('/media/nikhil/106E-2432/Final Codes'))
%% Paramters
SL_Method = 'HT'; 

% Localization parameters
Max_Delay = 20; %Maximum sample delays expected
Ref_Ch = 4; %Reference channel for TDOA estimation(delay=0)

%STFT parameters
wlen = 1024; % hop_size = wlen/2 (default)

%Read Data
[Data, Fs] = audioread(['Speaker1' filesep 'Spk1_MA_NO.wav']);
nsampl = size(Data,1);

% Perform STFT
X = stft_multi(Data.',wlen);
[nbin,nfram,nchan] = size(X);

% Estimate TDOAs
TDOA = Estimate_TDOA(X,SL_Method,Ref_Ch,Max_Delay); 
mode(TDOA)

