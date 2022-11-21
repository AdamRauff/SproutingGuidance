% Jason Manning and Adam Rauff
% Oct 2022

% This script runs the tip cell analysis program to determine the influence
% of microenvironmental cues in the vicinity of advancing angiogenic tip
% cells.

% Inputs: image projections from microscopic imaging prepared. One SHG and
% one Flouresence image showing an advancing neovessel tip and its
% microenvironment. The SHG image contains the extracellular fibril
% structures and the fluoresence contain information about the cellular
% bodies in the image.

% prepare work space
clear,clc; close all

%% User Defined Parameters

% define the microns/pix resolution of the image
micronPpix = 0.7843; % units of um/pix. 400 microns / 510 pixels

% define range of interest - semicircular area emanating from the tip in 
% the direction of the neovessel orientation.
windowLimits = 90; % angle limits of the region of interest
relative_paths = -windowLimits:5:windowLimits; % discretized path directions

% radius over which to analyze the paths - large to cover most of the image
radius_um = 250; 

% the cues analysis considers a more specific range. 
% ie remove the first 20 microns of data as this often introduces "noise" 
% from the neovessel tip itself and collegen condensation around the tip.
near = 20; % near range of data to use in microns from neovessel
% the far range must be equal to or less than roi_rad_um.
far = 200;  % far range of data to use in microns from neovessel

% Parameters of fiber orientations analysis
% defining the sub blocks
block_um = 50; % enter the size of sub-blocks to analyze in microns
block_pix =  round(block_um / micronPpix); % convert block size to pixels
overlap = 0.2; % Rough amount of overlap between sub-blocks

% frequnecy cutoffs
FFT_high_cutoff = round(0.5 / micronPpix); % High frequency cutoff for FFT
FFT_low_cutoff = round(50 / micronPpix); % Low frequency cutoff for FFT

% Concentric Sampling Parameters
radial_sampling = 5; % radial sampling distance between sampled points in microns
radial_points_um = 5:radial_sampling:radius_um; % vector of points to sample

%% user selects image files
% fluorescence and shg images from multiphoton microscopy
[fname, path] = uigetfile('*.*','SELECT SHG and FLUOR IMAGES','MultiSelect','on');
sp = filesep;

% separating fluor and shg image
if iscell(fname)
    for n = 1:length(fname)
        
        % identify SHG image (typically visualized as grayscale)
        if contains(fname{n}, 'sh', 'IgnoreCase', true)
            SHGimage = imread([path, sp, fname{n}]);
        end
        
        % identify auto-fluor image (typically green channel)
        if contains(fname{n}, 'fl', 'IgnoreCase', true)
            fluorimage = imread([path, sp, fname{n}]);
        end
    end  
else
    error(['Could not identify fluoresence and SHG images ', ...
    'Please try again with different files selected']);   
end
clear fname n
%--------------------------------------------------------------------------
%% Define the Neovessel Tip, Orientation, Growth Direction
% Interactively select neovessel tips and draw vector of vessel direction

[Neovessel] = User_Define_Neovessel(fluorimage, SHGimage, micronPpix);
%% Generate Sub-Blocks
% Divide the SHG image into sub-blocks for local analysis

[Neovessel] = Create_SubBlocks(Neovessel, block_pix, overlap);
%% Analyze SHG Sub-Blocks
% (fft for fibril orientation, and relative intensity for collagen density)

[Neovessel] = SubBlock_Orientations(Neovessel, FFT_high_cutoff, FFT_low_cutoff);
%% Guidance Analysis and Stats
% analysis for 3 microenvironmental cues - data is saved to structure

Neovessel.relative_paths = relative_paths; % save paths to structure
[Neovessel] = Analyze_Cues_Guidance(Neovessel, radial_points_um, near, far);
%% Visualization
close all; 

Visualize_Data(Neovessel, far, windowLimits);
