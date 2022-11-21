% Adam Rauff, Jason Manning
% Oct 2022

% this function iterates over each sub-block image saved in the "Neovessel"
% structure. the SHG images are analyzed for fibril alignment and relative
% density

function [Neovessel] = SubBlock_Orientations(Neovessel, Thigh, Tlow)

SHG_IM_Blocks = size(Neovessel.shg_blocks);

% initialize variables
anisotropy = zeros(SHG_IM_Blocks);
u2 = zeros(SHG_IM_Blocks);
v2 = zeros(SHG_IM_Blocks);

% for each image block
for i=1:SHG_IM_Blocks(1)
    for j = 1:SHG_IM_Blocks(2)
        
        % obtain SHG image domain
        im = Neovessel.shg_blocks{i,j};
        
        % Enhance contrast with histogram equalization
        im = adapthisteq(im);

        % Apply butterworth filter
        % smooths edges and ensures circular symmetry
        [butwthIM, ~, ~ ] = butterworth(im,6,.1);

        % Analyze fibril orientations
        [EV1, EV2, ~, Vector, ~] = discretize_fiber(butwthIM, Thigh, Tlow);
        
        % Calculate the anisotropy 
        % Fractional anisotropy calculated from the ratio of eigan vectors
        FA = 1 - EV1/EV2; 
        anisotropy(i,j) = FA;

        % Vectors for the quiver plot - scaled by the anisotropy
        u2(i,j) = Vector(1,2)*FA; % column 2 is principle
        v2(i,j) = Vector(2,2)*FA; % column 2 is principle

    end
end

% save data to structure
Neovessel.anisotropy = anisotropy;
Neovessel.vector_x = u2;
Neovessel.vector_y = v2;

end
