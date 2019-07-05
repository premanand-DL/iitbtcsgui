function [vad_seg]=vad(finwav, fpitch, fvad, vadThres, foutwav)

% Usage: vad(finwav, fpitch, foutwav, fvad, vadThres);
% vadThres = 0.1 is the default value.
%
% finwav: The input WAVE file path and name.
% fpitch: The pitch file path and name. If the pitch file exists, pitch information is loaded; otherwise, the pitch information will be extracted and saved to the file in Matlab format. 
% fvad: The output VAD file path and name. Each line in the file contains the start frame number and the end frame number for a speech segment. The frame shift is 10ms.
% vadThres: The threshold for VAD. The default value is 0.1 [optinal]. Increasing vadThres (e.g. to 0.2) makes the VAD more aggressive, i.e. the speech segment will be shortened.
% foutwav: The output denoised speech file path and name [optional]. This is to be specified only if denoised speech output is desired. 
%
% Ref:
%  Z.-H. Tan and B. Lindberg, "Low-complexity variable frame rate analysis for speech recognition and voice activity detection." 
%  IEEE Journal of Selected Topics in Signal Processing, vol. 4, no. 5, pp. 798-807, 2010.
%
% Modified 10 Nov 2014

if nargin < 3; error('Usage: vad(finwav, fpitch, fvad)'); end
if nargin == 3; vadThres = 0.1; foutwav = 0; end

[data,fs]=audioread(finwav);

% Parameter setting
ENERGYFLOOR = exp(-50);
flen=fs/40;
fsh10=fs/100;
nfr10=floor((length(data)-(flen-fsh10))/fsh10);

b=[0.9770   -0.9770]; a=[ 1.0000   -0.9540];
fdata=filter(b,a,data);

if exist(fpitch)
  load(fpitch,'-mat');
else
  [pv01, pitch]=pitchestm(data, fs, nfr10);
  save(fpitch,'pv01','pitch');
end
pvblk=pitchblockdetect(pv01, nfr10, pitch);

[D1, Dsmth1, snre_vad1,e]=vad_snre_round1(fdata, nfr10, flen, fsh10, ENERGYFLOOR);

% block based processing to remove noise part by using snre_vad1.
sign_vad = 0;
noise_seg=zeros(floor(nfr10/1.6),1);
noise_samp=zeros(nfr10,2);
n_noise_samp=0;
for i=1:nfr10
    if snre_vad1(i) == 1 && sign_vad == 0 % start of a segment
        sign_vad = 1;
        nstart=i;
    elseif (snre_vad1(i) ==0 || i==nfr10) && sign_vad == 1 % end of a segment
        sign_vad = 0;
        nstop=i-1;
        if sum(pv01(nstart:nstop))==0
            noise_seg(round(nstart/1.6):floor(nstop/1.6)) = 1;
            n_noise_samp=n_noise_samp+1;
            noise_samp(n_noise_samp,:)=[(nstart-1)*fsh10+1 nstop*fsh10];
        end
    end
end
noise_samp(n_noise_samp+1:nfr10,:)=[];

%if sum(pv01(1:10))>=1
%    noise_seg(1:10)=1;
%end

[dfdatarm]=specsub_rats_noiseseg_lfn(fdata,fs,noise_seg,pv01);

for i=1:n_noise_samp
    dfdatarm(noise_samp(i,1):noise_samp(i,2)) = 0;
end

[D2, Dsmth2, snre_vad2, pv_vad2, e]=vad_snre_pv(dfdatarm, nfr10, flen, fsh10, ENERGYFLOOR, pv01, pvblk, vadThres);
if foutwav ~= 0;  audiowrite(foutwav, dfdatarm,fs); end

sign_vad=0;
vad_seg=zeros(nfr10,2);
n_vad_seg=0;
for i=1:nfr10
    if pv_vad2(i)==1 && sign_vad==0
        nstart=i;
        sign_vad=1;
    elseif (pv_vad2(i)==0 || i==nfr10) && sign_vad==1
        nstop=i-1;
        sign_vad=0;
        n_vad_seg=n_vad_seg+1;
        vad_seg(n_vad_seg,:)=[nstart nstop];
    end
end
vad_seg(n_vad_seg+1:nfr10,:)=[];
fid=fopen(fvad,'wt');
fprintf(fid, '%d %d\n',vad_seg');
fclose(fid);

