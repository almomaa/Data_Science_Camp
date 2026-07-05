%% CHAOS PART 4 (BONUS): Play with r yourself!
%
% Drag the slider and watch the rabbit population change in real time.
% Watch for: calm -> 2-cycle -> 4-cycle -> chaos ... as r grows.

clear; close all; clc;

nYears = 60;
x0     = 0.2;

% ---- Build the window ----
fig = figure('Name', 'Chaos Explorer', 'Position', [200 200 700 500]);
ax  = axes('Parent', fig, 'Position', [0.1 0.25 0.85 0.65]);

sld = uicontrol(fig, 'Style', 'slider', ...
    'Min', 2.5, 'Max', 4.0, 'Value', 2.8, ...
    'Units', 'normalized', 'Position', [0.1 0.08 0.7 0.05]);

txt = uicontrol(fig, 'Style', 'text', ...
    'Units', 'normalized', 'Position', [0.82 0.07 0.13 0.06], ...
    'FontSize', 12);

% Redraw the plot whenever the slider moves
sld.Callback = @(src, ~) drawPopulation(src.Value, ax, txt, nYears, x0);

% Draw once at the start
drawPopulation(sld.Value, ax, txt, nYears, x0);

% ---- This function simulates and plots one run ----
function drawPopulation(r, ax, txt, nYears, x0)
    x = zeros(1, nYears);
    x(1) = x0;
    for n = 1:nYears-1
        x(n+1) = r * x(n) * (1 - x(n));   % next year's rabbits
    end

    plot(ax, 1:nYears, x, 'o-', 'LineWidth', 1.5, 'MarkerSize', 5);
    ylim(ax, [0 1]);
    grid(ax, 'on');
    xlabel(ax, 'Year');
    ylabel(ax, 'Population');
    title(ax, 'Drag the slider: when does chaos begin?');
    txt.String = sprintf('r = %.3f', r);
end
