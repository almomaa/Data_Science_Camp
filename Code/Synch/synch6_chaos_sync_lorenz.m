%% SYNC PART 6: Even CHAOS Can Sync (a callback to Day 1)
%
% Remember yesterday's "weather machines" - the Lorenz butterflies? The
% whole point was that they are UNPREDICTABLE: start two of them a hair
% apart and they end up in totally different weather. Chaos.
%
% So here is a wild question: could we ever force two chaotic weathers
% to agree? It sounds impossible - chaos is the enemy of prediction.
%
% Yet in 1990, Pecora and Carroll showed you CAN. If you let the two
% chaotic systems whisper to each other (a coupling), they lock onto the
% exact same chaotic dance - forever in step, yet still never repeating.
%
%   Yesterday: two weathers that can never agree.
%   Today:     we make them dance as ONE.
%
% *** THIS VERSION IS LIVE ***  Drag the COUPLING SLIDER at the bottom
% while it runs. Start at 0 (pure chaos, the two weathers drift apart),
% then slowly turn the coupling up and watch the gap between them
% collapse to zero. Turn it back down and chaos pulls them apart again.
%
% (This is real technology: it can hide a secret message inside a
%  chaotic signal, and only an identical, synced system can read it.)

clear; close all; clc;

% ---- Things to play with ----
cStart    = 0;      % coupling at the start (the slider begins here)
cMax      = 12;     % the largest coupling the slider allows
playSpeed = 1.0;    % 0.5 = slow motion, 1 = normal, 2 = fast forward

sigma = 10;  rho = 28;  beta = 8/3;      % the same Lorenz constants as Day 1

% Two weathers, started FAR apart
Y0 = [1; 1; 20;  -6; 4; 25];
Y  = Y0;

% A faint "ghost" butterfly for the background
opts = odeset('RelTol', 1e-7, 'AbsTol', 1e-7);
[~, g] = ode45(@(tt, s) [sigma*(s(2)-s(1)); s(1)*(rho-s(3))-s(2); ...
                         s(1)*s(2)-beta*s(3)], 0:0.01:60, [1;1;20], opts);

% ---- Set up the picture ----
fig = figure('Name', 'Two Chaotic Weathers Syncing (LIVE)', 'Color', 'k', ...
             'Position', [100 60 900 740]);
setappdata(fig, 'reset', false);

% Main 3D view
ax = axes('Parent', fig, 'Color', 'k', 'Position', [0.02 0.30 0.96 0.66], ...
          'XColor', 'none', 'YColor', 'none', 'ZColor', 'none');
hold(ax, 'on');
axis(ax, [-25 25 -32 32 0 55]); view(ax, 15, 25);   % fixed, good viewing angle
plot3(ax, g(:,1), g(:,2), g(:,3), '-', 'Color', [0.20 0.20 0.28], 'LineWidth', 0.5);

trail1 = animatedline(ax, 'Color', [0.2 0.9 1]*0.7, 'LineWidth', 1, 'MaximumNumPoints', 250);
trail2 = animatedline(ax, 'Color', [1 0.6 0.2]*0.7, 'LineWidth', 1, 'MaximumNumPoints', 250);
m1 = plot3(ax, Y(1), Y(2), Y(3), 'o', 'MarkerSize', 9, ...
           'MarkerFaceColor', [0.2 0.9 1], 'MarkerEdgeColor', 'w');
m2 = plot3(ax, Y(4), Y(5), Y(6), 'o', 'MarkerSize', 9, ...
           'MarkerFaceColor', [1 0.6 0.2], 'MarkerEdgeColor', 'w');
statusTxt = text(ax, 0.5, 0.97, 'Two chaotic weathers, started far apart...', ...
                 'Units', 'normalized', 'HorizontalAlignment', 'center', ...
                 'Color', 'w', 'FontSize', 13);

% Live "gap between the two weathers" strip along the bottom
axErr = axes('Parent', fig, 'Color', 'k', 'Position', [0.09 0.12 0.84 0.13], ...
             'XColor', 'w', 'YColor', 'w', 'YScale', 'log');
hold(axErr, 'on'); grid(axErr, 'on');
ylim(axErr, [1e-3 100]);
ylabel(axErr, 'gap'); xlabel(axErr, 'time (s)');
hErr = plot(axErr, NaN, NaN, '-', 'Color', [0.95 0.85 0.3], 'LineWidth', 1.3);

% ---- Controls ----
resetBtn = uicontrol(fig, 'Style', 'pushbutton', 'String', 'Reset (fling apart)', ...
    'Units', 'normalized', 'Position', [0.02 0.015 0.17 0.045], ...
    'Callback', @(s,e) setappdata(fig, 'reset', true));
uicontrol(fig, 'Style', 'text', 'String', 'Coupling:', 'ForegroundColor', 'w', ...
    'BackgroundColor', 'k', 'FontSize', 11, 'HorizontalAlignment', 'right', ...
    'Units', 'normalized', 'Position', [0.20 0.012 0.09 0.04]);
cSlider = uicontrol(fig, 'Style', 'slider', 'Min', 0, 'Max', cMax, 'Value', cStart, ...
    'Units', 'normalized', 'Position', [0.30 0.02 0.45 0.035]);
cLabel = uicontrol(fig, 'Style', 'text', 'String', '', 'ForegroundColor', [1 0.85 0.4], ...
    'BackgroundColor', 'k', 'FontSize', 12, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left', 'Units', 'normalized', 'Position', [0.76 0.012 0.22 0.04]);

% ---- Integration settings ----
h    = 0.005;                                  % integration step
nSub = max(1, round((playSpeed/60) / h));      % sub-steps per drawn frame

% ---- Run live until the window is closed ----
simT  = 0;
tHist = [];  eHist = [];
frame = 0;
clock0 = tic;
while ishandle(fig)
    frame = frame + 1;
    c = get(cSlider, 'Value');
    set(cLabel, 'String', sprintf('c = %.2f', c));

    % Reset button was pressed?
    if getappdata(fig, 'reset')
        Y = Y0;  simT = 0;  tHist = [];  eHist = [];
        clearpoints(trail1);  clearpoints(trail2);
        setappdata(fig, 'reset', false);
        clock0 = tic;  frame = 1;
    end

    % Advance the two coupled systems a few small steps (RK4)
    for s = 1:nSub
        Y = rk4(Y, h, c, sigma, rho, beta);
        simT = simT + h;
    end

    % Update the moving dots and their trails
    set(m1, 'XData', Y(1), 'YData', Y(2), 'ZData', Y(3));
    set(m2, 'XData', Y(4), 'YData', Y(5), 'ZData', Y(6));
    addpoints(trail1, Y(1), Y(2), Y(3));
    addpoints(trail2, Y(4), Y(5), Y(6));

    % The gap between the two weathers, right now
    err = norm(Y(1:3) - Y(4:6));
    tHist(end+1) = simT;  eHist(end+1) = max(err, 1e-3);
    if numel(tHist) > 6000            % keep the strip from growing forever
        tHist = tHist(end-5999:end);  eHist = eHist(end-5999:end);
    end
    set(hErr, 'XData', tHist, 'YData', eHist);
    xlim(axErr, [max(0, simT-20), simT + 0.5]);

    % Live status message reacts to how close they are
    if err < 0.5
        set(statusTxt, 'String', 'IN SYNC - the two weathers move as ONE!', ...
            'Color', [0.4 1 0.5]);
    elseif err < 5
        set(statusTxt, 'String', 'Coupling is fighting the chaos...', ...
            'Color', [1 0.9 0.3]);
    else
        set(statusTxt, 'String', 'Chaos wins - turn the coupling UP to catch them', ...
            'Color', [1 0.5 0.5]);
    end
    title(ax, sprintf('coupling c = %.2f      gap = %.3f', c, err), ...
          'Color', 'w', 'FontSize', 11);

    drawnow limitrate;
    while ishandle(fig) && toc(clock0) < frame/60
        pause(0.001);
    end
end

% ---- THINGS TO TRY (while it runs!) ----
% 1. Start with the slider at 0: pure Day-1 chaos, the gap graph stays
%    high and jumpy. Now s-l-o-w-l-y drag the coupling up. Somewhere the
%    gap suddenly plunges to near zero - you just found the CRITICAL
%    COUPLING with your own hand.
% 2. Once they are locked, drag the coupling back down to 0. Watch chaos
%    peel them apart again - sync is not permanent, it needs the coupling.
% 3. Hit "Reset (fling apart)" to throw the two weathers far apart again,
%    then race to catch them by turning the coupling up fast.
% 4. Big idea of the whole camp: DAY 1 showed tiny differences EXPLODING
%    (chaos); DAY 2 showed coupling PULLING differences away (sync). Same
%    Lorenz butterfly - two opposite fates, decided by whether the two
%    systems are connected, and how strongly.

% ---- The coupled physics (you don't need to read this part!) ----
% Two Lorenz systems, each nudged toward the other by the coupling c.
function d = coupled(Y, sigma, rho, beta, c)
    s1 = Y(1:3);  s2 = Y(4:6);
    f1 = [sigma*(s1(2)-s1(1)); s1(1)*(rho-s1(3))-s1(2); s1(1)*s1(2)-beta*s1(3)];
    f2 = [sigma*(s2(2)-s2(1)); s2(1)*(rho-s2(3))-s2(2); s2(1)*s2(2)-beta*s2(3)];
    d  = [f1 + c*(s2 - s1);
          f2 + c*(s1 - s2)];
end

% One Runge-Kutta step (a careful way to move the simulation forward).
function Ynew = rk4(Y, h, c, sigma, rho, beta)
    k1 = coupled(Y,          sigma, rho, beta, c);
    k2 = coupled(Y + h/2*k1, sigma, rho, beta, c);
    k3 = coupled(Y + h/2*k2, sigma, rho, beta, c);
    k4 = coupled(Y + h*k3,   sigma, rho, beta, c);
    Ynew = Y + (h/6)*(k1 + 2*k2 + 2*k3 + k4);
end
