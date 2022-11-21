Sprouting Guidance Analysis
A set of functions to compute the microenvironmental stimuli affecting angiogenic sprout guidance

November, 21st, 2022
Adam Rauff and Jason Manning
Musculoskeletal Research Laboratory, University of Utah

The code is structured to contain a set of functions that help a user quantify the influence of the immediate extracellular environment on a sprouting angiogenic neovessel. 

Requirements - time-series microscopic images including SHG signal of the ECM and fluorescence of the blood vessel cells. The images should be cropped around an advancing tip cell. Prepare maximum image projection of both channels
Output - Directional probability distribution functions of the microenvironmental stimuli (visualized)

Description of functions

Main Function: Run_Neovessel_Tip_Program.m - Master script that runs through the whole analysis

User_Define_Neovessel.m - user uploads the images, marks the tip location, neovessel orientation, and subsequent growth trajectory

Create_SubBlocks.m - Divides the SHG image into sub-blocks for local analysis of orientation

SubBlock_Orientations.m - Extract the ecm fibril alignment and dominant orientation using fft analysis.

Analyze_Cues_Guidance.m - Measures the amount of influence of each microenvironmental cue 

Visualize_Data.m - graphs the directional PDFs alongside the original image projections to visualize the output of the analysis.

Description of subdirectories

IM_Projections - Folder containing samples of image projections analyzed in the paper.
