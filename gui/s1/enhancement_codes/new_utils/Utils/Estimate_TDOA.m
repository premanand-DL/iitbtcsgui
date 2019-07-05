function [ Tau ] = Estimate_TDOA(X,SL_Method,Ref_Ch,Max_Delay)
%% Reference paper
% Knapp, Charles, and Glifford Carter. "The generalized correlation method 
%for estimation of time delay." IEEE Transactions on Acoustics, Speech, and
%Signal Processing 24.4 (1976): 320-327.
% Input parameters
%X:Multichannel STFT of the audio
%SL_Method: Source localization methods
%   'GCC' = GCC-PHAT
%   'CC' = Cross-correlation
%   'SCOT' = Smoothed Coherence Transform 
%   'HT' = Hannan Thompson
%Max_Delay: Maximum sample delay expected
%Ref_Ch: Refernce channel for source localisation(zero sample delay )
% Output parameter
%Tau: Estimated sample delays [#frame x #channel]

if strcmp(SL_Method,'GCC')
    [ Tau ] = Compute_GCC( X, Ref_Ch,Max_Delay);
elseif strcmp(SL_Method,'CC')
    [ Tau ] = Compute_CC( X, Ref_Ch,Max_Delay);
elseif strcmp(SL_Method,'SCOT')
    [ Tau ] = Compute_CC( X, Ref_Ch,Max_Delay);
elseif strcmp(SL_Method,'HT')
    [ Tau ] = Compute_CC( X, Ref_Ch,Max_Delay);
end

end

%% GCC-PHAT
function [ Tau ] = Compute_GCC( Multi_STFT, Ref_Ch,Max_Delay)

[No_Bins, No_Frames, No_Ch] = size(Multi_STFT);
FFT_Size = (No_Bins-1)*2;

%% --------------------------------GCC-------------------------------------
Tau = zeros(No_Frames,No_Ch);

for j = 1:No_Frames
    for k = 1:No_Ch
        G_x1x2  = zeros(No_Bins,1);
        FFT_X1 = Multi_STFT(:,j,Ref_Ch);
        FFT_X2 = Multi_STFT(:,j,k);
        G_x1x2   = FFT_X1.*conj(FFT_X2);
        PHAT_Weight = 1./abs(G_x1x2);
        G_Hat = G_x1x2.*PHAT_Weight;
        G_Hat = [G_Hat; conj(G_Hat(No_Bins-1:-1:2))];
        R     = fftshift(ifft(G_Hat));
        [~, Index] = max(abs(R(FFT_Size/2+1-Max_Delay:FFT_Size/2+1+Max_Delay)));
        Tau(j,k) = -(Index-Max_Delay-1);
    end;
end;
end

%% GCC-PHAT
function [ Tau ] = Compute_CC( Multi_STFT, Ref_Ch,Max_Delay)

[No_Bins, No_Frames, No_Ch] = size(Multi_STFT);
FFT_Size = (No_Bins-1)*2;

%% ---------------------------------CC-------------------------------------
Tau = zeros(No_Frames,No_Ch);

for j = 1:No_Frames
    for k = 1:No_Ch
        G_x1x2  = zeros(No_Bins,1);
        FFT_X1 = Multi_STFT(:,j,Ref_Ch);
        FFT_X2 = Multi_STFT(:,j,k);
        G_x1x2   = FFT_X1.*conj(FFT_X2);
        G_Hat = [G_x1x2; conj(G_x1x2(No_Bins-1:-1:2))];
        R     = fftshift(ifft(G_Hat));
        [~, Index] = max(abs(R(FFT_Size/2+1-Max_Delay:FFT_Size/2+1+Max_Delay)));
        Tau(j,k) = -(Index-Max_Delay-1);
    end;
end;
end

function [ Tau ] = Compute_SCOT( Multi_STFT, Ref_Ch,Max_Delay)

[No_Bins No_Frames No_Ch] = size(Multi_STFT);
FFT_Size = (No_Bins-1)*2;

%% -------------------------------SCOT-------------------------------------
Tau = zeros(No_Frames,No_Ch);

Phi_X1X2 = zeros(No_Ch,No_Bins);
Phi_X1X1 = zeros(No_Ch,No_Bins);

for k = 1:No_Ch
    for j = 1:No_Bins
        Phi_X1X1(k,j) = sum(abs(Multi_STFT(j,:,k)).^2);
        Phi_X1X2(k,j) = Multi_STFT(j,:,Ref_Ch)*Multi_STFT(j,:,k)';
    end;
end;
    
for j = 1:No_Frames
    for k = 1:No_Ch
        FFT_Ref = Multi_STFT(:,j,Ref_Ch);
        FFT_X = Multi_STFT(:,j,k);
        G   = FFT_Ref.*conj(FFT_X);
        SCOT_Weight = 1./sqrt(Phi_X1X1(k,:).*Phi_X1X1(Ref_Ch,:));
        G_Hat = G.*SCOT_Weight.';
        G_Hat = [G_Hat; conj(G_Hat(No_Bins-1:-1:2))];
        R     = fftshift(ifft(G_Hat));
        [~, Index] = max(R(FFT_Size/2+1-Max_Delay:FFT_Size/2+1+Max_Delay));
        Tau(j,k) = -(Index-Max_Delay-1);
    end;
end;

end

function [ Tau ] = Compute_HT( Multi_STFT, Ref_Ch,Max_Delay)

[No_Bins, No_Frames, No_Ch] = size(Multi_STFT);
FFT_Size = (No_Bins-1)*2;

%% -------------------------------HT-------------------------------------
Tau = zeros(No_Frames,No_Ch);

Phi_X1X2 = zeros(No_Ch,No_Bins);
Phi_X1X1 = zeros(No_Ch,No_Bins);

for k = 1:No_Ch
    for j = 1:No_Bins
        Phi_X1X1(k,j) = sum(abs(Multi_STFT(j,:,k)).^2);
        Phi_X1X2(k,j) = Multi_STFT(j,:,Ref_Ch)*Multi_STFT(j,:,k)';
    end;
end;
    
 for j = 1:No_Frames
    for k = 1:No_Ch
        FFT_Ref = Multi_STFT(:,j,Ref_Ch);
        FFT_X = Multi_STFT(:,j,k);
        G   = FFT_Ref.*conj(FFT_X);
        G_Hat = G./max(abs(G),1e-6);
        Gamma = abs(Phi_X1X2(k,:)./sqrt(Phi_X1X1(k,:).*Phi_X1X1(Ref_Ch,:)));
        ML_Weight = Gamma.^2./((1-Gamma.^2));
        G_Hat = G_Hat.*ML_Weight.';
        G_Hat = [G_Hat; conj(G_Hat(No_Bins-1:-1:2))];
        R     = fftshift(ifft(G_Hat));
        [~, Index] = max(abs(R(FFT_Size/2+1-Max_Delay:FFT_Size/2+1+Max_Delay)));
        Tau(j,k) = -(Index-Max_Delay-1);
    end;
end;

end