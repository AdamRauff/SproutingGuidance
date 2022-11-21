function [image, H, bw] = butterworth(image, n, perc)
% n is the slope of the gradient
% perc is the percentage for the taper
% H is the filter
% bw is a binary mask (used for heat maps)

% June 2020 - Adam Rauff
% this function applies a butterworth filter to the image prior to the fft.
% this is an update of the previously used tukey filter used.

% construct matrices with image coordinates - for computational efficiency

[U,V] = size(image);
%[U, V, W] = size(image);

Rindex = floor(U/2 + 1);
Cindex = floor(V/2 + 1);
%Zindex = floor(W/2 + 1);

% store x,y,z coordinates of every location in power spectrum.
% used for expediting computation by matrix operations, rather
% than for loops. x position changes with the column index. y position
% changes with the row index

%[Um, Vm, Wm] = meshgrid(1:V, 1:U, 1:W); % AR Note 11/8 U and V where switched because meshgrid outputs matrix of "y rows and x columns"
[Um,Vm] = meshgrid(1:V, 1:U);

% move center coordinate to center of spectrum, and store as signed 32bit
% integer matrix
Um = Um - Cindex;
Vm = Vm - Rindex;
%Wm = Wm - Zindex;

% solve for radius of each voxel location
%Rad = sqrt(Um.^2 + Vm.^2 + Wm.^2);
Rad = sqrt(Um.^2 + Vm.^2);

% Rad(Rindex, Cindex, Zindex) = 1; % ensure no radius value is 0. 
% Radius is used to obtain the inclination angle

%% Apply butterworth Filter 
% This filter darkens the edges of the images in a circular fashion, or spherical
% for 3D. This operation is crucial prior to FFT, as the FFT assumes a
% signal is continuous function from -inf to +inf. This is implemented on
% digital signals by replication the signal/image. This would cause a hard
% edge to form where the image domain ends and the replication begins. This
% edge is high frequency content that would corrupt the power spectrum. By
% darkening the edges, we are removing this edge, and instead the
% replication of the signal would be a smooth lon-frequency signal that
% will be easilt filtered out.

RadMax = min([U,V])/2;
%RadMax = min([U,V,W])/2;

% filter parameters
Do = RadMax-RadMax*perc; % start "descend" perc% from edge

% construct BW signal
H = 1./(1 + (Rad./Do).^(2*n)); % This equation comes from Gonzales textbook: "Digitial Image Processing" Third Edition page 273.
bw = H > .5;

image = uint16(double(image).*H); % darken image edges

end