function [Neovessel, Fibril_tracks_cue, ECM_density_cue, Cellular_bodies_cue, glob_paths] ...
    = Analyze_Cues_Guidance(Neovessel, rad_points_um, near, far)

%% Setup relevant variables from the structure
micronPpix = Neovessel.mpp;

% Neovessel orientation
vessel_orientation = Neovessel.neovessel_orientation;

% location of neovessel tip
tip_x = Neovessel.tip_local_pix(1);
tip_y = Neovessel.tip_local_pix(2);

% Define Guidance Paths
% relative path directions, neovessel is oriented along 0deg
rel_paths = Neovessel.relative_paths;
% global path directions
glob_paths = rel_paths + vessel_orientation;

%% Compute location of sample points
% creates an array of points at 5 micron increments along discretized path
% directions at 5 degree increments. the paths span -90 to +90 degrees from
% the neovessel orientation

% pre-allocate variables
sampled_x = zeros(length(rad_points_um), length(glob_paths));
sampled_y = zeros(length(rad_points_um), length(glob_paths));

for n = 1:length(rad_points_um) % for each radial sampling distance

    % convert the radial distance to pixels from neovessel tip position
    rad_point_pix = rad_points_um(n)/micronPpix;

    for m = 1:length(glob_paths) % for each discretized path 

        % x coordinate location
        % position of tip + (cosine of outward path dir * radial length)
        sampled_x(n,m) = tip_x + cosd(glob_paths(m))*rad_point_pix;

        % y coordinate location
        % same, subtract the sine to account for inverted image coordinates
        sampled_y(n,m) = tip_y - sind(glob_paths(m))*rad_point_pix;
    end
end

%% interpolate anisotropy and fibril vectors at the sampled points
% this sub function augments the array of data nodes, by adding nodes along
% the edges of the image using the data from the nearest node. this helps
% reduce NaN values at sampled points near the image edge during the 
% interpolation.

[anisotropy_interpolated, vectorx_interpolated, vectory_interpolated] = ...
    augment_nodes_interpolate(Neovessel, sampled_x, sampled_y);

%% Microenvironmental cues

% Fibril Tracks Cue
% Calculate fibril directions (principle eigan vector) in each sub-block
% Find the difference between the fibril direction and the discretized path
% Examine fibril alignment extending from the neovessel tip for tracks cue

% Cellular Bodies Cue
% calculated from a binarized fluorescence image
% each sampled point (previously calculated) is the center of a 2um region
% sum of the binary image in these 2um regions along the discretized paths
% estimate quantity of cellular components

% ECM Densitiy Cue
% calculated from the intensity of the SHG image
% use the same 2um regions as the cellular bodies cue
% sum of the shg image in these 2um regions along the discretized paths
% collegen density is related to the intensity of SHG

% pre-allocate
Fibril_tracks_cue = zeros(size(vectorx_interpolated));
ECM_density_cue = zeros(size(vectorx_interpolated));
Cellular_bodies_cue = zeros(size(vectorx_interpolated));
% principal fibril direction
fibril_direction = zeros(size(vectorx_interpolated));
% difference between fibril direction and discretized paths
tracks_difference = zeros(size(vectorx_interpolated));

% binarize fluorescent data
fluor_BW = double(imbinarize(Neovessel.fluor));

% generate a grid with the location of each sampled point.
[xgrid, ygrid] = meshgrid(1:size(fluor_BW,2), 1:size(fluor_BW,1));
cue_radius = round(2/micronPpix); % radius of the 2um regions in pixels

for n = 1:size(vectorx_interpolated,1) % for each sampled distance
    for m = 1:size(vectorx_interpolated,2) % for each path direction

        % get the fibril direction at the sampled point
        fibril_direction(n,m) = get_angle(vectorx_interpolated(n,m), vectory_interpolated(n,m));

        % get the difference between the fibril direction and path dir.
        % did Adam name this something specific in the paper? rename?
        angle_difference = fibril_direction(n,m) - glob_paths(m);

        % adjust the angle such that the angle between the fibril tracks
        % vector and the path direction is always between -90 and 90. 
        % Collagen fibrils aren't direction specific (ie 90 degrees is the
        % same as 270 degrees). Negative values are ok because in quadrants 
        % 1 and 4 (ie -90 to 90 degrees) cos(x) = cos(-x)
        tracks_difference(n,m) = adjust_angle_difference(angle_difference);

        % create a region of 2um radius at the sampled point
        sample_region = ((xgrid-sampled_x(n,m)).^2 + (ygrid-sampled_y(n,m)).^2) <= cue_radius.^2;

        % get the shg and binarized fluor data in the sampled region
        shg_region = Neovessel.shg(sample_region);
        fluor_region = fluor_BW(sample_region);

        % get the final cue value for each sampled point
        Fibril_tracks_cue(n,m) = anisotropy_interpolated(n,m)*cosd(tracks_difference(n,m));
        ECM_density_cue(n,m) = sum(shg_region(:));
        Cellular_bodies_cue(n,m) = sum(fluor_region(:));

    end
end

% save data to the structure
Neovessel.sampled_paths = glob_paths;

% the sub function calculate_cue_distribution takes the matrix of data
% obtained for each cue over the discretized paths and specified radius.
% here the data is "cropped" to the near and far bounds specified.
Neovessel.fibril_tracks_distribution = calculate_cue_distribution(Fibril_tracks_cue, near, far, rad_points_um, 0);
Neovessel.cellular_bodies_distribution = calculate_cue_distribution(Cellular_bodies_cue, near, far, rad_points_um, 1);
Neovessel.ecm_density_distribution = calculate_cue_distribution(ECM_density_cue, near, far, rad_points_um, 0);
end