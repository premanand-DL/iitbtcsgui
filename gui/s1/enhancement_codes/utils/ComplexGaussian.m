function [P] = ComplexGaussian(y,R)
    if(y'*inv(R)*y<0)
        1
    end;
    P = real(exp(-y'/R*y)/(det(pi*R))); 
end