function Visualize_Data(Neovessel, far, windowLimits)

% a few parameters for visualization
fontsize = 10; % fontsize for image titles
growth_vector = 90 / Neovessel.mpp; % vector length (um) for visualization


%% Figure 1
figure; 
% first figure displays polar propabilty functions of the 3 cues
% displays data from -90 to 90 degrees of the neovessel (oriented at 0 deg)
% has an overlaid line in the direction of neovessel growth
% see figure in manuscript

subplot(1,3,1)
Plot_Cue_PDF([-90:5:90], Neovessel.fibril_tracks_distribution, Neovessel.relative_growth, [0.3010 0.7450 0.9330]);
title('fibril tracks', FontSize=fontsize)

subplot(1,3,2)
Plot_Cue_PDF([-90:5:90], Neovessel.cellular_bodies_distribution, Neovessel.relative_growth, 'green')
title('cellular bodies', FontSize=fontsize)

subplot(1,3,3)
Plot_Cue_PDF([-90:5:90], Neovessel.ecm_density_distribution, Neovessel.relative_growth, 'black')
title('ECM density', FontSize=fontsize)

%% Figure 2
figure;
% second figure displays the raw shg and fluorescence channel images
% overlaid with the location of the tip, semi-circle radius marking the far
% range of data considered for the cues, and a red line indicating growth
% direction

% create semi-circle to mark the region in which cues were analyzed
theta = linspace(deg2rad(Neovessel.neovessel_orientation + windowLimits), deg2rad(Neovessel.neovessel_orientation - windowLimits), 100);
radius =  far/Neovessel.mpp; % draw the line at the far end of the range
x = radius*cos(theta) + Neovessel.tip_local_pix(1); % x values
y = -1*radius*sin(theta) + Neovessel.tip_local_pix(2); % y - 4th quadrant

subplot(1,2,1)
imshow(Neovessel.fluor); % show the fluor image
hold on;
% plot the semi-circle
plot(x,y, 'y', 'LineWidth',2) 
% mark location of the neovessel tip (as marked by user)
plot(Neovessel.tip_local_pix(1), Neovessel.tip_local_pix(2), 'y*', 'MarkerSize',6,'LineWidth',3)
% draw a line marking the subsequent growth (as marked by user)
quiver(Neovessel.tip_local_pix(1), Neovessel.tip_local_pix(2), ...
    growth_vector*cosd(Neovessel.growth_direction), ...
    growth_vector*sind(Neovessel.growth_direction) * (-1), ...
    'ShowArrowHead','on', 'MaxHeadSize',1.5,'LineWidth',3,'color','r')
title('fluor image', FontSize=fontsize)

subplot(1,2,2)
imshow(Neovessel.shg); % show the shg image
hold on;
% plot the semi-circle
plot(x,y, 'y', 'LineWidth',2) 
% mark location of the neovessel tip (as marked by user)
plot(Neovessel.tip_local_pix(1), Neovessel.tip_local_pix(2), 'y*', 'MarkerSize',6,'LineWidth',3)
% draw a line marking the subsequent growth (as marked by user)
quiver( Neovessel.tip_local_pix(1), Neovessel.tip_local_pix(2), ...
    growth_vector*cosd(Neovessel.growth_direction), ...
    growth_vector*sind(Neovessel.growth_direction) * (-1), ...
    'ShowArrowHead','on', 'MaxHeadSize',1.5,'LineWidth',3,'color','r')
title('shg image', FontSize=fontsize)

end
