function [H] = BeamPattern_Circular( Filter, No_Ch, No_Bins, FFT_Size, r, Fs)

c = 343;

Angle_Pos = pi*(0:(No_Ch-1))/4;
Mic_Loc = [r*cos(Angle_Pos).' r*sin(Angle_Pos).'];
Ref_Loc = Mic_Loc(1,:);

%------------------Computing Delay For Circular Microphones----------------
Angle = (-pi+pi/360):(pi/360):(pi-pi/369);
H = zeros(length(Angle),No_Bins);

% %-----------------Method 1 - Distance between parallel lines-------------
% for k = 1:length(Angle)
%     T = zeros(No_Ch,1);
%     Ref_Con = Ref_Loc(2)-Ref_Loc(1)*tan(pi/2+Angle(k));
%     for j = 1:No_Ch
%         Con = Mic_Loc(j,2)-Mic_Loc(j,1)*tan(pi/2+Angle(k));
%         D = -(Con-Ref_Con)*cos(Angle(k));
%         T(j) = D/c;
%     end;
%     for i = 1:No_Bins
%         D_Vector = exp(-2*pi*(i-1)*Fs*T/FFT_Size);
%         H(k,i) = D_Vector'*Filter(:,i);
%     end; 
% end;

%--------------------Method 2 - Polar Coordinates Rotation-----------------
for k = 1:length(Angle)
    Rel_Loc = [r*cos(Angle_Pos-Angle(k)).' r*sin(Angle_Pos-Angle(k)).'];
    Rel_Ref = Rel_Loc(1,:);
    T = zeros(No_Ch,1);
    for j = 1:No_Ch
        D = Rel_Ref(1) - Rel_Loc(j,1);
        T(j) = D/c;
    end;
    for i = 1:No_Bins
        D_Vector = exp(-1i*2*pi*(i-1)*Fs*T/FFT_Size);
        H(k,i) = D_Vector'*Filter(:,i);
    end; 
end;

mesh((0:No_Bins-1)*Fs/FFT_Size,Angle,20*log10(abs(H)));
xlabel('Frequency');
ylabel('Angle');
end

