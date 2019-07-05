function [] = Compute_BeamPattern( H,Mic_Pos, Src_Dist, Fs)
% Computes the beampattern of a beamformer (H) having dimensions
% No_Ch x No_Bins 
% c : Speed of sound (m/s)
% Mic_Pos : Positions of Mic Array
% Src_Dist : Distance of source from centre of array
% Fs : Sampling frequency

[No_Ch, No_Bins] = size(H);
FFT_Size = (No_Bins-1)*2;

c = 343;
%--------------------------Computing Source Locations----------------------
Src_Angle = [(-pi+2*pi/360):(2*pi/360):(pi-2*pi/360)];
Src_Loc =  [Src_Dist*cos(Src_Angle).' Src_Dist*sin(Src_Angle).'];
BP = zeros(length(Src_Angle),No_Bins);

%-------------------Computing Steering Vectors and Beampattern-------------
TDOA = zeros(No_Ch,length(Src_Angle));
for k = 1:length(Src_Angle)
    for i = 1:No_Ch
        Dist = pdist([Src_Loc(k,:) ; Mic_Pos(i,:)],'euclidean');
        TDOA(i,k) = round(Fs*Dist/c);
    end;
    TDOA(:,k) = TDOA(:,k) - TDOA(1,k);
    for i = 1:No_Bins
        D_Vector = exp(-1j*2*pi*(i-1)*TDOA(:,k)/FFT_Size)/No_Ch;
        BP(k,i) = D_Vector'*H(:,i);
    end; 
end;

mesh((0:No_Bins-1)*Fs/FFT_Size,Src_Angle,20*log10(abs(BP)));
xlabel('Frequency');
ylabel('Angle');
end

