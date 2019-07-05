%-------------------------------------
% Left right convolution
function z = convlr( x, y, c)

if ~exist( 'c', 'var')
    c = [0 0];
end

l = size(x,2) + size(y,2) - 1;
x = fft( x, l, 2);
y = fft( y, l, 2);
if c(1), x = conj( x); end
if c(2), y = conj( y); end
z = real( ifft( x.*y, [], 2));

i =  z < 0 & z > -1e-4;
z(i) = eps;