%% CHAOS PART 1: The Rabbit Island
%
% Imagine an island full of rabbits.
%   x = the rabbit population (as a fraction: 0 = no rabbits, 1 = island full)
%   r = how fast rabbits breed
%
% Every year the population changes by this simple rule:
%
%       next year = r * (this year) * (1 - this year)
%
% The (1 - x) part means: when the island gets crowded, food runs out
% and the population drops.
%
% QUESTION: With such a simple rule, the population should be easy to
% predict... right? Let's find out!

clear; close all; clc;

% ---- Try changing this number! ----
% r = 2.8  -> population settles down to ONE value
% r = 3.2  -> population bounces between TWO values forever
% r = 3.5  -> population repeats every FOUR years
% r = 3.9  -> CHAOS! It never repeats!
r = 3.2;

x0     = 0.2;    % starting population (20% of the island)
nYears = 60;     % how many years to simulate

% ---- Simulate year by year ----
x = zeros(1, nYears);   % a list to store the population each year
x(1) = x0;

for n = 1:nYears-1
    x(n+1) = r * x(n) * (1 - x(n));   % next year's rabbits
end

% ---- Plot the population over time ----
figure('Name', 'Rabbit Island');
plot(1:nYears, x, 'o-', 'LineWidth', 1.5, 'MarkerSize', 5);
xlabel('Year');
ylabel('Population (fraction of island)');
title(['Rabbit population with r = ' num2str(r)]);
ylim([0 1]);
grid on;

% ---- THINGS TO TRY ----
% 1. Run with r = 2.8, then 3.2, then 3.5, then 3.9.
%    Same rule, same starting point - only r changed!
% 2. At r = 3.9, does the pattern ever repeat?
% 3. Run the r = 3.9 case TWICE. Do you get the same plot both times?
%    (Yes! So chaos is NOT the same as random...)
