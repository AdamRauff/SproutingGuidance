% Jason Manning and Adam Rauff
% Oct 2022

% within this function, the user selects the location of the neovessel tip
% and draws vectors to 1) indicate neovessel orientation and 2) indicate 
% the subsequent growth direction. the user is given the option to
% open the next timepoint to draw the growth

function [Neovessel] = User_Define_Neovessel(fluor, shg, microns)
%% User selects point of the neovessel tip
% show the fluoresence image
figure('Name','Fluoresence Image - Mark tip location');
imshow(fluor,[min(fluor(:)) max(fluor(:))]); hold on;

% display message box with directions. User clicks on the image to mark a
% point, and presses enter to continue
CreateStruct.Interpreter = 'tex';
CreateStruct.WindowStyle = 'modal';
msgbox('\fontsize{18} Choose 1 point to mark the tip location, then press Enter', CreateStruct)

% Save point location
[tip_x,tip_y] = getpts;

%plot tip location
plot(tip_x,tip_y,'r+', 'MarkerSize',10,'LineWidth',3);


%% User selects neovessel orientation 

close all;
figure('Name', 'Fluoresence Image - Mark tip location and orientation')
imshow(fluor,[min(fluor(:)) max(fluor(:))]);

% User Draws a line indicating the direction of the vessel. line drawn by
% two points. Vessel body -> vessel tip. So the direction is alway from 1st
% point to second.
msgbox(['\fontsize{18}Draw a line to mark the NEOVESSEL ORIENTATION', ...
    newline 'Orientation = 1st point -> 2nd point', ...
    newline 'Then press the spacebar'] , CreateStruct);
vector = drawline; pause;

pt1 = vector.Position(1,:);
pt2 = vector.Position(2,:);

% image coordinates are always in the fourth quadrant of a plane (bottom
% right) with the y coordinates negative. Inverting Y coordinates.
pt1(2) = -pt1(2); pt2(2) = -pt2(2);

% Calculate the neovessel orietnation
% Note that Matlab images are indexed opposite in the y direction
dx = pt2(1) - pt1(1);
dy = pt2(2) - pt1(2);
Neovessel.neovessel_orientation = round(get_angle(dx,dy));

%% User selects growth direction and visualizes it
% ask user if they want to choose subsequent time image to visualize the
% growth direction.
quest = 'Would you like to upload the subsequent image?';
dlgtitle = 'Growth Direction';
answer = questdlg(quest, dlgtitle, 'Yes', 'No', 'Cancel');

switch answer
    case 'Yes'
        % read in the the new image
        [fname, path] = uigetfile('*.*','Select Fluoresence Image for growth direction');
        sub_fluorIM = imread([path,filesep,fname]);

    case 'No'
        sub_fluorIM = fluor;

    case 'Cancel'
        error('User terminated program');
end

% visualize the image - either the current time or subsequent time as
% selected by user. the user draws a vector to indicate growth direction 
figure('Name', 'Visualize growth direction');
imshow(sub_fluorIM, [min(sub_fluorIM(:)) max(sub_fluorIM(:))]); hold on;
ax = gca;

% ask user to draw growth orientation
msgbox(['\fontsize{18}Draw a line to mark GROWTH DIRECTION', ...
    newline 'Orientation = 1st point -> 2nd point', ...
    newline 'Then press the spacebar'] , CreateStruct);
vector = drawline(ax); pause;

% compute growth direction from the points
pt1 = vector.Position(1,:);
pt2 = vector.Position(2,:);
growthx = pt2(1) - pt1(1);
growthy = -(pt2(2) - pt1(2)); % inverting y coordinates because of natural image coordinates in 4th quadrant.

% use trig to get growth direction in degrees
growth_direction = round(get_angle(growthx,growthy));
close all; % close figures

%% calculating relative growth direction

% Note the growth direction is in the image coordinates. 
% Both variables are in degrees.
Neovessel.growth_direction = growth_direction;

% Direction in the vessel coordinates (with respect to where the vessel is
% positioned), substracting the growth direction from the neovessel
% orientation. This way +90 degrees is counter-clockwise of the neovessel 
% and -90 is clockwise of the neovessel. See figure in manuscript
Neovessel.relative_growth = round(Neovessel.growth_direction - Neovessel.neovessel_orientation);

% Just in case , adjusts the growth to be realistic
if Neovessel.relative_growth > 90
    Neovessel.relative_growth = Neovessel.relative_growth - 360;
elseif Neovessel.relative_growth < -90
    Neovessel.relative_growth = Neovessel.relative_growth + 360;
end

%% save data to structure
Neovessel.shg = shg; % shg image
Neovessel.fluor = fluor; % fluor image
Neovessel.mpp = microns; % microns per pixel
Neovessel.tip_local_pix(1) = tip_x; % x location of neovessel tip
Neovessel.tip_local_pix(2) = tip_y; % y location of neovessel tip
end


