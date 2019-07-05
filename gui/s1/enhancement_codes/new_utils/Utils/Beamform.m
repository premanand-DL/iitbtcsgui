function [ Y1 ] = Beamform( Multi_STFT,BF_Method,TDOA,Fs,varargin)
%% Reference papers
% [1] Cohen, Israel, Jacob Benesty, and Sharon Gannot, eds. Speech 
% processing in modern communication: Challenges and perspectives. Vol. 3. 
% Springer Science & Business Media, 2009.
% [2] Bitzer, Joerg, and K. Uwe Simmer. "Superdirective microphone arrays." 
% Microphone arrays. Springer Berlin Heidelberg, 2001. 19-38.
% [3] Stolbov, Mikhail Borisovich, and Sergei Vladimirovich Aleinik. "Improvement
% of microphone array characteristics for speech capturing." Modern Applied
% Science 9.6 (2015): 310.

%% Input parameters
%Multi_STFT: Multichannel STFT of the audio
%BF_Method: Beamfoming methods
%   'DSB' = Delay Sum Beamforming [1]
%   'SDB' = Superdirective Beamforming [2]
%   'MCA' = Multi Channel Alignment [3]
%   'GDSB' = Multi Channel Alignment with Gain based tranfer function 
%            Gain-DSB + DSB [3]
%   'MVDR' = Minimum Variance Distortionless Response [1]
%   'GMVDR' = MVDR with Gain based tranfer function (Gain-DSB + MVDR) 
% TDOA: TDOAs from source localization step 
%% Output parameter
%Y1: Output from beamforming

if strcmp(BF_Method,'DSB')
    [ Y1 ] = DSB( Multi_STFT, TDOA);
elseif strcmp(BF_Method,'SDB')
    if(nargin<4)
        error('Specify x & y coordinates of mic positions (No_Mics x 2)');
    end;
    [ Y1 ] = SDB( Multi_STFT, TDOA,Fs,varargin{1});
    
elseif strcmp(BF_Method,'MCA')
    [ Y1 ] = MCA( Multi_STFT, TDOA);
    
elseif strcmp(BF_Method,'GDSB')
    [ Y1 ] = MCA_Gain( Multi_STFT, TDOA);
    
elseif strcmp(BF_Method,'MVDR')
    if(nargin<4)
        error('Give noise covariance matrix');
    end;
    [ Y1 ] = MVDR( Multi_STFT, TDOA,varargin{1});
    
elseif strcmp(BF_Method,'GMVDR')
    if(nargin<4)
        error('Give noise covariance matrix');
    end;
    [ Y1 ] = MVDR_Gain( Multi_STFT, TDOA,varargin{1});
end

end

%% ----------------------------------DSB-----------------------------------
function [ DSB_Data ] = DSB( Multi_STFT,TDOA)
% Performs Delay Sum Beamforming
% Multi_STFT - Multi Channel STFT of the input data
% TDOA - Time Delay of Arrival for each frame (No_Frames x No_Ch)
[No_Bins, No_Frames, No_Ch] = size(Multi_STFT);
FFT_Size = (No_Bins-1)*2;

DSB_Data = zeros(No_Bins,No_Frames);

for j = 1:No_Bins
    for i = 1:No_Frames
        S_Vector = exp(-1i*2*pi*(j-1)*TDOA(i,:).'/FFT_Size)/No_Ch;
        MC_Data  = reshape(Multi_STFT(j,i,:),[No_Ch 1]);
        DSB_Data(j,i) = S_Vector'*MC_Data;
    end;
end;

end

%% ----------------------------------SDB-----------------------------------
function [ SDB_Data] = SDB( Multi_STFT,TDOA,Fs,Mic_Pos)
% Performs Super directive beamforming 
% Multi_STFT - STFT of the input data (No_Bins x No_Frames x No_Ch)
% Mic_Pos - Positions of the microphones (No_Mic x No_Dim) 
% Fs - Sampling Frequency (Fs = 16kHz)

%% Additional Parameters
% c - Speed of sound (Default = 343m/s)
% Eps - Diagonal Loading Factor (Default = 1e1)

[No_Bins, No_Frames, No_Ch] = size(Multi_STFT);
FFT_Size = (No_Bins-1)*2;

% Compute Diffuse Field Coherence Matrix
c = 343;
D =zeros(No_Ch);
for i = 1:No_Ch
    for j = 1:No_Ch
        D(i,j) = sqrt(sum((Mic_Pos(i,:)-Mic_Pos(j,:)).^2));
    end;
end;

Eps = 1e1;
Inv_Cov = zeros(No_Ch,No_Ch,No_Bins);
for j = 2:No_Bins
        Inv_Cov(:,:,j) = inv(sinc(2*(j-1)*Fs/FFT_Size*D/c)+Eps*eye(No_Ch));
end;

SDB_Data = zeros(No_Bins,No_Frames);
for i = 1:No_Frames
    SDB_Data(1,i) = mean(Multi_STFT(1,i,:));
end;

SDB_Data = zeros(No_Bins,No_Frames);

for i = 1:No_Frames
    for j = 2:No_Bins
        S_Vector = exp(-1i*2*pi*(j-1)*TDOA(i,:).'/FFT_Size);
        SDB = Inv_Cov(:,:,j)*S_Vector/(S_Vector'*Inv_Cov(:,:,j)*S_Vector);
        SDB_Data(j,i) = SDB'*reshape(Multi_STFT(j,i,:),[No_Ch 1]);
    end;
end;


end


%% --------------------------------MCA-------------------------------------
function [ MCA_Data ] = MCA( Multi_STFT,TDOA)
% Performs Multi Channel Alignment
% Multi_STFT - Multi Channel STFT of the input data
% TDOA - Time Delay of Arrival for each frame (No_Frames x No_Ch)
[No_Bins, No_Frames, No_Ch] = size(Multi_STFT);
FFT_Size = (No_Bins-1)*2;

Cross_PSD = zeros(No_Ch,No_Bins);
Auto_PSD = zeros(No_Ch,No_Bins);

DSB_Data = zeros(No_Bins,No_Frames);
MCA_Data = zeros(No_Bins,No_Frames);

Alpha = 0.30;
for i = 1:No_Frames
    for j = 1:No_Bins
        S_Vector = exp(-1i*2*pi*(j-1)*TDOA(i,:).'/FFT_Size)/No_Ch;
        MC_Data  = conj(S_Vector).*reshape(Multi_STFT(j,i,:),[No_Ch 1]);
        DSB_Data(j,i) = sum(MC_Data);
        if (i == 1)
            Cross_PSD(:,j) = MC_Data*conj(DSB_Data(j,i)); 
            Auto_PSD(:,j) = MC_Data.*conj(MC_Data);
        else
        Cross_PSD(:,j) = (1-Alpha)*Cross_PSD(:,j) + Alpha*MC_Data*conj(DSB_Data(j,i)); 
        Auto_PSD(:,j) = (1-Alpha)*Auto_PSD(:,j) + Alpha*MC_Data.*conj(MC_Data);
        end;
        H = Cross_PSD(:,j)./Auto_PSD(:,j);
        MCA_Data(j,i) = sum(H.*MC_Data);
    end;
end;

end

%% --------------------------------MCA Gain--------------------------------
function [ MCA_Data ] = MCA_Gain( Multi_STFT,TDOA)
% Performs Multi Channel Alignment
% Multi_STFT - Multi Channel STFT of the input data
% TDOA - Time Delay of Arrival for each frame (No_Frames x No_Ch)

%% Additional Parameters
% Alpha - Smoothing Parameter (Default = 0.30)


[No_Bins, No_Frames, No_Ch] = size(Multi_STFT);
FFT_Size = (No_Bins-1)*2;

Cross_PSD = zeros(No_Ch,No_Bins);
Auto_PSD = zeros(No_Ch,No_Bins);

DSB_Data = zeros(No_Bins,No_Frames);
MCA_Data = zeros(No_Bins,No_Frames);

Alpha = 0.30;  
for i = 1:No_Frames
    for j = 1:No_Bins
        S_Vector = exp(-1i*2*pi*(j-1)*TDOA(i,:).'/FFT_Size)/No_Ch;
        MC_Data  = conj(S_Vector).*reshape(Multi_STFT(j,i,:),[No_Ch 1]);
        DSB_Data(j,i) = sum(MC_Data);
        if (i == 1)
            Cross_PSD(:,j) = MC_Data*conj(DSB_Data(j,i)); 
            Auto_PSD(:,j) = MC_Data.*conj(MC_Data);
        else
        Cross_PSD(:,j) = (1-Alpha)*Cross_PSD(:,j) + Alpha*MC_Data*conj(DSB_Data(j,i)); 
        Auto_PSD(:,j) = (1-Alpha)*Auto_PSD(:,j) + Alpha*MC_Data.*conj(MC_Data);
        end;
        H = abs(Cross_PSD(:,j)./Auto_PSD(:,j));
        MCA_Data(j,i) = sum(H.*MC_Data);
    end;
end;

end

function [ Y ] = MVDR( X,TDOA,Ncov)
% Performs Multi Channel Alignment
% TDOA - Time Delay of Arrival for each frame (No_Frame x No_Ch)
% Ncov - Noise coherence matrix (No_Ch x No_Ch x No_Bins) 

[nbin, nfram, nchan] = size(X);
FFT_Size = (nbin-1)*2;

%--------------------------------MVDR--------------------------------------

Mu = 1e-3;
Energy = permute(mean(abs(X).^2,2),[3 1 2]);
Y = zeros(nbin,nfram);

for j = 1:nbin
    Inv_Cov = inv(Ncov(:,:,j)+Mu*diag(Energy(:,j)));
    for i = 1:nfram
        S_Vector = exp(-1i*2*pi*(j-1)*TDOA(i,:).'/FFT_Size);
        % MVDR beamforming
        MVDR = Inv_Cov*S_Vector/(S_Vector'*Inv_Cov*S_Vector);
        Y(j,i) = MVDR'*reshape(X(j,i,:),[nchan 1]);
    end
end

end

%% -------------------------------MVDR_Gain--------------------------------
function [ Y2 ] = MVDR_Gain( X,TDOA,Ncov)
% Performs Multi Channel Alignment
% Multi_STFT - Multi Channel STFT of the input data
% TDOA - Time Delay of Arrival for each frame (No_Frame x No_Ch)
% Ncov - Noise coherence matrix (No_Ch x No_Ch x No_Bins) 

%% Additional Parameters
% Alpha - Smoothing Parameter (Default = 0.30)
% Mu - Diagonal Loading (Mu = 1e-3)

[nbin, nfram, nchan] = size(X);
FFT_Size = (nbin-1)*2;

Cross_PSD = zeros(nchan,nbin);
Auto_PSD = zeros(nchan,nbin);

Mu = 1e-3;
Energy = permute(mean(abs(X).^2,2),[3 1 2]);
DSB_Data = zeros(nbin,nfram);
Y2 = zeros(nbin,nfram);

Alpha = 0.30;

for j = 1:nbin
    Inv_Cov = inv(Ncov(:,:,j)+Mu*diag(Energy(:,j)));
    for i = 1:nfram
        S_Vector = exp(-1i*2*pi*(j-1)*TDOA(i,:).'/FFT_Size);
        MC_Data  = conj(S_Vector).*reshape(X(j,i,:),[nchan 1]);
        DSB_Data(j,i) = sum(MC_Data);
        if (i == 1)
            Cross_PSD(:,j) = MC_Data*conj(DSB_Data(j,i)); 
            Auto_PSD(:,j) = MC_Data.*conj(MC_Data);

        else
        Cross_PSD(:,j) = (1-Alpha)*Cross_PSD(:,j) + Alpha*MC_Data*conj(DSB_Data(j,i)); 
        Auto_PSD(:,j) = (1-Alpha)*Auto_PSD(:,j) + Alpha*MC_Data.*conj(MC_Data);

        end;

        %Compute Gain Vector
        G_Vector = abs(Auto_PSD(:,j)./Cross_PSD(:,j));
        G_Vector = S_Vector.*G_Vector;

        % MVDR beamforming
        MVDR = Inv_Cov*G_Vector/(G_Vector'*Inv_Cov*G_Vector);
        Y2(j,i) = MVDR'*reshape(X(j,i,:),[nchan 1]);
    end
end

end