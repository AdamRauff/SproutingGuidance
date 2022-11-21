% Jason Manning and Adam Rauff

% This function takes the sampled data for a microenvironmental cue in the
% input matrix "data". It calculates the polar probability density function 
% for the cue - considering only the data within the range set by the user.

function [cue_guidance] = calculate_cue_distribution(data, minimum, maximum, sampled_dist, avg_flag)

% disregard NaN values - when points extend beyond the image bounds
map = data>=0;
data(map == 0) = 0;

% disregard sampled points within "minimum" microns
if (minimum > 0)
    limit = find(sampled_dist < minimum);
    limit = limit(end);
    map(1:limit, :) = 0;
    data(1:limit, :) = 0;
end

% disregard sampled points beyond "maximum" microns
if (maximum < 250)
    limit = find(sampled_dist > maximum);
    limit = limit(1);
    map(limit:end, :) = 0;
    data(limit:end, :) = 0;
end

% sum the data along each discretized path to create a polar probability
% density function for the microenvironmental cue
cue_guidance = sum(data,1);

% to account for instances where the number of sampled points in each
% discretized path varies (ie if some paths extend beyond the image
% bounds), the data is divided by the number of points sampled for each
% path
num = sum(map,1);
cue_guidance = cue_guidance ./ num;

if avg_flag % flag set to 1 only for cellular bodies distribution
    % moving average filter to smooth cellular bodies distribution
    windowSize = 3; 
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    cue_guidance = filter(b,a,cue_guidance);
end

% normalize - set the polar distribution to add to 1
cue_guidance = cue_guidance ./ sum(cue_guidance);

end


