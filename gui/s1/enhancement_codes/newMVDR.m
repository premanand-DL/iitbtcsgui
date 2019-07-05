addpath(genpath('../audio'))
addpath('new_utils/Utils')
addpath('source_localization')
addpath('beamform/')
addpath('utils/')
%addpath('rVAD1.0/')

%% parameters for running
input = 'wav/demo1';
output = '../wav/demo1';
enhan = 'MVDR1';
file_id = 'recording1';

%% parameters for running from terminal
% input= argv(){1};      % location of array recording
% output = argv(){2};    % location of enhaced data
% enhan = argv(){3};     % type of beamforming
% file_id = argv(){4};   % file id of arrray

%% ----------------------------Array Definition---------------------------
input=['../' input ];
out_dir=['../' output '/' enhan '/'];
%input_dir
%out_dir

%Read Data
ch=4;
[Data1, Fs] = audioread([input '/' file_id '.CH1.wav']);
[Data2, Fs] = audioread([input '/' file_id '.CH2.wav']);
[Data3, Fs] = audioread([input '/' file_id '.CH3.wav']);
[Data4, Fs] = audioread([input '/' file_id '.CH4.wav']);
if (ch == 5)
	[Data5, Fs] = audioread([input '/' file_id '.CH5.wav']);
end
Data=[Data1 Data2 Data3 Data4];
if (ch == 5)
	Data = [Data Data5];
end
nsampl = size(Data1,1);
clear Data1 Data2 Data3 Data4 Data5

%% Paramters
SL_Method = 'GCC'; %source localisation parameters
BF_Method = enhan; %'GDSB';%beamforming parameters

% Localization parameters
Max_Delay = ceil(0.2 * Fs / 340); %Maximum sample delays expected obtained from knowledge of array
Ref_Ch = 1; %Reference channel for TDOA estimation(delay=0)

%STFT parameters
wlen = round(32e-3 * Fs); % hop_size = wlen/2 (default)


% Perform STFT
disp('STFT computation')
X = stft_multi(Data.',wlen);
[nbin,nfram,nchan] = size(X);
clear Data

% Estimate TDOAs
disp('TDOA estimation')
TDOA = Estimate_TDOA(X,SL_Method,Ref_Ch,Max_Delay); 

% VAD on channel 1
fpitch = 'fpitch.mat'; % file name of stored pitch info, needed for algorithm
fvad = 'fvad'; % file name of stored the VAD decision
fout = 'fout.wav'; %file of denoised speech, obtained as a byproduct
thre = 0.1; %threshold, needs to be set
fil = ['../' input '/' file_id '.CH1.wav'];
cd('rVAD1.0/')
system('rm fpitch.mat');
vad_seg = vad(fil, 'fpitch.mat', 'fvad', thre, 'fout.wav');
cd -
size('vad_seg')
if 1 % code to check performance of VAD
     [data, fs] = audioread(fil);
     flen=32e-3*Fs; % analysis window
     fsh10=16e-3*Fs; % hop size
     nfr10=floor((length(data)-(flen-fsh10))/fsh10);
     vad_decision = zeros(length(data),1);
     for i = 1 : size(vad_seg, 1)
         vad_decision(vad_seg(i,1) * fsh10 + 1 : vad_seg(i,2) * fsh10 + flen) = 1;
     end
     plot(0.75*data/max(data)), hold on, plot(vad_decision), hold off
end

if 0 % commented at present
% Noise covariance estimate
Ncov=zeros(ch, ch, nbin);
for f=1:nbin,
    for n=1:IS,
        Ntf=permute(X(f,n,:),[3 1 2]);
        Ncov(:,:,f)=Ncov(:,:,f)+Ntf*Ntf';
    end
    Ncov(:,:,f)=Ncov(:,:,f)/IS;
end

%MVDR with better noise covariance matrix estimate
if strcmp(BF_Method, 'MVDR1') 
    %Dynamic estimation of Ncov
    disp('Code incomplete')    
end
end

%% Perform Beanforming
if strcmp(BF_Method, 'GDSB')
    Y1 = Beamform(X,BF_Method,TDOA,Fs);
    disp('Enhanced data using DSB stored in ')
    y1=istft_multi(Y1(:,:,1),nsampl).';
    disp([out_dir 'GDSB.wav'])
    Write_File( y1, Fs, [out_dir file_id '.wav'] );
    % Perform Inverse STFT 
    %y1=istft_multi(Y1(:,:,1),nsampl).';
end

if(strcmp(enhan,'MVDR')) % Perform MVDR beamforming
   % initial few frames assumed to be silence
   Y3 = MVDR(X,TDOA.',20);
   y3=istft_multi(Y3(:,:,1),nsampl).';
   y3=y3/max(abs(y3));
   disp('Enhanced audio using MVDR written to ')
   disp([out_dir 'MVDR.wav'])
   Write_File(y3, Fs, [out_dir file_id '.wav']);
end
