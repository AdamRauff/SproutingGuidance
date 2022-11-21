% Jason Manning and Adam Rauff
% Oct 2022

function [] = Plot_Cue_PDF(Angles, Probs, growthDir, color)

% creates a polar plot using the input cue distribution
% inputs are Angles (degrees), Probs (cue distribution), growth direction

radAngles = deg2rad(Angles); % matlab works with radians, not degrees

% the way the counts work, I need to have a count between each edge.
% so need to average data between each domain point 
ProbBinCounts = zeros(1,length(Angles)-1);
for i = 2:length(Angles)
    ProbBinCounts(i-1) = mean([Probs(i), Probs(i-1)]);
end

h = polarhistogram('BinEdges',radAngles,'BinCounts', ProbBinCounts, 'FaceColor', color);
 
thetalim([-90, 90]) % only display relevant domain
h.Parent.ThetaZeroLocation = 'top'; % orient neovessel at 0 degrees upwards
h.Parent.FontSize = 20;

hold on

% plot arrow in direction of subsequent growth
arrLen = max(Probs); % scale to data
Theta  = deg2rad(growthDir)*ones(100,1); 
Rho = linspace(0,arrLen,100)';
polarplot(Theta, Rho, 'LineWidth',2, 'color','r')

end

