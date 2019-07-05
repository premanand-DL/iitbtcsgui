
function [y H cost spectrogram_inp spectrogram_out] = DereverbKLdivFrequencyEnvelope(reverb,sparsity,rir,parm)

%Implementation of 'Speech Dereverberation Using Non-Negative
%Convolutive Transfer Function and Spectro-Temporal Modeling'

%The function computes estimate of clean speech, magnitude spectrogram 
%of RIR and cost function after each itteration
%Inputs:
%   reverb: reverb data (1 channel)
%   sparsity: 1 if sparsity in X, 
%             2 if sparsity in H
%             0 no sparsity
%Output:
%   y: dereverb speech
%   H: estimated spectrogram of RIR
%   cost: cost functin for each itteration
%   spectrogram_inp: spectrogram of revern speech
%   spectrogram_out: spectrogram of reverb model
mag_res = 1;

reverb = reverb - mean(reverb);
reverb = norm_wav(reverb, 16);

%% STFT parameters
analsize = parm.analysis;
hp = parm.hop;
Nframes = parm.Nframe;
hwindow = parm.win;
Hlate = parm.Hlate;

%% Computing envelope for RIR 
% cond = 'reverb challenge RIR/RIR_SimRoom2_far_AnglA';
% disp (cond)
% rir = wavread(['/media/nikhil/2C4A68104A67D4DC/nikhil/RIR/' cond]);
% rir = rir(:,1);
RIR = abs(stft(rir, analsize, hp, 0, hwindow));
l1 = sum(RIR);
l2 = RIR(:,l1 == max(l1));
p = polyfit((1:length(l2))',l2,10);
env = polyval(p,1:length(l2));

%% STFT - Fourier spectra
F = stft(reverb, analsize, hp, 0, hwindow);
Fa = abs(F);
Ga = Fa;
spectrogram_inp = Ga;%output reverb spectrogram
reverblen = Nframes-1;

%% Z is observed reverberated spectra
Y = Ga.^mag_res;
[M,N] = size(Y);

%% sparsity constrain
lm_H = 0;
lm_X = 0;
if sparsity == 1
     lm_X = 0.1*sum(Y(:))/numel(Y);
elseif sparsity == 2
     lm_H = 1;
end

H = 1-(0:Nframes-1) / (2*Nframes); 
% if Hlate ~= 0
%     H(2:Hlate) = 0;
% end
H = repmat(H, size(Y,1), 1);

%% Initialize the spectral component X as just Z
S = Y(:,1:end-reverblen);
itt = 20;
cost = zeros(1,itt);
for i=1:itt
    Y_est = convlr(S,H);
    Y_temp = Y ./ (Y_est + eps);
    
    He = convlr(Y_temp, S, [0 1]) ./ (eps + repmat(sum(S,2),1,N + size(S,2) - 1) + lm_H);
    H = H .* He(:,1:size(H,2));
    
    Se = convlr(Y_temp, H, [0 1]) ./ (eps + repmat(sum(H,2),1,N + size(H,2) -1) + lm_X);
    S = S .* Se(:,1:size(S,2));
    
    %S = S .*repmat(sum(Y,2),1,size(S,2)) ./ repmat(sum(S,2),1,size(S,2));
    H = H ./ repmat(H(:,1) .* env', 1, Nframes);
    %H = H ./ repmat(sum(H,2),1,size(H,2));
    cost(i) = betaDiv(Y, Y_est, 1);
end
spectrogram_out = Y_est;

% %for Hlate
% if Hlate ~= 0
%     S = convlr(S,H(:,1:Hlate));
%     S = S(:,1:end - Hlate + 1);
% end


% Resynthesize. Note the addition of zeros to fill out the signal.
eFa = [S zeros(size(S,1), reverblen)];

% Back to time
fphase = F./abs(F);
finiteid = isfinite(fphase); fphase(finiteid==0) = 1;
y = stft( eFa .* fphase, analsize, hp, 0, hwindow);
y = y - mean(y);
y = norm_wav(y, 16);

%%Function for computing Beta Divergence
function bD = betaDiv(V,Vh,beta)
if beta == 0
    bD = sum((V(:)./Vh(:))-log(V(:)./Vh(:)) - 1);
elseif beta == 1 %%for KL divergence
    bD = sum(V(:).*(log(V(:))-log(Vh(:))) + Vh(:) - V(:));
else
    bD = sum(max(1/(beta*(beta-1))*(V(:).^beta + (beta-1)*Vh(:).^beta - beta*V(:).*Vh(:).^(beta-1)),0));
end
