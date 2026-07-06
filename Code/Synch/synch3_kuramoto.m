%% SYNC PART 3: The Coupling Dial (the Kuramoto model)
%
% Time to open the hood. Every example today - clocks, fireflies,
% clapping crowds - is captured by ONE beautiful little model, invented
% by Yoshiki Kuramoto in 1975.
%
% Picture each oscillator as a runner on a circular track, each with
% their own natural speed. A "coupling" makes each runner gently speed
% up or slow down to match the crowd. Turn the coupling DIAL:
%
%   - Low coupling  -> runners smear all around the track (no sync).
%   - High coupling -> they bunch together and run as a pack (sync!).
%
% The amazing part: the change is not gradual. Below a magic value
% NOTHING syncs; a hair above it, the whole group locks. A TIPPING
% POINT - just like the sudden onset of chaos in yesterday's rabbits.
%
% We measure sync with the "order parameter" r (see orderParameter.m):
% the arrow in the middle of the circle. Short arrow = chaos of beats,
% long arrow = everyone together.

clear; close all; clc;

% ---- Things to play with ----
N     = 60;     % number of oscillators
Kanim = 2.0;    % coupling for the animation (try 0.5, then 3.0)

rng(3);
omega = randn(1, N);          % natural speeds (some fast, some slow)
theta = 2*pi*rand(1, N);      % random starting positions
dt    = 0.02;
playSpeed = 1.0;

% ---- PART A: watch the oscillators on the circle ----
fig = figure('Name', 'The Coupling Dial', 'Color', 'k', 'Position', [150 120 620 620]);
ax  = axes('Parent', fig, 'Color', 'k'); hold(ax, 'on'); axis(ax, 'equal');
axis(ax, [-1.3 1.3 -1.35 1.35]); set(ax, 'XColor', 'none', 'YColor', 'none');

tt = linspace(0, 2*pi, 200);
plot(ax, cos(tt), sin(tt), '-', 'Color', [0.3 0.3 0.35], 'LineWidth', 1.2);
dots  = scatter(ax, cos(theta), sin(theta), 60, [0.3 0.7 1], 'filled');
arrow = plot(ax, [0 0], [0 0], '-', 'Color', [1 0.45 0.2], 'LineWidth', 3);
tip   = plot(ax, 0, 0, 'o', 'Color', [1 0.45 0.2], ...
             'MarkerFaceColor', [1 0.45 0.2], 'MarkerSize', 8);
meter = text(ax, 0, 1.22, '', 'Color', 'w', 'FontSize', 14, ...
             'HorizontalAlignment', 'center');

nFrames = round(20/dt);
clock0 = tic;
for k = 1:nFrames
    [r, psi] = orderParameter(theta);
    theta    = theta + dt*(omega + Kanim*r*sin(psi - theta));
    set(dots,  'XData', cos(theta), 'YData', sin(theta));
    set(arrow, 'XData', [0 r*cos(psi)], 'YData', [0 r*sin(psi)]);
    set(tip,   'XData', r*cos(psi), 'YData', r*sin(psi));
    set(meter, 'String', sprintf('Coupling K = %.1f     Sync = %d%%', Kanim, round(100*r)));
    drawnow limitrate;
    while toc(clock0) < k*dt/playSpeed
        pause(0.001);
    end
end

% ---- PART B: find the tipping point (sweep the whole dial) ----
fprintf('Sweeping the coupling dial from 0 to 4 to find the tipping point...\n');
Kvals  = 0:0.05:4;
rFinal = zeros(size(Kvals));
Tsweep = 25;  dts = 0.02;  steps = round(Tsweep/dts);

for ik = 1:numel(Kvals)
    K  = Kvals(ik);
    rng(ik);
    th = 2*pi*rand(1, N);
    racc = 0;  cnt = 0;
    for s = 1:steps
        [r, psi] = orderParameter(th);
        th = th + dts*(omega + K*r*sin(psi - th));
        if s > steps/2                    % average over the settled part
            racc = racc + r;  cnt = cnt + 1;
        end
    end
    rFinal(ik) = racc/cnt;
end

Kc = 1.6;   % the theoretical tipping point for this spread of speeds
figure('Name', 'The Tipping Point', 'Color', 'w');
plot(Kvals, rFinal, 'o-', 'LineWidth', 1.5, 'MarkerSize', 4); hold on;
plot([Kc Kc], [0 1], 'r--', 'LineWidth', 1);
text(Kc + 0.05, 0.12, 'critical coupling', 'Color', 'r');
xlabel('Coupling strength  K  (the dial)');
ylabel('Sync level  r  (0 = chaos, 1 = unison)');
title('Nothing... nothing... then SUDDENLY everyone syncs');
grid on; ylim([0 1]);

% ---- THINGS TO TRY ----
% 1. Re-run with Kanim = 0.5 (below the tipping point): the dots keep
%    smearing around the circle and the arrow stays tiny. Then Kanim =
%    3.0 (above it): they snap into a pack and the arrow grows long.
% 2. On the tipping-point graph, find where the curve lifts off zero.
%    That is the critical coupling - the least "togetherness" needed
%    before ANY sync is possible.
% 3. Make the oscillators more alike: omega = 0.3*randn(1,N). Similar
%    speeds are easier to herd, so the tipping point moves LEFT.
% 4. Compare with yesterday's bifurcation diagram. Both show a system
%    doing nothing special until a knob crosses a critical value - then
%    everything changes at once.
