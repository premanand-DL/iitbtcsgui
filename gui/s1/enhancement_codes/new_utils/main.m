clc;
clear;
close all;

addpath(['.' filesep 'Utils']);
addpath(['.' filesep 'Speaker1']);

%% Paramters
SL_Method = 'GCC'; %source localisation parameters
BF_Method = 'GDSB';%beamforming parameters

% Localization parameters
Max_Delay = 20; %Maximum sample delays expected
Ref_Ch = 1; %Reference channel for TDOA estimation(delay=0)

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


%% Perform Beanforming
Y1 = Beamform(X,BF_Method,TDOA,Fs);

%% Alternate Usages :

% (1) For BF_Method = 'MVDR' and 'GMVDR' , noise covariance matrix estimate 
%(Ncov - No_Ch x No_Ch x No_Bins)for each bin needs to be passed on as an
% additional argument
% Example : 1
% In the demo given below, noise covariance matrix is estimated from
% initial 'IS' silence frames
% IS = 10;
% Ncov=zeros(nchan,nchan,nbin);
% for j=1:nbin,
%     for i=1:IS,
%         Ntf=permute(X(j,i,:),[3 1 2]);
%         Ncov(:,:,j)=Ncov(:,:,j)+Ntf*Ntf';
%     end
%     Ncov(:,:,j)=Ncov(:,:,j)/IS;
% end
% Y1 = Beamform(X,'GMVDR',TDOA,Fs,Ncov);

% (2) For BF_Method = 'SDB', an array containing x and y
% cordinates of the mic positions (No_Ch x 2)needs to passed on as an
% argument. Mic positions should be specified in same order as channel
% order in the input .wav file
% Example : 2
% In the demo given below, positions of TCS mics are given as inputs:
% Mic Positions for circular array of radius 10cm with a centre mic
% r = [ 0.1; 0.1; 0.1; 0];
% theta = [ 0 ; 2*pi/3; 4*pi/3; 0];
% Mic_Pos = [r.*cos(theta) r.*sin(theta)]; 
% Y1 = Beamform(X,'SDB',TDOA,Fs,Mic_Pos);

% Perform Inverse STFT 
y1=istft_multi(Y1(:,:,1),nsampl).';

%% Check Second Stage Output
y1=y1/max(abs(y1));
sound(y1,Fs);

pdir = pwd;
cd('/media/nikhil/2C4A68104A67D4DC/nikhil/thesis/nmf/VAD Codes')
[~, sig_energy] = VAD( Data(:,1),512,0.5);
Si = var(Data(:,1) .* sig_energy(1:length(Data(:,1)))');
Ni = var(Data(:,1) .* (1 - sig_energy(1:length(Data(:,1)))'));
10*log10((Si-Ni)/Ni)

[~, sig_energy] = VAD( y1,256,0.5);
Si = var(y1 .* sig_energy(1:length(y1))');
Ni = var(y1 .* (1 - sig_energy(1:length(y1))'));
10*log10((Si-Ni)/Ni)
cd(pdir)