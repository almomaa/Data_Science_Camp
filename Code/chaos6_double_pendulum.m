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
% We release TWO double pendulums at almost the same angle:
%   Pendulum A (cyan)   starts at 120.0 degrees
%   Pendulum B (orange) starts at 120.1 degrees   <- tiny difference!
%
% Watch them dance together... and then go their separate ways.
% This is the butterfly effect - with real physics instead of rabbits.

clear; close all; clc;

% ---- Things to play with ----
angleStart = 120;     % starting angle in degrees (try 30 - see below!)
tinyDiff   = 0.001;     % extra degrees given to pendulum B
totalTime  = 100;      % seconds to simulate

% ---- Pendulum properties ----
L1 = 1;  L2 = 1;      % rod lengths (meters)
m1 = 1;  m2 = 1;      % bob masses (kg)
g  = 9.81;            % gravity

% ---- Solve the physics for both pendulums ----
% State = [angle1; angle2; speed1; speed2]. MATLAB's ode45 does the
% hard work of stepping the equations of motion forward in time.
fps = 10;
t   = 0 : 1/fps : totalTime;

startA = [ angleStart;            angleStart;            0; 0 ] * pi/180;
startB = [ angleStart + tinyDiff; angleStart + tinyDiff; 0; 0 ] * pi/180;

opts = odeset('RelTol', 1e-9, 'AbsTol', 1e-9);   % chaos punishes sloppy math!
[~, yA] = ode45(@(tt, y) physics(y, L1, L2, m1, m2, g), t, startA, opts);
[~, yB] = ode45(@(tt, y) physics(y, L1, L2, m1, m2, g), t, startB, opts);

% ---- Turn angles into (x, y) positions on screen ----
x1A =  L1 * sin(yA(:,1));   y1A = -L1 * cos(yA(:,1));      % elbow of A
x2A =  x1A + L2 * sin(yA(:,2));   y2A = y1A - L2 * cos(yA(:,2));  % tip of A
x1B =  L1 * sin(yB(:,1));   y1B = -L1 * cos(yB(:,1));      % elbow of B
x2B =  x1B + L2 * sin(yB(:,2));   y2B = y1B - L2 * cos(yB(:,2));  % tip of B

% ---- Set up the picture ----
fig = figure('Name', 'Double Pendulum Race', 'Color', 'k', ...
             'Position', [100 80 700 700]);
ax = axes('Parent', fig, 'Color', 'k', 'XColor', 'none', 'YColor', 'none');
hold(ax, 'on');
axis(ax, 'equal');
axis(ax, [-2.3 2.3 -2.3 2.3]);

colA = [0.2 0.9 1.0];    % cyan
colB = [1.0 0.6 0.2];    % orange

% Glowing trails left behind by each pendulum's tip
trailA = animatedline(ax, 'Color', colA*0.7, 'LineWidth', 1, ...
                      'MaximumNumPoints', 500);
trailB = animatedline(ax, 'Color', colB*0.7, 'LineWidth', 1, ...
                      'MaximumNumPoints', 500);

% The pendulums themselves (pivot - elbow - tip)
rodA = plot(ax, [0 0 0], [0 0 0], '-o', 'Color', colA, 'LineWidth', 2.5, ...
            'MarkerFaceColor', colA, 'MarkerSize', 8);
rodB = plot(ax, [0 0 0], [0 0 0], '-o', 'Color', colB, 'LineWidth', 2.5, ...
            'MarkerFaceColor', colB, 'MarkerSize', 8);

plot(ax, 0, 0, 'w.', 'MarkerSize', 14);   % the pivot on the ceiling

% ---- Run the animation ----
for k = 1:numel(t)
    set(rodA, 'XData', [0 x1A(k) x2A(k)], 'YData', [0 y1A(k) y2A(k)]);
    set(rodB, 'XData', [0 x1B(k) x2B(k)], 'YData', [0 y1B(k) y2B(k)]);
    addpoints(trailA, x2A(k), y2A(k));
    addpoints(trailB, x2B(k), y2B(k));

    title(ax, sprintf('Two pendulums, %g%c apart at start   |   t = %4.1f s', ...
          tinyDiff, char(176), t(k)), 'Color', 'w', 'FontSize', 12);
    drawnow limitrate;

end

% ---- The evidence: how far apart did they get? ----
tipDistance = sqrt((x2A - x2B).^2 + (y2A - y2B).^2);

figure('Name', 'Butterfly Effect, Measured');
plot(t, tipDistance, 'LineWidth', 1.5);
xlabel('Time (seconds)');
ylabel('Distance between the two tips (meters)');
title('Nearly identical twins... until they are not');
grid on;

% ---- THINGS TO TRY ----
% 1. Change angleStart to 30 degrees. Small swings are NOT chaotic -
%    the two pendulums stay together forever! Chaos needs big swings.
%    (So the same machine can be predictable OR chaotic. Where is the
%    boundary? Try 60, 90, 100...)
% 2. Make tinyDiff smaller: 0.01, then 0.001. They stay together
%    longer - but do they ever stay together forever?
% 3. Set tinyDiff = 0. Now A and B are identical, and stay identical.
%    Chaos is NOT randomness - same start, same dance, every time.

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
