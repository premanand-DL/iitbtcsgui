function [ Tau ] = Generate_Circular_Delays( r,c,No_Ch,Ref_Ch,Offset )

Angle_Pos = 2*pi*(0:(No_Ch-1))/No_Ch;
Mic_Loc = [r*cos(Angle_Pos + Offset).' r*sin(Angle_Pos + Offset).'];
%Ref_Mic = 1;

%------------------Computing Delay For Circular Microphones----------------
Angle = 0:2*pi/360:(2*pi-pi/360);
Tau = zeros(length(Angle),No_Ch);
    
for k = 1:length(Angle)
    Rel_Loc = [r*cos(Angle_Pos+Offset-Angle(k)).' r*sin(Angle_Pos+Offset-Angle(k)).'];
    Rel_Ref = Rel_Loc(Ref_Ch,:);
    for j = 1:No_Ch
        D = Rel_Ref(1) - Rel_Loc(j,1);
        Tau(k,j) = D/c;
    end;
end

end

