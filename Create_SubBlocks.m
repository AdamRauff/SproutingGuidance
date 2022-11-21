% Jason Manning and Adam Rauff
% Oct 2022

% this function divides the shg image data into sub-blocks for local
% analysis of the ecm fibril alignment

function [Neovessel] = Create_SubBlocks(Neovessel, BlockSize, overlap_percent)

shg_image = Neovessel.shg;
[m,n] = size(shg_image);

%----------------------------------------------------------------------
% Determining the number of sub-blocks along the shorter edge of image
minDim = min([m,n]); % shorter length of the image data
minblockdiv = ceil(minDim /(BlockSize*(1-overlap_percent))); % number of sub-blocks along shorter edge
extra = minblockdiv * BlockSize - minDim; % total pixels to be overlapped along shorter edge
offset = ceil(extra/(minblockdiv-1)); % pixels to be overlapped between sub-blocks
clear minDim minblockdiv extra

%----------------------------------------------------------------------
% Blocking the Image into the sub-blocks for analysis. 
% Saving the sub-blocks in the structure.
% Also save the center coordinates for each block - used for nodal analysis

rowEnd = 0;
i = 1; j = 1;

% nested while loops generate sub-blocks from the full image
% outer "while" loops to generate new rows of sub-blocks
while rowEnd < size(shg_image,1)
    colEnd = 0;
    j = 1;
    
    % set the row bounds for the sub-block based on the ith row
    % subtract the ith offset to account for desired overlapping
    rowBeg = round((i-1)*(BlockSize) - (i-1)*offset + 1);
    rowEnd = round(i*(BlockSize) - (i-1)*offset);
   
    if rowEnd > size(shg_image,1)
        break; % stop if a new row would exceed image bounds
    end
    
    % inner "while" loops along the row to generate the columns 
    while colEnd < size(shg_image,2)

        % same as for the rows - set the column bounds
        % based on the jth solumn less the offset to account for overlap
        colBeg = round((j-1)*(BlockSize) - (j-1)*offset + 1);
        colEnd = round(j*BlockSize - (j-1)*offset);

        if colEnd > size(shg_image,2)
            break; % stop if a new column would exceed image bounds
        end

        % save the sub-block of the shg image for local analysis
        Neovessel.shg_blocks{i,j} = shg_image(rowBeg:rowEnd, colBeg:colEnd);
        
        % save the center locations (in pixel units) of each sub-block
        % used as locational nodes for ECM data
        cx = (colBeg+colEnd)/2;
        cy = -(rowBeg+rowEnd)/2;
        Neovessel.node_pix(i,j,1) = cx;
        Neovessel.node_pix(i,j,2) = -cy; % image is 4th quadrant, invert y

        j = j + 1; 
    end
    i = i+1;
end

end