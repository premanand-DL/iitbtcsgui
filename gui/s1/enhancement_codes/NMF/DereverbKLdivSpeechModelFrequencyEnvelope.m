function [y H cost] = DereverbKLdivSpeechModelFrequencyEnvelope(reverb,sparsity,rir,parm)

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


%% Selection of spectrogram (1-magnitude, 2-power spectrum)
mag_res = 1;

%% normalization of reverb speech
reverb = reverb - mean(reverb);
reverb = norm_wav(reverb, 16);

% %% STFT parameters
% analsize = 1024;
% hp = fix(analsize/2);
% Nframes = 10;
% hwindow = sqrt(hanning(analsize));

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
Ga = abs(F);
spectrogram_inp = Ga;%output reverb spectrogram
reverblen = Nframes-1;

%% Y is observed reverberated spectra
Y = Ga.^mag_res;

%K - no of freq. bins
%T - no. of frames in reverb spectrogram
%R - rank of decomposition of clean speech
[K,T] = size(Y);
R = 50;

%% sparsity constrain
lm_H = 0;
lm_X = 0;
if sparsity == 1
     lm_X = 0.1*sum(Y(:))/numel(Y);
elseif sparsity == 2
     lm_H = 1;
end

H = 1-(0:Nframes-1) / (Nframes); H = repmat(H, K, 1);

%% Initialization of speech basis and activation
W = rand(K,R);
X = rand(R,T);
for i = 1 : 10
    t1 = Y ./ (W * X + eps);

    Xe = (W' * t1) ./ (W' * ones(K,T)); %repmat (sum(W)'+ eps, 1, size(t1,2));
    We = (t1 * X') ./ (ones(K,T) * X'); %repmat (sum(H,2)'+ eps, size(t1,1), 1);

    X = X .* Xe;
    W = W .* We;
%     cost_mat = V .* log(V./(W * H + eps) + eps) - V + W * H;
%     cost(i) = sum(cost_mat(:).^2);
    W = W ./ repmat(sum(W,1), K, 1);
end
X = X(:,1:T-reverblen);

%% no. of itteration and cost function
itt = 20;
cost = zeros(1,itt);

%% weight update
pow_S = 1.005;
pow_X = 1.005;
for i = 1 : itt
    S_est = (W * X) .^ pow_S;
    Y_est = convlr(S_est,H);
    Y_temp = Y ./ (Y_est + eps);
    
    %%update for H
    He = convlr(Y_temp, S_est, [0 1]) ./ (eps + repmat(sum(S_est,2),1,T + size(S_est,2) - 1) + lm_H);
    H = H .* He(:,1:size(H,2));    
    
    %%update for W
    HX = zeros(K,R,T);num = zeros(K,R);
    for r = 1 : R
        HX(:,r,:) = convlr(H, repmat(X(r,:),K,1));
        num(:,r) = sum(Y_temp .* squeeze(HX(:,r,:)),2);
    end
    den = sum(HX,3);
    We = num ./ (den + eps);
    W = W .* We;
    
    %%update for X
    den = lm_X + repmat(W' * sum(H,2), 1, T-reverblen);
    temp = convlr(Y_temp, H, [0 1]);
    temp = temp(:,1:T - reverblen);
    num = W' * temp;
    Xe = num ./ (den + eps);
    X = (X .* Xe) .^ pow_X;
    
    %%normalization
    W = W ./ repmat(sum(W,1), K, 1);
    H = H ./ repmat(H(:,1) .* env', 1, Nframes);
    %H = H ./ repmat(sum(H,2), 1, Nframes);
%     for ii = 2 : Nframes
%         H(:,ii) = min(H(:,ii),H(:,ii-1));
%     end
    
    %%compute cost
    cost(i) = betaDiv(Y,Y_est,1) + lm_X * sum(X(:)) + lm_H * sum(H(:));
end

% %plot the basis matrix
% for i=1:R
%     figure,plot(W(:,i));
%     title(['i = ' num2str(i)]);
% end

%% Gain computation
num = W * X;
den = convlr(H, num);
G = num ./ (den(:,1/1:T-reverblen));

S_est = G .* Y(:,1:T-reverblen);

%% Reconstruction of dereverb speech
spectrogram_out = Y_est;
% Resynthesize. Note the addition of zeros to fill out the signal.
eFa = [S_est zeros(size(S_est,1), reverblen)];

% Back to time
fphase = F./abs(F);
finiteid = isfinite(fphase); fphase(finiteid==0) = 1;
y = stft( eFa .* fphase, analsize, hp, 0, hwindow);


%% Function for computing Beta Divergence
function bD = betaDiv(V,Vh,beta)
if beta == 0
    bD = sum((V(:)./Vh(:))-log(V(:)./Vh(:)) - 1);
elseif beta == 1 %%for KL divergence
    bD = sum(V(:).*(log(V(:))-log(Vh(:))) + Vh(:) - V(:));
else
    bD = sum(max(1/(beta*(beta-1))*(V(:).^beta + (beta-1)*Vh(:).^beta - beta*V(:).*Vh(:).^(beta-1)),0));
end