%% CHAOS PART 3: The Map of All Behaviors (Bifurcation Diagram)
%
% In Part 1 we tried r = 2.8, 3.2, 3.5, 3.9 one at a time.
% Now let's try EVERY value of r at once and make one big picture:
%
%   - For each r, run the simulation for a long time.
%   - Throw away the first years (let the population settle).
%   - Plot the values the population keeps visiting, as dots.
%
% One column of dots = the long-term behavior for that r:
%   1 dot   = settles to one value
%   2 dots  = bounces between two values
%   4 dots  = cycle of four
%   a smear = CHAOS
%
% This picture is one of the most famous images in all of science!

clear; close all; clc;

rValues = 2.5 : 0.001 : 4.0;   % all the breeding rates to test
nSettle = 300;                 % years to let the population settle down
nKeep   = 100;                 % years to actually plot

figure('Name', 'Bifurcation Diagram');
hold on;

for r = rValues
    x = 0.5;                       % starting population

    % Let it settle (we don't plot these years)
    for n = 1:nSettle
        x = r * x * (1 - x);
    end

    % Now record where the population goes
    xKeep = zeros(1, nKeep);
    for n = 1:nKeep
        x = r * x * (1 - x);
        xKeep(n) = x;
    end

    % One column of dots at this r
    plot(r * ones(1, nKeep), xKeep, 'k.', 'MarkerSize', 1);
    drawnow
end

xlabel('r  (breeding rate)');
ylabel('Long-term population values');
title('Every possible fate of the rabbits, in one picture');
xlim([2.5 4]);
ylim([0 1]);

% ---- HOW TO READ THIS PICTURE ----
% Left side (r < 3):        one line  -> population settles down
% At r = 3:                 the line SPLITS in two -> boom-bust cycle
% Around r = 3.45:          splits again -> cycle of 4
% Then 8, 16, 32... faster and faster... until around r = 3.57:
% CHAOS - the dots fill whole bands.
%
% But look closely inside the chaos near r = 3.83:
% a clear WINDOW where order suddenly returns (a cycle of 3)!
%
% ---- THINGS TO TRY ----
% 1. Zoom in on the region r = 3.83 to 3.86 (use the magnifier tool,
%    or change rValues to 3.83:0.00002:3.86).
%    The little window contains a tiny copy of the WHOLE diagram!
%    This "pattern inside the pattern" is called self-similarity.
% 2. Find the r values in Part 1 (2.8, 3.2, 3.5, 3.9) on this picture.
%    Do the number of dots match what you saw there?
