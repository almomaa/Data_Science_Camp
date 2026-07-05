%% CHAOS PART 6: The Double Pendulum - chaos you can build!
%
% A pendulum is just a weight on a stick. Totally predictable - it
% swings tick, tock, tick, tock. Clocks used them for 300 years!
%
% Now hang a SECOND pendulum from the end of the first one.
% That's it. That's the whole machine. And it becomes CHAOTIC:
% it tumbles, flips, and spins in a way that never repeats.
%
% THE EXPERIMENT:
% We release TWO double pendulums at almost the same angle.
% The difference can be as tiny as you like - the script simulates
% ahead, finds the moment they separate, and shows you the whole
% story: dancing together... then going their separate ways.
% This is the butterfly effect - with real physics instead of rabbits.

clear; close all; clc;

% ---- Things to play with ----
angleStart = 120;      % starting angle in degrees (try 30 - see below!)
tinyDiff   = 0.0;    % extra degrees given to pendulum B (any size works!)
playSpeed  = 0.5;      % 0.5 = slow motion, 1 = real time, 2 = fast forward

% ---- Pendulum properties ----
L1 = 1;  L2 = 1;      % rod lengths (meters)
m1 = 1;  m2 = 1;      % bob masses (kg)
g  = 9.81;            % gravity

% ---- Solve the physics for both pendulums ----
% State = [angle1; angle2; speed1; speed2]. MATLAB's ode45 does the
% hard work of stepping the equations of motion forward in time.
fps     = 60;         % frames per second (smooth!)
maxTime = 180;        % simulate far ahead - the tinier the difference,
t       = 0 : 1/fps : maxTime;   % the longer separation takes

startA = [ angleStart;            angleStart;            0; 0 ] * pi/180;
startB = [ angleStart + tinyDiff; angleStart + tinyDiff; 0; 0 ] * pi/180;

fprintf('Computing the physics (a few seconds)...\n');
opts = odeset('RelTol', 1e-10, 'AbsTol', 1e-10);  % chaos punishes sloppy math!
[~, yA] = ode45(@(tt, y) physics(y, L1, L2, m1, m2, g), t, startA, opts);
[~, yB] = ode45(@(tt, y) physics(y, L1, L2, m1, m2, g), t, startB, opts);

% ---- Turn angles into (x, y) positions on screen ----
x1A = L1 * sin(yA(:,1));          y1A = -L1 * cos(yA(:,1));        % elbow of A
x2A = x1A + L2 * sin(yA(:,2));    y2A = y1A - L2 * cos(yA(:,2));   % tip of A
x1B = L1 * sin(yB(:,1));          y1B = -L1 * cos(yB(:,1));        % elbow of B
x2B = x1B + L2 * sin(yB(:,2));    y2B = y1B - L2 * cos(yB(:,2));   % tip of B

% ---- Find the moment they separate ----
% We call them "separated" once their tips are half a meter apart.
tipDistance = sqrt((x2A - x2B).^2 + (y2A - y2B).^2);
kSplit = find(tipDistance > 0.5, 1);

if isempty(kSplit)
    % They never separate (happens with small swings, or tinyDiff = 0)
    kSplit = inf;
    kEnd   = 30 * fps;                            % just show 30 seconds
else
    kEnd   = min(kSplit + 12*fps, numel(t));      % split + 12 more seconds
end

% ---- Set up the picture ----
fig = figure('Name', 'Double Pendulum Race', 'Color', 'k', ...
             'Position', [100 80 700 700]);
ax = axes('Parent', fig, 'Color', 'k', 'XColor', 'none', 'YColor', 'none');
hold(ax, 'on');
axis(ax, 'equal');
axis(ax, [-2.3 2.3 -2.3 2.6]);

colA = [0.2 0.9 1.0];    % cyan
colB = [1.0 0.6 0.2];    % orange

% Glowing trails left behind by each pendulum's tip
trailA = animatedline(ax, 'Color', colA*0.7, 'LineWidth', 1, ...
                      'MaximumNumPoints', 20*fps);
trailB = animatedline(ax, 'Color', colB*0.7, 'LineWidth', 1, ...
                      'MaximumNumPoints', 20*fps);

% The pendulums themselves (pivot - elbow - tip)
rodA = plot(ax, [0 0 0], [0 0 0], '-o', 'Color', colA, 'LineWidth', 2.5, ...
            'MarkerFaceColor', colA, 'MarkerSize', 8);
rodB = plot(ax, [0 0 0], [0 0 0], '-o', 'Color', colB, 'LineWidth', 2.5, ...
            'MarkerFaceColor', colB, 'MarkerSize', 8);

plot(ax, 0, 0, 'w.', 'MarkerSize', 14);   % the pivot on the ceiling

statusTxt = text(ax, 0, 2.4, 'Moving together - can you even see two pendulums?', ...
                 'Color', 'w', 'FontSize', 13, 'HorizontalAlignment', 'center');
hasSplit = false;

% ---- Run the animation (paced by a real clock, so it is never rushed) ----
clock0 = tic;
for k = 1:kEnd
    set(rodA, 'XData', [0 x1A(k) x2A(k)], 'YData', [0 y1A(k) y2A(k)]);
    set(rodB, 'XData', [0 x1B(k) x2B(k)], 'YData', [0 y1B(k) y2B(k)]);
    addpoints(trailA, x2A(k), y2A(k));
    addpoints(trailB, x2B(k), y2B(k));

    if ~hasSplit && k >= kSplit
        hasSplit = true;
        set(statusTxt, 'String', 'SEPARATED! The tiny difference has taken over', ...
            'Color', [1 0.9 0.2]);
    end

    title(ax, sprintf('Started %g%c apart   |   t = %.1f s   |   tips are %.2f m apart', ...
          tinyDiff, char(176), t(k), tipDistance(k)), 'Color', 'w', 'FontSize', 11);

    drawnow limitrate;

    % Wait until the wall clock catches up with simulation time
    while toc(clock0) < t(k) / playSpeed
        pause(0.001);
    end
end

if ~hasSplit
    set(statusTxt, 'String', 'They never separated - no chaos at this angle!', ...
        'Color', [0.4 1 0.5]);
end

% ---- The evidence: how far apart did they get? ----
figure('Name', 'Butterfly Effect, Measured');
plot(t(1:kEnd), tipDistance(1:kEnd), 'LineWidth', 1.5);
hold on;
if hasSplit
    plot(t(kSplit)*[1 1], [0 max(tipDistance(1:kEnd))], 'r--', 'LineWidth', 1);
    text(t(kSplit), max(tipDistance(1:kEnd))*0.95, '  they separate here', ...
         'Color', 'r');
end
xlabel('Time (seconds)');
ylabel('Distance between the two tips (meters)');
title('Nearly identical twins... until they are not');
grid on;

% ---- THINGS TO TRY ----
% 1. Make tinyDiff smaller: 0.001 -> 0.000001 -> 0.000000001.
%    They stay together LONGER... but they ALWAYS separate in the end.
%    Notice: making the difference 1000x smaller only delays the split
%    by a few seconds! That is why chaos makes prediction hopeless.
% 2. Change angleStart to 30 degrees. Small swings are NOT chaotic -
%    the pendulums never separate. Chaos needs big swings.
%    (Where is the boundary? Try 60, 90, 100...)
% 3. Set tinyDiff = 0. Identical twins stay identical forever.
%    Chaos is NOT randomness - same start, same dance, every time.
% 4. playSpeed = 0.25 for super-slow-motion replays of the split.

% ---- The physics engine (you don't need to read this part!) ----
% These are Newton's laws written out for the double pendulum.
% The equations look scary, but notice: there is no randomness in
% them anywhere. The chaos comes from the physics itself.
function dydt = physics(y, L1, L2, m1, m2, g)
    th1 = y(1);  th2 = y(2);  w1 = y(3);  w2 = y(4);
    d   = th1 - th2;
    den = 2*m1 + m2 - m2*cos(2*d);

    acc1 = ( -g*(2*m1 + m2)*sin(th1) - m2*g*sin(th1 - 2*th2) ...
             - 2*sin(d)*m2*(w2^2*L2 + w1^2*L1*cos(d)) ) / (L1*den);

    acc2 = ( 2*sin(d) .* ( w1^2*L1*(m1 + m2) + g*(m1 + m2)*cos(th1) ...
             + w2^2*L2*m2*cos(d) ) ) / (L2*den);

    dydt = [w1; w2; acc1; acc2];
end
