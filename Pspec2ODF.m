%this function converts a power spectrum into an orientation distribution
%function stored in the matrix "polar"
%Adam Rauff
%Novemeber 7, 2018


function polar = Pspec2ODF(I, Rad, Um, Vm)

%compute maximum radius and allocate space for transformed matrix
tRad = Rad(:); %flatten radius matrix
rmax = ceil(max(tRad)) + 1; clear tRad;
polar = zeros(rmax,361);

theta = round(rad2deg(atan2(Um, Vm)) + 181);
%theta = theta(:);
Rad = round(Rad);
Rad(Rad==0) = 1;
% DC component has already been zeroes, so this is inconsequential.
% the for loop ahead relies on Rad for indices, so 0 index causes error.
% excInds = Rad<1;
% Rad(excInds) = [];
% theta(excInds) = [];
% polar(Rad,theta)

% accumulate fiber distribution function from contribution of each pixel in
% power spectrum
for m = 1:size(I,1) % rows
    for n = 1:size(I,2) %columns
        polar(Rad(m,n), theta(m,n)) = polar(Rad(m,n), theta(m,n)) + I(m, n);
    end
end

end
