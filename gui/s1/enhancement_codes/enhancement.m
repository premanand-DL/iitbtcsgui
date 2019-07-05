addpath(genpath('../audio'))
addpath('utils')
addpath('source_localization')
addpath('beamform')
wlen = 1024;
input= argv(){1};
output = argv(){2};
enhan = argv(){3};
%% ----------------------------Array Definition---------------------------
% TCS Array
% xmic=[-.10 .10 -.10 0 .10]; % left to right axis
% ymic=[.095 .095 -.095 -.095 -.095]; % bottom to top axis
input_dir=['../' input ];
out_dir=['../' output '/' enhan '/'];
input_dir
out_dir

%Read Data
[Data1, Fs] = audioread([input_dir '04_ARRAY1_04_06_2017.wav']);
[Data2, Fs] = audioread([input_dir '05_ARRAY2_04_06_2017.wav']);
[Data3, Fs] = audioread([input_dir '06_ARRAY3_04_06_2017.wav']);
[Data4, Fs] = audioread([input_dir '07_ARRAY4_04_06_2017.wav']);
Data=[Data1 Data2 Data3 Data4];
nsampl = size(Data1,1);

% Perform STFT
X = stft_multi(Data.',wlen);
[nbin,nfram,nchan] = size(X);


% Localize
Max_Delay = ceil(0.2 * Fs / 340);
[TDOA R]= Compute_GCC(X,Max_Delay);
disp(size(TDOA))
Index = -Max_Delay:Max_Delay;
%plot(Index,R);

for t=1:nfram
   TDOA(t,:) = TDOA(t,:) - TDOA(t,1);
end;

%% Perform VAD
% VAD_Size = wlen;
% VAD_Out = VAD(Data(:,5),VAD_Size);

% y = Data(:,2);
% y=y/max(abs(y));
% audiowrite('Degrade_Spk1_MA2_NO.wav',y,Fs);
% 
% y = Data(:,3);
% y=y/max(abs(y));
% audiowrite('Degrade_Spk1_MA3_NO.wav',y,Fs);
% 
% y = Data(:,4);
% y=y/max(abs(y));
% audiowrite('Degrade_Spk1_MA4_NO.wav',y,Fs);
% 
if(strcmp(enhan,'DSB')) % Perform DSB Beanforming
  Y1 = DSB(X,TDOA.');
  y1=istft_multi(Y1(:,:,1),nsampl).';
  y1=y1/max(abs(y1));
  disp('Enhanced data using DSB stored in ')
  disp([out_dir 'DSB.wav'])
  Write_File( y1, Fs, [out_dir 'DSB.wav'] );
  %audiowrite([out_dir 'DSB.wav'],y1,Fs);
end% DSB

% Y2 = MCA(X,TDOA);
% y2=istft_multi(Y2(:,:,1),nsampl).';
% y2=y2/max(abs(y2));
% audiowrite('MCA_Gain_Spk3.wav',y2,Fs);
%

if(strcmp(enhan,'MVDR')) % Perform MVDR beamforming 
   % initial few frames assumed to be silence	
   Y3 = MVDR(X,TDOA.',10);
   y3=istft_multi(Y3(:,:,1),nsampl).';
   y3=y3/max(abs(y3));
   disp('Enhanced audio using MVDR written to ')
   disp([out_dir 'MVDR.wav'])
   Write_File(y3, Fs, [out_dir 'MVDR.wav']);
end
% 
% Y4 = MVDR_Gain(X,TDOA.',10);
%y4=istft_multi(Y4(:,:,1),nsampl).';
%y4=y4/max(abs(y4));
%audiowrite('MVDR_Gain_Spk3.wav',y4,Fs);

