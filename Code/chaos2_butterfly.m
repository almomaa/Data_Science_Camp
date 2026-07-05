%% CHAOS PART 2: The Butterfly Effect
%
% Two islands. Same breeding rate. ALMOST the same starting population:
%
%   Island A starts with x = 0.2
%   Island B starts with x = 0.2000001   (just 0.00001% more rabbits!)
%
% That difference is like ONE extra hair on ONE rabbit.
% Surely both islands will behave the same way... right?

clear; close all; clc;

r      = 3.9;          % chaotic breeding rate (try 2.8 too - see below!)
nYears = 50;

xA = zeros(1, nYears);
xB = zeros(1, nYears);
xA(1) = 0.2;           % island A
xB(1) = 0.201;     % island B - tiny, tiny difference

for n = 1:nYears-1
    xA(n+1) = r * xA(n) * (1 - xA(n));
    xB(n+1) = r * xB(n) * (1 - xB(n));
end

% ---- Plot both islands together ----
figure('Name', 'Butterfly Effect');

subplot(2,1,1);
plot(1:nYears, xA, 'b.-', 'LineWidth', 1.2); hold on;
plot(1:nYears, xB, 'r.-', 'LineWidth', 1.2);
xlabel('Year'); ylabel('Population');
title(['Two nearly identical islands (r = ' num2str(r) ')']);
legend('Island A (x_0 = 0.2)', 'Island B (x_0 = 0.2000001)', ...
       'Location', 'best');
grid on;

subplot(2,1,2);
plot(1:nYears, abs(xA - xB), 'k.-', 'LineWidth', 1.2);
xlabel('Year'); ylabel('|A - B|');
title('Difference between the two islands');
grid on;

% ---- WHAT JUST HAPPENED? ----
% For about 25 years the islands look identical.
% Then suddenly they go completely different ways!
%
% The tiny starting difference DOUBLES again and again until it
% takes over. This is called SENSITIVITY TO INITIAL CONDITIONS,
% or the "butterfly effect."
%
% This is why weather forecasts fail after ~10 days: we can never
% measure today's weather perfectly, and chaos blows up any tiny
% measurement error.
%
% ---- THINGS TO TRY ----
% 1. Change r to 2.8. Do the islands still separate? (No! Without
%    chaos, small differences fade away instead of growing.)
% 2. Make the starting difference even smaller: 0.2000000001.
%    Does it still blow up? How many years does it take now?
