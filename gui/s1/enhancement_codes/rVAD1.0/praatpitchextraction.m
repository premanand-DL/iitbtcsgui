function [pvblk]=praatpitchextraction(fpitch)
% Extract pitch segment from praat output. 

[tm, pitch, aa, bb, f1, f2, f3]=textread(fpitch, '%f %s %s %s %s %s %s');
pv01=ones(nfr10,1);
if nfr10-length(pitch)==1
    pitch(nfr10)=pitch(nfr10-1);
end
for i=1:nfr10
    if strcmp(pitch(i),'--undefined--')
        pv01(i)=0;
    end
end
pvblk=pitchblockdetect(pv01, nfr10, pitch);



