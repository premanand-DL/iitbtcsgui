addpath(genpath('../audio'))
addpath('new_utils/Utils')
addpath('source_localization')
addpath('beamform')
addpath('utils/')
%wlen = 2048;

input= argv(){1};      % location of array recording
output = argv(){2};    % location of enhaced data
enhan = argv(){3};     % type of beamforming
file_id = argv(){4};   % file id of arrray

%% ----------------------------Array Definition---------------------------
%input=['../' input ];
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

%% Paramters
SL_Method = 'GCC'; %source localisation parameters
BF_Method = enhan; %'GDSB';%beamforming parameters

% Localization parameters
Max_Delay = ceil(0.2 * Fs / 340); %Maximum sample delays expected obtained from knowledge of array
Ref_Ch = 1; %Reference channel for TDOA estimation(delay=0)

%STFT parameters
wlen = 2048; % hop_size = wlen/2 (default)


% Perform STFT
disp('STFT computation')
X = stft_multi(Data.',wlen);
[nbin,nfram,nchan] = size(X);

% Estimate TDOAs
disp('TDOA estimation')
TDOA = Estimate_TDOA(X,SL_Method,Ref_Ch,Max_Delay); 

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
