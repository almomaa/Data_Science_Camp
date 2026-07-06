%% SYNC PART 1: The Clocks That Talked (where it all began)
%
% In 1665, Christiaan Huygens was sick in bed with two pendulum clocks
% hanging on the same wall. He noticed something spooky: no matter how
% he started them, within half an hour the two pendulums always ended up
% swinging in a perfect, locked rhythm. He called it "the sympathy of
% clocks." It was the first time anyone recorded SYNCHRONIZATION.
%
% Why does it happen? The clocks are not really separate. Each pendulum
% gives the wall a tiny push, and those pushes travel through the wall
% to the other clock. That whisper-thin connection - the COUPLING - is
% enough to pull the two rhythms together.
%
% We start two clocks ticking at slightly DIFFERENT speeds and out of
% step. Watch the coupling reel them in.

clear; close all; clc;

% ---- Things to play with ----
f1        = 1.00;   % natural speed of clock 1 (ticks per second)
f2        = 1.15;   % natural speed of clock 2 (a bit faster)
K         = 0.0;    % coupling strength through the wall (try 0 - see below!)
playSpeed = 1.0;    % 0.5 = slow motion, 1 = normal
T         = 40;     % seconds to simulate

w1 = 2*pi*f1;  w2 = 2*pi*f2;

% ---- Let the two clocks influence each other, moment by moment ----
dt = 0.005;
t  = 0:dt:T;
n  = numel(t);
th1 = zeros(1, n);  th2 = zeros(1, n);
th1(1) = 0;  th2(1) = pi;          % start in OPPOSITE swings

for k = 1:n-1
    th1(k+1) = th1(k) + dt*(w1 + K*sin(th2(k) - th1(k)));
    th2(k+1) = th2(k) + dt*(w2 + K*sin(th1(k) - th2(k)));
end

% When does the phase difference stop changing? That is "locked".
delta   = th1 - th2;
ddelta  = abs(diff(unwrap(delta))) / dt;
lockIdx = find(movmean(ddelta, round(1/dt)) < 0.05, 1);

% ---- Turn the phases into swinging pendulums ----
maxAng = deg2rad(28);
a1 = maxAng * sin(th1);   a2 = maxAng * sin(th2);
Lp = 1;  piv1 = -1.1;  piv2 = 1.1;
x1 = piv1 + Lp*sin(a1);   y1 = -Lp*cos(a1);
x2 = piv2 + Lp*sin(a2);   y2 = -Lp*cos(a2);

% ---- Set up the picture ----
fig = figure('Name', 'Huygens Clocks', 'Color', 'k', 'Position', [150 120 760 560]);
ax  = axes('Parent', fig, 'Color', 'k'); hold(ax, 'on');
axis(ax, 'equal'); axis(ax, [-2.2 2.2 -1.4 0.55]);
set(ax, 'XColor', 'none', 'YColor', 'none');

plot(ax, [-2 2], [0 0], 'w-', 'LineWidth', 3);       % the shared wall/ceiling
rod1 = plot(ax, [piv1 x1(1)], [0 y1(1)], '-o', 'Color', [0.3 0.9 1], ...
            'LineWidth', 3, 'MarkerFaceColor', [0.3 0.9 1], 'MarkerSize', 12);
rod2 = plot(ax, [piv2 x2(1)], [0 y2(1)], '-o', 'Color', [1 0.6 0.2], ...
            'LineWidth', 3, 'MarkerFaceColor', [1 0.6 0.2], 'MarkerSize', 12);
plot(ax, piv1, 0, 'w.', 'MarkerSize', 12);
plot(ax, piv2, 0, 'w.', 'MarkerSize', 12);

statusTxt = text(ax, 0, 0.4, 'Two clocks, out of step...', ...
                 'Color', 'w', 'FontSize', 14, 'HorizontalAlignment', 'center');

% ---- Animate (paced by a real clock, so it is never rushed) ----
stp = max(1, round((1/60)/dt));
idx = 1:stp:n;
locked = false;
clock0 = tic;
for j = 1:numel(idx)
    k = idx(j);
    set(rod1, 'XData', [piv1 x1(k)], 'YData', [0 y1(k)]);
    set(rod2, 'XData', [piv2 x2(k)], 'YData', [0 y2(k)]);
    if ~locked && ~isempty(lockIdx) && k >= lockIdx
        locked = true;
        set(statusTxt, 'String', 'LOCKED! Same rhythm now, held forever', ...
            'Color', [0.4 1 0.5]);
    end
    title(ax, sprintf('t = %.1f s', t(k)), 'Color', 'w');
    drawnow limitrate;
    while toc(clock0) < t(k)/playSpeed
        pause(0.001);
    end
end
if isempty(lockIdx)
    set(statusTxt, 'String', 'They never locked - coupling too weak!', ...
        'Color', [1 0.5 0.5]);
end

% ---- The evidence: the phase difference flattens out ----
figure('Name', 'Phase difference over time', 'Color', 'w');
plot(t, rad2deg(unwrap(th1 - th2)), 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Phase difference (degrees)');
title('When the line goes FLAT, the two clocks are locked together');
grid on;

% ---- THINGS TO TRY ----
% 1. Set K = 0 (cut the wall connection). The clocks now ignore each
%    other and drift apart forever - the phase-difference line keeps
%    sliding and never flattens.
% 2. Make the clocks more different (f2 = 1.4). Now the same coupling
%    may not be strong enough to lock them. Every coupling has a limit -
%    the "locking range".
% 3. Huygens actually saw ANTI-phase sync (pendulums mirroring each
%    other). Try different starting angles and watch what they settle
%    into.
% 4. This is the SAME math as the fireflies and the Kuramoto model
%    coming up next - just with two oscillators instead of thousands.
