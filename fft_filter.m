%this function takes in an FFT matrix, low and high period cuttoff
%values and the center coordinates of the fft matrix and returns a matrix
%with all values outside of this removed

function I = fft_filter(I, Rad, Thigh, Tlow)


N = min(size(I));
% convert spatial period (in pixles) to frequency cuttoff
flow = 1/Tlow;
fhigh = 1/Thigh;

Rad = Rad(:); %flatten Raidus matrix
F = Rad./N;

% identify indices to remove
ZilchInd = (F<flow | F>fhigh) & F~=0;

I(ZilchInd) = 0;

% imshow(I);

end
