%% CHAOS PART 5: The Cobweb Plot
%
% So far we plotted population vs TIME. A cobweb plot instead shows
% HOW each year turns into the next, using two curves:
%
%   - The PARABOLA is our rule:  next = r * x * (1 - x)
%   - The DIAGONAL is the line y = x (a "mirror")
%
% To trace one year:
%   1. From the current population, go UP to the parabola
%      (that applies the rule -> you land on next year's population)
%   2. Go SIDEWAYS to the diagonal
%      (the mirror hands the answer back as the new starting point)
%   3. Repeat!  Up, across, up, across... like a spider spinning a web.
%
% Each behavior has its own shape:
%   r = 2.8  -> the web SPIRALS IN to one point (settles down)
%   r = 3.2  -> the web locks onto a RECTANGLE (2-year cycle)
%   r = 3.9  -> the web WANDERS FOREVER, never repeating (chaos!)

clear; close all; clc;

% ---- Try changing this number! ----
r = 3.2;

x0     = 0.01;    % starting population
nSteps = 40;     % how many years to trace

% ---- Draw the two curves ----
figure('Name', 'Cobweb Plot');
hold on;

xx = 0:0.001:1;
plot(xx, r .* xx .* (1 - xx), 'b-', 'LineWidth', 2);   % the rule
plot(xx, xx, 'k-', 'LineWidth', 1);                    % the mirror y = x

xlabel('Population this year');
ylabel('Population next year');
title(['Cobweb plot,  r = ' num2str(r)]);
axis([0 1 0 1]);
axis square;
grid on;


% ---- Spin the web, one year at a time ----
x = x0;
plot(x, x, 'ro', 'MarkerFaceColor', 'r');   % starting point (on the mirror)

for n = 1:nSteps
    y = r * x * (1 - x);                    % apply the rule

    plot([x x], [x y], 'r-');               % go UP/DOWN to the parabola
    plot([x y], [y y], 'r-');               % go SIDEWAYS to the mirror

    x = y;                                  % next year begins
    pause(0.15);                            % slow it down so we can watch
end

% ---- THINGS TO TRY ----
% 1. r = 2.8 : watch the web spiral INTO one point.
% 2. r = 3.2 : the web becomes a rectangle. Why a rectangle?
%    (Because the population repeats every 2 years!)
% 3. r = 3.9 : the web never settles - it fills the whole region.
% 4. Make pause(0.15) smaller or bigger to change the animation speed.
