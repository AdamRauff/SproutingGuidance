function [EV1, EV2, ODF, Vector, Fimage] = discretize_fiber(Image, Thigh, Tlow)
% Inputs:
% Image - image (preprocessed w/ Butterworth filter)

% Outputs:

% EV1 - eigan value 1 (minor)
% EV2 - eigan value 2 (major)
% ODF - sum of fibers oriented in each direction (normalized 0 - 1)
% Vector - components of the 2 eigan vectors
% Fimage - the filtered image

% SubFunctions:
%   fft_filter.m
%   Pspec2ODF.m
%   get_angle.m

%--------------------------------------------------------------
%Get 2d fourier transform
IspectrumComplex = fftshift(fft2(Image));
IspectrumReal = abs(IspectrumComplex);

%--------------------------------------------------------------
%Find center of spectrum
[U, Vector] = size(IspectrumReal);
Rindex = floor(U/2 + 1);
Cindex = floor(Vector/2 + 1);

%--------------------------------------------------------------
%Remove DC component - set center component to zero
%Save the original DC component
IspectrumReal(Rindex, Cindex) = 0;
DC = IspectrumComplex(Rindex, Cindex);

%--------------------------------------------------------------
% store x,y,z coordinates of every location in power spectrum.
% used for expediting computation by matrix operations, rather
% than for loops. x position changes with the column index. y position
% changes with the row index
[Um, Vm] = meshgrid(1:U, 1:Vector);

% move center coordinate to center of spectrum, and store as signed 32bit
% integer matrix
Um = Um - Cindex;
Vm = Vm - Rindex;

% solve for radius in spherical coordinates
Rad = sqrt(Um.^2 + Vm.^2);

%--------------------------------------------------------------
% Filtering Using the fft_filter function
IspectrumReal = fft_filter(IspectrumReal, Rad, Thigh, Tlow);
IspectrumComplex = fft_filter(IspectrumComplex, Rad, Thigh, Tlow);

%--------------------------------------------------------------
% Put back DC Component before inverse FFT
IspectrumComplex(Rindex, Cindex) = DC;

%--------------------------------------------------------------
% Inverse FFT to Recreate the Image
Fimage = abs((ifft2(IspectrumComplex)));

%--------------------------------------------------------------
%Pspec2ODF function
%convert power spectrum to an orientation distribution
%converts "image" Ispectrum to polar coordinates in matrix "IPolar"

Ipolar = Pspec2ODF(IspectrumReal, Rad, Um, Vm);

%--------------------------------------------------------------
% Determining Proportion of Fibers in Each Direction

%Sum along radius. Gets rid of frequency infromation. Keep orientation
%Sums along radius in each direction (all 360 degrees).
ODF = sum(Ipolar,1);

%Angles - Degrees to Radians
ang = 0:360;
ang = deg2rad(ang);

%Normalize the distribution
ODF = ODF./sum(ODF); % normalize so cdf converges to 1

%--------------------------------------------------------------
%Compute cartesian coordinates, find covariance matrix
x = ODF.*cos(ang);
y = ODF.*sin(ang);
cmat = cov(x,y); %compute covariance matrix

%--------------------------------------------------------------
%eigenvectors, eignevalues
if any(isnan(cmat(:))) || any(isinf(cmat(:)))
    %isotropic
    EV1 = 1;
    EV2 = 1;
    Vector1 = [1,1]/norm([1,1]);
    Vector2 = [-1,1]/norm([-1,1]);
    Vector = ones(2,2);
    Vector(:,1) = Vector1;
    Vector(:,2) = Vector2;

else
    %Compute eigenvectors and values
    [Vector,D] = eig(cmat);
    D = D./sum(sum(D));
    Vector1 = Vector(:,1);%normalize both
    EV1 = D(1,1); % Eigan Value 1
    Vector2 = Vector(:,2); %normalize both
    EV2 = D(2,2); % Eigan Value 2
end



end

